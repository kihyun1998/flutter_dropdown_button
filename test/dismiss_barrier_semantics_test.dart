import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The dismiss barrier is a gesture, not a control.
///
/// It exists so a tap outside the menu closes it. Its `GestureDetector` used to
/// annotate the semantics tree as well, which put a screen-sized node carrying
/// `tap` — with no label and no role — above the whole open menu. Measured:
///
///     #4 200x50  label="Pick"  acts=[tap, focus]      ← the trigger
///       #5 800x600 label=""    acts=[tap]             ← the barrier
///         #6 198x48 label="Alpha" acts=[tap, focus]   ← rows, its children
///
/// The rows being *children* of it is why `ExcludeSemantics` is the wrong tool:
/// it prunes the subtree, taking the menu with it. `excludeFromSemantics`
/// suppresses only the detector's own annotation, so the menu stays.
///
/// Nothing is lost by dropping it. The trigger node survives an open menu and
/// still carries `tap`, and activating it through the semantics API closes the
/// menu — pinned below, because that is the claim the removal rests on.

class Role {
  const Role(this.name);
  final String name;
}

const alpha = Role('Alpha');
const beta = Role('Beta');
const roles = [alpha, beta];

Widget custom() => MaterialApp(
  home: Scaffold(
    body: Center(
      child: FlutterDropdownButton<Role>(
        width: 200,
        items: roles,
        itemBuilder: (role, isSelected) => Text(role.name),
        hintWidget: const Text('Pick'),
        onChanged: (_) {},
      ),
    ),
  ),
);

/// Every node in the tree that carries an action, with its size.
List<({int id, Size size, String label})> actionable(WidgetTester tester) {
  final found = <({int id, Size size, String label})>[];
  void walk(SemanticsNode node) {
    final data = node.getSemanticsData();
    final hasAny = SemanticsAction.values.any(data.hasAction);
    if (hasAny) {
      found.add((id: node.id, size: node.rect.size, label: data.label));
    }
    node.visitChildren((child) {
      walk(child);
      return true;
    });
  }

  // ignore: deprecated_member_use
  walk(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
  return found;
}

void main() {
  testWidgets('an open menu puts no screen-sized target in the tree', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(custom());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FlutterDropdownButton<Role>));
    await tester.pumpAndSettle();

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final screenSized = actionable(
      tester,
    ).where((n) => n.size.width >= screen.width).toList();

    expect(
      screenSized,
      isEmpty,
      reason: 'the barrier is a gesture, not a control the user can hear',
    );

    // The side condition, and the reason `ExcludeSemantics` is not the tool:
    // the menu must survive the barrier's removal from the tree.
    expect(
      tester.getSemantics(find.text('Alpha')),
      // ignore: deprecated_member_use
      containsSemantics(label: 'Alpha', hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.text('Beta')),
      // ignore: deprecated_member_use
      containsSemantics(label: 'Beta', hasTapAction: true),
    );

    semantics.dispose();
  });

  testWidgets('the empty state is its own node, not the whole screen', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FlutterDropdownButton<Role>.text(
              width: 200,
              items: roles,
              searchable: true,
              label: (role) => role.name,
              hint: 'Pick',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FlutterDropdownButton<Role>));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    // It is a bare `Text` with no interactive ancestor, so it merged into the
    // barrier and named it: one screen-sized node reading "No results found"
    // whose activation dismissed the menu.
    //
    // Size is the assertion, because size is what distinguishes the barrier
    // from everything else — it was the only node as large as the view. What
    // this deliberately does *not* assert is that the node carries no action:
    // measured across the CI matrix, on 3.44.8 it is its own 166x40 node with
    // none, while on the 3.32.0 floor the message merges into the **search
    // field**, giving one 200x146 node labelled "No results found" that also
    // carries `setText`/`setSelection`/`focus`. That is a different defect on a
    // different mechanism, it is bounded by the menu rather than the view, and
    // pinning it here would make this test assert two unrelated things and go
    // red on one end of the matrix for the wrong reason.
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final node = tester.getSemantics(find.text('No results found'));

    expect(
      node.rect.width,
      lessThan(screen.width),
      reason: 'the message names its own box, not the screen',
    );
    expect(
      node.rect.height,
      lessThan(screen.height),
      reason: 'both axes — a full-width strip would still not be the barrier',
    );

    semantics.dispose();
  });

  testWidgets('the trigger still closes the menu through the semantics API', (
    tester,
  ) async {
    // Guard. This is what makes the barrier disposable: assistive technology
    // never needed it, because the control that opened the menu is still in the
    // tree and still activatable while it is open.
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(custom());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FlutterDropdownButton<Role>));
    await tester.pumpAndSettle();

    final trigger = tester.getSemantics(find.text('Pick'));
    expect(
      trigger.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
      reason: 'the trigger is reachable while its own menu is open',
    );

    // ignore: deprecated_member_use
    tester.binding.pipelineOwner.semanticsOwner!.performAction(
      trigger.id,
      SemanticsAction.tap,
    );
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsNothing);

    semantics.dispose();
  });
}
