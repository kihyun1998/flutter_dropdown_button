import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// A disabled control accepts no input, and the menu is part of the control.
///
/// The window this file exists for is narrow and is the whole point: `close()`
/// is animated, so the rows are still mounted while the menu reverses out. A
/// fix that only closed the menu would leave those frames live, and a test that
/// only pumped to settle would never see them.
///
/// Asserted at `onChanged`, not at the semantics tree — this is a functional
/// contract, and the tree was merely where it first became audible (#88).

class Role {
  const Role(this.name);
  final String name;
}

const owner = Role('Owner');
const member = Role('Member');
const roles = [owner, member];

/// Single-select whose `enabled` the test can flip while the menu is open.
class SingleHost extends StatefulWidget {
  const SingleHost({super.key});

  @override
  State<SingleHost> createState() => SingleHostState();
}

class SingleHostState extends State<SingleHost> {
  bool enabled = true;
  final List<Role> chosen = [];

  void disable() => setState(() => enabled = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<Role>(
            width: 200,
            items: roles,
            enabled: enabled,
            itemBuilder: (role, isSelected) => Text(role.name),
            hintWidget: const Text('Pick'),
            onChanged: (role) => setState(() {
              if (role != null) chosen.add(role);
            }),
          ),
        ),
      ),
    );
  }
}

/// Multi-select. Worse than the single-select case: `closeOnTap` is false, so
/// without a fix a disabled checklist stays operable indefinitely.
class MultiHost extends StatefulWidget {
  const MultiHost({super.key});

  @override
  State<MultiHost> createState() => MultiHostState();
}

class MultiHostState extends State<MultiHost> {
  bool enabled = true;
  Set<Role> chosen = {};
  int calls = 0;

  void disable() => setState(() => enabled = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterMultiSelectDropdown<Role>(
            width: 200,
            items: roles,
            selected: chosen,
            enabled: enabled,
            label: (role) => role.name,
            labelBuilder: (selected) => '${selected.length} selected',
            onChanged: (Set<Role> next) => setState(() {
              calls++;
              chosen = next;
            }),
          ),
        ),
      ),
    );
  }
}

/// Reaches the same state through `disableWhenSingleItem`, where the caller
/// never touches `enabled` at all — the list simply shrinks.
class ShrinkHost extends StatefulWidget {
  const ShrinkHost({super.key});

  @override
  State<ShrinkHost> createState() => ShrinkHostState();
}

class ShrinkHostState extends State<ShrinkHost> {
  List<Role> items = roles;
  Role? value;
  int calls = 0;

  void shrink() => setState(() => items = const [owner]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<Role>(
            width: 200,
            items: items,
            value: value,
            disableWhenSingleItem: true,
            itemBuilder: (role, isSelected) => Text(role.name),
            // The face must read differently from a row: after the automatic
            // selection the button draws the same item, and `find.text` would
            // otherwise answer about the trigger while the test asks about the
            // menu.
            selectedBuilder: (role) => Text('Face ${role.name}'),
            hintWidget: const Text('Pick'),
            // `value` is stored, not merely counted: `disableWhenSingleItem`
            // chooses the only item for the caller after the frame, and a host
            // that never writes it back re-arms that callback forever.
            onChanged: (role) => setState(() {
              calls++;
              value = role;
            }),
          ),
        ),
      ),
    );
  }
}

/// Text mode with a search field, to reach the overlay's own `TextField`.
class SearchHost extends StatefulWidget {
  const SearchHost({super.key});

  @override
  State<SearchHost> createState() => SearchHostState();
}

class SearchHostState extends State<SearchHost> {
  bool enabled = true;

  void disable() => setState(() => enabled = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<Role>.text(
            width: 200,
            items: roles,
            enabled: enabled,
            searchable: true,
            label: (role) => role.name,
            hint: 'Pick',
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }
}

void main() {
  group('single-select', () {
    testWidgets('a row tapped while the menu closes after a disable does not '
        'select', (tester) async {
      final key = GlobalKey<SingleHostState>();
      await tester.pumpWidget(SingleHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      key.currentState!.disable();
      // One frame only. The rows are still mounted here — the close animation
      // has not finished — which is exactly the window a tap can land in.
      await tester.pump();
      expect(
        find.text('Owner'),
        findsOneWidget,
        reason: 'the window this test exists for must actually exist',
      );

      await tester.tap(find.text('Owner'));
      await tester.pumpAndSettle();

      expect(
        key.currentState!.chosen,
        isEmpty,
        reason: 'a disabled control accepts no input',
      );
    });

    testWidgets('the menu closes when the dropdown is disabled while open', (
      tester,
    ) async {
      final key = GlobalKey<SingleHostState>();
      await tester.pumpWidget(SingleHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();
      expect(find.text('Owner'), findsOneWidget);

      key.currentState!.disable();
      await tester.pumpAndSettle();

      expect(
        find.text('Owner'),
        findsNothing,
        reason: 'a menu that shows options none of which work is its own lie',
      );
    });
  });

  group('multi-select', () {
    testWidgets('a disabled checklist accepts no toggle', (tester) async {
      final key = GlobalKey<MultiHostState>();
      await tester.pumpWidget(MultiHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterMultiSelectDropdown<Role>));
      await tester.pumpAndSettle();

      key.currentState!.disable();
      await tester.pump();
      expect(find.text('Owner'), findsOneWidget);

      await tester.tap(find.text('Owner'));
      await tester.pumpAndSettle();

      expect(
        key.currentState!.calls,
        0,
        reason:
            'closeOnTap is false here, so an ungated row stays tappable '
            'for as long as the checklist is on screen',
      );
    });

    testWidgets('the checklist closes too — one shell, one rule', (
      tester,
    ) async {
      final key = GlobalKey<MultiHostState>();
      await tester.pumpWidget(MultiHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterMultiSelectDropdown<Role>));
      await tester.pumpAndSettle();
      expect(find.text('Owner'), findsOneWidget);

      key.currentState!.disable();
      await tester.pumpAndSettle();

      expect(find.text('Owner'), findsNothing);
    });
  });

  group('disableWhenSingleItem — reached without touching `enabled`', () {
    testWidgets('shrinking to one item closes the open menu, and the row it '
        'leaves behind is inert', (tester) async {
      final key = GlobalKey<ShrinkHostState>();
      await tester.pumpWidget(ShrinkHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();
      expect(find.text('Owner'), findsOneWidget);

      key.currentState!.shrink();
      await tester.pump();

      // The row is still there for this frame; tapping it must add nothing on
      // top of the one call `disableWhenSingleItem` makes by design.
      if (find.text('Owner').evaluate().isNotEmpty) {
        await tester.tap(find.text('Owner'));
      }
      await tester.pumpAndSettle();

      expect(
        key.currentState!.calls,
        1,
        reason: 'the auto-selection of the only item, and nothing from the tap',
      );
      expect(key.currentState!.value, owner);
      expect(find.text('Owner'), findsNothing, reason: 'the menu closed');
    });
  });

  group('closing is the general case of not accepting input', () {
    testWidgets('a row tapped during an ordinary close does not select', (
      tester,
    ) async {
      // Nothing to do with `enabled`: the user dismissed the menu themselves.
      // Measured before this was gated — 150ms into the default 200ms close the
      // rows are still mounted at 38% opacity and a tap on one selected.
      final key = GlobalKey<SingleHostState>();
      await tester.pumpWidget(SingleHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      // Dismiss through the barrier, far from the menu.
      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        find.text('Owner'),
        findsOneWidget,
        reason: 'the window this test exists for must actually exist',
      );

      await tester.tap(find.text('Owner'));
      await tester.pumpAndSettle();

      expect(key.currentState!.chosen, isEmpty);
    });

    testWidgets('a second row tapped while the first tap closes the menu does '
        'not select twice', (tester) async {
      final key = GlobalKey<SingleHostState>();
      await tester.pumpWidget(SingleHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Owner'));
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Member').evaluate().isNotEmpty) {
        await tester.tap(find.text('Member'));
      }
      await tester.pumpAndSettle();

      expect(
        key.currentState!.chosen,
        [owner],
        reason: 'one tap, one selection — the menu was already on its way out',
      );
    });
  });

  group('the search field is part of the control', () {
    testWidgets('a disabled dropdown does not keep an editable search field', (
      tester,
    ) async {
      final key = GlobalKey<SearchHostState>();
      await tester.pumpWidget(SearchHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      key.currentState!.disable();
      await tester.pump();
      await tester.pump();

      final field = find.byType(TextField);
      if (field.evaluate().isNotEmpty) {
        expect(
          tester.widget<TextField>(field).enabled,
          isFalse,
          reason: 'measured before: it stayed focused and accepted typing',
        );
      }
      await tester.pumpAndSettle();
    });
  });

  group('the tree agrees with the behaviour', () {
    testWidgets('a disabled row announces that it is disabled, not just a '
        'state', (tester) async {
      // ADR-0001 rule 3. Dropping the tap action alone would leave a node that
      // still announces a chosen state and still takes focus while saying
      // nothing about being a control or being unavailable — measured, before
      // the row carried `enabled`: `flags=[hasSelectedState, isFocusable]
      // actions=[focus]`.
      final semantics = tester.ensureSemantics();
      final key = GlobalKey<SingleHostState>();
      await tester.pumpWidget(SingleHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Owner')),
        // ignore: deprecated_member_use
        containsSemantics(hasEnabledState: true, isEnabled: true),
        reason: 'an enabled row',
      );

      key.currentState!.disable();
      await tester.pump();
      await tester.pump();

      expect(
        tester.getSemantics(find.text('Owner')),
        // ignore: deprecated_member_use
        containsSemantics(
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
        reason: 'and the same row once the control is disabled',
      );

      await tester.pumpAndSettle();
      semantics.dispose();
    });
  });

  group('what must not change', () {
    testWidgets('an enabled dropdown still selects — the guard is not a ban', (
      tester,
    ) async {
      // Guard. Gating a tap on `enabled` is one expression away from gating it
      // on nothing; this is what notices.
      final key = GlobalKey<SingleHostState>();
      await tester.pumpWidget(SingleHost(key: key));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Owner'));
      await tester.pumpAndSettle();

      expect(key.currentState!.chosen, [owner]);
    });

    testWidgets('a dropdown that was disabled from the start is unaffected', (
      tester,
    ) async {
      // The menu cannot be opened at all, so there is nothing to close; this
      // pins that the new close path does not fire on an ordinary rebuild.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<Role>(
                width: 200,
                items: roles,
                enabled: false,
                itemBuilder: (role, isSelected) => Text(role.name),
                hintWidget: const Text('Pick'),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      expect(find.text('Owner'), findsNothing);
    });
  });
}
