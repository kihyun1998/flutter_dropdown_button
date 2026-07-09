import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Observed at the public seam: the `Tooltip` the button renders.
///
/// Flutter's `Tooltip` treats a non-null `decoration` as a *total* replacement
/// for its own default. A theme that sets one visual property must therefore
/// still hand it a complete box, or the slots it left alone go blank.

const _long = 'A label far too long for a narrow button';

Future<Tooltip> pumpTooltip(
  WidgetTester tester,
  DropdownTooltipTheme tooltip, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(brightness: brightness),
    home: Scaffold(
      body: Center(
        child: FlutterDropdownButton<String>.text(
          width: 140,
          items: const [_long],
          value: _long,
          disableWhenSingleItem: false,
          theme: DropdownStyleTheme(tooltip: tooltip),
          onChanged: (_) {},
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return tester.widget<Tooltip>(find.byType(Tooltip).first);
}

BoxDecoration boxOf(Tooltip tooltip) => tooltip.decoration! as BoxDecoration;

void main() {
  testWidgets('a rounded tooltip still has a background', (tester) async {
    final tooltip = await pumpTooltip(
      tester,
      DropdownTooltipTheme(borderRadius: BorderRadius.circular(8)),
    );

    expect(boxOf(tooltip).borderRadius, BorderRadius.circular(8));
    expect(
      boxOf(tooltip).color,
      isNotNull,
      reason: 'setting the radius must not erase the default background',
    );
  });

  testWidgets('a recoloured tooltip keeps its rounded corners', (tester) async {
    final tooltip = await pumpTooltip(
      tester,
      const DropdownTooltipTheme(backgroundColor: Colors.black87),
    );

    expect(boxOf(tooltip).color, Colors.black87);
    expect(
      boxOf(tooltip).borderRadius,
      const BorderRadius.all(Radius.circular(4)),
      reason: "the corners Flutter's own tooltip has",
    );
  });

  testWidgets('a shadow does not blank the box', (tester) async {
    const shadow = [BoxShadow(color: Colors.black26, blurRadius: 8)];
    final tooltip =
        await pumpTooltip(tester, const DropdownTooltipTheme(shadow: shadow));

    expect(boxOf(tooltip).boxShadow, shadow);
    expect(boxOf(tooltip).color, isNotNull);
    expect(boxOf(tooltip).borderRadius, isNotNull);
  });

  testWidgets('a border does not blank the box', (tester) async {
    final tooltip = await pumpTooltip(
      tester,
      const DropdownTooltipTheme(borderColor: Colors.red, borderWidth: 3),
    );

    final border = boxOf(tooltip).border! as Border;
    expect(border.top.color, Colors.red);
    expect(border.top.width, 3);
    expect(boxOf(tooltip).color, isNotNull);
  });

  testWidgets('the default background flips with the ambient brightness',
      (tester) async {
    final light = await pumpTooltip(
      tester,
      DropdownTooltipTheme(borderRadius: BorderRadius.circular(8)),
    );
    final dark = await pumpTooltip(
      tester,
      DropdownTooltipTheme(borderRadius: BorderRadius.circular(8)),
      brightness: Brightness.dark,
    );

    expect(boxOf(light).color, isNot(boxOf(dark).color));
    expect(boxOf(dark).color, Colors.white.withValues(alpha: 0.9));
  });

  testWidgets('an unstyled tooltip leaves the box to Flutter', (tester) async {
    // Guard, not a regression test: this passed before the fix too. It pins
    // the reason `resolve()` returns a nullable decoration — an app-wide
    // `TooltipTheme` must still win when this theme names no box property.
    final tooltip = await pumpTooltip(tester, const DropdownTooltipTheme());

    expect(tooltip.decoration, isNull);
  });

  testWidgets('an explicit decoration is a total override', (tester) async {
    // Guard: `decoration` has always bypassed the individual properties, and
    // must keep doing so even though they now carry defaults.
    const override = BoxDecoration(color: Colors.green);
    final tooltip = await pumpTooltip(
      tester,
      DropdownTooltipTheme(
        decoration: override,
        backgroundColor: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    expect(tooltip.decoration, same(override));
  });
}
