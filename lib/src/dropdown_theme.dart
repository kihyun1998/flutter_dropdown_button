import 'package:flutter/material.dart';

/// Shared theme configuration for all dropdown widgets.
///
/// This class contains styling and behavior properties that are common
/// across all dropdown variants (CustomDropdown, TextOnlyDropdown, etc.)
/// to maintain visual consistency throughout the application.
///
/// Example:
/// ```dart
/// DropdownTheme(
///   animationDuration: Duration(milliseconds: 300),
///   borderRadius: 12.0,
///   elevation: 4.0,
///   backgroundColor: Colors.white,
///   border: Border.all(color: Colors.grey),
/// )
/// ```
class DropdownTheme {
  /// Creates a dropdown theme configuration.
  const DropdownTheme({
    this.animationDuration = const Duration(milliseconds: 200),
    this.borderRadius = 8.0,
    this.elevation = 8.0,
    this.backgroundColor,
    this.border,
    this.selectedItemColor,
    this.itemHoverColor,
    this.shadowColor,
    this.overlayDecoration,
    this.buttonDecoration,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  /// The duration of the dropdown show/hide animation.
  ///
  /// All dropdown variants will use this animation duration for
  /// consistent behavior across the application.
  final Duration animationDuration;

  /// The border radius for both the dropdown button and overlay.
  ///
  /// Applied to all corners of the dropdown components for
  /// a unified rounded appearance.
  final double borderRadius;

  /// The elevation (shadow depth) of the dropdown overlay.
  ///
  /// Higher values create more prominent shadows and visual separation
  /// from the background content.
  final double elevation;

  /// The background color of the dropdown overlay.
  ///
  /// If null, uses the theme's card color as default.
  /// This color is applied to the dropdown options container.
  final Color? backgroundColor;

  /// The border style for dropdown components.
  ///
  /// Applied to both the dropdown button and overlay container.
  /// If null, uses theme's divider color with 1px width.
  final Border? border;

  /// The background color for selected dropdown items.
  ///
  /// If null, uses the theme's primary color with 10% opacity.
  /// Applied when an item matches the currently selected value.
  final Color? selectedItemColor;

  /// The background color for dropdown items on hover/tap.
  ///
  /// If null, no hover effect is applied. This can enhance
  /// user interaction feedback on supported platforms.
  final Color? itemHoverColor;

  /// The shadow color for the dropdown overlay.
  ///
  /// If null, uses the default Material shadow color.
  /// Allows customization of shadow appearance to match app theme.
  final Color? shadowColor;

  /// Custom decoration for the dropdown overlay container.
  ///
  /// If provided, this takes precedence over individual color and
  /// border properties. Allows for complex styling like gradients,
  /// images, or custom shadows.
  final BoxDecoration? overlayDecoration;

  /// Custom decoration for the dropdown button.
  ///
  /// If provided, overrides the default button styling.
  /// Useful for creating unique button appearances while maintaining
  /// consistent overlay styling.
  final BoxDecoration? buttonDecoration;

  /// Padding applied to each dropdown item.
  ///
  /// Controls the internal spacing within dropdown options.
  /// Affects touch target size and visual spacing.
  final EdgeInsets itemPadding;

  /// Padding applied to the dropdown button content.
  ///
  /// Controls the internal spacing of the dropdown button.
  /// Should provide adequate touch target size for accessibility.
  final EdgeInsets buttonPadding;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownTheme copyWith({
    Duration? animationDuration,
    double? borderRadius,
    double? elevation,
    Color? backgroundColor,
    Border? border,
    Color? selectedItemColor,
    Color? itemHoverColor,
    Color? shadowColor,
    BoxDecoration? overlayDecoration,
    BoxDecoration? buttonDecoration,
    EdgeInsets? itemPadding,
    EdgeInsets? buttonPadding,
  }) {
    return DropdownTheme(
      animationDuration: animationDuration ?? this.animationDuration,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      itemHoverColor: itemHoverColor ?? this.itemHoverColor,
      shadowColor: shadowColor ?? this.shadowColor,
      overlayDecoration: overlayDecoration ?? this.overlayDecoration,
      buttonDecoration: buttonDecoration ?? this.buttonDecoration,
      itemPadding: itemPadding ?? this.itemPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
    );
  }

  /// Default theme that works well with Material Design.
  static const DropdownTheme defaultTheme = DropdownTheme();
}