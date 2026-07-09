import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// No widget tree, no `pumpWidget`, no `BuildContext`.

BoxDecoration boxOf(DropdownTooltipTheme theme,
        [Brightness brightness = Brightness.light]) =>
    theme.resolve(brightness).decoration! as BoxDecoration;

final grey700 = Colors.grey.shade700.withValues(alpha: 0.9);
const radius4 = BorderRadius.all(Radius.circular(4));

void main() {
  test('a theme that names no box property leaves the decoration null', () {
    expect(const DropdownTooltipTheme().resolve(Brightness.light).decoration,
        isNull);
  });

  test('borderWidth alone names no box, because it draws nothing alone', () {
    expect(
      const DropdownTooltipTheme(borderWidth: 3)
          .resolve(Brightness.light)
          .decoration,
      isNull,
      reason: 'synthesising a box here would override an ambient TooltipTheme',
    );
  });

  test('any one box property fills all the others', () {
    final box = boxOf(DropdownTooltipTheme(borderRadius: BorderRadius.zero));

    expect(box.color, grey700);
    expect(box.borderRadius, BorderRadius.zero);
    expect(box.border, isNull);
    expect(box.boxShadow, isNull);
  });

  test('a background keeps the default radius', () {
    final box = boxOf(const DropdownTooltipTheme(backgroundColor: Colors.red));

    expect(box.color, Colors.red);
    expect(box.borderRadius, radius4);
  });

  test('the default background follows the brightness', () {
    final theme = DropdownTooltipTheme(borderRadius: BorderRadius.circular(8));

    expect(boxOf(theme, Brightness.light).color, grey700);
    expect(boxOf(theme, Brightness.dark).color,
        Colors.white.withValues(alpha: 0.9));
  });

  test('an explicit background overrides the brightness default', () {
    const theme = DropdownTooltipTheme(backgroundColor: Colors.red);

    expect(boxOf(theme, Brightness.dark).color, Colors.red);
  });

  test('borderWidth defaults to one, and applies once a colour is given', () {
    final thin = boxOf(const DropdownTooltipTheme(borderColor: Colors.red))
        .border! as Border;
    expect(thin.top.width, 1.0);

    final thick = boxOf(const DropdownTooltipTheme(
      borderColor: Colors.red,
      borderWidth: 3,
    )).border! as Border;
    expect(thick.top.width, 3.0);
  });

  test('border takes a BoxBorder, like the other themes do', () {
    final theme = DropdownTooltipTheme(
      border: Border.all(color: Colors.blue, width: 2),
    );

    final border = boxOf(theme).border! as Border;
    expect(border.top.color, Colors.blue);
    expect(border.top.width, 2.0);
    expect(boxOf(theme).color, grey700, reason: 'and it fills the box too');
  });

  test('border wins over the deprecated borderColor pair', () {
    final theme = DropdownTooltipTheme(
      border: Border.all(color: Colors.blue),
      // ignore: deprecated_member_use_from_same_package
      borderColor: Colors.red,
    );

    expect((boxOf(theme).border! as Border).top.color, Colors.blue);
  });

  test('an explicit decoration wins over every individual property', () {
    const override = BoxDecoration(color: Colors.green);
    const theme = DropdownTooltipTheme(
      decoration: override,
      backgroundColor: Colors.red,
      borderColor: Colors.blue,
    );

    expect(theme.resolve(Brightness.light).decoration, same(override));
  });
}
