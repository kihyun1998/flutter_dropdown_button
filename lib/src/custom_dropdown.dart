import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dropdown_item.dart';
import 'dropdown_theme.dart';

/// A highly customizable dropdown widget using OverlayEntry for better control.
///
/// This dropdown provides smooth animations, automatic outside-tap dismissal,
/// and complete customization of appearance and behavior. Unlike Flutter's
/// built-in DropdownButton, this widget renders the dropdown options in an
/// overlay, allowing for better positioning and visual effects.
///
/// Example usage:
/// ```dart
/// CustomDropdown<String>(
///   items: [
///     DropdownItem(
///       value: 'apple',
///       child: Text('Apple'),
///     ),
///     DropdownItem(
///       value: 'banana',
///       child: Text('Banana'),
///     ),
///   ],
///   value: selectedValue,
///   hint: Text('Select a fruit'),
///   onChanged: (value) {
///     setState(() {
///       selectedValue = value;
///     });
///   },
/// )
/// ```
class CustomDropdown<T> extends StatefulWidget {
  /// Creates a custom dropdown widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  /// All other parameters have sensible defaults but can be customized.
  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.borderRadius = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.decoration,
    this.width,
    this.maxWidth,
    this.minWidth,
    this.theme,
  });

  /// The list of items to display in the dropdown.
  ///
  /// Each item should have a unique value to ensure proper selection behavior.
  final List<DropdownItem<T>> items;

  /// Called when the user selects an item from the dropdown.
  ///
  /// The callback receives the value of the selected item, or null if
  /// no item is selected.
  final ValueChanged<T?> onChanged;

  /// The currently selected value.
  ///
  /// If this value is not null and matches one of the item values,
  /// that item will be highlighted in the dropdown and displayed
  /// as the current selection.
  final T? value;

  /// The widget to display when no item is selected.
  ///
  /// If both [value] and [hint] are null, the dropdown will show
  /// an empty space.
  final Widget? hint;

  /// The maximum height of the dropdown overlay.
  ///
  /// If the content exceeds this height, the dropdown becomes scrollable.
  /// Defaults to 200.0.
  final double height;

  /// The height of each individual dropdown item.
  ///
  /// All items will have the same height for consistent appearance.
  /// Defaults to 48.0.
  final double itemHeight;

  /// The border radius for both the dropdown button and overlay.
  ///
  /// Defaults to 8.0 for a modern, rounded appearance.
  final double borderRadius;

  /// The duration of the dropdown show/hide animation.
  ///
  /// The dropdown uses a combination of scale and opacity animations.
  /// Defaults to 200 milliseconds.
  final Duration animationDuration;

  /// Custom decoration for the dropdown overlay.
  ///
  /// If null, a default decoration with theme-appropriate colors
  /// and border will be used. This allows complete customization
  /// of the dropdown appearance including background color,
  /// border, shadow, etc.
  final BoxDecoration? decoration;

  /// The width of the dropdown button and overlay.
  ///
  /// If null, the dropdown will size itself to fit its content
  /// within the constraints of [minWidth] and [maxWidth].
  /// If specified, both the button and overlay will have this fixed width.
  final double? width;

  /// The maximum width of the dropdown button and overlay.
  ///
  /// When [width] is null, the dropdown will size itself based on content
  /// but will not exceed this maximum width. If content is longer,
  /// it will be ellipsized or wrapped depending on the child widget.
  ///
  /// If null, no maximum width constraint is applied.
  final double? maxWidth;

  /// The minimum width of the dropdown button and overlay.
  ///
  /// When [width] is null, the dropdown will size itself based on content
  /// but will be at least this wide. Useful for ensuring consistent
  /// minimum button size regardless of content length.
  ///
  /// Defaults to null (no minimum width constraint).
  final double? minWidth;

  /// Custom theme configuration for the dropdown appearance and behavior.
  ///
  /// If null, uses [DropdownTheme.defaultTheme] with theme-appropriate colors.
  /// Allows customization of colors, animations, and interaction effects.
  final DropdownTheme? theme;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

/// The state class for [CustomDropdown].
///
/// Manages the dropdown's open/closed state, animations, and overlay positioning.
/// Uses [SingleTickerProviderStateMixin] to provide animation ticker functionality.
class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  /// Global key to access the dropdown button's render object for positioning.
  final GlobalKey _buttonKey = GlobalKey();

  /// The overlay entry that contains the dropdown options when open.
  OverlayEntry? _overlayEntry;

  /// Whether the dropdown is currently open.
  bool _isOpen = false;

  /// Controls the dropdown show/hide animations.
  late AnimationController _animationController;

  /// Animation for the dropdown scale effect (grows from 0.8 to 1.0).
  late Animation<double> _scaleAnimation;

  /// Animation for the dropdown opacity (fades from 0.0 to 1.0).
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with the specified duration
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Create a scale animation that starts at 0.8 and grows to 1.0
    // Uses easeOutBack curve for a slight bounce effect
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Create an opacity animation that fades from 0.0 to 1.0
    // Uses easeOut curve for smooth fade-in effect
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    // Ensure the dropdown is closed and resources are cleaned up
    _closeDropdown();
    _animationController.dispose();
    super.dispose();
  }

  /// Toggles the dropdown between open and closed states.
  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  /// Opens the dropdown by creating and inserting an overlay entry.
  ///
  /// Calculates the position based on the dropdown button's location
  /// and starts the opening animation.
  void _openDropdown() {
    if (_isOpen) return;

    // Get the dropdown button's position and size for overlay positioning
    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Create and insert the overlay entry
    _overlayEntry = _createOverlayEntry(offset, size);
    Overlay.of(context).insert(_overlayEntry!);

    _isOpen = true;
    _animationController.forward();
  }

  /// Closes the dropdown by reversing the animation and removing the overlay.
  ///
  /// The overlay entry is removed after the animation completes to ensure
  /// smooth visual transition.
  void _closeDropdown() {
    if (!_isOpen) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    });
  }

  /// Creates the overlay entry that contains the dropdown options.
  ///
  /// The overlay is positioned optimally based on available screen space and includes:
  /// - A full-screen gesture detector to handle outside taps
  /// - Animated appearance with scale and opacity effects
  /// - Scrollable list of dropdown items
  /// - Smart positioning (above or below button) based on available space
  /// - Dynamic height adjustment to prevent overflow
  /// - Theme-appropriate styling and colors
  ///
  /// [offset] is the global position of the dropdown button
  /// [size] is the size of the dropdown button for positioning
  OverlayEntry _createOverlayEntry(Offset offset, Size size) {
    // Calculate available space for smart positioning
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - (offset.dy + size.height + 8);
    final spaceAbove = offset.dy - 8;
    
    // Calculate dynamic preferred height based on items
    final totalItemsHeight = widget.items.length * widget.itemHeight;
    final preferredHeight = math.min(totalItemsHeight, widget.height);
    
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
        menuHeight = spaceBelow - 8; // Extra margin for safety
        openDown = true;
        transformAlignment = Alignment.topCenter;
      } else {
        menuHeight = spaceAbove - 8;
        openDown = false;
        transformAlignment = Alignment.bottomCenter;
      }
      
      // Ensure minimum height for usability (show at least 2 items)
      final minItemsVisible = 2;
      final minHeight = minItemsVisible * widget.itemHeight;
      menuHeight = math.max(menuHeight, minHeight);
    }
    
    return OverlayEntry(
      builder: (context) => GestureDetector(
        // Detect taps outside the dropdown to close it
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: openDown 
                    ? offset.dy + size.height + 4 // 4px gap below button
                    : offset.dy - menuHeight - 4,  // 4px gap above button
                width: widget.width ?? size.width,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: transformAlignment,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius,
                          ),
                          child: Container(
                            height: menuHeight,
                            constraints: BoxConstraints(
                              minWidth: widget.minWidth ?? 0,
                              maxWidth: widget.maxWidth ?? double.infinity,
                            ),
                            decoration: widget.decoration ??
                                BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    widget.borderRadius,
                                  ),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.items.map((item) {
                                  final isSelected = widget.value == item.value;
                                  final itemIndex = widget.items.indexOf(item);
                                  final isFirst = itemIndex == 0;
                                  final isLast =
                                      itemIndex == widget.items.length - 1;

                                  final dropdownTheme = widget.theme ?? DropdownTheme.defaultTheme;
                                  
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // Call both callbacks and close dropdown
                                        widget.onChanged(item.value);
                                        item.onTap?.call();
                                        _closeDropdown();
                                      },
                                      // Custom splash and highlight colors from theme
                                      splashColor: dropdownTheme.itemSplashColor ?? 
                                          Theme.of(context).splashColor,
                                      highlightColor: dropdownTheme.itemHighlightColor ?? 
                                          Theme.of(context).highlightColor,
                                      hoverColor: dropdownTheme.itemHoverColor ??
                                          Theme.of(context).hoverColor,
                                      // Apply border radius for ripple effect clipping
                                      borderRadius: isFirst
                                          ? BorderRadius.only(
                                              topLeft: Radius.circular(
                                                widget.borderRadius,
                                              ),
                                              topRight: Radius.circular(
                                                widget.borderRadius,
                                              ),
                                            )
                                          : isLast
                                              ? BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    widget.borderRadius,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    widget.borderRadius,
                                                  ),
                                                )
                                              : null,
                                      child: Container(
                                        height: widget.itemHeight,
                                        width: double.infinity,
                                        padding: dropdownTheme.itemPadding,
                                        decoration: BoxDecoration(
                                          // Highlight selected item with theme or primary color
                                          color: isSelected
                                              ? dropdownTheme.selectedItemColor ??
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: item.child,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    // Find the currently selected item to display
    final selectedItem =
        widget.items.where((item) => item.value == widget.value).firstOrNull;

    Widget dropdownButton = GestureDetector(
      key: _buttonKey,
      onTap: _toggleDropdown,
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize:
              widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Show selected item, hint, or nothing
            Flexible(
              child:
                  selectedItem?.child ?? widget.hint ?? const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            // Arrow icon that rotates based on open/closed state
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );

    // Apply width constraints if specified
    if (widget.width == null &&
        (widget.minWidth != null || widget.maxWidth != null)) {
      dropdownButton = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? 0,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: dropdownButton,
      );
    }

    return dropdownButton;
  }
}
