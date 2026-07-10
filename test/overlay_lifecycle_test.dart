import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Characterisation tests for the overlay's lifecycle: single-open
/// coordination, `closeAll`, and cleanup on dispose.
///
/// These lock in behaviour that has never had a test, so that the controller
/// extraction in #6 can be verified rather than hoped at.

Widget twoDropdowns() {
  return MaterialApp(
    home: Scaffold(
      body: Row(
        children: [
          FlutterDropdownButton<String>.text(
            width: 150,
            items: const ['Alpha 1', 'Alpha 2'],
            hint: 'Alpha',
            onChanged: (_) {},
          ),
          FlutterDropdownButton<String>.text(
            width: 150,
            items: const ['Beta 1', 'Beta 2'],
            hint: 'Beta',
            onChanged: (_) {},
          ),
        ],
      ),
    ),
  );
}

Finder alphaButton() => find.byType(FlutterDropdownButton<String>).first;
Finder betaButton() => find.byType(FlutterDropdownButton<String>).last;

/// An item only ever rendered inside the open menu.
bool alphaMenuOpen() => find.text('Alpha 2').evaluate().isNotEmpty;
bool betaMenuOpen() => find.text('Beta 2').evaluate().isNotEmpty;

void main() {
  testWidgets('a menu opens and closes on tap', (tester) async {
    await tester.pumpWidget(twoDropdowns());

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();
    expect(alphaMenuOpen(), isTrue);

    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(alphaMenuOpen(), isFalse);
  });

  testWidgets('only one menu is open at a time', (tester) async {
    await tester.pumpWidget(twoDropdowns());

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();
    expect(alphaMenuOpen(), isTrue);

    // The open menu covers the screen with a dismiss barrier, so reaching the
    // other button may take two taps. Either way, both menus must never be
    // open together.
    await tester.tap(betaButton(), warnIfMissed: false);
    await tester.pumpAndSettle();
    if (!betaMenuOpen()) {
      await tester.tap(betaButton());
      await tester.pumpAndSettle();
    }

    expect(betaMenuOpen(), isTrue);
    expect(alphaMenuOpen(), isFalse);
  });

  testWidgets('closeAll() closes the open menu', (tester) async {
    await tester.pumpWidget(twoDropdowns());

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();
    expect(alphaMenuOpen(), isTrue);

    FlutterDropdownButton.closeAll();
    await tester.pumpAndSettle();

    expect(alphaMenuOpen(), isFalse);
  });

  testWidgets('closeAll(animate: false) removes the menu at once', (
    tester,
  ) async {
    await tester.pumpWidget(twoDropdowns());

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();

    FlutterDropdownButton.closeAll(animate: false);
    await tester.pump(); // one frame, no time for a close animation

    expect(alphaMenuOpen(), isFalse);
  });

  testWidgets('closeAll() leaves the dropdown reopenable', (tester) async {
    await tester.pumpWidget(twoDropdowns());

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();
    FlutterDropdownButton.closeAll();
    await tester.pumpAndSettle();

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();

    expect(alphaMenuOpen(), isTrue);
  });

  testWidgets('disposing the widget while open tears the overlay down', (
    tester,
  ) async {
    await tester.pumpWidget(twoDropdowns());

    await tester.tap(alphaButton());
    await tester.pumpAndSettle();
    expect(alphaMenuOpen(), isTrue);

    // Navigate away, disposing both dropdowns mid-animation.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('x'))));
    await tester.pumpAndSettle();

    expect(alphaMenuOpen(), isFalse);
    expect(tester.takeException(), isNull);
  });
}
