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
    this.tooltipDecoration,
    this.tooltipTextStyle,
    this.tooltipPadding,
    this.tooltipMargin,
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

  /// The decoration for the tooltip background.
  ///
  /// If null, uses Flutter's default tooltip decoration (dark background with rounded corners).
  /// Customize this to match your app's design system.
  final Decoration? tooltipDecoration;

  /// The text style for tooltip content.
  ///
  /// If null, uses Flutter's default tooltip text style (white text).
  final TextStyle? tooltipTextStyle;

  /// The padding inside the tooltip.
  ///
  /// If null, uses Flutter's default tooltip padding.
  final EdgeInsetsGeometry? tooltipPadding;

  /// The margin around the tooltip.
  ///
  /// Controls the spacing between the tooltip and the target widget.
  /// If null, uses Flutter's default tooltip margin.
  final EdgeInsetsGeometry? tooltipMargin;

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
    Decoration? tooltipDecoration,
    TextStyle? tooltipTextStyle,
    EdgeInsetsGeometry? tooltipPadding,
    EdgeInsetsGeometry? tooltipMargin,
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
      tooltipDecoration: tooltipDecoration ?? this.tooltipDecoration,
      tooltipTextStyle: tooltipTextStyle ?? this.tooltipTextStyle,
      tooltipPadding: tooltipPadding ?? this.tooltipPadding,
      tooltipMargin: tooltipMargin ?? this.tooltipMargin,
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
