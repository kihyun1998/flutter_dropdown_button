import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import '../theme/dropdown_theme.dart';
import 'base_dropdown_button.dart';

/// A dynamic dropdown button widget that adapts its behavior based on the number of items.
///
/// This widget provides intelligent behavior switching:
/// - When [items] has only one element: displays as a non-interactive button (no dropdown)
/// - When [items] has multiple elements: functions as a normal dropdown button
///
/// This is particularly useful for forms or interfaces where options may vary,
/// and you want to avoid showing a dropdown for single-option scenarios.
///
/// Features:
/// - Automatic behavior switching based on item count
/// - Same text rendering controls as [TextOnlyDropdownButton]
/// - Smooth animations and outside-tap dismissal (when dropdown is enabled)
/// - Shared theme with other dropdown variants
///
/// Example:
/// ```dart
/// DynamicDropdownButton(
///   items: availableOptions, // May have 1 or more items
///   value: selectedValue,
///   hint: 'Select an option',
///   theme: DropdownTheme(borderRadius: 12.0),
///   config: TextDropdownConfig(
///     overflow: TextOverflow.ellipsis,
///     maxLines: 1,
///     textStyle: TextStyle(fontSize: 16),
///   ),
///   onChanged: (value) => setState(() => selectedValue = value),
/// )
/// ```
class DynamicDropdownButton extends BaseDropdownButton<String> {
  /// Creates a dynamic dropdown button widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  /// Behavior automatically adapts based on [items.length].
  const DynamicDropdownButton({
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
    this.hideIconWhenSingleItem = true,
  });

  /// The list of text options to display in the dropdown.
  ///
  /// - If [items.length] == 1: displays as a non-interactive button
  /// - If [items.length] > 1: displays as a normal dropdown button
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

  /// Whether to hide the dropdown icon when there's only one item.
  ///
  /// When true (default), the icon is hidden for single-item scenarios
  /// to make it clear the button is not interactive.
  /// When false, the icon is always shown.
  final bool hideIconWhenSingleItem;

  @override
  State<DynamicDropdownButton> createState() => _DynamicDropdownButtonState();
}

/// The state class for [DynamicDropdownButton].
///
/// Manages the dropdown's behavior switching and delegates to
/// [BaseDropdownButtonState] for common functionality.
class _DynamicDropdownButtonState
    extends BaseDropdownButtonState<DynamicDropdownButton, String> {
  /// The effective config, using provided config or default.
  TextDropdownConfig get _config =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  /// Whether the dropdown should behave as interactive.
  ///
  /// Returns false when there's only one item (non-interactive mode).
  bool get _isDropdownEnabled => widget.items.length > 1 && widget.enabled;

  /// Whether to show the dropdown icon.
  ///
  /// Hidden when there's only one item and [hideIconWhenSingleItem] is true.
  bool get _shouldShowIcon =>
      !widget.hideIconWhenSingleItem || widget.items.length > 1;

  @override
  bool get isEnabled => _isDropdownEnabled;

  @override
  Widget buildSelectedWidget() {
    final selectedText = widget.value;
    final displayText = selectedText ?? widget.hint ?? '';
    final isHint = selectedText == null;

    return Text(
      displayText,
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
    return Text(
      item,
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

  @override
  Widget build(BuildContext context) {
    // If there's only one item, show a simple non-interactive button
    if (widget.items.length == 1) {
      Widget dropdownButton = Container(
        key: dropdownButtonKey,
        width: widget.width,
        padding: effectiveTheme.buttonPadding,
        decoration: buildButtonDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize:
              widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Flexible(child: buildSelectedWidget()),
            // Conditionally show icon for single item
            if (_shouldShowIcon)
              Padding(
                padding: effectiveTheme.iconPadding ??
                    const EdgeInsets.only(left: 8.0),
                child: Icon(
                  effectiveTheme.icon ?? Icons.keyboard_arrow_down,
                  size: effectiveTheme.iconSize ?? 24.0,
                  color: widget.enabled
                      ? (effectiveTheme.iconColor ??
                          Theme.of(context).iconTheme.color)
                      : (effectiveTheme.iconDisabledColor ??
                          Theme.of(context).disabledColor),
                ),
              ),
          ],
        ),
      );

      // Apply opacity for disabled state
      if (!widget.enabled) {
        dropdownButton = Opacity(opacity: 0.6, child: dropdownButton);
      }

      // Apply width constraints if specified
      return _applyWidthConstraints(dropdownButton);
    }

    // For multiple items, use the default dropdown behavior
    return super.build(context);
  }

  /// Applies width constraints to the dropdown button.
  Widget _applyWidthConstraints(Widget child) {
    if (widget.width == null &&
        (widget.minWidth != null || widget.maxWidth != null)) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? 0,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: child,
      );
    }
    return child;
  }
}
