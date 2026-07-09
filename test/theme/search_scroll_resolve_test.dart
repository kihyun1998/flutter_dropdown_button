import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// No widget tree, no `pumpWidget`, no `BuildContext`.

const ambient = DropdownAmbientColors(
  card: Color(0xFFFFFFFF),
  divider: Color(0xFFBDBDBD),
  splash: Color(0xFFE0E0E0),
  highlight: Color(0xFFEEEEEE),
  hover: Color(0xFFF5F5F5),
  primary: Color(0xFF2196F3),
  disabled: Color(0xFF9E9E9E),
);

const red = Color(0xFFE53935);

void main() {
  group('search field', () {
    test('totalHeight is the field, its margin, and nothing else', () {
      // 36 + 8 + 4, with no divider.
      expect(const SearchFieldTheme().resolve(ambient).totalHeight, 48);
    });

    test('a divider adds exactly the height reserved for it', () {
      const theme = SearchFieldTheme(divider: Divider(), dividerHeight: 16);

      final style = theme.resolve(ambient);
      expect(style.dividerHeight, 16);
      expect(style.totalHeight, 64, reason: '36 + 8 + 4 + 16');
    });

    test('dividerHeight is ignored when there is no divider', () {
      const theme = SearchFieldTheme(dividerHeight: 16);

      final style = theme.resolve(ambient);
      expect(style.dividerHeight, 0);
      expect(style.totalHeight, 48);
    });

    test('borders fall back to the ambient palette', () {
      final decoration = const SearchFieldTheme().resolve(ambient).decoration;

      final enabled = decoration.enabledBorder! as OutlineInputBorder;
      final focused = decoration.focusedBorder! as OutlineInputBorder;

      expect(enabled.borderSide.color, ambient.divider);
      expect(focused.borderSide.color, ambient.primary,
          reason: 'the focused edge picks up the accent');
    });

    test('a themed border wins over the ambient one', () {
      final theme = SearchFieldTheme(border: Border.all(color: red));

      final enabled = theme.resolve(ambient).decoration.enabledBorder!
          as OutlineInputBorder;
      expect(enabled.borderSide.color, red);
    });

    test('a full decoration override replaces the built one', () {
      const override = InputDecoration(hintText: 'Find a country');

      expect(
        const SearchFieldTheme(decoration: override)
            .resolve(ambient)
            .decoration,
        override,
      );
    });

    test('the field is only filled when a background is given', () {
      expect(
          const SearchFieldTheme().resolve(ambient).decoration.filled, false);
      expect(
        const SearchFieldTheme(backgroundColor: red)
            .resolve(ambient)
            .decoration
            .filled,
        true,
      );
    });

    test('keyboard defaults suit a search box', () {
      final style = const SearchFieldTheme().resolve(ambient);

      expect(style.keyboardType, TextInputType.text);
      expect(style.textInputAction, TextInputAction.search);
      expect(style.cursorWidth, 2.0);
      expect(style.autofocus, isTrue);
    });
  });

  group('scrollbar', () {
    test('thumb and track fall back to thickness, then to 8', () {
      expect(const DropdownScrollTheme().resolve().thumbWidth, 8);
      expect(const DropdownScrollTheme(thickness: 4).resolve().trackWidth, 4);
      expect(
        const DropdownScrollTheme(thickness: 4, trackWidth: 12)
            .resolve()
            .trackWidth,
        12,
      );
    });

    test('custom widths are flagged, because Scrollbar cannot honour them', () {
      expect(const DropdownScrollTheme().resolve().hasCustomWidths, isFalse);
      expect(
        const DropdownScrollTheme(thickness: 4).resolve().hasCustomWidths,
        isFalse,
        reason: 'thickness alone is something Scrollbar understands',
      );
      expect(
        const DropdownScrollTheme(thumbWidth: 6).resolve().hasCustomWidths,
        isTrue,
      );
    });

    test('RawScrollbar\'s non-null slots are all filled', () {
      final style = const DropdownScrollTheme().resolve();

      expect(style.thumbVisibility, isFalse);
      expect(style.trackVisibility, isFalse);
      expect(style.interactive, isTrue);
      expect(style.crossAxisMargin, 0);
      expect(style.mainAxisMargin, 0);
      expect(style.minThumbLength, 18);
      expect(style.gradientHeight, 24);
    });
  });
}
