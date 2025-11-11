import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import '../theme/dropdown_theme.dart';
import '../widgets/smart_tooltip_text.dart';
import 'base_dropdown_button.dart';

/// A dropdown button widget specifically designed for text-only content.
///
/// This widget provides precise control over text rendering, overflow behavior,
/// and typography while maintaining the visual consistency defined by [DropdownTheme].
/// Unlike [BasicDropdownButton], this widget only accepts string values, allowing
/// for better text-specific optimizations and controls.
///
/// Features:
/// - Text overflow control (ellipsis, fade, clip, visible)
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
///   hint: 'Select a fruit',
///   theme: DropdownTheme(borderRadius: 12.0),
///   config: TextDropdownConfig(
///     overflow: TextOverflow.ellipsis,
///     maxLines: 1,
///     textStyle: TextStyle(fontSize: 16),
///   ),
///   onChanged: (value) => setState(() => selectedValue = value),
/// )
/// ```
class TextOnlyDropdownButton extends BaseDropdownButton<String> {
  /// Creates a text-only dropdown button widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  const TextOnlyDropdownButton({
    super.key,
    required this.items,
    required super.onChanged,
    super.value,
    this.hint,
    super.theme,
    this.config,
    super.width,
    super.maxWidth,
    super.minWidth,
    super.height = 200.0,
    super.itemHeight = 48.0,
    super.enabled = true,
    super.scrollToSelectedItem = true,
    super.scrollToSelectedDuration,
    super.expand = false,
    super.trailing,
  });

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
///
/// Manages the dropdown's open/closed state, animations, and overlay positioning.
/// Uses [BaseDropdownButtonState] to provide common dropdown functionality.
class _TextOnlyDropdownButtonState
    extends BaseDropdownButtonState<TextOnlyDropdownButton, String> {
  /// The effective config, using provided config or default.
  TextDropdownConfig get _config =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  @override
  Widget buildSelectedWidget() {
    final selectedText = widget.value;
    final displayText = selectedText ?? widget.hint ?? '';
    final isHint = selectedText == null;

    return SmartTooltipText(
      text: displayText,
      config: _config,
      style: isHint ? _config.hintStyle : _config.textStyle,
      textAlign: _config.textAlign,
      maxLines: _config.maxLines,
      overflow: _config.overflow,
      softWrap: _config.softWrap,
      textDirection: _config.textDirection,
      locale: _config.locale,
      textScaler: _config.textScaler,
    );
  }

  @override
  Widget buildItemWidget(String item, bool isSelected) {
    return SmartTooltipText(
      text: item,
      config: _config,
      style: isSelected
          ? _config.selectedTextStyle ?? _config.textStyle
          : _config.textStyle,
      textAlign: _config.textAlign,
      maxLines: _config.maxLines,
      overflow: _config.overflow,
      softWrap: _config.softWrap,
      textDirection: _config.textDirection,
      locale: _config.locale,
      textScaler: _config.textScaler,
      semanticsLabel: _config.semanticsLabel,
    );
  }

  @override
  List<String> getItems() {
    return widget.items;
  }
}
