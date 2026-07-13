import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The checklist box is a `FlutterCheckbox`, drawn `onChanged: null` but left
/// `enabled: true` — presentational without being greyed, so no `activeColor` →
/// `fillColor` workaround is needed (the accent shows on a checked box directly).
/// `resolve()` builds the `CheckboxStyle` FlutterCheckbox takes: each named field
/// is set, each unset field keeps CheckboxStyle's own default (which FlutterCheckbox
/// later resolves against the ambient ThemeData), and a colour left null stays
/// null so the app theme wins.
void main() {
  group('resolve', () {
    test(
      'a default theme leaves colours null, keeps CheckboxStyle defaults',
      () {
        final r = const DropdownCheckboxTheme().resolve();

        expect(
          r.activeColor,
          isNull,
          reason: 'null defers to the ambient theme',
        );
        expect(r.checkColor, isNull);
        expect(r.borderColor, isNull);
        expect(r.inactiveColor, isNull);
        // CheckboxStyle's own non-null defaults survive an unset theme.
        expect(r.shape, CheckboxShape.rectangle);
        expect(r.size, 24);
        expect(r.borderWidth, 2);
        expect(r.borderRadius, 4);
        expect(r.checkStrokeWidth, 2.5);
        expect(r.checkScale, 1.0);
      },
    );

    test('activeColor reaches the style directly — no disabled dance', () {
      final r = const DropdownCheckboxTheme(
        activeColor: Color(0xFF00AA88),
      ).resolve();

      expect(r.activeColor, const Color(0xFF00AA88));
    });

    test('every named field passes into the CheckboxStyle', () {
      final r = const DropdownCheckboxTheme(
        activeColor: Color(0xFF00AA88),
        checkColor: Color(0xFFFFFFFF),
        inactiveColor: Color(0xFFEEEEEE),
        borderColor: Color(0xFFDDDDDD),
        borderWidth: 3,
        shape: CheckboxShape.circle,
        borderRadius: 6,
        size: 20,
        checkStrokeWidth: 3.5,
        checkScale: 0.8,
      ).resolve();

      expect(r.activeColor, const Color(0xFF00AA88));
      expect(r.checkColor, const Color(0xFFFFFFFF));
      expect(r.inactiveColor, const Color(0xFFEEEEEE));
      expect(r.borderColor, const Color(0xFFDDDDDD));
      expect(r.borderWidth, 3);
      expect(r.shape, CheckboxShape.circle);
      expect(r.borderRadius, 6);
      expect(r.size, 20);
      expect(r.checkStrokeWidth, 3.5);
      expect(r.checkScale, 0.8);
    });

    test('mouseCursor is not part of the style — it is read off the theme', () {
      const theme = DropdownCheckboxTheme(
        mouseCursor: SystemMouseCursors.click,
      );

      expect(theme.mouseCursor, SystemMouseCursors.click);
    });
  });

  group('copyWith', () {
    const base = DropdownCheckboxTheme(
      activeColor: Color(0xFF00AA88),
      checkColor: Color(0xFF000000),
    );

    test('replaces the named field and keeps the rest', () {
      final next = base.copyWith(checkColor: const Color(0xFFFFFFFF));

      expect(next.activeColor, const Color(0xFF00AA88), reason: 'kept');
      expect(next.checkColor, const Color(0xFFFFFFFF), reason: 'replaced');
    });

    test('an unnamed field falls back to the original', () {
      // Exercises both branches of every field's `x ?? this.x`: the first
      // copyWith sets each (the non-null branch), the empty one keeps each.
      final full = base.copyWith(
        activeColor: const Color(0xFF010101),
        inactiveColor: const Color(0xFF020202),
        borderColor: const Color(0xFF030303),
        borderWidth: 3,
        shape: CheckboxShape.circle,
        borderRadius: 6,
        size: 20,
        checkStrokeWidth: 3.5,
        checkScale: 0.8,
        mouseCursor: SystemMouseCursors.click,
      );
      final unchanged = full.copyWith();

      expect(unchanged.activeColor, const Color(0xFF010101));
      expect(unchanged.checkColor, const Color(0xFF000000));
      expect(unchanged.inactiveColor, const Color(0xFF020202));
      expect(unchanged.borderColor, const Color(0xFF030303));
      expect(unchanged.borderWidth, 3);
      expect(unchanged.shape, CheckboxShape.circle);
      expect(unchanged.borderRadius, 6);
      expect(unchanged.size, 20);
      expect(unchanged.checkStrokeWidth, 3.5);
      expect(unchanged.checkScale, 0.8);
      expect(unchanged.mouseCursor, SystemMouseCursors.click);
    });
  });
}
