// The visible half: that the app this slice wires up actually draws its menu.
//
// `destinations_test.dart` never pumps a widget — it holds the roster as data.
// Data being right is not the same claim as the shell drawing it, and this
// slice's whole user-facing effect is the second one. A change that got
// `createDestinations` wrong, or handed `ShellPage` a title it never used,
// passes every assertion in that file.

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the shell draws every destination this slice declares', (
    tester,
  ) async {
    // Desktop-width, because the menu is a pane at that size. A default
    // 800x600 surface is not this app's ordinary shape.
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    for (final label in const [
      'Basic',
      'Domain type',
      'Multi-select',
      'Bare anchor',
      'Build your own',
      'Overlay lifetime',
      'Every setting',
    ]) {
      expect(find.text(label), findsWidgets, reason: 'menu is missing $label');
    }
  });

  testWidgets('the shell wears this package name, not a fallback', (
    tester,
  ) async {
    // `ShellPage.title` is deliberately not defaulted upstream, so that a shell
    // with a forgotten title cannot ship somebody else's product name. That
    // guarantee is only worth anything if the literal we pass actually reaches
    // the screen.
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Dropdown Button'), findsWidgets);
  });
}
