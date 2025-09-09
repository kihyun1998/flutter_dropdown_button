import 'package:flutter/material.dart';

import 'dropdown_item.dart';
import 'dropdown_mixin.dart';
import 'dropdown_theme.dart';

/// A basic dropdown button widget using OverlayEntry for better control.
///
/// This dropdown provides smooth animations, automatic outside-tap dismissal,
/// and complete customization of appearance and behavior. Unlike Flutter's
/// built-in DropdownButton, this widget renders the dropdown options in an
/// overlay, allowing for better positioning and visual effects.
///
/// Example usage:
/// ```dart
/// BasicDropdownButton<String>(
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
class BasicDropdownButton<T> extends StatefulWidget {
  /// Creates a basic dropdown button widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  /// All other parameters have sensible defaults but can be customized.
  const BasicDropdownButton({
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
  State<BasicDropdownButton<T>> createState() => _BasicDropdownButtonState<T>();
}

/// The state class for [BasicDropdownButton].
///
/// Manages the dropdown's open/closed state, animations, and overlay positioning.
/// Uses [DropdownMixin] to provide common dropdown functionality.
class _BasicDropdownButtonState<T> extends State<BasicDropdownButton<T>>
    with SingleTickerProviderStateMixin, DropdownMixin<BasicDropdownButton<T>> {
  // Implement DropdownMixin abstract getters
  @override
  Duration get animationDuration => widget.animationDuration;

  @override
  double get itemHeight => widget.itemHeight;

  @override
  double get maxDropdownHeight => widget.height;

  @override
  int get itemCount => widget.items.length;

  @override
  double get overlayElevation => 8.0;

  @override
  double get overlayBorderRadius => widget.borderRadius;

  @override
  void initState() {
    super.initState();
    initializeDropdown();
  }

  @override
  void dispose() {
    disposeDropdown();
    super.dispose();
  }

  @override
  void onDropdownItemSelected() {
    // This will be called from buildOverlayContent when an item is tapped
    closeDropdown();
  }

  @override
  BoxDecoration? buildOverlayDecoration() {
    return widget.decoration ??
        BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        );
  }

  @override
  Widget buildOverlayContent(double height) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.items.map((item) {
          final isSelected = widget.value == item.value;
          final itemIndex = widget.items.indexOf(item);
          final isFirst = itemIndex == 0;
          final isLast = itemIndex == widget.items.length - 1;

          final dropdownTheme = widget.theme ?? DropdownTheme.defaultTheme;

          return Material(
            color: Colors.transparent,
            child: Container(
              margin: dropdownTheme.itemMargin,
              child: InkWell(
                onTap: () {
                  // Call both callbacks and close dropdown
                  widget.onChanged(item.value);
                  item.onTap?.call();
                  onDropdownItemSelected();
                },
                // Custom splash and highlight colors from theme
                splashColor: dropdownTheme.itemSplashColor ??
                    Theme.of(context).splashColor,
                highlightColor: dropdownTheme.itemHighlightColor ??
                    Theme.of(context).highlightColor,
                hoverColor: dropdownTheme.itemHoverColor ??
                    Theme.of(context).hoverColor,
                // Apply item-specific border radius if provided, otherwise use overlay radius for edges
                borderRadius:
                    BorderRadius.circular(dropdownTheme.itemBorderRadius ??
                        (isFirst
                            ? widget.borderRadius
                            : isLast
                                ? widget.borderRadius
                                : 0.0)),
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
                    // Apply item-specific border radius if provided
                    borderRadius: dropdownTheme.itemBorderRadius != null
                        ? BorderRadius.circular(dropdownTheme.itemBorderRadius!)
                        : null,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: item.child,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find the currently selected item to display
    final selectedItem =
        widget.items.where((item) => item.value == widget.value).firstOrNull;

    Widget dropdownButton = GestureDetector(
      key: dropdownButtonKey,
      onTap: toggleDropdown,
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
              isDropdownOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
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
