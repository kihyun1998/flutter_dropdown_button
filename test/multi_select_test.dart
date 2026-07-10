import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reason this widget exists: ticking a box emits a new `Set` at once, and
/// the menu stays open so the next box can be ticked.

/// Holds `selected` the way a caller does, so `onChanged` → `setState` → the
/// open overlay repainting is exercised end to end.
class Harness extends StatefulWidget {
  const Harness({
    super.key,
    this.items = const ['Apple', 'Banana', 'Cherry'],
    this.initial = const <String>{},
    this.searchable = false,
    this.onChanged,
  });

  final List<String> items;
  final Set<String> initial;
  final bool searchable;
  final void Function(Set<String>)? onChanged;

  @override
  State<Harness> createState() => HarnessState();
}

class HarnessState extends State<Harness> {
  late Set<String> selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterMultiSelectDropdown<String>(
            width: 220,
            height: 200,
            items: widget.items,
            selected: selected,
            searchable: widget.searchable,
            labelBuilder: (s) => s.isEmpty ? 'All' : '${s.length} selected',
            onChanged: (next) {
              widget.onChanged?.call(next);
              setState(() => selected = next);
            },
          ),
        ),
      ),
    );
  }
}

Future<void> openMenu(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterMultiSelectDropdown<String>));
  await tester.pumpAndSettle();
}

/// The row's tappable area, found by the text it carries.
Finder row(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(InkWell));

void main() {
  testWidgets('ticking a box emits the item and leaves the menu open', (
    tester,
  ) async {
    Set<String>? emitted;
    await tester.pumpWidget(Harness(onChanged: (s) => emitted = s));
    await openMenu(tester);

    await tester.tap(row('Banana').first);
    await tester.pumpAndSettle();

    expect(emitted, {'Banana'});
    expect(
      find.text('Cherry'),
      findsOneWidget,
      reason: 'the menu is still open, so the other rows are still drawn',
    );
  });

  testWidgets('ticking a chosen box unticks it', (tester) async {
    Set<String>? emitted;
    await tester.pumpWidget(
      Harness(initial: const {'Banana'}, onChanged: (s) => emitted = s),
    );
    await openMenu(tester);

    await tester.tap(row('Banana').first);
    await tester.pumpAndSettle();

    expect(emitted, isEmpty);
  });

  testWidgets("the caller's Set is never mutated", (tester) async {
    // A caller may hand over an unmodifiable Set, and it is their state either
    // way. `_toggle` copies.
    final owned = <String>{'Apple'};
    await tester.pumpWidget(Harness(initial: owned));
    await openMenu(tester);

    await tester.tap(row('Banana').first);
    await tester.pumpAndSettle();

    expect(owned, {'Apple'}, reason: 'still exactly what we handed in');
  });

  testWidgets('two ticks accumulate without reopening the menu', (
    tester,
  ) async {
    Set<String>? emitted;
    await tester.pumpWidget(Harness(onChanged: (s) => emitted = s));
    await openMenu(tester);

    await tester.tap(row('Apple').first);
    await tester.pumpAndSettle();
    await tester.tap(row('Cherry').first);
    await tester.pumpAndSettle();

    expect(emitted, {'Apple', 'Cherry'});
  });

  testWidgets('the boxes repaint when the owner rebuilds', (tester) async {
    // The overlay lives in its own element subtree. Without the shell marking
    // it dirty after the frame, the ticks would not appear until reopening.
    await tester.pumpWidget(const Harness());
    await openMenu(tester);

    await tester.tap(row('Apple').first);
    await tester.pumpAndSettle();

    final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(boxes.map((b) => b.value), [true, false, false]);
  });

  testWidgets('the face is whatever labelBuilder makes of the set', (
    tester,
  ) async {
    await tester.pumpWidget(const Harness());
    expect(find.text('All'), findsOneWidget);

    await openMenu(tester);
    await tester.tap(row('Apple').first);
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
  });

  testWidgets('a chosen value absent from items counts, but draws no row', (
    tester,
  ) async {
    // The refresh that drops a chosen value's data leaves it in `selected`.
    // The widget draws what it was handed: the face counts it, the menu does
    // not invent a row for it, and nothing throws.
    await tester.pumpWidget(
      const Harness(items: ['Apple'], initial: {'Apple', 'ghost'}),
    );

    expect(find.text('2 selected'), findsOneWidget);

    await openMenu(tester);

    expect(find.text('ghost'), findsNothing);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the query survives a tick', (tester) async {
    await tester.pumpWidget(const Harness(searchable: true));
    await openMenu(tester);

    await tester.enterText(find.byType(TextField), 'an');
    await tester.pumpAndSettle();
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Cherry'), findsNothing);

    await tester.tap(row('Banana').first);
    await tester.pumpAndSettle();

    expect(
      find.byType(TextField),
      findsOneWidget,
      reason: 'the menu did not close',
    );
    expect(
      find.text('Cherry'),
      findsNothing,
      reason: 'and the query was not reset by the tap',
    );
  });

  testWidgets('closeAll shuts a checklist too', (tester) async {
    await tester.pumpWidget(const Harness());
    await openMenu(tester);
    expect(find.byType(Checkbox), findsNWidgets(3));

    FlutterMultiSelectDropdown.closeAll(animate: false);
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('opening a plain dropdown closes an open checklist', (
    tester,
  ) async {
    // Single-open coordination is a registry keyed by `Overlay`, so the two
    // widgets close one another without either knowing the other exists.
    // Side by side. Stacked, the checklist's menu would cover the second
    // button, and the tap meant for it would land on a checklist row instead.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              FlutterMultiSelectDropdown<String>(
                width: 200,
                items: const ['Apple', 'Banana'],
                selected: const {},
                labelBuilder: (s) => 'pick',
                onChanged: (_) {},
              ),
              FlutterDropdownButton<String>.text(
                width: 200,
                items: const ['One', 'Two'],
                hint: 'other',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FlutterMultiSelectDropdown<String>));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(2));

    // The open menu covers the screen with a dismiss barrier, so reaching the
    // other button may take two taps. Either way, both must never be open.
    await tester.tap(
      find.byType(FlutterDropdownButton<String>),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    if (find.text('One').evaluate().isEmpty) {
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();
    }

    expect(find.text('One'), findsOneWidget, reason: 'the other one opened');
    expect(find.byType(Checkbox), findsNothing, reason: 'the checklist closed');
  });

  testWidgets('reopening the menu does reset the query', (tester) async {
    // Guard. Opening and closing is what clears the query, and that is driven
    // from the overlay controller rather than from a tap.
    await tester.pumpWidget(const Harness(searchable: true));
    await openMenu(tester);

    await tester.enterText(find.byType(TextField), 'an');
    await tester.pumpAndSettle();
    expect(find.text('Cherry'), findsNothing);

    await tester.tap(find.byType(FlutterMultiSelectDropdown<String>));
    await tester.pumpAndSettle();
    await openMenu(tester);

    expect(find.text('Cherry'), findsOneWidget);
  });
}
