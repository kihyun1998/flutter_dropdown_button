import 'package:flutter/material.dart';

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
