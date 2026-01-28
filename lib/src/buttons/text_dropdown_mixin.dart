import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import '../theme/tooltip_theme.dart';
import '../widgets/smart_tooltip_text.dart';
import 'base_dropdown_button.dart';

/// A mixin that provides common text rendering logic for text-based dropdown variants.
///
/// This mixin extracts the shared [SmartTooltipText] creation logic used by both
/// [TextOnlyDropdownButton] and [DynamicTextBaseDropdownButton], eliminating
/// code duplication between text-based dropdown implementations.
///
/// Requirements for using this mixin:
/// - The widget must have `String? hint` and `TextDropdownConfig? config` properties
/// - The state must extend [BaseDropdownButtonState] with `String` type parameter
mixin TextDropdownRenderMixin<W extends BaseDropdownButton<String>>
    on BaseDropdownButtonState<W, String> {
  /// The hint text to display when no item is selected.
  String? get hint;

  /// The text dropdown configuration.
  TextDropdownConfig get textConfig;

  /// The tooltip theme for text rendering.
  DropdownTooltipTheme get tooltipTheme => effectiveTooltipTheme;

  @override
  Widget buildSelectedWidget() {
    final selectedText = widget.value;
    final displayText = selectedText ?? hint ?? '';
    final isHint = selectedText == null;

    return SmartTooltipText(
      text: displayText,
      tooltipTheme: tooltipTheme,
      style: isHint ? textConfig.hintStyle : textConfig.textStyle,
      textAlign: textConfig.textAlign,
      maxLines: textConfig.maxLines,
      overflow: textConfig.overflow,
      softWrap: textConfig.softWrap,
      textDirection: textConfig.textDirection,
      locale: textConfig.locale,
      textScaler: textConfig.textScaler,
    );
  }

  @override
  Widget buildItemWidget(String item, bool isSelected) {
    return SmartTooltipText(
      text: item,
      tooltipTheme: tooltipTheme,
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
  }
}
