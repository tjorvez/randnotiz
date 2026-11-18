import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/collections/presentation/collection_dialogs.dart';
import 'package:randnotiz/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('the name dialog returns the name and closes cleanly', (
    tester,
  ) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  result = await showCollectionNameDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Reise ');
    await tester.tap(find.text('Anlegen'));
    // Closing animation: the text field must stay usable until it is gone.
    await tester.pumpAndSettle();
    expect(result, 'Reise');
    expect(find.byType(TextField), findsNothing);
  });
}
