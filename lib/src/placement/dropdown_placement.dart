import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../buttons/menu_alignment.dart';

/// Everything the placement calculation needs, as plain values.
///
/// No [BuildContext], no `MediaQuery`, no `State` — the caller reads those
/// and passes the results in.
class DropdownPlacementInput {
  /// Creates the inputs for a placement calculation.
  const DropdownPlacementInput({
    required this.screenSize,
    required this.safeInsetTop,
    required this.safeInsetBottom,
    required this.buttonOffset,
    required this.buttonSize,
    required this.itemCount,
    required this.actualItemHeight,
    required this.maxDropdownHeight,
    this.chromeHeight = 0.0,
    this.screenMargin = 8.0,
    this.buttonGap = 4.0,
    this.minVisibleItems = 2,
    this.minMenuWidth,
    this.maxMenuWidth,
    this.menuAlignment = MenuAlignment.left,
  });

  /// The full screen size.
  final Size screenSize;

  /// Space reserved at the top of the screen (status bar).
  final double safeInsetTop;

  /// Space reserved at the bottom (navigation bar, home indicator).
  final double safeInsetBottom;

  /// The button's top-left corner in global coordinates.
  final Offset buttonOffset;

  /// The button's size.
  final Size buttonSize;

  /// How many items the menu holds.
  final int itemCount;

  /// The vertical space one item occupies, including its margin.
  final double actualItemHeight;

  /// The tallest the item list may grow, ignoring available space.
  ///
  /// This caps the items, not the overlay: [chromeHeight] and any border or
  /// padding sit on top of it.
  final double maxDropdownHeight;

  /// Vertical space taken by everything in the overlay that is not an item:
  /// the search field, the border, the overlay's own padding.
  ///
  /// The overlay grows by this much rather than surrendering item space, so
  /// enabling search does not force a short list to scroll. Callers sum the
  /// pieces themselves — this module does not care what they are made of.
  final double chromeHeight;

  /// The gap kept between the menu and the edge of the safe area.
  final double screenMargin;

  /// The gap kept between the button and the menu.
  final double buttonGap;

  /// How many items must stay visible when space runs out.
  ///
  /// Honouring this can push the menu past [screenMargin]: a menu too short
  /// to show anything is worse than one that crowds the screen edge.
  final int minVisibleItems;

  /// The narrowest the menu may be, even if the button is narrower.
  final double? minMenuWidth;

  /// The widest the menu may be, even if the button is wider.
  final double? maxMenuWidth;

  /// How the menu lines up with the button when it is the wider of the two.
  final MenuAlignment menuAlignment;

  /// The y coordinate of the button's bottom edge.
  double get buttonBottom => buttonOffset.dy + buttonSize.height;
}

/// Where the menu should be drawn, and how large.
class DropdownPlacementResult {
  /// Creates a placement result.
  const DropdownPlacementResult({
    required this.height,
    required this.openDown,
    required this.transformAlignment,
    required this.top,
    required this.width,
    required this.left,
  });

  /// The width the menu should occupy.
  final double width;

  /// The x coordinate of the menu's left edge.
  final double left;

  /// The height the menu should occupy.
  final double height;

  /// Whether the menu opens below the button rather than above it.
  final bool openDown;

  /// The anchor the open/close animation scales from.
  final Alignment transformAlignment;

  /// The y coordinate of the menu's top edge.
  final double top;
}

/// Resolves where a dropdown menu should be drawn, given plain values.
///
/// The invariant: the menu always keeps [DropdownPlacementInput.screenMargin]
/// between itself and the edge of the safe area, and
/// [DropdownPlacementInput.buttonGap] between itself and the button.
abstract final class DropdownPlacement {
  /// Calculates the menu's placement.
  static DropdownPlacementResult resolve(DropdownPlacementInput input) {
    final width = _resolveWidth(input);
    final preferredHeight =
        math.min(
          input.itemCount * input.actualItemHeight,
          input.maxDropdownHeight,
        ) +
        input.chromeHeight;

    // Both spans already exclude the screen margin and the button gap, so a
    // menu that fits within one of them satisfies the invariant by itself.
    final spaceBelow =
        input.screenSize.height -
        input.safeInsetBottom -
        input.screenMargin -
        input.buttonBottom -
        input.buttonGap;
    final spaceAbove =
        input.buttonOffset.dy -
        input.safeInsetTop -
        input.screenMargin -
        input.buttonGap;

    final double height;
    final bool openDown;
    if (spaceBelow >= preferredHeight) {
      height = preferredHeight;
      openDown = true;
    } else if (spaceAbove >= preferredHeight) {
      height = preferredHeight;
      openDown = false;
    } else {
      // Neither side fits. Take the larger span whole; because the spans
      // already exclude the margin and the gap, no further trimming is needed.
      openDown = spaceBelow >= spaceAbove;
      final available = openDown ? spaceBelow : spaceAbove;

      // Deliberately allowed to exceed the span: see [minVisibleItems].
      final minHeight =
          input.minVisibleItems * input.actualItemHeight + input.chromeHeight;
      height = math.max(available, minHeight);
    }

    return DropdownPlacementResult(
      height: height,
      openDown: openDown,
      transformAlignment:
          openDown ? Alignment.topCenter : Alignment.bottomCenter,
      top:
          openDown
              ? input.buttonBottom + input.buttonGap
              : input.buttonOffset.dy - input.buttonGap - height,
      width: width,
      left: _resolveLeft(input, width),
    );
  }

  static double _resolveWidth(DropdownPlacementInput input) {
    var width = input.buttonSize.width;

    final min = input.minMenuWidth;
    if (min != null && width < min) width = min;

    final max = input.maxMenuWidth;
    if (max != null && width > max) width = max;

    return width;
  }

  static double _resolveLeft(DropdownPlacementInput input, double width) {
    final buttonLeft = input.buttonOffset.dx;
    final overhang = width - input.buttonSize.width;

    double left;
    if (overhang <= 0) {
      left = buttonLeft;
    } else {
      left = switch (input.menuAlignment) {
        MenuAlignment.left => buttonLeft,
        MenuAlignment.center => buttonLeft - overhang / 2,
        MenuAlignment.right => buttonLeft - overhang,
      };
    }

    // Slide back inside the screen. The right edge is corrected first so a
    // menu wider than the screen ends up flush with the left margin.
    final rightLimit = input.screenSize.width - input.screenMargin - width;
    if (left > rightLimit) left = rightLimit;
    if (left < input.screenMargin) left = input.screenMargin;

    return left;
  }
}
