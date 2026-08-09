import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// Observed at the semantics tree, not the widget tree — a screen reader reads
/// the former. Every assertion in this file passes under `find.text` while the
/// tree says nothing (#37 is the precedent).
///
/// Two contracts live here:
///
/// * the trigger is a **control that opens a list**, so it announces the button
///   role and whether it is enabled;
/// * a row that is **chosen** says so. Which word it uses is the presentation's
///   call — a checklist row is `checked`, a single-select row is `selected` —
///   because the shell does not know what selection is.
///
/// `containsSemantics`, deliberately ignored — the same choice and the same
/// reasoning as `presentation/multi_select_presentation_test.dart`, which worked
/// this out first. `isSemantics` does not exist on the 3.32 floor; `hasFlag` and
/// `flagsCollection` are mirror problems. `matchesSemantics` compiles on both
/// ends but insists on describing *every* flag, which is not a stronger bar
/// here — it is a trap: `Focus` emits its focus action only off-iOS
/// (`widgets/focus_scope.dart:723`), so an exhaustive matcher pins the host
/// default and goes red under `TargetPlatform.iOS`. Measured, not guessed.
/// Drop the ignores when the floor moves past `isSemantics`.
///
/// What is asserted here is therefore *this package's* contract, not Flutter's
/// contributions to the node. The negative assertions carry the weight: an
/// unchosen row states `isSelected: false` rather than staying silent, so a bug
/// that marked every row selected cannot pass.

class Role {
  const Role(this.name);
  final String name;
}

const owner = Role('Owner');
const member = Role('Member');
const viewer = Role('Viewer');
const roles = [owner, member, viewer];

/// Custom mode. The face is built by [selectedBuilder] so its text differs from
/// the rows' — otherwise `find.text('Member')` matches both the trigger and its
/// row, and the finder, not the tree, decides what is asserted.
Future<void> pumpCustom(WidgetTester tester, {bool enabled = true}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<Role>(
            width: 200,
            items: roles,
            value: member,
            enabled: enabled,
            itemBuilder: (role, isSelected) => Text(role.name),
            selectedBuilder: (role) => Text('Face ${role.name}'),
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpText(WidgetTester tester, {String? semanticsLabel}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<Role>.text(
            width: 200,
            items: roles,
            value: member,
            label: (role) => role.name,
            config: TextDropdownConfig(semanticsLabel: semanticsLabel),
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpMulti(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterMultiSelectDropdown<Role>(
            width: 200,
            items: roles,
            selected: const {member},
            label: (role) => role.name,
            labelBuilder: (selected) => '${selected.length} selected',
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('the trigger carries its role', () {
    testWidgets('an enabled dropdown announces the button role', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCustom(tester);

      expect(
        tester.getSemantics(find.text('Face Member')),
        // ignore: deprecated_member_use
        containsSemantics(
          label: 'Face Member',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets(
      'a disabled dropdown announces the role and the disabled state',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpCustom(tester, enabled: false);

        // No tap or focus action, and no `isEnabled` — but the node must still
        // say it *has* an enabled state, or a screen reader cannot tell a
        // disabled control from a decorative one.
        expect(
          tester.getSemantics(find.text('Face Member')),
          // ignore: deprecated_member_use
          containsSemantics(
            label: 'Face Member',
            isButton: true,
            hasEnabledState: true,
            isEnabled: false,
          ),
        );

        semantics.dispose();
      },
    );

    testWidgets(
      'the multi-select trigger carries it too — one shell, one fix',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpMulti(tester);

        expect(
          tester.getSemantics(find.text('1 selected')),
          // ignore: deprecated_member_use
          containsSemantics(
            label: '1 selected',
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
          ),
        );

        semantics.dispose();
      },
    );
  });

  group('a chosen row says so', () {
    testWidgets('custom mode — only the chosen row is selected', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCustom(tester);
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Member')),
        // ignore: deprecated_member_use
        containsSemantics(
          label: 'Member',
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
        reason: 'the chosen row',
      );

      // The side conditions. A lone positive assertion would also pass if every
      // row were marked selected — which is a bug that looks identical from the
      // chosen row alone.
      for (final unchosen in ['Owner', 'Viewer']) {
        expect(
          tester.getSemantics(find.text(unchosen)),
          // ignore: deprecated_member_use
          containsSemantics(
            label: unchosen,
            hasSelectedState: true,
            isSelected: false,
            hasTapAction: true,
          ),
          reason: '$unchosen is not chosen',
        );
      }

      semantics.dispose();
    });

    testWidgets('text mode — only the chosen row is selected', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpText(tester);
      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      // The trigger shows 'Member' too, so scope the finder to the menu. `Ink`
      // is the row's own surface and appears nowhere else — the menu is not
      // always a `ListView` (three rows fit, so they are laid out in a Column).
      Finder row(String name) =>
          find.descendant(of: find.byType(Ink), matching: find.text(name));

      expect(
        tester.getSemantics(row('Member')),
        // ignore: deprecated_member_use
        containsSemantics(
          label: 'Member',
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(row('Owner')),
        // ignore: deprecated_member_use
        containsSemantics(
          label: 'Owner',
          hasSelectedState: true,
          isSelected: false,
          hasTapAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets(
      'a checklist row stays checked and does not also claim to be selected',
      (tester) async {
        // Guard, not a regression test: `checked` is already emitted (#64/#81).
        // What this pins is that the single-select word did not leak into the
        // checklist — one vocabulary per cardinality.
        final semantics = tester.ensureSemantics();
        await pumpMulti(tester);
        await tester.tap(find.byType(FlutterMultiSelectDropdown<Role>));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.text('Member')),
          // ignore: deprecated_member_use
          containsSemantics(
            label: 'Member',
            hasCheckedState: true,
            isChecked: true,
            isSelected: false,
            hasTapAction: true,
          ),
        );

        semantics.dispose();
      },
    );
  });

  group('what was already right stays right', () {
    testWidgets('the bare anchor keeps the role it already announced', (
      tester,
    ) async {
      // Guard. The bare path has carried `button`/`enabled` since #75; the
      // issue proposed excluding it, which would have deleted working
      // behaviour.
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<Role>(
                items: roles,
                value: member,
                minMenuWidth: 200,
                itemBuilder: (role, isSelected) => Text(role.name),
                anchorBuilder: (context, isOpen) => const Text('Anchor'),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Anchor')),
        // ignore: deprecated_member_use
        containsSemantics(
          label: 'Anchor',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('the merged trigger label survives the added role', (
      tester,
    ) async {
      // Guard for #37: the announced string is the merge of the dropdown's
      // `semanticsLabel` and the current value. Adding a role to that node must
      // not split the node or replace the string.
      final semantics = tester.ensureSemantics();
      await pumpText(tester, semanticsLabel: 'Role picker');

      expect(
        tester.getSemantics(find.text('Member')),
        // ignore: deprecated_member_use
        containsSemantics(
          label: 'Role picker\nMember',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      semantics.dispose();
    });
  });
}
