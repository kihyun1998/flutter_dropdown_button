import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Characterisation tests for the fifteen fallback chains inlined across the
/// widget's build methods. They pin the rules down at the rendered widget, not
/// at the code that computes them, so they survive the move into `resolve()`.

const red = Color(0xFFE53935);
const green = Color(0xFF43A047);
const blue = Color(0xFF1E88E5);

Widget host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Widget dropdown({
  DropdownStyleTheme? theme,
  bool enabled = true,
  List<String> items = const ['Apple', 'Banana', 'Cherry'],
  String? value,
}) {
  return FlutterDropdownButton<String>.text(
    width: 200,
    items: items,
    value: value,
    hint: 'Pick a fruit',
    enabled: enabled,
    theme: theme,
    onChanged: (_) {},
  );
}

/// The button's own Container — the outermost one the widget builds.
BoxDecoration buttonDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(FlutterDropdownButton<String>),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

/// The item rows inside the open menu, in order.
List<BoxDecoration> itemDecorations(WidgetTester tester) {
  return tester
      .widgetList<Ink>(find.byType(Ink))
      .map((ink) => ink.decoration! as BoxDecoration)
      .toList();
}

Future<void> openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

void main() {
  group('button decoration when disabled', () {
    testWidgets('disabledButtonDecoration wins outright', (tester) async {
      await tester.pumpWidget(
        host(
          dropdown(
            enabled: false,
            theme: DropdownStyleTheme(
              dropdown: DropdownTheme(
                disabledButtonDecoration: const BoxDecoration(color: red),
                disabledBackgroundColor: green,
                border: Border.all(color: blue),
              ),
            ),
          ),
        ),
      );

      final decoration = buttonDecoration(tester);
      expect(decoration.color, red);
      expect(decoration.border, isNull, reason: 'the override replaces all');
    });

    testWidgets(
      'disabledBackgroundColor and disabledBorder build one together',
      (tester) async {
        await tester.pumpWidget(
          host(
            dropdown(
              enabled: false,
              theme: DropdownStyleTheme(
                dropdown: DropdownTheme(
                  disabledBackgroundColor: green,
                  disabledBorder: Border.all(color: red),
                  borderRadius: 12,
                ),
              ),
            ),
          ),
        );

        final decoration = buttonDecoration(tester);
        expect(decoration.color, green);
        expect((decoration.border! as Border).top.color, red);
        expect(decoration.borderRadius, BorderRadius.circular(12));
      },
    );

    testWidgets('disabledBorder falls back to border', (tester) async {
      await tester.pumpWidget(
        host(
          dropdown(
            enabled: false,
            theme: DropdownStyleTheme(
              dropdown: DropdownTheme(
                disabledBackgroundColor: green,
                border: Border.all(color: blue),
              ),
            ),
          ),
        ),
      );

      expect((buttonDecoration(tester).border! as Border).top.color, blue);
    });

    testWidgets(
      'with no disabled styling at all, the enabled decoration stands',
      (tester) async {
        await tester.pumpWidget(
          host(
            dropdown(
              enabled: false,
              theme: DropdownStyleTheme(
                dropdown: DropdownTheme(border: Border.all(color: blue)),
              ),
            ),
          ),
        );

        final decoration = buttonDecoration(tester);
        expect(decoration.color, isNull);
        expect((decoration.border! as Border).top.color, blue);
      },
    );
  });

  group('item decoration', () {
    testWidgets('the selected item takes selectedItemColor', (tester) async {
      await tester.pumpWidget(
        host(
          dropdown(
            value: 'Banana',
            theme: const DropdownStyleTheme(
              dropdown: DropdownTheme(selectedItemColor: red),
            ),
          ),
        ),
      );
      await openMenu(tester);

      final decorations = itemDecorations(tester);
      expect(decorations[0].color, Colors.transparent);
      expect(decorations[1].color, red, reason: 'Banana is selected');
      expect(decorations[2].color, Colors.transparent);
    });

    testWidgets('the last item skips itemBorder by default', (tester) async {
      await tester.pumpWidget(
        host(
          dropdown(
            theme: DropdownStyleTheme(
              dropdown: DropdownTheme(
                itemBorder: Border(bottom: BorderSide(color: blue)),
              ),
            ),
          ),
        ),
      );
      await openMenu(tester);

      final decorations = itemDecorations(tester);
      expect(decorations[0].border, isNotNull);
      expect(decorations[1].border, isNotNull);
      expect(decorations[2].border, isNull, reason: 'excludeLastItemBorder');
    });

    testWidgets('excludeLastItemBorder false keeps the last border', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          dropdown(
            theme: DropdownStyleTheme(
              dropdown: DropdownTheme(
                itemBorder: Border(bottom: BorderSide(color: blue)),
                excludeLastItemBorder: false,
              ),
            ),
          ),
        ),
      );
      await openMenu(tester);

      expect(itemDecorations(tester)[2].border, isNotNull);
    });

    testWidgets('itemBorderRadius applies to every item', (tester) async {
      await tester.pumpWidget(
        host(
          dropdown(
            theme: const DropdownStyleTheme(
              dropdown: DropdownTheme(itemBorderRadius: 6),
            ),
          ),
        ),
      );
      await openMenu(tester);

      for (final decoration in itemDecorations(tester)) {
        expect(decoration.borderRadius, BorderRadius.circular(6));
      }
    });
  });
}
