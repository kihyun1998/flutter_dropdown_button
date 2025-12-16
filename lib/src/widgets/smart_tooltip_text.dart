import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import '../theme/tooltip_theme.dart';

/// A text widget that intelligently displays tooltips based on overflow detection.
///
/// This widget wraps a [Text] widget and automatically shows a tooltip containing
/// the full text when the text is clipped due to overflow. The tooltip behavior
/// is controlled by the [DropdownTooltipTheme.mode] setting.
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
///   tooltipTheme: DropdownTooltipTheme(
///     enabled: true,
///     mode: TooltipMode.onlyWhenOverflow,
///     backgroundColor: Colors.black87,
///     textStyle: TextStyle(color: Colors.white),
///   ),
/// )
/// ```
class SmartTooltipText extends StatelessWidget {
  /// Creates a smart tooltip text widget.
  const SmartTooltipText({
    super.key,
    required this.text,
    this.tooltipTheme,
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

  /// The theme for tooltip configuration.
  ///
  /// Controls both visual styling (colors, borders, padding, shadows, text styling)
  /// and behavioral settings (when to show, durations, trigger modes, positioning).
  /// If null, uses [DropdownTooltipTheme.defaultTheme].
  final DropdownTooltipTheme? tooltipTheme;

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
    // Get effective theme
    final theme = tooltipTheme ?? DropdownTooltipTheme.defaultTheme;

    // If tooltips are disabled, return text only
    if (!theme.enabled || theme.mode == TooltipMode.disabled) {
      return _buildText();
    }

    // If mode is always, always show tooltip
    if (theme.mode == TooltipMode.always) {
      return _buildWithTooltip(context: context, showTooltip: true);
    }

    // For onlyWhenOverflow mode, detect overflow dynamically
    return LayoutBuilder(
      builder: (context, constraints) {
        final isOverflowing = _checkTextOverflow(
          context: context,
          maxWidth: constraints.maxWidth,
        );

        return _buildWithTooltip(
          context: context,
          showTooltip: isOverflowing,
        );
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
  Widget _buildWithTooltip({
    required BuildContext context,
    required bool showTooltip,
  }) {
    final textWidget = _buildText();

    if (!showTooltip) {
      return textWidget;
    }

    // Get effective theme (use provided theme or default)
    final theme = tooltipTheme ?? DropdownTooltipTheme.defaultTheme;

    // Build decoration from individual properties if not explicitly provided
    Decoration? effectiveDecoration = theme.decoration;
    if (effectiveDecoration == null &&
        (theme.backgroundColor != null ||
            theme.borderRadius != null ||
            theme.borderColor != null ||
            theme.shadow != null)) {
      effectiveDecoration = BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: theme.borderRadius,
        border: theme.borderColor != null
            ? Border.all(
                color: theme.borderColor!,
                width: theme.borderWidth ?? 1.0,
              )
            : null,
        boxShadow: theme.shadow,
      );
    }

    // Build text style from individual properties if not explicitly provided
    TextStyle? effectiveTextStyle = theme.textStyle;
    if (effectiveTextStyle == null && theme.textColor != null) {
      effectiveTextStyle = TextStyle(color: theme.textColor);
    }

    // Calculate preferBelow automatically if not explicitly set
    final bool effectivePreferBelow =
        theme.preferBelow ?? _calculatePreferBelow(context);

    return Tooltip(
      message: text,
      waitDuration: theme.waitDuration,
      showDuration: theme.showDuration,
      exitDuration: theme.exitDuration,
      decoration: effectiveDecoration,
      textStyle: effectiveTextStyle,
      textAlign: theme.textAlign,
      padding: theme.padding,
      margin: theme.margin,
      constraints: theme.constraints,
      verticalOffset: theme.verticalOffset,
      preferBelow: effectivePreferBelow,
      enableTapToDismiss: theme.enableTapToDismiss ?? true,
      triggerMode: theme.triggerMode,
      child: textWidget,
    );
  }

  /// Calculates whether the tooltip should prefer to appear below the widget.
  ///
  /// This method calculates the available space above and below the widget
  /// and returns true if there is more space below, false otherwise.
  /// This mimics the behavior of dropdown overlays.
  bool _calculatePreferBelow(BuildContext context) {
    try {
      // Get the RenderBox of the widget
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        // If we can't get the render box, default to below
        return true;
      }

      // Get the global position of the widget
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final Size size = renderBox.size;

      // Get the screen height
      final double screenHeight = MediaQuery.of(context).size.height;

      // Calculate space above and below the widget
      final double spaceAbove = offset.dy;
      final double spaceBelow = screenHeight - (offset.dy + size.height);

      // Prefer below if there's more space below
      return spaceBelow >= spaceAbove;
    } catch (e) {
      // If any error occurs during calculation, default to below
      return true;
    }
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
    final effectiveTextDirection = textDirection ?? Directionality.of(context);

    // Get the effective text scaler
    final effectiveTextScaler = textScaler ?? MediaQuery.textScalerOf(context);

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
