import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import 'base_dropdown_button.dart';
import 'text_dropdown_mixin.dart';

/// A dropdown button widget specifically designed for text-only content
/// with a fixed width.
///
/// This widget provides precise control over text rendering, overflow behavior,
/// and typography while maintaining the visual consistency defined by [DropdownTheme].
/// Unlike [BasicDropdownButton], this widget only accepts string values, allowing
/// for better text-specific optimizations and controls.
///
/// The [width] parameter is required because this widget is designed for
/// fixed-width layouts. For content-based dynamic width, use
/// [DynamicTextBaseDropdownButton] instead.
///
/// Features:
/// - Fixed width with text overflow control (ellipsis, fade, clip, visible)
/// - Multi-line text support
/// - Custom text styling and alignment
/// - Shared theme with other dropdown variants
/// - Smooth animations and outside-tap dismissal
///
/// Example:
/// ```dart
/// TextOnlyDropdownButton(
///   items: ['Apple', 'Banana', 'Very Long Orange Name That Might Overflow'],
///   value: selectedValue,
///   width: 200,
///   hint: 'Select a fruit',
///   theme: DropdownStyleTheme(
///     dropdown: DropdownTheme(borderRadius: 12.0),
///   ),
///   config: TextDropdownConfig(
///     overflow: TextOverflow.ellipsis,
///     maxLines: 1,
///     textStyle: TextStyle(fontSize: 16),
///   ),
///   onChanged: (value) => setState(() => selectedValue = value),
/// )
/// ```
class TextOnlyDropdownButton extends BaseDropdownButton<String> {
  /// Creates a text-only dropdown button widget with a fixed width.
  ///
  /// The [items], [onChanged], and [width] parameters are required.
  const TextOnlyDropdownButton({
    super.key,
    required this.items,
    required super.onChanged,
    required double width,
    super.value,
    this.hint,
    super.theme,
    this.config,
    super.height = 200.0,
    super.itemHeight = 48.0,
    super.animationDuration = const Duration(milliseconds: 200),
    super.enabled = true,
    super.scrollToSelectedItem = true,
    super.scrollToSelectedDuration,
    super.trailing,
    super.showSeparator = false,
    super.separator,
    super.minMenuWidth,
    super.maxMenuWidth,
    super.menuAlignment,
  }) : super(width: width);

  /// The list of text options to display in the dropdown.
  ///
  /// Each string represents both the display text and the value.
  /// Empty strings are allowed but may not be visually clear to users.
  final List<String> items;

  /// The text to display when no item is selected.
  ///
  /// If null, the dropdown will show empty space when no item is selected.
  final String? hint;

  /// Configuration specific to text rendering and behavior.
  ///
  /// Controls text overflow, styling, alignment, and other text-specific
  /// properties. If null, uses [TextDropdownConfig.defaultConfig].
  final TextDropdownConfig? config;

  @override
  State<TextOnlyDropdownButton> createState() => _TextOnlyDropdownButtonState();
}

/// The state class for [TextOnlyDropdownButton].
class _TextOnlyDropdownButtonState
    extends BaseDropdownButtonState<TextOnlyDropdownButton, String>
    with TextDropdownRenderMixin<TextOnlyDropdownButton> {
  @override
  String? get hint => widget.hint;

  @override
  TextDropdownConfig get textConfig =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  @override
  List<String> getItems() {
    return widget.items;
  }
}
