import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolution takes plain values, so these run with no widget tree, no
/// `pumpWidget`, and no `BuildContext`. Each surface resolves through its own
/// sub-theme (`DropdownButtonTheme` / `DropdownOverlayTheme` / `DropdownItemTheme`).

const ambient = DropdownAmbientColors(
  card: Color(0xFFFFFFFF),
  divider: Color(0xFFBDBDBD),
  splash: Color(0xFFE0E0E0),
  highlight: Color(0xFFEEEEEE),
  hover: Color(0xFFF5F5F5),
  primary: Color(0xFF2196F3),
  disabled: Color(0xFF9E9E9E),
  icon: Color(0xFF212121),
);

const red = Color(0xFFE53935);
const green = Color(0xFF43A047);

void main() {
  group('icon size', () {
    test('resolvedIconSize falls back to the named default', () {
      expect(
        const DropdownButtonTheme().resolvedIconSize,
        DropdownButtonTheme.defaultIconSize,
      );
      expect(const DropdownButtonTheme(iconSize: 18).resolvedIconSize, 18);
    });

    test('it agrees with the size resolveButton hands out', () {
      // Two readers, one fallback. A second copy of `24.0` is how a divider
      // came to be reserved at one height and drawn at another.
      for (final theme in const [
        DropdownButtonTheme(),
        DropdownButtonTheme(iconSize: 18),
      ]) {
        expect(
          theme.resolveButton(ambient, enabled: true).iconSize,
          theme.resolvedIconSize,
        );
      }
    });

    test('it needs no ambient palette', () {
      expect(const DropdownButtonTheme(iconSize: 30).resolvedIconSize, 30);
    });
  });

  group('button', () {
    test('falls back to the ambient palette', () {
      final style = const DropdownButtonTheme().resolveButton(
        ambient,
        enabled: true,
      );

      expect(style.splashColor, ambient.splash);
      expect(style.hoverColor, ambient.hover);
      expect(style.iconColor, ambient.icon);
      expect(style.icon, Icons.keyboard_arrow_down);
      expect(style.iconSize, 24.0);
    });

    test('contentHeight prefers height, then iconSize, then 24', () {
      expect(
        const DropdownButtonTheme(
          height: 40,
          iconSize: 30,
        ).resolveButton(ambient, enabled: true).contentHeight,
        40,
      );
      expect(
        const DropdownButtonTheme(
          iconSize: 30,
        ).resolveButton(ambient, enabled: true).contentHeight,
        30,
      );
      expect(
        const DropdownButtonTheme()
            .resolveButton(ambient, enabled: true)
            .contentHeight,
        24,
      );
    });

    test('the icon switches colour with the enabled state', () {
      const theme = DropdownButtonTheme(
        iconColor: red,
        iconDisabledColor: green,
      );

      expect(theme.resolveButton(ambient, enabled: true).iconColor, red);
      expect(theme.resolveButton(ambient, enabled: false).iconColor, green);
    });

    test('backgroundColor fills the enabled decoration', () {
      final decoration = const DropdownButtonTheme(
        backgroundColor: red,
      ).resolveButton(ambient, enabled: true).decoration;

      expect(decoration.color, red);
    });

    test('disabledDecoration wins outright', () {
      final theme = DropdownButtonTheme(
        disabledDecoration: const BoxDecoration(color: red),
        disabledBackgroundColor: green,
        border: Border.all(color: green),
      );

      final decoration = theme
          .resolveButton(ambient, enabled: false)
          .decoration;
      expect(decoration.color, red);
      expect(decoration.border, isNull);
    });

    test(
      'disabledBorder falls back to border, then to the ambient divider',
      () {
        final withBorder =
            DropdownButtonTheme(
                  disabledBackgroundColor: green,
                  border: Border.all(color: red),
                ).resolveButton(ambient, enabled: false).decoration.border!
                as Border;
        expect(withBorder.top.color, red);

        final bare =
            const DropdownButtonTheme(
                  disabledBackgroundColor: green,
                ).resolveButton(ambient, enabled: false).decoration.border!
                as Border;
        expect(bare.top.color, ambient.divider);
      },
    );

    test('with no disabled styling, the enabled decoration stands', () {
      final theme = DropdownButtonTheme(border: Border.all(color: red));

      final disabled = theme.resolveButton(ambient, enabled: false).decoration;
      final enabled = theme.resolveButton(ambient, enabled: true).decoration;

      expect(disabled.color, isNull);
      expect(disabled.border, enabled.border);
    });
  });

  group('overlay', () {
    test('reports the border thickness the placement module reserves', () {
      final theme = DropdownOverlayTheme(
        border: Border.all(color: red, width: 3),
      );

      expect(theme.resolveOverlay(ambient).borderThickness, 6);
    });

    test('a borderless custom decoration reserves nothing', () {
      const theme = DropdownOverlayTheme(decoration: BoxDecoration(color: red));

      expect(theme.resolveOverlay(ambient).borderThickness, 0);
    });

    test('backgroundColor falls back to the ambient card colour', () {
      expect(
        const DropdownOverlayTheme().resolveOverlay(ambient).backgroundColor,
        ambient.card,
      );
      expect(
        const DropdownOverlayTheme(
          backgroundColor: red,
        ).resolveOverlay(ambient).backgroundColor,
        red,
      );
    });
  });

  group('item', () {
    ResolvedItemStyle resolve(
      DropdownItemTheme theme, {
      bool selected = false,
      bool isFirst = false,
      bool isLast = false,
      double menuBorderRadius = 0,
    }) => theme.resolveItem(
      ambient,
      selected: selected,
      isFirst: isFirst,
      isLast: isLast,
      menuBorderRadius: menuBorderRadius,
    );

    test('only the selected item is tinted', () {
      const theme = DropdownItemTheme(selectedColor: red);

      expect(resolve(theme, selected: true).decoration.color, red);
      expect(resolve(theme).decoration.color, Colors.transparent);
    });

    test('an untinted selection falls back to the ambient primary at 10%', () {
      final colour = resolve(
        const DropdownItemTheme(),
        selected: true,
      ).decoration.color!;

      expect(colour.a, closeTo(0.1, 0.001));
    });

    test('without a row borderRadius, only the end rows round to the menu', () {
      const theme = DropdownItemTheme();

      expect(
        resolve(theme, isFirst: true, menuBorderRadius: 10).inkBorderRadius,
        10,
      );
      expect(
        resolve(theme, isLast: true, menuBorderRadius: 10).inkBorderRadius,
        10,
      );
      expect(resolve(theme, menuBorderRadius: 10).inkBorderRadius, 0);
    });

    test('a row borderRadius rounds every row', () {
      const theme = DropdownItemTheme(borderRadius: 4);

      expect(resolve(theme, menuBorderRadius: 10).inkBorderRadius, 4);
      expect(
        resolve(theme, isFirst: true, menuBorderRadius: 10).inkBorderRadius,
        4,
      );
    });

    test('the last row drops border unless told otherwise', () {
      final excluding = DropdownItemTheme(
        border: const Border(bottom: BorderSide(color: red)),
      );
      final keeping = DropdownItemTheme(
        border: const Border(bottom: BorderSide(color: red)),
        excludeLastItemBorder: false,
      );

      expect(resolve(excluding, isLast: true).decoration.border, isNull);
      expect(resolve(excluding).decoration.border, isNotNull);
      expect(resolve(keeping, isLast: true).decoration.border, isNotNull);
    });
  });
}
