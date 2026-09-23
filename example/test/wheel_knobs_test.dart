// The Wheel scrolling recipe's knobs: that the code pane prints the motion the
// menu is actually handed, and that the knobs reach the right-hand menu.

import 'package:example/app/recipe_knobs.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the code pane says what the menu is handed', () {
    late WheelKnobs knobs;

    setUp(() => knobs = WheelKnobs());
    tearDown(() => knobs.dispose());

    test('unset hands nothing and says so', () {
      expect(knobs.motion, isNull);
      expect(knobs.code, startsWith('// wheelMotion unset'));
    });

    test('spring', () {
      knobs
        ..kind = WheelKind.spring
        ..durationMs = 300
        ..bounceTenths = 2;

      final motion = knobs.motion! as SpringWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 300));
      expect(motion.bounce, 0.2);
      expect(knobs.code, contains('WheelMotion.spring('));
      expect(knobs.code, contains('Duration(milliseconds: 300)'));
      expect(knobs.code, contains('bounce: 0.2'));
    });

    test('a spring with no bounce does not print one', () {
      knobs.kind = WheelKind.spring;

      expect((knobs.motion! as SpringWheelMotion).bounce, 0);
      expect(knobs.code, isNot(contains('bounce')));
    });

    test('curve', () {
      knobs
        ..kind = WheelKind.curve
        ..durationMs = 400
        ..curve = 'easeInOut';

      final motion = knobs.motion! as CurveWheelMotion;
      expect(motion.duration, const Duration(milliseconds: 400));
      expect(motion.curve, same(Curves.easeInOut));
      expect(knobs.code, contains('curve: Curves.easeInOut'));
      expect(knobs.code, contains('Duration(milliseconds: 400)'));
    });

    test('lerp', () {
      knobs
        ..kind = WheelKind.lerp
        ..timeConstantMs = 90;

      final motion = knobs.motion! as LerpWheelMotion;
      expect(motion.timeConstant, const Duration(milliseconds: 90));
      expect(knobs.code, contains('Duration(milliseconds: 90)'));
    });

    test('off is the exact jump', () {
      knobs.kind = WheelKind.off;

      final motion = knobs.motion! as SpringWheelMotion;
      expect(motion.duration, Duration.zero);
      expect(knobs.code, contains('Duration.zero'));
    });
  });

  group('the knobs reach the right-hand menu', () {
    Future<double> offsetAfterOneNotch(
      WidgetTester tester,
      WheelKind kind,
    ) async {
      final knobs = WheelKnobs()..kind = kind;
      addTearDown(knobs.dispose);
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: WheelScrollStage(knobs: knobs)),
        ),
      );
      await tester.tap(find.byType(FlutterDropdownButton<String>).last);
      await tester.pumpAndSettle();

      final list = find.byType(ListView).last;
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(tester.getCenter(list)));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 40)));

      return tester.widget<ListView>(list).controller!.offset;
    }

    testWidgets('unset glides', (tester) async {
      expect(await offsetAfterOneNotch(tester, WheelKind.unset), 0);
    });

    testWidgets('off jumps', (tester) async {
      expect(await offsetAfterOneNotch(tester, WheelKind.off), 40);
    });
  });
}
