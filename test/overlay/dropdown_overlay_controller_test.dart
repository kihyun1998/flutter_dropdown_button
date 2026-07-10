import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The controller is a plain object. Constructing and driving it needs a
/// ticker, nothing more — no `State`, no widget tree, no `pumpWidget`.
DropdownOverlayController makeController({
  ValueChanged<bool>? onOpenStateChanged,
}) {
  return DropdownOverlayController(
    vsync: const TestVSync(),
    spec: () => const DropdownOverlaySpec(
      itemCount: 3,
      actualItemHeight: 48,
      maxDropdownHeight: 200,
    ),
    contentBuilder: (_) => const SizedBox.shrink(),
    decorationBuilder: () => null,
    onOpenStateChanged: onOpenStateChanged,
  );
}

void main() {
  test('a fresh controller is closed', () {
    final controller = makeController();
    addTearDown(controller.dispose);

    expect(controller.isOpen, isFalse);
  });

  test('closing a closed controller is a no-op', () {
    var notifications = 0;
    final controller = makeController(
      onOpenStateChanged: (_) => ++notifications,
    );
    addTearDown(controller.dispose);

    controller.close();

    expect(controller.isOpen, isFalse);
    expect(notifications, 0);
  });

  test('rebuild on a closed controller does nothing', () {
    final controller = makeController();
    addTearDown(controller.dispose);

    expect(controller.rebuild, returnsNormally);
  });

  test('measuring without an open menu yields no placement', () {
    final controller = makeController();
    addTearDown(controller.dispose);

    expect(controller.measurePlacement(), isNull);
  });

  test('closeAll with nothing open is a no-op', () {
    expect(DropdownOverlayController.closeAll, returnsNormally);
  });

  test('disposing does not notify the owner', () {
    var notifications = 0;
    final controller = makeController(
      onOpenStateChanged: (_) => ++notifications,
    );

    controller.dispose();

    expect(notifications, 0);
  });

  test('the spec sums everything that is not an item', () {
    const spec = DropdownOverlaySpec(
      itemCount: 3,
      actualItemHeight: 48,
      maxDropdownHeight: 200,
      chromeHeight: 48, // search field
      borderThickness: 2,
      overlayPadding: EdgeInsets.symmetric(vertical: 4),
    );

    expect(spec.totalChromeHeight, 58);
  });
}
