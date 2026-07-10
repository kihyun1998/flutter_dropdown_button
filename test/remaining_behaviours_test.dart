import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The last few behaviours #56 found uncovered: the tooltip's three modes,
/// the scroll position resetting as a query narrows the list, `searchable`
/// flipping at runtime, and `isTextMode`'s public promise.

const long = 'A label far too long for a narrow button';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

Widget textDropdown({
  DropdownTooltipTheme? tooltip,
  bool searchable = false,
  List<String> items = const ['Apple', 'Banana'],
  String? value,
}) {
  return FlutterDropdownButton<String>.text(
    width: 140,
    items: items,
    value: value,
    hint: 'Pick a fruit',
    searchable: searchable,
    disableWhenSingleItem: false,
    theme: DropdownStyleTheme(tooltip: tooltip ?? const DropdownTooltipTheme()),
    onChanged: (_) {},
  );
}

void main() {
  group('isTextMode', () {
    test('the text constructor says so', () {
      final button = FlutterDropdownButton<String>.text(
        items: const ['a'],
        onChanged: (_) {},
      );

      expect(button.isTextMode, isTrue);
    });

    test('the default constructor does not', () {
      final button = FlutterDropdownButton<String>(
        items: const ['a'],
        itemBuilder: (item, isSelected) => Text(item),
        onChanged: (_) {},
      );

      expect(button.isTextMode, isFalse);
    });
  });

  group('tooltip modes', () {
    testWidgets('disabled draws no tooltip, however long the text', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          textDropdown(
            items: const [long],
            value: long,
            tooltip: const DropdownTooltipTheme(mode: TooltipMode.disabled),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('enabled: false draws no tooltip either', (tester) async {
      await tester.pumpWidget(
        host(
          textDropdown(
            items: const [long],
            value: long,
            tooltip: const DropdownTooltipTheme(enabled: false),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsNothing);
    });

    testWidgets('always draws a tooltip even when the text fits', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          textDropdown(
            items: const ['Ok'],
            value: 'Ok',
            tooltip: const DropdownTooltipTheme(mode: TooltipMode.always),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsWidgets);
    });

    testWidgets('textColor becomes the tooltip text style', (tester) async {
      await tester.pumpWidget(
        host(
          textDropdown(
            items: const [long],
            value: long,
            tooltip: const DropdownTooltipTheme(textColor: Colors.amber),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.textStyle!.color, Colors.amber);
    });

    testWidgets('an explicit textStyle wins over textColor', (tester) async {
      await tester.pumpWidget(
        host(
          textDropdown(
            items: const [long],
            value: long,
            tooltip: const DropdownTooltipTheme(
              textColor: Colors.amber,
              textStyle: TextStyle(color: Colors.green),
            ),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.textStyle!.color, Colors.green);
    });
  });

  testWidgets('narrowing a query scrolls the list back to the top', (
    tester,
  ) async {
    final many = List.generate(20, (i) => 'item$i');

    await tester.pumpWidget(
      host(
        FlutterDropdownButton<String>.text(
          width: 200,
          height: 150,
          items: many,
          hint: 'Pick one',
          searchable: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();

    final controller = tester
        .widget<ListView>(find.byType(ListView))
        .controller!;
    controller.jumpTo(100);
    await tester.pump();
    expect(controller.offset, 100);

    await tester.enterText(find.byType(TextField), 'item1');
    await tester.pumpAndSettle();

    expect(
      tester.widget<ListView>(find.byType(ListView)).controller!.offset,
      0,
      reason: 'the old offset means nothing once the list changes',
    );
  });

  testWidgets('searchable can be turned on after the first build', (
    tester,
  ) async {
    var searchable = false;
    late StateSetter setOuterState;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            setOuterState = setState;
            return textDropdown(searchable: searchable);
          },
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.tapAt(const Offset(10, 10)); // dismiss
    await tester.pumpAndSettle();

    setOuterState(() => searchable = true);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('searchable can be turned off again', (tester) async {
    var searchable = true;
    late StateSetter setOuterState;

    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            setOuterState = setState;
            return textDropdown(searchable: searchable);
          },
        ),
      ),
    );

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    setOuterState(() => searchable = false);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FlutterDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });
}
