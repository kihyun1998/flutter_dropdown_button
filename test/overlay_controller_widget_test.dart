import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// `DropdownOverlayController` driven the way a third party drives it — held by
/// a `State`, with no `FlutterDropdownButton` anywhere.
///
/// `toggle()` and the controller's own default menu chrome are unreachable
/// through the widget, which always supplies a decoration of its own.

class BareDropdown extends StatefulWidget {
  const BareDropdown({super.key, this.decoration});

  /// Null lets the controller draw its own chrome from the ambient theme.
  final BoxDecoration? decoration;

  @override
  State<BareDropdown> createState() => _BareDropdownState();
}

class _BareDropdownState extends State<BareDropdown>
    with SingleTickerProviderStateMixin {
  late final DropdownOverlayController menu = DropdownOverlayController(
    vsync: this,
    spec: () => const DropdownOverlaySpec(
      itemCount: 2,
      actualItemHeight: 40,
      maxDropdownHeight: 200,
    ),
    contentBuilder: (height) => const Column(
      mainAxisSize: MainAxisSize.min,
      children: [Text('one'), Text('two')],
    ),
    decorationBuilder: () => widget.decoration,
    onOpenStateChanged: (_) => setState(() {}),
  );

  @override
  void dispose() {
    menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: menu.buttonKey,
      onTap: () => menu.toggle(context),
      child: const SizedBox(width: 120, height: 40, child: Text('open me')),
    );
  }
}

Widget host(Widget child) => MaterialApp(
  theme: ThemeData(cardColor: const Color(0xFF102030)),
  home: Scaffold(body: Center(child: child)),
);

/// The menu's own box — the one the controller gives a border radius.
BoxDecoration menuDecoration(WidgetTester tester) {
  final containers = tester.widgetList<Container>(
    find.descendant(of: find.byType(Overlay), matching: find.byType(Container)),
  );

  return containers
      .map((c) => c.decoration)
      .whereType<BoxDecoration>()
      .firstWhere((d) => d.borderRadius != null);
}

void main() {
  testWidgets('toggle opens a closed menu and closes an open one', (
    tester,
  ) async {
    await tester.pumpWidget(host(const BareDropdown()));

    expect(find.text('one'), findsNothing);

    await tester.tap(find.text('open me'));
    await tester.pumpAndSettle();
    expect(find.text('one'), findsOneWidget);

    await tester.tap(find.text('open me'));
    await tester.pumpAndSettle();
    expect(find.text('one'), findsNothing);
  });

  testWidgets('a null decoration falls back to the ambient theme', (
    tester,
  ) async {
    await tester.pumpWidget(host(const BareDropdown()));

    await tester.tap(find.text('open me'));
    await tester.pumpAndSettle();

    final decoration = menuDecoration(tester);
    expect(
      decoration.color,
      const Color(0xFF102030),
      reason: "the ThemeData's cardColor",
    );
    expect(decoration.border, isNotNull, reason: 'and its dividerColor');
  });

  testWidgets('a supplied decoration is used as-is', (tester) async {
    await tester.pumpWidget(
      host(
        const BareDropdown(
          decoration: BoxDecoration(
            color: Color(0xFFAABBCC),
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open me'));
    await tester.pumpAndSettle();

    expect(menuDecoration(tester).color, const Color(0xFFAABBCC));
  });
}
