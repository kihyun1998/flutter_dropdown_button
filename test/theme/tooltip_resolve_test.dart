import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// No widget tree, no `pumpWidget`, no `BuildContext`.

BoxDecoration boxOf(
  DropdownTooltipTheme theme, [
  Brightness brightness = Brightness.light,
]) => theme.resolve(brightness).decoration! as BoxDecoration;

final grey700 = Colors.grey.shade700.withValues(alpha: 0.9);
const radius4 = BorderRadius.all(Radius.circular(4));

void main() {
  test('a theme that names no box property leaves the decoration null', () {
    expect(
      const DropdownTooltipTheme().resolve(Brightness.light).decoration,
      isNull,
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
    expect(
      boxOf(theme, Brightness.dark).color,
      Colors.white.withValues(alpha: 0.9),
    );
  });

  test('an explicit background overrides the brightness default', () {
    const theme = DropdownTooltipTheme(backgroundColor: Colors.red);

    expect(boxOf(theme, Brightness.dark).color, Colors.red);
  });

  test('a border is a BoxBorder, and it fills the box too', () {
    final theme = DropdownTooltipTheme(
      border: Border.all(color: Colors.blue, width: 2),
    );

    final border = boxOf(theme).border! as Border;
    expect(border.top.color, Colors.blue);
    expect(border.top.width, 2.0);
    expect(boxOf(theme).color, grey700);
    expect(boxOf(theme).borderRadius, radius4);
  });

  test('an explicit decoration wins over every individual property', () {
    const override = BoxDecoration(color: Colors.green);
    final theme = DropdownTooltipTheme(
      decoration: override,
      backgroundColor: Colors.red,
      border: Border.all(color: Colors.blue),
    );

    expect(theme.resolve(Brightness.light).decoration, same(override));
  });
}
