import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

const enabledIcon = Color(0xFFE53935);
const disabledIcon = Color(0xFF9E9E9E);

final theme = DropdownStyleTheme(
  button: const DropdownButtonTheme(
    iconColor: enabledIcon,
    iconDisabledColor: disabledIcon,
  ),
);

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

Color? arrowColour(WidgetTester tester) =>
    tester.widget<Icon>(find.byType(Icon)).color;

/// The style the button's face is drawn with.
TextStyle? faceStyle(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style;

void main() {
  group('disabledTextStyle merges over the base style', () {
    // `merge` keeps what the disabled style does not name. Replacing instead
    // would silently drop the caller's font size the moment they disabled the
    // button — the kind of change nobody writes a bug report for.
    const base = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    const disabled = TextStyle(color: disabledIcon);

    Widget dropdown({required bool enabled, String? value}) =>
        FlutterDropdownButton<String>.text(
          width: 200,
          items: const ['Apple', 'Banana'],
          value: value,
          hint: 'Pick a fruit',
          enabled: enabled,
          config: const TextDropdownConfig(
            textStyle: base,
            hintStyle: base,
            disabledTextStyle: disabled,
          ),
          onChanged: (_) {},
        );

    testWidgets('an enabled button keeps the base style untouched', (
      tester,
    ) async {
      await tester.pumpWidget(host(dropdown(enabled: true, value: 'Apple')));

      final style = faceStyle(tester, 'Apple')!;
      expect(style.color, isNull, reason: 'the disabled colour never applied');
      expect(style.fontSize, 20);
    });

    testWidgets('a disabled value takes the colour and keeps its size', (
      tester,
    ) async {
      await tester.pumpWidget(host(dropdown(enabled: false, value: 'Apple')));

      final style = faceStyle(tester, 'Apple')!;
      expect(style.color, disabledIcon);
      expect(style.fontSize, 20, reason: 'merged, not replaced');
      expect(style.fontWeight, FontWeight.bold);
    });

    testWidgets('a disabled hint merges over hintStyle', (tester) async {
      await tester.pumpWidget(host(dropdown(enabled: false)));

      final style = faceStyle(tester, 'Pick a fruit')!;
      expect(style.color, disabledIcon);
      expect(style.fontSize, 20);
    });

    testWidgets('with no base style, the disabled style stands alone', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            width: 200,
            items: const ['Apple'],
            value: 'Apple',
            enabled: false,
            disableWhenSingleItem: false,
            config: const TextDropdownConfig(disabledTextStyle: disabled),
            onChanged: (_) {},
          ),
        ),
      );

      expect(faceStyle(tester, 'Apple')!.color, disabledIcon);
    });
  });

  group('the arrow icon agrees with the rest of the button', () {
    testWidgets('enabled dropdown draws the enabled icon colour', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana'],
            hint: 'Pick a fruit',
            theme: theme,
            onChanged: (_) {},
          ),
        ),
      );

      expect(arrowColour(tester), enabledIcon);
    });

    testWidgets('disabled dropdown draws the disabled icon colour', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana'],
            hint: 'Pick a fruit',
            enabled: false,
            theme: theme,
            onChanged: (_) {},
          ),
        ),
      );

      expect(arrowColour(tester), disabledIcon);
    });

    testWidgets('a single-item dropdown disabled by policy draws the '
        'disabled icon colour too', (tester) async {
      // `disableWhenSingleItem` makes the button non-interactive: the tap is
      // blocked, the decoration switches to its disabled form, and the text
      // takes `disabledTextStyle`. The icon must not be the odd one out.
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            items: const ['Only one'],
            hint: 'Pick a fruit',
            disableWhenSingleItem: true,
            hideIconWhenSingleItem: false,
            theme: theme,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(arrowColour(tester), disabledIcon);
    });
  });
}
