import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// One trigger, one contract — whoever draws the anchor.
///
/// ADR-0001 rule 5: `anchorBuilder` changes what the anchor *looks like*, not
/// what it *is*. Before this, the two paths each held what the other lacked —
/// the chromed one was focusable and keyboard-activatable through its
/// `InkWell`, the bare one announced the button role first (#75) — and neither
/// said whether the menu it toggles was open.
///
/// `isFocusable` is asserted, never the focus *action*: `Focus` emits that only
/// off-iOS (`widgets/focus_scope.dart:723`), so pinning it would pin the host
/// platform. Activation is checked functionally instead, by sending the key.

class Role {
  const Role(this.name);
  final String name;
}

const alpha = Role('Alpha');
const beta = Role('Beta');
const roles = [alpha, beta];

Widget chromed() => MaterialApp(
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

Widget bare() => MaterialApp(
  home: Scaffold(
    body: Center(
      child: FlutterDropdownButton<Role>(
        items: roles,
        minMenuWidth: 200,
        itemBuilder: (role, isSelected) => Text(role.name),
        anchorBuilder: (context, isOpen) => const Text('Anchor'),
        onChanged: (_) {},
      ),
    ),
  ),
);

Widget checklist() => MaterialApp(
  home: Scaffold(
    body: Center(
      child: FlutterMultiSelectDropdown<Role>(
        width: 200,
        items: roles,
        selected: const {},
        label: (role) => role.name,
        labelBuilder: (selected) => '${selected.length} selected',
        onChanged: (_) {},
      ),
    ),
  ),
);

void main() {
  group('the trigger says whether its menu is open', () {
    testWidgets('chromed anchor — collapsed, then expanded', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(chromed());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Pick')),
        // ignore: deprecated_member_use
        containsSemantics(hasExpandedState: true, isExpanded: false),
        reason: 'closed',
      );

      await tester.tap(find.byType(FlutterDropdownButton<Role>));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Pick')),
        // ignore: deprecated_member_use
        containsSemantics(hasExpandedState: true, isExpanded: true),
        reason: 'open — the one thing a caller cannot read for itself',
      );

      semantics.dispose();
    });

    testWidgets('bare anchor — the same, drawn by the caller', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(bare());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Anchor')),
        // ignore: deprecated_member_use
        containsSemantics(hasExpandedState: true, isExpanded: false),
      );

      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Anchor')),
        // ignore: deprecated_member_use
        containsSemantics(hasExpandedState: true, isExpanded: true),
      );

      semantics.dispose();
    });

    testWidgets('the checklist trigger too — one shell', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(checklist());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FlutterMultiSelectDropdown<Role>));
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('0 selected')),
        // ignore: deprecated_member_use
        containsSemantics(hasExpandedState: true, isExpanded: true),
      );

      semantics.dispose();
    });
  });

  group('the bare anchor is a control, not a picture', () {
    testWidgets('it is focusable, like the chromed one', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(bare());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Anchor')),
        // ignore: deprecated_member_use
        containsSemantics(isFocusable: true, isButton: true, isEnabled: true),
      );

      semantics.dispose();
    });

    testWidgets('a keyboard can open it', (tester) async {
      // The functional half. Measured before: a keyboard-only user could not
      // open a bare-anchor dropdown at all, while the chromed path has had
      // Enter/Space since forever through `InkWell`'s `ActivateIntent`.
      await tester.pumpWidget(bare());
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('and the web binding opens it too', (tester) async {
      // On the web, Enter dispatches `ButtonActivateIntent` rather than
      // `ActivateIntent` — `widgets/app.dart:1317`, "On the web, enter
      // activates buttons, but not other controls". `InkWell` binds both for
      // that reason (`ink_well.dart:853-854`) and so does the bare path.
      //
      // `kIsWeb` is a compile-time constant, so a test cannot get the web
      // shortcut map. The binding is invoked directly instead: that is the part
      // this package owns, and the map that reaches it is Flutter's.
      await tester.pumpWidget(bare());
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Anchor'));
      Actions.invoke(context, const ButtonActivateIntent());
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('a disabled bare anchor is not a tab stop', (tester) async {
      // True under `NavigationMode.traditional`, which is the default and what
      // this test runs in. Under `NavigationMode.directional` — a remote or a
      // D-pad — it *is* focusable, deliberately, so the user can land on it and
      // hear that it is unavailable. That is Flutter's switch, not ours:
      // `FocusableActionDetector._canRequestFocus` returns `widget.enabled`
      // traditionally and `true` directionally, and `InkWell` has the identical
      // switch — so both anchor paths agree there too.
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<Role>(
                items: roles,
                enabled: false,
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
        containsSemantics(isFocusable: false, isEnabled: false),
      );

      semantics.dispose();
    });
  });

  group('what must not change', () {
    testWidgets('the chromed anchor keeps its role and enabled state', (
      tester,
    ) async {
      // Guard. Adding `expanded` to the same node must not disturb what #88
      // put there.
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(chromed());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Pick')),
        // ignore: deprecated_member_use
        containsSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
        ),
      );

      semantics.dispose();
    });

    testWidgets('a tap still opens the bare anchor', (tester) async {
      // Guard. Wrapping the gesture in a focus detector must not consume it.
      await tester.pumpWidget(bare());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anchor'));
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
    });
  });
}
