import 'package:flutter/material.dart';

import 'dropdown_mixin.dart';
import 'dropdown_theme.dart';
import 'text_dropdown_config.dart';

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
class TextOnlyDropdownButton extends StatefulWidget {
  /// Creates a text-only dropdown button widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  const TextOnlyDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.theme,
    this.config,
    this.width,
    this.maxWidth,
    this.minWidth,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.enabled = true,
  });

  /// The list of text options to display in the dropdown.
  ///
  /// Each string represents both the display text and the value.
  /// Empty strings are allowed but may not be visually clear to users.
  final List<String> items;

  /// Called when the user selects an item from the dropdown.
  ///
  /// The callback receives the selected string value, or null if
  /// no item is selected.
  final ValueChanged<String?> onChanged;

  /// The currently selected value.
  ///
  /// Must be one of the strings in [items] or null.
  /// If the value is not in [items], no item will be highlighted.
  final String? value;

  /// The text to display when no item is selected.
  ///
  /// If null, the dropdown will show empty space when no item is selected.
  final String? hint;

  /// The visual theme shared across all dropdown variants.
  ///
  /// Controls animations, colors, borders, and other visual aspects.
  /// If null, uses [DropdownTheme.defaultTheme].
  final DropdownTheme? theme;

  /// Configuration specific to text rendering and behavior.
  ///
  /// Controls text overflow, styling, alignment, and other text-specific
  /// properties. If null, uses [TextDropdownConfig.defaultConfig].
  final TextDropdownConfig? config;

  /// The fixed width of the dropdown button and overlay.
  ///
  /// If null, the dropdown will size itself based on content
  /// within the constraints of [minWidth] and [maxWidth].
  final double? width;

  /// The maximum width of the dropdown button and overlay.
  ///
  /// Only applied when [width] is null. Prevents the dropdown
  /// from becoming too wide with long text content.
  final double? maxWidth;

  /// The minimum width of the dropdown button and overlay.
  ///
  /// Only applied when [width] is null. Ensures consistent
  /// minimum size regardless of content length.
  final double? minWidth;

  /// The maximum height of the dropdown overlay.
  ///
  /// If the content exceeds this height, the dropdown becomes scrollable.
  final double height;

  /// The height of each individual dropdown item.
  ///
  /// Should be large enough to accommodate the text with the
  /// specified padding and font size.
  final double itemHeight;

  /// Whether the dropdown is enabled for user interaction.
  ///
  /// When false, the dropdown appears dimmed and does not respond
  /// to taps or other user input.
  final bool enabled;

  @override
  State<TextOnlyDropdownButton> createState() => _TextOnlyDropdownButtonState();
}

/// The state class for [TextOnlyDropdownButton].
///
/// Manages the dropdown's open/closed state, animations, and overlay positioning.
/// Uses [DropdownMixin] to provide common dropdown functionality.
class _TextOnlyDropdownButtonState extends State<TextOnlyDropdownButton>
    with SingleTickerProviderStateMixin, DropdownMixin<TextOnlyDropdownButton> {
  /// The effective theme, using provided theme or default.
  DropdownTheme get _theme => widget.theme ?? DropdownTheme.defaultTheme;

  /// The effective config, using provided config or default.
  TextDropdownConfig get _config =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  // Implement DropdownMixin abstract getters
  @override
  Duration get animationDuration => _theme.animationDuration;

  @override
  double get itemHeight => widget.itemHeight;

  @override
  double get maxDropdownHeight => widget.height;

  @override
  int get itemCount => widget.items.length;

  @override
  bool get isEnabled => widget.enabled;

  @override
  double get overlayElevation => _theme.elevation;

  @override
  double get overlayBorderRadius => _theme.borderRadius;

  @override
  Color? get overlayShadowColor => _theme.shadowColor;

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
    closeDropdown();
  }

  @override
  BoxDecoration? buildOverlayDecoration() {
    return _theme.overlayDecoration ??
        BoxDecoration(
          color: _theme.backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(_theme.borderRadius),
          border: _theme.border ??
              Border.all(
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
          final isSelected = widget.value == item;
          final itemIndex = widget.items.indexOf(item);
          final isFirst = itemIndex == 0;
          final isLast = itemIndex == widget.items.length - 1;

          return Material(
            color: Colors.transparent,
            child: Container(
              margin: _theme.itemMargin,
              child: InkWell(
                onTap: () {
                  widget.onChanged(item);
                  onDropdownItemSelected();
                },
                // Custom splash and highlight colors from theme
                splashColor:
                    _theme.itemSplashColor ?? Theme.of(context).splashColor,
                highlightColor: _theme.itemHighlightColor ??
                    Theme.of(context).highlightColor,
                hoverColor:
                    _theme.itemHoverColor ?? Theme.of(context).hoverColor,
                // Apply item-specific border radius if provided, otherwise use overlay radius for edges
                borderRadius: BorderRadius.circular(_theme.itemBorderRadius ??
                    (isFirst
                        ? _theme.borderRadius
                        : isLast
                            ? _theme.borderRadius
                            : 0.0)),
                child: Container(
                  height: widget.itemHeight,
                  width: double.infinity,
                  padding: _theme.itemPadding,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _theme.selectedItemColor ??
                            Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
                        : Colors.transparent,
                    // Apply item-specific border radius if provided
                    borderRadius: _theme.itemBorderRadius != null
                        ? BorderRadius.circular(_theme.itemBorderRadius!)
                        : null,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
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
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the dropdown button widget.
  Widget _buildDropdownButton() {
    final selectedText = widget.value;
    final displayText = selectedText ?? widget.hint ?? '';
    final isHint = selectedText == null;

    return GestureDetector(
      key: dropdownButtonKey,
      onTap: toggleDropdown,
      child: Container(
        width: widget.width,
        padding: _theme.buttonPadding,
        decoration: _theme.buttonDecoration ??
            BoxDecoration(
              border: _theme.border ??
                  Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(_theme.borderRadius),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize:
              widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                displayText,
                style: isHint ? _config.hintStyle : _config.textStyle,
                textAlign: _config.textAlign,
                maxLines: _config.maxLines,
                overflow: _config.overflow,
                softWrap: _config.softWrap,
                textDirection: _config.textDirection,
                locale: _config.locale,
                textScaler: _config.textScaler,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isDropdownOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: widget.enabled
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdownButton = _buildDropdownButton();

    // Apply opacity for disabled state
    if (!widget.enabled) {
      dropdownButton = Opacity(opacity: 0.6, child: dropdownButton);
    }

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
