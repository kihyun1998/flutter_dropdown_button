import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

const enabledIcon = Color(0xFFE53935);
const disabledIcon = Color(0xFF9E9E9E);

final theme = DropdownStyleTheme(
  dropdown: const DropdownTheme(
    iconColor: enabledIcon,
    iconDisabledColor: disabledIcon,
  ),
);

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Color? arrowColour(WidgetTester tester) =>
    tester.widget<Icon>(find.byType(Icon)).color;

void main() {
  group('the arrow icon agrees with the rest of the button', () {
    testWidgets('enabled dropdown draws the enabled icon colour',
        (tester) async {
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

    testWidgets('disabled dropdown draws the disabled icon colour',
        (tester) async {
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

    testWidgets(
        'a single-item dropdown disabled by policy draws the '
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
