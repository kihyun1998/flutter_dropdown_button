import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'menu_alignment.dart';

/// Position calculation result for dropdown overlay positioning.
class DropdownPositionResult {
  /// Creates a position result with calculated values.
  const DropdownPositionResult({
    required this.height,
    required this.openDown,
    required this.transformAlignment,
    required this.topPosition,
  });

  /// The calculated height for the dropdown overlay.
  final double height;

  /// Whether the dropdown should open downward (true) or upward (false).
  final bool openDown;

  /// The transform alignment for animations.
  final Alignment transformAlignment;

  /// The calculated top position for the overlay.
  final double topPosition;
}

/// A mixin that provides common dropdown functionality including positioning,
/// animations, and overlay management.
///
/// This mixin eliminates code duplication between different dropdown variants
/// by providing shared functionality for:
/// - Smart positioning based on available screen space
/// - Animation setup and management
/// - Overlay entry creation and lifecycle
/// - Common state management
///
/// Usage:
/// ```dart
/// class _MyDropdownState extends State<MyDropdown>
///     with SingleTickerProviderStateMixin, DropdownMixin<MyDropdown> {
///
///   @override
///   Widget buildOverlayContent(double height) {
///     return Container(height: height, child: ListView(...));
///   }
///
///   @override
///   Duration get animationDuration => Duration(milliseconds: 200);
///   // ... other required implementations
/// }
/// ```
mixin DropdownMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  /// Global key to access the dropdown button's render object for positioning.
  final GlobalKey dropdownButtonKey = GlobalKey();

  /// The overlay entry that contains the dropdown options when open.
  OverlayEntry? _overlayEntry;

  /// Tracks the currently open dropdown overlay for manual cleanup.
  /// Only one dropdown can be open at a time due to overlay behavior.
  static OverlayEntry? _currentOverlay;

  /// Whether the dropdown is currently open.
  bool get isDropdownOpen => _overlayEntry != null;

  /// Controls the dropdown show/hide animations.
  late AnimationController dropdownAnimationController;

  /// Animation for the dropdown scale effect (grows from 0.8 to 1.0).
  late Animation<double> dropdownScaleAnimation;

  /// Animation for the dropdown opacity (fades from 0.0 to 1.0).
  late Animation<double> dropdownOpacityAnimation;

  /// Animation for the dropdown icon rotation (rotates 180 degrees).
  late Animation<double> dropdownIconRotationAnimation;

  // Abstract getters that must be implemented by the using class

  /// The duration of the dropdown animations.
  Duration get animationDuration;

  /// The height of each individual dropdown item.
  double get itemHeight;

  /// The actual height of each dropdown item including margins.
  ///
  /// This should return the total vertical space each item occupies,
  /// including any margins applied to the item.
  double get actualItemHeight;

  /// The maximum height of the dropdown overlay.
  double get maxDropdownHeight;

  /// The number of items in the dropdown.
  int get itemCount;

  /// Whether the dropdown is enabled for interaction.
  bool get isEnabled => true;

  /// Additional margin from screen edges for safety.
  double get screenMargin => 8.0;

  /// Gap between button and dropdown overlay.
  double get buttonGap => 4.0;

  /// Minimum number of visible items when space is constrained.
  int get minVisibleItems => 2;

  /// The elevation of the dropdown overlay Material.
  double get overlayElevation => 8.0;

  /// The border radius for the dropdown overlay.
  double get overlayBorderRadius => 8.0;

  /// The total vertical border thickness (top + bottom) for the dropdown overlay.
  ///
  /// This is used to calculate the available content height within the overlay.
  /// Returns 0.0 if no border is applied.
  double get overlayBorderThickness => 0.0;

  /// The shadow color for the dropdown overlay Material.
  Color? get overlayShadowColor => null;

  /// The padding applied to the dropdown overlay container.
  ///
  /// This padding creates internal spacing between the overlay edges
  /// and the item list. If null, no padding is applied.
  EdgeInsets? get overlayPadding => null;

  /// The minimum width of the dropdown menu overlay.
  ///
  /// When set, the menu will be at least this wide even if the button
  /// is narrower. If null, the menu width matches the button width.
  double? get minMenuWidth => null;

  /// The maximum width of the dropdown menu overlay.
  ///
  /// When set, the menu will not exceed this width even if the button
  /// is wider. If null, no maximum width constraint is applied.
  double? get maxMenuWidth => null;

  /// The alignment of the menu relative to the button when wider.
  ///
  /// This only applies when the menu is wider than the button.
  /// Defaults to [MenuAlignment.left].
  MenuAlignment get menuAlignment => MenuAlignment.left;

  // Abstract methods that must be implemented by the using class

  /// Builds the content of the dropdown overlay with the given height.
  ///
  /// This method should return the scrollable content that will be displayed
  /// inside the dropdown overlay. The [height] parameter specifies the
  /// calculated optimal height for the overlay.
  Widget buildOverlayContent(double height);

  /// Builds the decoration for the dropdown overlay container.
  ///
  /// Return null to use the default theme-based decoration.
  BoxDecoration? buildOverlayDecoration();

  /// Called when an item is selected from the dropdown.
  ///
  /// Implementations should handle the selection logic and call
  /// [closeDropdown] to close the overlay.
  void onDropdownItemSelected();

  /// Initializes the dropdown animations and controllers.
  ///
  /// This should be called in the [initState] method of the using class.
  void initializeDropdown() {
    dropdownAnimationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );

    dropdownScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: dropdownAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    dropdownOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: dropdownAnimationController,
        curve: Curves.easeOut,
      ),
    );

    dropdownIconRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: dropdownAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Disposes of the dropdown resources.
  ///
  /// This should be called in the [dispose] method of the using class.
  void disposeDropdown() {
    // Immediately remove overlay without animation when disposing
    // to prevent overlay from remaining after screen transitions
    if (_overlayEntry != null) {
      // Clear the tracked overlay if it matches before removing
      if (_currentOverlay == _overlayEntry) {
        _currentOverlay = null;
      }

      try {
        if (_overlayEntry != null) {
          _overlayEntry!.remove();
        }
      } catch (e) {
        // Overlay may have already been removed, ignore the error
      } finally {
        _overlayEntry = null;
      }
    }
    dropdownAnimationController.dispose();
  }

  /// Closes all currently open dropdowns immediately without animation.
  ///
  /// This is useful when you need to manually close any open dropdown
  /// before performing a navigation or other action. Since only one
  /// dropdown can be open at a time, this removes that single overlay.
  ///
  /// Example usage:
  /// ```dart
  /// // Close any open dropdown before navigation
  /// DropdownMixin.closeAll();
  /// Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  /// ```
  ///
  /// Note: This removes the overlay immediately without animation,
  /// similar to the behavior in [disposeDropdown].
  static void closeAll() {
    if (_currentOverlay != null) {
      try {
        _currentOverlay!.remove();
      } catch (e) {
        // Overlay may have already been removed, ignore the error
      } finally {
        _currentOverlay = null;
      }
    }
  }

  /// Toggles the dropdown between open and closed states.
  void toggleDropdown() {
    if (!isEnabled) return;

    if (isDropdownOpen) {
      closeDropdown();
    } else {
      openDropdown();
    }
  }

  /// Opens the dropdown by creating and inserting an overlay entry.
  void openDropdown() {
    if (isDropdownOpen || !isEnabled) return;

    final renderBox =
        dropdownButtonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonSize = renderBox.size;
    final buttonOffset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(buttonOffset, buttonSize);
    Overlay.of(context).insert(_overlayEntry!);

    // Track the current overlay for manual cleanup via closeAll()
    _currentOverlay = _overlayEntry;

    dropdownAnimationController.forward();

    // Update UI to reflect dropdown state change
    if (mounted) {
      setState(() {});
    }
  }

  /// Closes the dropdown by reversing the animation and removing the overlay.
  void closeDropdown() {
    if (!isDropdownOpen) return;

    dropdownAnimationController.reverse().then((_) {
      // Clear the tracked overlay if it matches before removing
      if (_currentOverlay == _overlayEntry) {
        _currentOverlay = null;
      }

      _overlayEntry?.remove();
      _overlayEntry = null;

      // Update UI to reflect dropdown state change
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// Calculates the optimal position and height for the dropdown overlay.
  ///
  /// This method performs smart positioning based on available screen space:
  /// - Prefers to open downward if there's sufficient space
  /// - Falls back to opening upward if there's more space above
  /// - Adjusts height dynamically when space is constrained
  /// - Ensures minimum visibility of items
  DropdownPositionResult calculateDropdownPosition(
    Offset buttonOffset,
    Size buttonSize,
  ) {
    // Calculate available space for smart positioning
    // Account for safe areas (status bar, navigation bar, home indicator)
    // On desktop platforms, these padding values are 0.0
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top; // status bar
    final bottomPadding =
        mediaQuery.padding.bottom; // navigation bar / home indicator

    final spaceBelow = screenHeight -
        bottomPadding -
        (buttonOffset.dy + buttonSize.height + screenMargin);
    final spaceAbove = buttonOffset.dy - topPadding - screenMargin;

    // Calculate dynamic preferred height based on items with actual item heights
    final totalItemsHeight = itemCount * actualItemHeight;
    // Calculate total overlay padding
    final overlayPaddingVertical = overlayPadding != null
        ? (overlayPadding!.top + overlayPadding!.bottom)
        : 0.0;
    // Add border thickness and overlay padding to ensure enough space for content + border + padding
    final preferredHeight = math.min(totalItemsHeight, maxDropdownHeight) +
        overlayBorderThickness +
        overlayPaddingVertical;

    // Determine positioning and height
    double menuHeight;
    bool openDown;
    Alignment transformAlignment;

    if (spaceBelow >= preferredHeight) {
      // Sufficient space below - open downward
      menuHeight = preferredHeight;
      openDown = true;
      transformAlignment = Alignment.topCenter;
    } else if (spaceAbove >= preferredHeight) {
      // Sufficient space above - open upward
      menuHeight = preferredHeight;
      openDown = false;
      transformAlignment = Alignment.bottomCenter;
    } else {
      // Insufficient space in both directions - choose the larger space
      if (spaceBelow >= spaceAbove) {
        menuHeight = spaceBelow - screenMargin; // Extra margin for safety
        openDown = true;
        transformAlignment = Alignment.topCenter;
      } else {
        menuHeight = spaceAbove - screenMargin;
        openDown = false;
        transformAlignment = Alignment.bottomCenter;
      }

      // Ensure minimum height for usability with actual item heights + border + padding
      final minHeight = minVisibleItems * actualItemHeight +
          overlayBorderThickness +
          overlayPaddingVertical;
      menuHeight = math.max(menuHeight, minHeight);
    }

    final topPosition = openDown
        ? buttonOffset.dy + buttonSize.height + buttonGap
        : buttonOffset.dy - menuHeight - buttonGap;

    return DropdownPositionResult(
      height: menuHeight,
      openDown: openDown,
      transformAlignment: transformAlignment,
      topPosition: topPosition,
    );
  }

  /// Calculates the effective width for the dropdown menu.
  ///
  /// Applies [minMenuWidth] and [maxMenuWidth] constraints to the button width.
  /// Returns a width between minMenuWidth and maxMenuWidth, preferring buttonWidth.
  double calculateMenuWidth(double buttonWidth) {
    double menuWidth = buttonWidth;

    // Apply minMenuWidth if provided
    if (minMenuWidth != null && menuWidth < minMenuWidth!) {
      menuWidth = minMenuWidth!;
    }

    // Apply maxMenuWidth if provided
    if (maxMenuWidth != null && menuWidth > maxMenuWidth!) {
      menuWidth = maxMenuWidth!;
    }

    return menuWidth;
  }

  /// Calculates the left position for the dropdown menu based on alignment.
  ///
  /// When the menu is wider than the button, aligns according to [menuAlignment]:
  /// - [MenuAlignment.left]: Left edges align
  /// - [MenuAlignment.center]: Centers menu over button
  /// - [MenuAlignment.right]: Right edges align
  ///
  /// Also ensures the menu stays within screen bounds.
  double calculateMenuLeftPosition(
    double buttonLeft,
    double buttonWidth,
    double menuWidth,
  ) {
    double leftPosition;

    // Calculate initial position based on alignment
    if (menuWidth <= buttonWidth) {
      // Menu is not wider than button, use button position
      leftPosition = buttonLeft;
    } else {
      // Menu is wider than button, apply alignment
      final widthDiff = menuWidth - buttonWidth;

      switch (menuAlignment) {
        case MenuAlignment.left:
          // Left edges align: menu extends to the right
          leftPosition = buttonLeft;
          break;

        case MenuAlignment.center:
          // Center menu over button
          leftPosition = buttonLeft - (widthDiff / 2);
          break;

        case MenuAlignment.right:
          // Right edges align: menu extends to the left
          leftPosition = buttonLeft - widthDiff;
          break;
      }
    }

    // Ensure menu stays within screen bounds
    final screenWidth = MediaQuery.of(context).size.width;
    final rightEdge = leftPosition + menuWidth;

    // Check right edge overflow
    if (rightEdge > screenWidth - screenMargin) {
      leftPosition = screenWidth - screenMargin - menuWidth;
    }

    // Check left edge overflow
    if (leftPosition < screenMargin) {
      leftPosition = screenMargin;
    }

    return leftPosition;
  }

  /// Creates the overlay entry that contains the dropdown options.
  OverlayEntry _createOverlayEntry(Offset buttonOffset, Size buttonSize) {
    final position = calculateDropdownPosition(buttonOffset, buttonSize);
    final menuWidth = calculateMenuWidth(buttonSize.width);
    final leftPosition = calculateMenuLeftPosition(
      buttonOffset.dx,
      buttonSize.width,
      menuWidth,
    );

    return OverlayEntry(
      builder: (context) => GestureDetector(
        // Detect taps outside the dropdown to close it
        onTap: closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                left: leftPosition,
                top: position.topPosition,
                width: menuWidth,
                child: AnimatedBuilder(
                  animation: dropdownAnimationController,
                  // Build overlay content once and reuse it during animation
                  child: Material(
                    elevation: overlayElevation,
                    shadowColor: overlayShadowColor,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(overlayBorderRadius),
                    child: Container(
                      height: position.height,
                      decoration: buildOverlayDecoration() ??
                          BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(overlayBorderRadius),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                      child: buildOverlayContent(position.height),
                    ),
                  ),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: dropdownScaleAnimation.value,
                      alignment: position.transformAlignment,
                      child: Opacity(
                        opacity: dropdownOpacityAnimation.value,
                        child: child,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
