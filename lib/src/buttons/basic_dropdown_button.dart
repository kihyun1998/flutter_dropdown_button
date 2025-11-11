import 'package:flutter/material.dart';

import '../dropdown_item.dart';
import 'base_dropdown_button.dart';

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
class BasicDropdownButton<T> extends BaseDropdownButton<T> {
  /// Creates a basic dropdown button widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  /// All other parameters have sensible defaults but can be customized.
  const BasicDropdownButton({
    super.key,
    required this.items,
    required super.onChanged,
    super.value,
    this.hint,
    super.height = 200.0,
    super.itemHeight = 48.0,
    this.borderRadius = 8.0,
    super.animationDuration = const Duration(milliseconds: 200),
    this.decoration,
    super.width,
    super.maxWidth,
    super.minWidth,
    super.theme,
    super.enabled = true,
    super.scrollToSelectedItem = true,
    super.scrollToSelectedDuration,
    super.expand = false,
    super.trailing,
  });

  /// The list of items to display in the dropdown.
  ///
  /// Each item should have a unique value to ensure proper selection behavior.
  final List<DropdownItem<T>> items;

  /// The widget to display when no item is selected.
  ///
  /// If both [value] and [hint] are null, the dropdown will show
  /// an empty space.
  final Widget? hint;

  /// The border radius for both the dropdown button and overlay.
  ///
  /// Defaults to 8.0 for a modern, rounded appearance.
  final double borderRadius;

  /// Custom decoration for the dropdown overlay.
  ///
  /// If null, a default decoration with theme-appropriate colors
  /// and border will be used. This allows complete customization
  /// of the dropdown appearance including background color,
  /// border, shadow, etc.
  final BoxDecoration? decoration;

  @override
  State<BasicDropdownButton<T>> createState() => _BasicDropdownButtonState<T>();
}

/// The state class for [BasicDropdownButton].
///
/// Manages the dropdown's open/closed state, animations, and overlay positioning.
/// Uses [BaseDropdownButtonState] to provide common dropdown functionality.
class _BasicDropdownButtonState<T>
    extends BaseDropdownButtonState<BasicDropdownButton<T>, T> {
  @override
  double get overlayBorderRadius => widget.borderRadius;

  @override
  BoxDecoration? buildOverlayDecoration() {
    return widget.decoration ?? super.buildOverlayDecoration();
  }

  @override
  BoxDecoration buildButtonDecoration() {
    return BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(widget.borderRadius),
    );
  }

  @override
  Widget buildSelectedWidget() {
    final selectedItem =
        widget.items.where((item) => item.value == widget.value).firstOrNull;
    return selectedItem?.child ?? widget.hint ?? const SizedBox.shrink();
  }

  @override
  Widget buildItemWidget(T item, bool isSelected) {
    final dropdownItem =
        widget.items.firstWhere((dropdownItem) => dropdownItem.value == item);
    return dropdownItem.child;
  }

  @override
  List<T> getItems() {
    return widget.items.map((item) => item.value).toList();
  }

  @override
  void onItemTap(T item) {
    final dropdownItem =
        widget.items.firstWhere((dropdownItem) => dropdownItem.value == item);
    widget.onChanged(item);
    dropdownItem.onTap?.call();
  }
}
