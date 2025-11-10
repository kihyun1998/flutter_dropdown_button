import 'package:flutter/material.dart';

/// Determines when tooltips should be displayed for text content.
enum TooltipMode {
  /// Show tooltip only when text overflows the available space (recommended).
  ///
  /// This mode uses TextPainter to detect if the text is clipped, and only
  /// displays the tooltip when necessary, providing the best user experience.
  onlyWhenOverflow,

  /// Always show tooltip on hover/long-press, regardless of overflow.
  ///
  /// This mode displays tooltips for all text content, which may be redundant
  /// when text fits within the available space.
  always,

  /// Never show tooltips.
  ///
  /// Completely disables tooltip functionality.
  disabled,
}

/// Configuration specific to text-only dropdown widgets.
///
/// This class contains settings that are unique to dropdowns that handle
/// only text content, allowing for precise control over text rendering,
/// overflow behavior, and typography.
///
/// Example:
/// ```dart
/// TextDropdownConfig(
///   overflow: TextOverflow.ellipsis,
///   maxLines: 1,
///   textStyle: TextStyle(fontSize: 16, color: Colors.black87),
///   hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
///   textAlign: TextAlign.left,
///   enableTooltip: true,
///   tooltipMode: TooltipMode.onlyWhenOverflow,
/// )
/// ```
class TextDropdownConfig {
  /// Creates a text dropdown configuration.
  const TextDropdownConfig({
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.textStyle,
    this.hintStyle,
    this.selectedTextStyle,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.semanticsLabel,
    this.enableTooltip = true,
    this.tooltipMode = TooltipMode.onlyWhenOverflow,
    this.tooltipWaitDuration = const Duration(milliseconds: 500),
    this.tooltipShowDuration = const Duration(seconds: 3),
    this.tooltipExitDuration = const Duration(milliseconds: 100),
    this.tooltipBackgroundColor,
    this.tooltipTextColor,
    this.tooltipBorderRadius,
    this.tooltipBorderColor,
    this.tooltipBorderWidth,
    this.tooltipShadow,
    this.tooltipDecoration,
    this.tooltipTextStyle,
    this.tooltipTextAlign,
    this.tooltipPadding,
    this.tooltipMargin,
    this.tooltipConstraints,
    this.tooltipVerticalOffset,
    this.tooltipPreferBelow,
    this.tooltipEnableTapToDismiss,
    this.tooltipTriggerMode,
  });

  /// How to handle text that overflows the available space.
  ///
  /// Common options:
  /// - [TextOverflow.ellipsis]: Show "..." at the end
  /// - [TextOverflow.fade]: Gradually fade out the text
  /// - [TextOverflow.clip]: Cut off the text abruptly
  /// - [TextOverflow.visible]: Allow text to overflow (may cause layout issues)
  final TextOverflow overflow;

  /// The maximum number of lines for dropdown text content.
  ///
  /// If null, there is no limit on the number of lines.
  /// Setting this to 1 ensures single-line text with overflow handling.
  final int? maxLines;

  /// The text style for dropdown items.
  ///
  /// Applied to all dropdown option text. If null, uses the
  /// theme's default text style with appropriate contrast.
  final TextStyle? textStyle;

  /// The text style for the hint text.
  ///
  /// Applied when no item is selected and hint text is shown.
  /// If null, uses a muted version of the regular text style.
  final TextStyle? hintStyle;

  /// The text style for the currently selected item.
  ///
  /// Applied to the selected item's text in both the button
  /// and the dropdown overlay. If null, uses [textStyle].
  final TextStyle? selectedTextStyle;

  /// How to align text within dropdown items.
  ///
  /// Controls the horizontal alignment of text content.
  /// Common values: [TextAlign.start], [TextAlign.center], [TextAlign.end]
  final TextAlign textAlign;

  /// Whether text should break at soft line breaks.
  ///
  /// When true, text will wrap to new lines at word boundaries.
  /// When false, text will not wrap and [overflow] behavior applies.
  final bool softWrap;

  /// The text direction for dropdown content.
  ///
  /// Determines whether text flows left-to-right or right-to-left.
  /// If null, uses the ambient [Directionality].
  final TextDirection? textDirection;

  /// The locale for text rendering.
  ///
  /// Some fonts may render differently based on locale.
  /// If null, uses the ambient [Localizations].
  final Locale? locale;

  /// The text scaler for dropdown text.
  ///
  /// Controls how text is scaled for accessibility. If null,
  /// uses the ambient [MediaQuery] text scaler.
  final TextScaler? textScaler;

  /// A semantic description of the dropdown for accessibility.
  ///
  /// Used by screen readers and other assistive technologies.
  /// If null, no semantic label is provided.
  final String? semanticsLabel;

  /// Whether to enable tooltip functionality for text content.
  ///
  /// When true, tooltips will be shown based on [tooltipMode].
  /// When false, tooltips are completely disabled.
  /// Defaults to true.
  final bool enableTooltip;

  /// Determines when tooltips should be displayed.
  ///
  /// - [TooltipMode.onlyWhenOverflow]: Show tooltip only when text is clipped (default, recommended)
  /// - [TooltipMode.always]: Always show tooltip on hover/long-press
  /// - [TooltipMode.disabled]: Never show tooltips (same as setting [enableTooltip] to false)
  ///
  /// Defaults to [TooltipMode.onlyWhenOverflow] for optimal UX.
  final TooltipMode tooltipMode;

  /// The duration to wait before showing the tooltip after hovering.
  ///
  /// On desktop platforms, this is the delay between mouse hover and tooltip appearance.
  /// Defaults to 500 milliseconds.
  final Duration tooltipWaitDuration;

  /// How long the tooltip remains visible after it appears.
  ///
  /// After this duration, the tooltip will automatically dismiss.
  /// Defaults to 3 seconds.
  final Duration tooltipShowDuration;

  /// The duration for the tooltip to fade out when hiding.
  ///
  /// This controls how long it takes for the tooltip to disappear after
  /// the pointer stops hovering or the showDuration expires.
  /// Defaults to 100 milliseconds.
  final Duration tooltipExitDuration;

  /// The background color of the tooltip.
  ///
  /// If null, uses Flutter's default tooltip background color (dark grey).
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [tooltipDecoration] is provided, this property is ignored.
  final Color? tooltipBackgroundColor;

  /// The text color for tooltip content.
  ///
  /// If null, uses Flutter's default tooltip text color (white).
  /// This is a convenience property that creates a TextStyle internally.
  /// If [tooltipTextStyle] is provided, this property is ignored.
  final Color? tooltipTextColor;

  /// The border radius of the tooltip.
  ///
  /// If null, uses Flutter's default rounded corners.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [tooltipDecoration] is provided, this property is ignored.
  final BorderRadius? tooltipBorderRadius;

  /// The border color of the tooltip.
  ///
  /// If null, no border is displayed.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [tooltipDecoration] is provided, this property is ignored.
  final Color? tooltipBorderColor;

  /// The border width of the tooltip.
  ///
  /// Only applies if [tooltipBorderColor] is also set.
  /// Defaults to 1.0 if [tooltipBorderColor] is provided.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [tooltipDecoration] is provided, this property is ignored.
  final double? tooltipBorderWidth;

  /// The shadow for the tooltip.
  ///
  /// If null, uses Flutter's default tooltip shadow.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [tooltipDecoration] is provided, this property is ignored.
  final List<BoxShadow>? tooltipShadow;

  /// The decoration for the tooltip background.
  ///
  /// If provided, this takes precedence over [tooltipBackgroundColor],
  /// [tooltipBorderRadius], [tooltipBorderColor], [tooltipBorderWidth],
  /// and [tooltipShadow].
  ///
  /// If null, a BoxDecoration is created from the individual style properties.
  /// Customize this to match your app's design system.
  final Decoration? tooltipDecoration;

  /// The text style for tooltip content.
  ///
  /// If provided, this takes precedence over [tooltipTextColor].
  /// If null, uses Flutter's default tooltip text style (white text).
  final TextStyle? tooltipTextStyle;

  /// The horizontal alignment of the tooltip text.
  ///
  /// Controls how the tooltip message is aligned horizontally.
  /// If null, uses Flutter's default (left-aligned).
  final TextAlign? tooltipTextAlign;

  /// The padding inside the tooltip.
  ///
  /// If null, uses Flutter's default tooltip padding.
  final EdgeInsetsGeometry? tooltipPadding;

  /// The margin around the tooltip.
  ///
  /// Controls the spacing between the tooltip and the target widget.
  /// If null, uses Flutter's default tooltip margin.
  final EdgeInsetsGeometry? tooltipMargin;

  /// The constraints for the tooltip's dimensions.
  ///
  /// Allows flexible sizing control using BoxConstraints.
  /// You can control min/max width and height of the tooltip.
  ///
  /// If null, uses Flutter's default tooltip constraints.
  ///
  /// Example:
  /// ```dart
  /// tooltipConstraints: BoxConstraints(
  ///   minHeight: 32,
  ///   maxHeight: 200,
  ///   maxWidth: 300,
  /// )
  /// ```
  final BoxConstraints? tooltipConstraints;

  /// The vertical gap between the widget and the displayed tooltip.
  ///
  /// When [tooltipPreferBelow] is true, this is the space between the
  /// widget's bottom edge and the tooltip's top edge.
  /// When false, this is the space between the widget's top edge and
  /// the tooltip's bottom edge.
  /// If null, uses Flutter's default vertical offset.
  final double? tooltipVerticalOffset;

  /// Whether the tooltip should prefer to appear below the widget.
  ///
  /// If true, the tooltip will be displayed below the widget.
  /// If false, the tooltip will be displayed above the widget.
  /// If null (default), automatically calculates the best position by comparing
  /// available space above and below the widget, similar to dropdown overlays.
  ///
  /// **Auto-calculation behavior (when null):**
  /// - Measures the widget's position on screen
  /// - Compares space above vs. space below
  /// - Prefers the direction with more available space
  /// - Falls back to below if calculation fails
  final bool? tooltipPreferBelow;

  /// Whether the tooltip can be dismissed by tapping on it.
  ///
  /// If true, tapping the tooltip will dismiss it.
  /// If false, the tooltip can only be dismissed by un-hovering or waiting
  /// for the [tooltipShowDuration] to expire.
  /// If null, uses Flutter's default behavior (typically true).
  final bool? tooltipEnableTapToDismiss;

  /// Determines how the tooltip is triggered.
  ///
  /// Controls whether the tooltip appears on hover, long press, tap, or manually.
  /// If null, uses Flutter's default trigger mode (typically long press on mobile,
  /// hover on desktop).
  final TooltipTriggerMode? tooltipTriggerMode;

  /// Creates a copy of this config with the given fields replaced.
  TextDropdownConfig copyWith({
    TextOverflow? overflow,
    int? maxLines,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    TextStyle? selectedTextStyle,
    TextAlign? textAlign,
    bool? softWrap,
    TextDirection? textDirection,
    Locale? locale,
    TextScaler? textScaler,
    String? semanticsLabel,
    bool? enableTooltip,
    TooltipMode? tooltipMode,
    Duration? tooltipWaitDuration,
    Duration? tooltipShowDuration,
    Duration? tooltipExitDuration,
    Color? tooltipBackgroundColor,
    Color? tooltipTextColor,
    BorderRadius? tooltipBorderRadius,
    Color? tooltipBorderColor,
    double? tooltipBorderWidth,
    List<BoxShadow>? tooltipShadow,
    Decoration? tooltipDecoration,
    TextStyle? tooltipTextStyle,
    TextAlign? tooltipTextAlign,
    EdgeInsetsGeometry? tooltipPadding,
    EdgeInsetsGeometry? tooltipMargin,
    BoxConstraints? tooltipConstraints,
    double? tooltipVerticalOffset,
    bool? tooltipPreferBelow,
    bool? tooltipEnableTapToDismiss,
    TooltipTriggerMode? tooltipTriggerMode,
  }) {
    return TextDropdownConfig(
      overflow: overflow ?? this.overflow,
      maxLines: maxLines ?? this.maxLines,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
      textAlign: textAlign ?? this.textAlign,
      softWrap: softWrap ?? this.softWrap,
      textDirection: textDirection ?? this.textDirection,
      locale: locale ?? this.locale,
      textScaler: textScaler ?? this.textScaler,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      enableTooltip: enableTooltip ?? this.enableTooltip,
      tooltipMode: tooltipMode ?? this.tooltipMode,
      tooltipWaitDuration: tooltipWaitDuration ?? this.tooltipWaitDuration,
      tooltipShowDuration: tooltipShowDuration ?? this.tooltipShowDuration,
      tooltipExitDuration: tooltipExitDuration ?? this.tooltipExitDuration,
      tooltipBackgroundColor:
          tooltipBackgroundColor ?? this.tooltipBackgroundColor,
      tooltipTextColor: tooltipTextColor ?? this.tooltipTextColor,
      tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
      tooltipBorderColor: tooltipBorderColor ?? this.tooltipBorderColor,
      tooltipBorderWidth: tooltipBorderWidth ?? this.tooltipBorderWidth,
      tooltipShadow: tooltipShadow ?? this.tooltipShadow,
      tooltipDecoration: tooltipDecoration ?? this.tooltipDecoration,
      tooltipTextStyle: tooltipTextStyle ?? this.tooltipTextStyle,
      tooltipTextAlign: tooltipTextAlign ?? this.tooltipTextAlign,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipMargin: tooltipMargin ?? this.tooltipMargin,
      tooltipConstraints: tooltipConstraints ?? this.tooltipConstraints,
      tooltipVerticalOffset:
          tooltipVerticalOffset ?? this.tooltipVerticalOffset,
      tooltipPreferBelow: tooltipPreferBelow ?? this.tooltipPreferBelow,
      tooltipEnableTapToDismiss:
          tooltipEnableTapToDismiss ?? this.tooltipEnableTapToDismiss,
      tooltipTriggerMode: tooltipTriggerMode ?? this.tooltipTriggerMode,
    );
  }

  /// Default configuration optimized for single-line text with ellipsis.
  static const TextDropdownConfig defaultConfig = TextDropdownConfig();

  /// Configuration for multi-line text display.
  static const TextDropdownConfig multiLine = TextDropdownConfig(
    maxLines: null,
    overflow: TextOverflow.visible,
    softWrap: true,
  );

  /// Configuration for center-aligned text.
  static const TextDropdownConfig centered = TextDropdownConfig(
    textAlign: TextAlign.center,
  );

  /// Configuration for text that fades out instead of showing ellipsis.
  static const TextDropdownConfig fadeOverflow = TextDropdownConfig(
    overflow: TextOverflow.fade,
  );
}
