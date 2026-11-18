import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/format/formatters.dart';
import '../../../core/widgets/paper.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/note.dart';
import '../../settings/presentation/settings_controller.dart';
import '../domain/calendar_days.dart';
import 'journal_screen.dart';

/// The calendar, opened from the journal next to the world map: a month at
/// a time, every day with entries marked, for a quick look at *when* things
/// happened. A tapped day shows how many days it is from today and lists its
/// entries; swiping (or the arrows) moves between months.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// First day of the month on show.
  late DateTime _month;
  late DateTime _selected;

  /// The year overview is on show instead of a month.
  var _showYears = false;

  /// Year on show in the year overview.
  late int _year;

  /// +1: the month shown now came from a later one (slides in from the
  /// right), -1: from an earlier one.
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    final today = dayOf(ref.read(clockProvider)());
    _selected = today;
    _month = monthOf(today);
    _year = today.year;
  }

  void _openYears() => setState(() {
    _year = _month.year;
    _showYears = true;
  });

  void _openMonth(DateTime month) {
    _goToMonth(month);
    setState(() => _showYears = false);
  }

  void _stepYear(int years, DateTime first, DateTime last) {
    final target = _year + years;
    if (target < first.year || target > last.year) return;
    setState(() => _year = target);
  }

  void _onYearSwipe(DragEndDetails details, DateTime first, DateTime last) {
    final v = details.primaryVelocity ?? 0;
    if (v.abs() < 200) return;
    _stepYear(v > 0 ? -1 : 1, first, last);
  }

  void _goToMonth(DateTime month) {
    final target = monthOf(month);
    if (target == _month) return;
    setState(() {
      _direction = target.isAfter(_month) ? 1 : -1;
      _month = target;
    });
  }

  void _goToToday() {
    final today = dayOf(ref.read(clockProvider)());
    _goToMonth(today);
    setState(() {
      _selected = today;
      _showYears = false;
    });
  }

  void _step(int months, DateTime first, DateTime last) {
    final target = DateTime(_month.year, _month.month + months);
    if (target.isBefore(first) || target.isAfter(last)) return;
    _goToMonth(target);
  }

  void _onSwipe(DragEndDetails details, DateTime first, DateTime last) {
    final v = details.primaryVelocity ?? 0;
    if (v.abs() < 200) return;
    // Dragging to the right brings the earlier month, like turning a page.
    _step(v > 0 ? -1 : 1, first, last);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = dayOf(ref.watch(clockProvider)());
    final notes = ref.watch(allNotesProvider).value ?? const <NoteSummary>[];
    final byDay = groupByDay(notes);

    // The months that can be reached: from the first entry to the last one,
    // always including the current month.
    var first = monthOf(today);
    var last = first;
    for (final day in byDay.keys) {
      final m = monthOf(day);
      if (m.isBefore(first)) first = m;
      if (m.isAfter(last)) last = m;
    }

    var inMonth = 0;
    for (final MapEntry(:key, :value) in byDay.entries) {
      if (monthOf(key) == _month) inMonth += value.length;
    }

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final bottom = MediaQuery.paddingOf(context).bottom + 24;

    final counts = {for (final e in byDay.entries) e.key: e.value.length};

    final content = _showYears
        ? _yearView(first, last, today, counts)
        : _monthView(
            first: first,
            last: last,
            today: today,
            byDay: byDay,
            counts: counts,
            inMonth: inMonth,
            reduceMotion: reduceMotion,
          );

    // Back from the year overview returns to the month, not out of the
    // calendar.
    return PopScope(
      canPop: !_showYears,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _showYears = false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.calendarTitle),
          actions: [
            IconButton(
              tooltip: l10n.calendarToday,
              icon: const Icon(Icons.today_outlined),
              onPressed: _goToToday,
            ),
          ],
        ),
        body: PaperBackground(
          child: ListView(
            padding: EdgeInsets.fromLTRB(12, 0, 12, bottom),
            children: [
              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                child: KeyedSubtree(key: ValueKey(_showYears), child: content),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _yearView(
    DateTime first,
    DateTime last,
    DateTime today,
    Map<DateTime, int> counts,
  ) {
    final l10n = AppLocalizations.of(context);
    var inYear = 0;
    for (final MapEntry(:key, :value) in counts.entries) {
      if (key.year == _year) inYear += value;
    }
    return Column(
      children: [
        _PeriodHeader(
          title: '$_year',
          subtitle: l10n.calendarYearEntries(inYear),
          previousTooltip: l10n.calendarPreviousYear,
          nextTooltip: l10n.calendarNextYear,
          onPrevious: _year > first.year
              ? () => _stepYear(-1, first, last)
              : null,
          onNext: _year < last.year ? () => _stepYear(1, first, last) : null,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (d) => _onYearSwipe(d, first, last),
          child: _YearGrid(
            year: _year,
            today: today,
            shown: _month,
            first: first,
            last: last,
            counts: counts,
            onSelect: _openMonth,
          ),
        ),
      ],
    );
  }

  Widget _monthView({
    required DateTime first,
    required DateTime last,
    required DateTime today,
    required Map<DateTime, List<NoteSummary>> byDay,
    required Map<DateTime, int> counts,
    required int inMonth,
    required bool reduceMotion,
  }) {
    return Column(
      children: [
        _PeriodHeader(
          title: Fmt.month(_month),
          subtitle: AppLocalizations.of(context).calendarMonthEntries(inMonth),
          previousTooltip: AppLocalizations.of(context).calendarPreviousMonth,
          nextTooltip: AppLocalizations.of(context).calendarNextMonth,
          onPrevious: _month.isAfter(first)
              ? () => _step(-1, first, last)
              : null,
          onNext: _month.isBefore(last) ? () => _step(1, first, last) : null,
          onTitleTap: _openYears,
          titleTooltip: AppLocalizations.of(context).calendarYearView,
        ),
        const SizedBox(height: 4),
        const _WeekdayRow(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (d) => _onSwipe(d, first, last),
          child: AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) {
              final incoming = child.key == ValueKey(_month);
              // The outgoing month runs its animation backwards, so the
              // same offset leads it out on the opposite side.
              final dx = incoming ? _direction : -_direction;
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(
                    begin: Offset(dx * 0.25, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _MonthGrid(
              key: ValueKey(_month),
              month: _month,
              today: today,
              selected: _selected,
              counts: counts,
              onSelect: (day) => setState(() => _selected = day),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DayPanel(
          day: _selected,
          today: today,
          birthday: ref.watch(birthdayProvider),
          entries: byDay[_selected] ?? const [],
        ),
      ],
    );
  }
}

/// Title (a month or a year) with arrows and the number of entries in it.
/// With [onTitleTap] the title is a button that zooms out.
class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({
    required this.title,
    required this.subtitle,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
    this.onTitleTap,
    this.titleTooltip,
  });

  final String title;
  final String subtitle;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onTitleTap;
  final String? titleTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget heading = Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (onTitleTap != null)
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
    if (onTitleTap != null) {
      heading = Tooltip(
        message: titleTooltip ?? '',
        child: InkWell(
          onTap: onTitleTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: heading,
          ),
        ),
      );
    }
    return Row(
      children: [
        IconButton(
          tooltip: previousTooltip,
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
        ),
        Expanded(child: heading),
        IconButton(
          tooltip: nextTooltip,
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// "M D M D F S S", starting with the week day the locale starts its week.
class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  material.narrowWeekdays[(material.firstDayOfWeekIndex + i) %
                      7],
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The days of one month. Always six rows high, so the entries below do not
/// jump from month to month.
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    super.key,
    required this.month,
    required this.today,
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  static const double rowHeight = 46;

  final DateTime month;
  final DateTime today;
  final DateTime selected;
  final Map<DateTime, int> counts;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final blanks = leadingBlanks(month, first);
    final days = daysInMonth(month);
    return Column(
      children: [
        for (var row = 0; row < 6; row++)
          SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _cell(context, row * 7 + col - blanks + 1, days),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, int dayNumber, int days) {
    if (dayNumber < 1 || dayNumber > days) return const SizedBox.shrink();
    final date = DateTime(month.year, month.month, dayNumber);
    return _DayCell(
      date: date,
      count: counts[date] ?? 0,
      isToday: date == today,
      isSelected: date == selected,
      onTap: () => onSelect(date),
    );
  }
}

/// The twelve months of one year, each with the number of its entries. A tap
/// opens the month.
class _YearGrid extends StatelessWidget {
  const _YearGrid({
    required this.year,
    required this.today,
    required this.shown,
    required this.first,
    required this.last,
    required this.counts,
    required this.onSelect,
  });

  static const double rowHeight = 84;

  final int year;
  final DateTime today;

  /// The month the calendar showed before.
  final DateTime shown;

  /// First and last month that can be reached.
  final DateTime first;
  final DateTime last;
  final Map<DateTime, int> counts;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final perMonth = <DateTime, int>{};
    for (final MapEntry(:key, :value) in counts.entries) {
      if (key.year == year) {
        perMonth.update(monthOf(key), (n) => n + value, ifAbsent: () => value);
      }
    }
    return Column(
      children: [
        for (var row = 0; row < 4; row++)
          SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                for (var col = 0; col < 3; col++)
                  Expanded(
                    child: _cell(
                      context,
                      DateTime(year, row * 3 + col + 1),
                      perMonth,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    DateTime month,
    Map<DateTime, int> perMonth,
  ) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final count = perMonth[month] ?? 0;
    final reachable = !month.isBefore(first) && !month.isAfter(last);
    final isCurrent = month == monthOf(today);
    final isShown = month == shown;
    final (Color? fill, Color text) = isShown
        ? (scheme.primary, scheme.onPrimary)
        : count > 0
        ? (scheme.primaryContainer, scheme.onPrimaryContainer)
        : (null, scheme.onSurface);
    final name = Fmt.monthName(month);
    return Semantics(
      button: true,
      enabled: reachable,
      selected: isShown,
      excludeSemantics: true,
      label: [
        Fmt.month(month),
        if (count > 0) l10n.mapEntriesCount(count),
      ].join(', '),
      onTap: reachable ? () => onSelect(month) : null,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Opacity(
          opacity: reachable ? 1 : 0.4,
          child: Material(
            color: fill ?? Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isCurrent
                  ? BorderSide(color: scheme.primary, width: 1.5)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: reachable ? () => onSelect(month) : null,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: text,
                        fontSize: 16,
                        fontWeight: count > 0 || isCurrent
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      count > 0 ? '$count' : '–',
                      style: TextStyle(
                        color: text.withValues(alpha: count > 0 ? 0.85 : 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.count,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (Color? fill, Color text) = isSelected
        ? (scheme.primary, scheme.onPrimary)
        : count > 0
        ? (scheme.primaryContainer, scheme.onPrimaryContainer)
        : (null, scheme.onSurface);
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: [
        Fmt.longDate(date),
        if (count > 0) l10n.mapEntriesCount(count),
      ].join(', '),
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: isToday
                  ? Border.all(color: scheme.primary, width: 1.5)
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: text,
                fontWeight: count > 0 || isToday
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chosen day: its date, how far it is from today, and its entries.
class _DayPanel extends StatelessWidget {
  const _DayPanel({
    required this.day,
    required this.today,
    required this.birthday,
    required this.entries,
  });

  final DateTime day;
  final DateTime today;
  final DateTime? birthday;
  final List<NoteSummary> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lifeShare = Fmt.lifeShareOf(l10n, birthday, day, today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Fmt.longDateWithWeekday(day),
                      style: theme.textTheme.titleMedium,
                    ),
                    if (lifeShare != null)
                      Text(
                        lifeShare,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  child: Text(
                    Fmt.daysFromToday(l10n, day, today),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Text(
              l10n.calendarDayEmpty,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final n in entries)
            JournalEntryCard(
              key: ValueKey(n.assetId),
              entry: n,
              maxLines: 3,
              heroScope: 'calendar',
            ),
      ],
    );
  }
}
