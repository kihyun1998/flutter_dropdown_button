import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The checklist checkbox is drawn with `onChanged: null`, so Flutter treats it
/// as **disabled** and resolves its fill through the `disabled` state. A plain
/// `activeColor` is dropped before it is ever read (`checkbox.dart:452`); only
/// `fillColor` survives (`checkbox.dart:543`). So `resolve()` must turn a simple
/// `activeColor` into a `fillColor` that answers for the selected state whether
/// or not `disabled` is also present. These tests pin exactly that.
void main() {
  // The state sets Flutter's Checkbox actually asks `fillColor` about.
  const selected = <WidgetState>{WidgetState.selected};
  const disabledSelected = <WidgetState>{
    WidgetState.disabled,
    WidgetState.selected,
  };
  const unselected = <WidgetState>{};
  const disabledUnselected = <WidgetState>{WidgetState.disabled};

  group('resolve — empty theme leaves every slot to Flutter', () {
    test('a default theme resolves every field to null', () {
      final r = const DropdownCheckboxTheme().resolve();

      expect(
        r.fillColor,
        isNull,
        reason: 'null defers to ambient CheckboxTheme',
      );
      expect(r.checkColor, isNull);
      expect(r.side, isNull);
      expect(r.shape, isNull);
      expect(r.materialTapTargetSize, isNull);
      expect(r.visualDensity, isNull);
    });
  });

  group(
    'resolve — activeColor routes into fillColor and survives disabled',
    () {
      test('the checked box takes activeColor even while disabled', () {
        final r = const DropdownCheckboxTheme(
          activeColor: Color(0xFF00AA88),
        ).resolve();

        expect(r.fillColor, isNotNull);
        expect(
          r.fillColor!.resolve(selected),
          const Color(0xFF00AA88),
          reason: 'selected → the accent fills the box',
        );
        expect(
          r.fillColor!.resolve(disabledSelected),
          const Color(0xFF00AA88),
          reason:
              'the whole point: onChanged:null adds `disabled`, and the '
              'accent must still win — a raw activeColor is dropped here',
        );
      });

      test('the unchecked box keeps the ambient default fill', () {
        final r = const DropdownCheckboxTheme(
          activeColor: Color(0xFF00AA88),
        ).resolve();

        expect(r.fillColor!.resolve(unselected), isNull);
        expect(r.fillColor!.resolve(disabledUnselected), isNull);
      });
    },
  );

  group('resolve — fillColor is the escape hatch and wins', () {
    test('an explicit fillColor is used verbatim over activeColor', () {
      final explicit = WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? const Color(0xFF112233)
            : const Color(0xFF445566),
      );
      final r = DropdownCheckboxTheme(
        activeColor: const Color(0xFF00AA88),
        fillColor: explicit,
      ).resolve();

      expect(identical(r.fillColor, explicit), isTrue);
      expect(r.fillColor!.resolve(selected), const Color(0xFF112233));
      expect(r.fillColor!.resolve(unselected), const Color(0xFF445566));
    });
  });

  group('resolve — the remaining fields pass straight through', () {
    test('checkColor, side, shape, tapTarget, density and cursor pass', () {
      const side = BorderSide(color: Color(0xFFDDDDDD), width: 2);
      const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      );
      final r = const DropdownCheckboxTheme(
        checkColor: Color(0xFFFFFFFF),
        side: side,
        shape: shape,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        mouseCursor: SystemMouseCursors.click,
      ).resolve();

      expect(r.checkColor, const Color(0xFFFFFFFF));
      expect(r.side, side);
      expect(r.shape, shape);
      expect(r.materialTapTargetSize, MaterialTapTargetSize.shrinkWrap);
      expect(r.visualDensity, VisualDensity.compact);
      expect(r.mouseCursor, SystemMouseCursors.click);
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
      // Exercises the fallback branch of every field: nothing is passed, so
      // each `x ?? this.x` must take `this.x`.
      const side = BorderSide(width: 3);
      const shape = CircleBorder();
      final full = base.copyWith(
        activeColor: const Color(0xFF010101),
        fillColor: WidgetStateProperty.all(const Color(0xFF020202)),
        side: side,
        shape: shape,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
        mouseCursor: SystemMouseCursors.click,
      );
      final unchanged = full.copyWith();

      expect(unchanged.activeColor, const Color(0xFF010101));
      expect(unchanged.checkColor, const Color(0xFF000000));
      expect(unchanged.fillColor, full.fillColor);
      expect(unchanged.side, side);
      expect(unchanged.shape, shape);
      expect(unchanged.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(unchanged.visualDensity, VisualDensity.standard);
      expect(unchanged.mouseCursor, SystemMouseCursors.click);
    });
  });
}
