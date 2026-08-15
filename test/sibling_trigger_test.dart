import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dismiss barrier stands down over a *registered sibling trigger*, so
/// swapping dropdowns costs one tap rather than two (#95).
///
/// The exception is narrow on purpose, and most of what is pinned here is what
/// it must **not** touch: the dismissing tap is still consumed everywhere else,
/// a disabled sibling still dismisses, and the menu's own area is unaffected.

Widget twoDropdowns({bool betaEnabled = true}) => MaterialApp(
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
          enabled: betaEnabled,
          onChanged: (_) {},
        ),
      ],
    ),
  ),
);

Finder alpha() => find.byType(FlutterDropdownButton<String>).first;
Finder beta() => find.byType(FlutterDropdownButton<String>).last;
bool alphaOpen() => find.text('Alpha 2').evaluate().isNotEmpty;
bool betaOpen() => find.text('Beta 2').evaluate().isNotEmpty;

void main() {
  group('a sibling trigger takes one tap', () {
    testWidgets('and the menu that was open closes', (tester) async {
      await tester.pumpWidget(twoDropdowns());
      await tester.tap(alpha());
      await tester.pumpAndSettle();

      await tester.tap(beta());
      await tester.pumpAndSettle();

      expect(betaOpen(), isTrue);
      expect(alphaOpen(), isFalse, reason: 'single-open still holds');
    });

    testWidgets('with a mouse, not only with a finger', (tester) async {
      // A veto scoped to `PointerDeviceKind.touch` passes every widget test in
      // this suite — they default to touch — while doing nothing on desktop or
      // web. Measured before this test existed: `dismisses=1 bTaps=0`.
      await tester.pumpWidget(twoDropdowns());
      await tester.tap(alpha(), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      await tester.tap(beta(), kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();

      expect(betaOpen(), isTrue);
      expect(alphaOpen(), isFalse);
    });

    testWidgets('while the first menu is still closing', (tester) async {
      // The entry outlives the close by one animation, so the barrier is still
      // in the hit path mid-reverse. Two taps here too, before this.
      await tester.pumpWidget(twoDropdowns());
      await tester.tap(alpha());
      await tester.pumpAndSettle();

      FlutterDropdownButton.closeAll();
      await tester.pump(const Duration(milliseconds: 60));

      await tester.tap(beta());
      await tester.pumpAndSettle();

      expect(betaOpen(), isTrue);
    });
  });

  group('what the exception must not touch', () {
    testWidgets('a disabled sibling trigger still dismisses', (tester) async {
      // The regression this fix could most easily have introduced. A disabled
      // anchor is still hit-tested — `InkWell` is unconditionally opaque — so
      // standing down over it would leave the tap claimed by nobody and the
      // menu up, where it dismisses today.
      await tester.pumpWidget(twoDropdowns(betaEnabled: false));
      await tester.tap(alpha());
      await tester.pumpAndSettle();
      expect(alphaOpen(), isTrue);

      await tester.tap(beta(), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(alphaOpen(), isFalse, reason: 'the tap still dismissed');
      expect(betaOpen(), isFalse, reason: 'and opened nothing');
    });

    testWidgets('an ordinary widget behind the menu is still consumed', (
      tester,
    ) async {
      // The documented contract. Only a registered trigger is exempt; anything
      // else behind an open menu still needs a second tap.
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                FlutterDropdownButton<String>.text(
                  width: 150,
                  items: const ['Alpha 1', 'Alpha 2'],
                  hint: 'Alpha',
                  onChanged: (_) {},
                ),
                GestureDetector(
                  onTap: () => taps++,
                  // Opaque, or it defers to a child that absorbs no hit and is
                  // never reached whatever the barrier does.
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(width: 150, height: 50),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(alpha());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).last, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(taps, 0, reason: 'the dismissing tap is consumed');
      expect(alphaOpen(), isFalse);

      await tester.tap(find.byType(GestureDetector).last);
      await tester.pumpAndSettle();
      expect(taps, 1, reason: 'the second tap reaches it');
    });

    testWidgets('a right-click over a sibling trigger opens nothing', (
      tester,
    ) async {
      await tester.pumpWidget(twoDropdowns());
      await tester.tap(alpha());
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(beta()),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await tester.pumpAndSettle();

      expect(betaOpen(), isFalse);
      expect(alphaOpen(), isTrue, reason: 'unchanged by this fix');
    });

    testWidgets('the open menu is unaffected over its own area', (
      tester,
    ) async {
      // Structural, not guarded: when the menu takes the hit, the theatre never
      // descends to the entries below, so no trigger can be in the path.
      String? picked;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterDropdownButton<String>.text(
              width: 150,
              items: const ['Alpha 1', 'Alpha 2'],
              hint: 'Alpha',
              onChanged: (v) => picked = v,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alpha 2'));
      await tester.pumpAndSettle();

      expect(picked, 'Alpha 2');
    });

    testWidgets('a lone dropdown has no sibling to stand down for', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterDropdownButton<String>.text(
              width: 150,
              items: const ['Alpha 1', 'Alpha 2'],
              hint: 'Alpha',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();
      expect(alphaOpen(), isTrue);

      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(alphaOpen(), isFalse);
    });

    testWidgets('the open menu closes from its own trigger, in one tap', (
      tester,
    ) async {
      await tester.pumpWidget(twoDropdowns());
      await tester.tap(alpha());
      await tester.pumpAndSettle();

      await tester.tap(alpha(), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(alphaOpen(), isFalse);
    });
  });

  testWidgets('a disposed controller is no longer a sibling', (tester) async {
    // The registry is keyed by lifetime, not by open state, so removal happens
    // in dispose. A stale entry would punch a hole over nothing.
    await tester.pumpWidget(twoDropdowns());
    await tester.tap(alpha());
    await tester.pumpAndSettle();
    expect(alphaOpen(), isTrue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlutterDropdownButton<String>.text(
            width: 150,
            items: const ['Alpha 1', 'Alpha 2'],
            hint: 'Alpha',
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(alphaOpen(), isTrue, reason: 'the survivor still works');
  });
}
