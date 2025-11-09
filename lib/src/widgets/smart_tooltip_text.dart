import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';

/// A text widget that intelligently displays tooltips based on overflow detection.
///
/// This widget wraps a [Text] widget and automatically shows a tooltip containing
/// the full text when the text is clipped due to overflow. The tooltip behavior
/// is controlled by the [TextDropdownConfig.tooltipMode] setting.
///
/// Features:
/// - Smart overflow detection using [TextPainter]
/// - Configurable tooltip modes (onlyWhenOverflow, always, disabled)
/// - Full tooltip customization support
/// - Efficient layout building with [LayoutBuilder]
///
/// Example:
/// ```dart
/// SmartTooltipText(
///   text: 'Very long text that might overflow',
///   style: TextStyle(fontSize: 16),
///   maxLines: 1,
///   overflow: TextOverflow.ellipsis,
///   config: TextDropdownConfig(
///     tooltipMode: TooltipMode.onlyWhenOverflow,
///   ),
/// )
/// ```
class SmartTooltipText extends StatelessWidget {
  /// Creates a smart tooltip text widget.
  const SmartTooltipText({
    super.key,
    required this.text,
    required this.config,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.semanticsLabel,
  });

  /// The text to display.
  final String text;

  /// The configuration for tooltip behavior.
  final TextDropdownConfig config;

  /// The text style to apply.
  final TextStyle? style;

  /// How to align the text horizontally.
  final TextAlign? textAlign;

  /// The maximum number of lines for the text.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// The locale for text rendering.
  final Locale? locale;

  /// The text scaler for accessibility.
  final TextScaler? textScaler;

  /// A semantic description for accessibility.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    // If tooltips are disabled, return text only
    if (!config.enableTooltip || config.tooltipMode == TooltipMode.disabled) {
      return _buildText();
    }

    // If mode is always, always show tooltip
    if (config.tooltipMode == TooltipMode.always) {
      return _buildWithTooltip(showTooltip: true);
    }

    // For onlyWhenOverflow mode, detect overflow dynamically
    return LayoutBuilder(
      builder: (context, constraints) {
        final isOverflowing = _checkTextOverflow(
          context: context,
          maxWidth: constraints.maxWidth,
        );

        return _buildWithTooltip(showTooltip: isOverflowing);
      },
    );
  }

  /// Builds the text widget without tooltip.
  Widget _buildText() {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
      textScaler: textScaler,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Builds the text widget with optional tooltip wrapper.
  Widget _buildWithTooltip({required bool showTooltip}) {
    final textWidget = _buildText();

    if (!showTooltip) {
      return textWidget;
    }

    return Tooltip(
      message: text,
      waitDuration: config.tooltipWaitDuration,
      showDuration: config.tooltipShowDuration,
      decoration: config.tooltipDecoration,
      textStyle: config.tooltipTextStyle,
      padding: config.tooltipPadding,
      margin: config.tooltipMargin,
      child: textWidget,
    );
  }

  /// Checks if the text overflows the available space.
  ///
  /// Uses [TextPainter] to measure the text layout and determine if it
  /// exceeds the maximum number of lines or available width.
  bool _checkTextOverflow({
    required BuildContext context,
    required double maxWidth,
  }) {
    // If maxWidth is infinite, text can't overflow
    if (maxWidth.isInfinite) {
      return false;
    }

    // Get the effective text direction
    final effectiveTextDirection =
        textDirection ?? Directionality.of(context);

    // Get the effective text scaler
    final effectiveTextScaler =
        textScaler ?? MediaQuery.textScalerOf(context);

    // Create a text painter to measure the text
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: effectiveTextDirection,
      maxLines: maxLines,
      locale: locale,
      textScaler: effectiveTextScaler,
    );

    // Layout the text with the available width
    textPainter.layout(maxWidth: maxWidth);

    // Check if text exceeded max lines
    if (textPainter.didExceedMaxLines) {
      return true;
    }

    // If no max lines specified, check if text wrapped to multiple lines
    // when softWrap is false
    if (maxLines == null && softWrap == false) {
      // For single-line display with softWrap false,
      // check if text width exceeds available width
      textPainter.layout(maxWidth: double.infinity);
      return textPainter.width > maxWidth;
    }

    return false;
  }
}
