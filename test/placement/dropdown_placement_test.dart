import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dropdown_button/src/buttons/menu_alignment.dart';
import 'package:flutter_dropdown_button/src/placement/dropdown_placement.dart';

/// A button 40px tall, sitting 100px down a roomy 400x800 screen.
///
/// Leaves 648px of usable space below once the screen margin and the
/// button gap are accounted for, so nothing is ever constrained unless
/// a test deliberately shrinks the screen.
DropdownPlacementInput roomyInput({
  double screenHeight = 800,
  double buttonTop = 100,
  int itemCount = 3,
  double actualItemHeight = 48,
  double maxDropdownHeight = 200,
  double chromeHeight = 0,
  double buttonLeft = 20,
  double? minMenuWidth,
  double? maxMenuWidth,
  MenuAlignment menuAlignment = MenuAlignment.left,
}) {
  return DropdownPlacementInput(
    screenSize: Size(400, screenHeight),
    safeInsetTop: 0,
    safeInsetBottom: 0,
    buttonOffset: Offset(buttonLeft, buttonTop),
    buttonSize: const Size(200, 40),
    itemCount: itemCount,
    actualItemHeight: actualItemHeight,
    maxDropdownHeight: maxDropdownHeight,
    chromeHeight: chromeHeight,
    minMenuWidth: minMenuWidth,
    maxMenuWidth: maxMenuWidth,
    menuAlignment: menuAlignment,
  );
}

void main() {
  group('vertical placement', () {
    test('opens downward when there is room below', () {
      final result = DropdownPlacement.resolve(roomyInput());

      expect(result.openDown, isTrue);
      expect(result.height, 144.0);
      expect(result.top, 144.0);
      expect(result.transformAlignment, Alignment.topCenter);
    });

    test('opens upward when below is too short but above is roomy', () {
      // Button bottom sits at 740, leaving 48px below once margin and gap
      // are taken — not enough for the 144px the three items want. Above
      // the button there are 688 usable pixels.
      final result = DropdownPlacement.resolve(roomyInput(buttonTop: 700));

      expect(result.openDown, isFalse);
      expect(result.height, 144.0);
      expect(result.top, 552.0);
      expect(result.transformAlignment, Alignment.bottomCenter);
    });

    test('shrinks to the larger span when neither side fits', () {
      // 300px screen. Below the button: 128 usable. Above it: 108.
      // The three items want 144, so the menu takes the larger span whole.
      final result = DropdownPlacement.resolve(
        roomyInput(screenHeight: 300, buttonTop: 120),
      );

      expect(result.openDown, isTrue);
      expect(result.height, 128.0);
      expect(result.top, 164.0);
    });

    test('keeps exactly one screen margin below when it shrinks', () {
      final input = roomyInput(screenHeight: 300, buttonTop: 120);
      final result = DropdownPlacement.resolve(input);

      final menuBottom = result.top + result.height;
      final safeBottom =
          input.screenSize.height - input.safeInsetBottom - input.screenMargin;

      expect(menuBottom, safeBottom);
    });
  });

  group('chrome height', () {
    // A search field is 48px of furniture that is not an item. The overlay
    // must grow to hold it, not steal the space from the item list.
    const searchField = 48.0;

    test('grows the overlay to hold the search field', () {
      final result = DropdownPlacement.resolve(
        roomyInput(chromeHeight: searchField),
      );

      expect(result.height, 192.0);
    });

    test('three items with a search field still do not scroll', () {
      final input = roomyInput(itemCount: 3, chromeHeight: searchField);
      final result = DropdownPlacement.resolve(input);

      final contentHeight = result.height - input.chromeHeight;
      final itemsHeight = input.itemCount * input.actualItemHeight;

      expect(contentHeight, greaterThanOrEqualTo(itemsHeight));
    });
  });

  group('minimum visibility', () {
    test('keeps two items visible even when that overruns the margin', () {
      // 200px screen, button bottom at 120. Only 68 usable pixels either
      // side — less than the 96 two items need. Usability wins: the menu
      // takes 96 and knowingly eats into the screen margin.
      final result = DropdownPlacement.resolve(
        roomyInput(screenHeight: 200, buttonTop: 80),
      );

      expect(result.height, 96.0);
    });

    test('reserves room for chrome on top of the minimum items', () {
      final result = DropdownPlacement.resolve(
        roomyInput(screenHeight: 200, buttonTop: 80, chromeHeight: 48),
      );

      expect(result.height, 144.0);
    });
  });

  group('menu width', () {
    test('matches the button when unconstrained', () {
      expect(DropdownPlacement.resolve(roomyInput()).width, 200.0);
    });

    test('grows to minMenuWidth when the button is narrower', () {
      final result = DropdownPlacement.resolve(roomyInput(minMenuWidth: 300));

      expect(result.width, 300.0);
    });

    test('shrinks to maxMenuWidth when the button is wider', () {
      final result = DropdownPlacement.resolve(roomyInput(maxMenuWidth: 150));

      expect(result.width, 150.0);
    });
  });

  group('menu alignment', () {
    test('lines up with the button when the widths match', () {
      expect(DropdownPlacement.resolve(roomyInput(buttonLeft: 20)).left, 20.0);
    });

    test('left alignment keeps the left edges together', () {
      final result = DropdownPlacement.resolve(
        roomyInput(buttonLeft: 50, minMenuWidth: 300),
      );

      expect(result.left, 50.0);
    });

    test('center alignment splits the overhang evenly', () {
      // Menu is 300 wide over a 200 wide button: 100px of overhang, half
      // of it to the left of the button.
      final result = DropdownPlacement.resolve(
        roomyInput(
          buttonLeft: 100,
          minMenuWidth: 300,
          menuAlignment: MenuAlignment.center,
        ),
      );

      expect(result.left, 50.0);
    });

    test('right alignment keeps the right edges together', () {
      final result = DropdownPlacement.resolve(
        roomyInput(
          buttonLeft: 150,
          minMenuWidth: 300,
          menuAlignment: MenuAlignment.right,
        ),
      );

      expect(result.left, 50.0);
    });
  });

  group('screen bounds', () {
    test('pulls the menu back inside the right edge', () {
      // The scenario from issue #1: a 200px button flush against the right
      // of a 400px screen. The menu must slide left to keep its margin.
      final result = DropdownPlacement.resolve(roomyInput(buttonLeft: 250));

      expect(result.left, 192.0);
      expect(result.left + result.width, 392.0);
    });

    test('pushes the menu back inside the left edge', () {
      final result = DropdownPlacement.resolve(roomyInput(buttonLeft: 2));

      expect(result.left, 8.0);
    });
  });
}
