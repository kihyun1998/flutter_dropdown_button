import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import '../widgets/smart_tooltip_text.dart';
import 'base_dropdown_button.dart';
import 'text_dropdown_mixin.dart';

/// A dynamic text-based dropdown button widget that adapts its behavior based on the number of items.
///
/// This widget provides intelligent behavior switching:
/// - When [disableWhenSingleItem] is true and [items] has only one element:
///   displays as a non-interactive button (no dropdown)
/// - Otherwise: functions as a normal dropdown button
///
/// Unlike [TextOnlyDropdownButton], this widget does not require a fixed width.
/// Instead, the width is determined by the content (text, leading, trailing widgets),
/// with optional [minWidth] and [maxWidth] constraints.
///
/// This is particularly useful for forms or interfaces where options may vary,
/// and you want to avoid showing a dropdown for single-option scenarios.
///
/// Features:
/// - Content-based dynamic width with minWidth/maxWidth constraints
/// - Automatic behavior switching based on item count (configurable)
/// - Same text rendering controls as [TextOnlyDropdownButton]
/// - Optional leading widget support via [leading] and [selectedLeading]
/// - Customizable leading widget padding
/// - Smooth animations and outside-tap dismissal (when dropdown is enabled)
/// - Shared theme with other dropdown variants
///
/// Example:
/// ```dart
/// DynamicTextBaseDropdownButton(
///   items: availableOptions, // May have 1 or more items
///   value: selectedValue,
///   hint: 'Select an option',
///   minWidth: 120,
///   theme: DropdownStyleTheme(
///     dropdown: DropdownTheme(borderRadius: 12.0),
///   ),
///   config: TextDropdownConfig(
///     overflow: TextOverflow.ellipsis,
///     maxLines: 1,
///     textStyle: TextStyle(fontSize: 16),
///   ),
///   leading: Icon(Icons.star, size: 20),
///   selectedLeading: Icon(Icons.star, size: 20, color: Colors.blue),
///   leadingPadding: EdgeInsets.only(right: 8.0),
///   onChanged: (value) => setState(() => selectedValue = value),
/// )
/// ```
class DynamicTextBaseDropdownButton extends BaseDropdownButton<String> {
  /// Creates a dynamic text-based dropdown button widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  /// Behavior automatically adapts based on [items.length].
  const DynamicTextBaseDropdownButton({
    super.key,
    required this.items,
    required super.onChanged,
    super.value,
    this.hint,
    super.theme,
    this.config,
    super.maxWidth,
    super.minWidth,
    super.height = 200.0,
    super.itemHeight = 48.0,
    super.animationDuration = const Duration(milliseconds: 200),
    super.enabled = true,
    super.scrollToSelectedItem = true,
    super.scrollToSelectedDuration,
    super.expand = false,
    super.trailing,
    this.disableWhenSingleItem = true,
    this.hideIconWhenSingleItem = true,
    this.leading,
    this.selectedLeading,
    this.leadingPadding,
    super.minMenuWidth,
    super.maxMenuWidth,
    super.menuAlignment,
  });

  /// The list of text options to display in the dropdown.
  ///
  /// - If [disableWhenSingleItem] is true and [items.length] == 1:
  ///   displays as a non-interactive button
  /// - Otherwise: displays as a normal dropdown button
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

  /// Whether to disable the dropdown when there's only one item.
  ///
  /// When true (default), a single-item dropdown becomes a non-interactive
  /// display widget. When false, the dropdown behaves normally regardless
  /// of item count.
  final bool disableWhenSingleItem;

  /// Whether to hide the dropdown icon when there's only one item.
  ///
  /// When true (default), the icon is hidden for single-item scenarios
  /// to make it clear the button is not interactive.
  /// When false, the icon is always shown.
  ///
  /// Only applies when [disableWhenSingleItem] is true.
  final bool hideIconWhenSingleItem;

  /// Widget to display before the text in all dropdown items.
  ///
  /// This widget will be displayed before the text in both the selected
  /// state and in the dropdown list. Useful for adding icons, images,
  /// or other decorative elements that are consistent across all items.
  ///
  /// If [selectedLeading] is provided, it will be used for the selected
  /// item instead of this widget.
  ///
  /// Example:
  /// ```dart
  /// leading: SvgPicture.asset('assets/icon.svg', width: 20)
  /// ```
  final Widget? leading;

  /// Widget to display before the text in the selected item.
  ///
  /// If null, [leading] will be used for the selected item as well.
  /// This is useful when you want to show a different visual state
  /// for the selected item (e.g., different color or icon).
  ///
  /// Example:
  /// ```dart
  /// selectedLeading: SvgPicture.asset(
  ///   'assets/icon.svg',
  ///   width: 20,
  ///   colorFilter: ColorFilter.mode(Colors.blue, BlendMode.srcIn),
  /// )
  /// ```
  final Widget? selectedLeading;

  /// Padding around the leading widget.
  ///
  /// If null, defaults to `EdgeInsets.only(right: 8.0)`.
  final EdgeInsets? leadingPadding;

  @override
  State<DynamicTextBaseDropdownButton> createState() =>
      _DynamicTextBaseDropdownButtonState();
}

/// The state class for [DynamicTextBaseDropdownButton].
class _DynamicTextBaseDropdownButtonState
    extends BaseDropdownButtonState<DynamicTextBaseDropdownButton, String>
    with TextDropdownRenderMixin<DynamicTextBaseDropdownButton> {
  @override
  String? get hint => widget.hint;

  @override
  TextDropdownConfig get textConfig =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  /// Whether the dropdown is in single-item non-interactive mode.
  bool get _isSingleItemDisabled =>
      widget.disableWhenSingleItem && widget.items.length == 1;

  @override
  bool get isEnabled => !_isSingleItemDisabled && widget.enabled;

  @override
  void initState() {
    super.initState();
    _autoSelectSingleItem();
  }

  @override
  void didUpdateWidget(DynamicTextBaseDropdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _autoSelectSingleItem();
  }

  /// Automatically selects the only item when in single-item mode.
  void _autoSelectSingleItem() {
    if (_isSingleItemDisabled && widget.value != widget.items.first) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(widget.items.first);
        }
      });
    }
  }

  @override
  bool get showTrailing =>
      !(_isSingleItemDisabled && widget.hideIconWhenSingleItem);

  @override
  Widget buildSelectedWidget() {
    final selectedText = widget.value;
    final displayText = selectedText ?? widget.hint ?? '';
    final isHint = selectedText == null;

    final textWidget = SmartTooltipText(
      text: displayText,
      tooltipTheme: effectiveTooltipTheme,
      style: isHint ? textConfig.hintStyle : textConfig.textStyle,
      textAlign: textConfig.textAlign,
      maxLines: textConfig.maxLines,
      overflow: textConfig.overflow,
      softWrap: textConfig.softWrap,
      textDirection: textConfig.textDirection,
      locale: textConfig.locale,
      textScaler: textConfig.textScaler,
    );

    // Determine which leading widget to use
    final leadingWidget = selectedText != null
        ? (widget.selectedLeading ?? widget.leading)
        : null;

    if (leadingWidget == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: widget.leadingPadding ?? const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: effectiveTheme.iconSize ?? 24.0,
            child: Center(child: leadingWidget),
          ),
        ),
        Flexible(child: textWidget),
      ],
    );
  }

  @override
  Widget buildItemWidget(String item, bool isSelected) {
    final textWidget = SmartTooltipText(
      text: item,
      tooltipTheme: effectiveTooltipTheme,
      style: isSelected
          ? textConfig.selectedTextStyle ?? textConfig.textStyle
          : textConfig.textStyle,
      textAlign: textConfig.textAlign,
      maxLines: textConfig.maxLines,
      overflow: textConfig.overflow,
      softWrap: textConfig.softWrap,
      textDirection: textConfig.textDirection,
      locale: textConfig.locale,
      textScaler: textConfig.textScaler,
      semanticsLabel: textConfig.semanticsLabel,
    );

    if (widget.leading == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: widget.leadingPadding ?? const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: effectiveTheme.iconSize ?? 24.0,
            child: Center(child: widget.leading!),
          ),
        ),
        Flexible(child: textWidget),
      ],
    );
  }

  @override
  List<String> getItems() {
    return widget.items;
  }
}
