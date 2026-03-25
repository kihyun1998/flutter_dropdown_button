import 'package:flutter/material.dart';

/// Theme configuration for the search field in searchable dropdowns.
///
/// This class provides comprehensive control over the appearance and behavior
/// of the search text field displayed at the top of the dropdown overlay
/// when [FlutterDropdownButton.searchable] is enabled.
///
/// Example:
/// ```dart
/// SearchFieldTheme(
///   decoration: InputDecoration(
///     hintText: 'Search...',
///     prefixIcon: Icon(Icons.search),
///   ),
///   textStyle: TextStyle(fontSize: 14),
///   cursorColor: Colors.blue,
///   backgroundColor: Colors.grey.shade100,
///   margin: EdgeInsets.all(8),
///   borderRadius: BorderRadius.circular(8),
/// )
/// ```
class SearchFieldTheme {
  /// Creates a search field theme configuration.
  const SearchFieldTheme({
    this.decoration,
    this.textStyle,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.backgroundColor,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.focusedBorder,
    this.contentPadding,
    this.divider,
    this.autofocus = true,
    this.keyboardType,
    this.textInputAction,
    this.textAlign = TextAlign.start,
  });

  /// The [InputDecoration] for the search text field.
  ///
  /// When provided, this takes precedence over individual properties like
  /// [contentPadding]. If null, a default decoration with a search icon
  /// and "Search..." hint text is used.
  final InputDecoration? decoration;

  /// The text style for the search input text.
  ///
  /// If null, uses the theme's default body text style.
  final TextStyle? textStyle;

  /// The color of the text cursor.
  ///
  /// If null, uses the theme's primary color.
  final Color? cursorColor;

  /// The width of the text cursor.
  ///
  /// If null, uses the default cursor width (2.0).
  final double? cursorWidth;

  /// The height of the text cursor.
  ///
  /// If null, the cursor height matches the text height.
  final double? cursorHeight;

  /// The radius of the text cursor.
  ///
  /// If null, the cursor has sharp corners.
  final Radius? cursorRadius;

  /// The background color of the search field container.
  ///
  /// If null, the search field has a transparent background.
  final Color? backgroundColor;

  /// The fixed height of the search field container.
  ///
  /// This height includes the text field and its [margin].
  /// If null, the height is determined by the text field's intrinsic size
  /// plus [margin].
  final double? height;

  /// The margin around the search field container.
  ///
  /// Creates spacing between the search field and the dropdown edges/items.
  /// If null, defaults to `EdgeInsets.fromLTRB(8, 8, 8, 4)`.
  final EdgeInsets? margin;

  /// The padding inside the search field container.
  ///
  /// If null, no additional padding is applied around the text field.
  final EdgeInsets? padding;

  /// The border radius of the search field container.
  ///
  /// If null, defaults to `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// The border of the search field container.
  ///
  /// Applied when the field is not focused. If null, uses a subtle
  /// border based on the theme's divider color.
  final BoxBorder? border;

  /// The border of the search field container when focused.
  ///
  /// If null, falls back to [border].
  final BoxBorder? focusedBorder;

  /// The content padding inside the text field itself.
  ///
  /// Controls the spacing between the text field's edges and its content.
  /// If null, defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 8)`.
  final EdgeInsets? contentPadding;

  /// A widget displayed between the search field and the items list.
  ///
  /// Typically a [Divider]. If null, no divider is shown.
  final Widget? divider;

  /// Whether the search field should be focused automatically when
  /// the dropdown opens.
  ///
  /// Defaults to true.
  final bool autofocus;

  /// The keyboard type for the search text field.
  ///
  /// If null, defaults to [TextInputType.text].
  final TextInputType? keyboardType;

  /// The text input action for the search text field.
  ///
  /// Controls the action button on the soft keyboard.
  /// If null, defaults to [TextInputAction.search].
  final TextInputAction? textInputAction;

  /// How to align the search input text horizontally.
  ///
  /// Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// Creates a copy of this theme with the given fields replaced.
  SearchFieldTheme copyWith({
    InputDecoration? decoration,
    TextStyle? textStyle,
    Color? cursorColor,
    double? cursorWidth,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? backgroundColor,
    double? height,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    BoxBorder? border,
    BoxBorder? focusedBorder,
    EdgeInsets? contentPadding,
    Widget? divider,
    bool? autofocus,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextAlign? textAlign,
  }) {
    return SearchFieldTheme(
      decoration: decoration ?? this.decoration,
      textStyle: textStyle ?? this.textStyle,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      contentPadding: contentPadding ?? this.contentPadding,
      divider: divider ?? this.divider,
      autofocus: autofocus ?? this.autofocus,
      keyboardType: keyboardType ?? this.keyboardType,
      textInputAction: textInputAction ?? this.textInputAction,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  /// Default theme with a search icon and subtle styling.
  static const SearchFieldTheme defaultTheme = SearchFieldTheme();
}
