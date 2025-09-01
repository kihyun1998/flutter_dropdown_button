import 'package:flutter/material.dart';

/// Represents an item in a [CustomDropdown].
///
/// Each dropdown item contains a value of type [T], a child widget to display,
/// and an optional tap callback for custom behavior when the item is selected.
///
/// Example:
/// ```dart
/// DropdownItem<String>(
///   value: 'apple',
///   child: Row(
///     children: [
///       Icon(Icons.apple, color: Colors.red),
///       SizedBox(width: 8),
///       Text('Apple'),
///     ],
///   ),
///   onTap: () => print('Apple selected!'),
/// )
/// ```
class DropdownItem<T> {
  /// Creates a dropdown item.
  ///
  /// The [value] and [child] parameters are required.
  /// The [onTap] callback is optional and will be called when the item is selected,
  /// in addition to the dropdown's [CustomDropdown.onChanged] callback.
  const DropdownItem({
    required this.value,
    required this.child,
    this.onTap,
  });

  /// The value associated with this dropdown item.
  ///
  /// This value will be passed to the [CustomDropdown.onChanged] callback
  /// when the item is selected. It should be unique among all items in the dropdown.
  final T value;

  /// The widget to display for this dropdown item.
  ///
  /// This can be any widget, allowing for custom styling, icons, images, or
  /// complex layouts within the dropdown item.
  final Widget child;

  /// An optional callback that will be invoked when this item is selected.
  ///
  /// This callback is called in addition to the dropdown's [CustomDropdown.onChanged]
  /// callback, allowing for item-specific behavior when selected.
  final VoidCallback? onTap;
}
