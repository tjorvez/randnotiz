import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/app/providers.dart';
import 'package:randnotiz/core/platform/app_info.dart';
import 'package:randnotiz/features/backup/domain/backup_service.dart';
import 'package:randnotiz/features/backup/presentation/backup_screen.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

import 'fake_backup_service.dart';

Future<FakeBackupService> pumpScreen(
  WidgetTester tester,
  BackupStatus initial, {
  bool devInstall = false,
}) async {
  final service = FakeBackupService(initial);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        backupServiceProvider.overrideWithValue(service),
        devInstallProvider.overrideWithValue(devInstall),
      ],
      child: const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BackupScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  testWidgets('connect, choose a password, see the emergency key once', (
    tester,
  ) async {
    final service = await pumpScreen(
      tester,
      const BackupStatus(phase: BackupPhase.signedOut),
    );
    await tester.tap(find.text('Mit Google verbinden'));
    await tester.pumpAndSettle();
    expect(find.text('ich@example.com'), findsOneWidget);

    await tester.tap(find.text('Backup-Passwort festlegen'));
    await tester.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(fields.at(0), 'zu kurz');
    await tester.enterText(fields.at(1), 'zu kurz');
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(find.text('Mindestens 10 Zeichen'), findsOneWidget);

    await tester.enterText(fields.at(0), 'ein langer Satz');
    await tester.enterText(fields.at(1), 'ein langer Satz!');
    await tester.tap(find.text('OK'));
    await tester.pump();
    expect(find.text('Die Passwörter stimmen nicht überein'), findsOneWidget);

    await tester.enterText(fields.at(1), 'ein langer Satz');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(service.calls, contains('setUp:ein langer Satz'));

    // The emergency key screen cannot be left before confirming.
    final shownCode = find.byWidgetPredicate(
      (w) => w is SelectableText && w.data == code,
    );
    expect(shownCode, findsOneWidget);
    final done = find.widgetWithText(FilledButton, 'Fertig');
    expect(tester.widget<FilledButton>(done).onPressed, isNull);
    await tester.tap(find.text('Ich habe den Notfallschlüssel sicher notiert'));
    await tester.pump();
    await tester.tap(done);
    await tester.pumpAndSettle();

    expect(shownCode, findsNothing);
    expect(find.text('Jetzt sichern'), findsOneWidget);
    expect(service.calls.last, 'backupNow');
  });

  testWidgets('unlock: wrong secret is reported, right one offers restore', (
    tester,
  ) async {
    final service = await pumpScreen(
      tester,
      BackupStatus(
        phase: BackupPhase.needsUnlock,
        account: 'ich@example.com',
        remoteBackupAt: DateTime(2026, 10, 31, 14, 5),
      ),
    );
    expect(find.textContaining('31. Oktober 2026, 14:05'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'falsch');
    await tester.tap(find.text('Entsperren'));
    await tester.pumpAndSettle();
    expect(
      find.text('Das passt nicht. Prüfe Passwort bzw. Notfallschlüssel.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'richtiges Passwort');
    await tester.tap(find.text('Entsperren'));
    await tester.pumpAndSettle();
    expect(find.text('Notizen wiederherstellen?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Wiederherstellen'));
    await tester.pumpAndSettle();
    expect(service.calls.last, 'restore');
    expect(find.text('3 Einträge wiederhergestellt'), findsOneWidget);
  });

  testWidgets('a backup not yet taken over says why backups pause', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const BackupStatus(
        phase: BackupPhase.ready,
        account: 'ich@example.com',
        restorePending: true,
      ),
    );
    expect(find.text('Sicherung noch nicht übernommen'), findsOneWidget);
    expect(find.textContaining('pausiert'), findsOneWidget);
    expect(find.text('Noch keine Sicherung.'), findsNothing);
  });

  testWidgets('a refused access offers to connect again', (tester) async {
    final service = await pumpScreen(
      tester,
      const BackupStatus(
        phase: BackupPhase.signedOut,
        problem: BackupProblem.auth,
      ),
    );
    expect(
      find.text(
        'Google hat den Zugriff verweigert. Bitte verbinde dich erneut.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Erneut verbinden'));
    await tester.pumpAndSettle();
    expect(service.calls, contains('connect'));
  });

  group('test app "Randnotiz Dev" (shares the Drive folder)', () {
    const banner =
        'Test-App – teilt die Sicherung mit der echten App. Was du hier '
        'einrichtest, sicherst oder löschst, betrifft dieselbe Sicherung in '
        'Google Drive.';

    testWidgets('the real app shows no banner and asks nothing extra', (
      tester,
    ) async {
      final service = await pumpScreen(
        tester,
        const BackupStatus(
          phase: BackupPhase.needsSetup,
          account: 'ich@example.com',
        ),
      );
      expect(find.text(banner), findsNothing);
      await tester.tap(find.text('Backup-Passwort festlegen'));
      await tester.pumpAndSettle();
      expect(find.text('Wirklich in der Test-App?'), findsNothing);
      expect(find.text('Backup-Passwort'), findsOneWidget);
      expect(service.calls, isNot(contains(startsWith('setUp'))));
    });

    testWidgets('banner; setting up asks first, cancelling does nothing', (
      tester,
    ) async {
      final service = await pumpScreen(
        tester,
        const BackupStatus(
          phase: BackupPhase.needsSetup,
          account: 'ich@example.com',
        ),
        devInstall: true,
      );
      expect(find.text(banner), findsOneWidget);

      await tester.tap(find.text('Backup-Passwort festlegen'));
      await tester.pumpAndSettle();
      expect(find.text('Wirklich in der Test-App?'), findsOneWidget);
      expect(find.textContaining('automatisch'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(find.text('Backup-Passwort'), findsNothing, reason: 'no dialog');

      await tester.tap(find.text('Backup-Passwort festlegen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trotzdem fortfahren'));
      await tester.pumpAndSettle();
      expect(find.text('Backup-Passwort'), findsOneWidget);
      expect(service.calls, isNot(contains(startsWith('setUp'))));
    });

    testWidgets('unlocking asks first', (tester) async {
      final service = await pumpScreen(
        tester,
        const BackupStatus(
          phase: BackupPhase.needsUnlock,
          account: 'ich@example.com',
        ),
        devInstall: true,
      );
      await tester.enterText(find.byType(TextField), 'richtiges Passwort');
      await tester.tap(find.text('Entsperren'));
      await tester.pumpAndSettle();
      expect(find.text('Wirklich in der Test-App?'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(service.calls, isNot(contains(startsWith('unlock'))));

      await tester.tap(find.text('Entsperren'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trotzdem fortfahren'));
      await tester.pumpAndSettle();
      expect(service.calls, contains('unlock:richtiges Passwort'));
    });

    testWidgets('deleting the backup asks once more, signing out does not', (
      tester,
    ) async {
      final service = await pumpScreen(
        tester,
        const BackupStatus(
          phase: BackupPhase.ready,
          account: 'ich@example.com',
        ),
        devInstall: true,
      );
      Future<void> openDisconnect() async {
        await tester.scrollUntilVisible(find.text('Abmelden'), 100);
        await tester.tap(find.text('Abmelden'));
        await tester.pumpAndSettle();
      }

      // With "delete": the extra question; cancelling keeps everything.
      await openDisconnect();
      await tester.tap(find.text('Auch die Sicherung in Google Drive löschen'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Abmelden'));
      await tester.pumpAndSettle();
      expect(find.textContaining('echten App, denn'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(service.calls, isNot(contains(startsWith('disconnect'))));

      await openDisconnect();
      await tester.tap(find.text('Auch die Sicherung in Google Drive löschen'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Abmelden'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trotzdem löschen'));
      await tester.pumpAndSettle();
      expect(service.calls, contains('disconnect:true'));
    });

    testWidgets('signing out without deleting needs no extra question', (
      tester,
    ) async {
      final service = await pumpScreen(
        tester,
        const BackupStatus(
          phase: BackupPhase.ready,
          account: 'ich@example.com',
        ),
        devInstall: true,
      );
      await tester.scrollUntilVisible(find.text('Abmelden'), 100);
      await tester.tap(find.text('Abmelden'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Abmelden'));
      await tester.pumpAndSettle();
      expect(find.text('Wirklich in der Test-App?'), findsNothing);
      expect(service.calls, contains('disconnect:false'));
    });
  });
}
