import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// positioningKey (#86): the menu measures against an outer box the caller
/// wraps around the whole field, instead of the interactive anchor.
///
/// A compact `[All ▾]` anchor lives at the head of a 300-wide field. With no
/// positioningKey the menu measures the anchor (its small width, its own left).
/// With positioningKey pointed at the field the same menu drops below the whole
/// field, left-aligns to it, and defaults to its width — with no change to the
/// pure placement engine, only to which RenderBox is measured.

/// The whole field: a 300-wide keyed box holding a compact anchor at its head.
///
/// Pinned to a known origin (top-left + 100 padding) so placement can be
/// asserted against the field's own rect.
class FieldHost extends StatelessWidget {
  const FieldHost({
    super.key,
    required this.fieldKey,
    required this.usePositioningKey,
    this.multiSelect = false,
  });

  final GlobalKey fieldKey;
  final bool usePositioningKey;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    final key = usePositioningKey ? fieldKey : null;

    final Widget dropdown = multiSelect
        ? FlutterMultiSelectDropdown<String>(
            items: const ['Apple', 'Banana', 'Cherry'],
            selected: const {'Apple'},
            onChanged: (_) {},
            labelBuilder: (s) => s.isEmpty ? 'All' : '${s.length}',
            anchorBuilder: (context, isOpen) => const Text('All ▾'),
            positioningKey: key,
          )
        : FlutterDropdownButton<String>.text(
            items: const ['Apple', 'Banana', 'Cherry'],
            value: 'Apple',
            onChanged: (_) {},
            anchorBuilder: (context, isOpen) => const Text('All ▾'),
            positioningKey: key,
          );

    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(100),
            child: SizedBox(
              key: fieldKey,
              width: 300,
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  dropdown,
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The single Positioned the menu is drawn into, inside the overlay.
Positioned menuPositioned(WidgetTester tester) => tester.widget<Positioned>(
  find.descendant(of: find.byType(Overlay), matching: find.byType(Positioned)),
);

void main() {
  testWidgets(
    'CONTROL: without positioningKey the menu measures the compact anchor',
    (tester) async {
      final fieldKey = GlobalKey();
      await tester.pumpWidget(
        FieldHost(fieldKey: fieldKey, usePositioningKey: false),
      );
      await tester.tap(find.text('All ▾'));
      await tester.pumpAndSettle();

      final anchorWidth = tester.getSize(find.text('All ▾')).width;
      final p = menuPositioned(tester);

      expect(
        p.width,
        anchorWidth,
        reason: 'menu takes the compact anchor width, not the field width',
      );
      expect(
        p.width,
        lessThan(300),
        reason: 'and it is far short of the field',
      );
    },
  );

  testWidgets(
    'positioningKey positions and sizes the menu to the whole field',
    (tester) async {
      final fieldKey = GlobalKey();
      await tester.pumpWidget(
        FieldHost(fieldKey: fieldKey, usePositioningKey: true),
      );
      await tester.tap(find.text('All ▾'));
      await tester.pumpAndSettle();

      final field = tester.getRect(find.byKey(fieldKey));
      final p = menuPositioned(tester);

      expect(
        p.width,
        field.width,
        reason: 'menu matches the field width (300)',
      );
      expect(p.left, field.left, reason: 'menu left-aligns to the field');
      expect(
        p.top,
        field.bottom + 4,
        reason: 'menu drops below the whole field (buttonGap 4)',
      );
    },
  );

  testWidgets('the anchor still measures below itself, not the field', (
    tester,
  ) async {
    // The control's menu drops below the anchor's own bottom, which — because
    // the anchor is centred in a taller field — sits above the field bottom.
    // This is the exact difference positioningKey erases.
    final fieldKey = GlobalKey();
    await tester.pumpWidget(
      FieldHost(fieldKey: fieldKey, usePositioningKey: false),
    );
    await tester.tap(find.text('All ▾'));
    await tester.pumpAndSettle();

    final field = tester.getRect(find.byKey(fieldKey));
    final p = menuPositioned(tester);

    expect(
      p.top,
      lessThan(field.bottom + 4),
      reason: 'without the key the menu hangs off the anchor, mid-field',
    );
  });

  testWidgets('positioningKey is honoured when toggled on at runtime', (
    tester,
  ) async {
    // Proves the controller's positioningKey is mutable: the same shell State
    // (and its controller) is reused across the rebuild, and build() reassigns
    // the key. Were it fixed at construction, the second open would still
    // measure the anchor.
    final fieldKey = GlobalKey();

    await tester.pumpWidget(
      FieldHost(fieldKey: fieldKey, usePositioningKey: false),
    );
    await tester.tap(find.text('All ▾'));
    await tester.pumpAndSettle();
    expect(menuPositioned(tester).width, lessThan(300), reason: 'anchor first');

    // Close, then rebuild the same tree with the key switched on.
    await tester.tap(find.text('All ▾'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      FieldHost(fieldKey: fieldKey, usePositioningKey: true),
    );

    await tester.tap(find.text('All ▾'));
    await tester.pumpAndSettle();
    final field = tester.getRect(find.byKey(fieldKey));
    expect(
      menuPositioned(tester).width,
      field.width,
      reason: 'the reassigned key now drives placement',
    );
  });

  testWidgets('positioningKey composes with the multi-select checklist', (
    tester,
  ) async {
    final fieldKey = GlobalKey();
    await tester.pumpWidget(
      FieldHost(fieldKey: fieldKey, usePositioningKey: true, multiSelect: true),
    );
    await tester.tap(find.text('All ▾'));
    await tester.pumpAndSettle();

    final field = tester.getRect(find.byKey(fieldKey));
    expect(
      menuPositioned(tester).width,
      field.width,
      reason: 'the checklist menu also measures the field',
    );
  });
}
