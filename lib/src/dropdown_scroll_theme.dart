import 'package:flutter/material.dart';

/// Theme configuration for dropdown scrollbar styling.
///
/// This class contains all properties related to scrollbar appearance
/// and behavior within dropdown overlays.
///
/// Example:
/// ```dart
/// DropdownScrollTheme(
///   thickness: 8.0,
///   radius: Radius.circular(4.0),
///   thumbColor: Colors.grey,
///   trackColor: Colors.grey.withOpacity(0.2),
///   alwaysVisible: true,
/// )
/// ```
class DropdownScrollTheme {
  /// Creates a dropdown scroll theme configuration.
  const DropdownScrollTheme({
    this.thickness,
    this.thumbWidth,
    this.trackWidth,
    this.radius,
    this.thumbColor,
    this.trackColor,
    this.trackBorderColor,
    this.alwaysVisible,
    this.thumbVisibility,
    this.trackVisibility,
    this.interactive,
    this.crossAxisMargin,
    this.mainAxisMargin,
    this.minThumbLength,
  });

  /// Thickness of the scrollbar track.
  ///
  /// If null, uses the default scrollbar thickness (platform-dependent).
  /// Controls the width of the scrollbar when visible.
  ///
  /// **Deprecated**: Use [thumbWidth] and [trackWidth] for independent control.
  /// If [thumbWidth] or [trackWidth] is set, this property is ignored.
  final double? thickness;

  /// Width of the scrollbar thumb (the draggable part).
  ///
  /// If null, falls back to [thickness] or the default scrollbar thickness.
  /// When set, allows independent control of thumb width separate from track width.
  final double? thumbWidth;

  /// Width of the scrollbar track (the background area).
  ///
  /// If null, falls back to [thickness] or the default scrollbar thickness.
  /// When set, allows independent control of track width separate from thumb width.
  final double? trackWidth;

  /// Radius of the scrollbar thumb corners.
  ///
  /// If null, uses the default scrollbar radius.
  /// Makes the scrollbar thumb rounded at the corners.
  final Radius? radius;

  /// Color of the scrollbar thumb.
  ///
  /// If null, uses the theme's default scrollbar color.
  /// The thumb is the draggable part of the scrollbar.
  final Color? thumbColor;

  /// Color of the scrollbar track.
  ///
  /// If null, no track is displayed.
  /// The track is the background area behind the thumb.
  final Color? trackColor;

  /// Color of the scrollbar track border.
  ///
  /// If null, no track border is displayed.
  /// Creates an outline around the scrollbar track.
  final Color? trackBorderColor;

  /// Whether the scrollbar should always be visible.
  ///
  /// If true, the scrollbar is always shown even when not scrolling.
  /// If false or null, the scrollbar appears only during scroll interaction.
  final bool? alwaysVisible;

  /// Whether the scrollbar thumb should be visible.
  ///
  /// If false, hides the scrollbar thumb.
  /// If true or null, shows the thumb when appropriate.
  final bool? thumbVisibility;

  /// Whether the scrollbar track should be visible.
  ///
  /// If false, hides the scrollbar track.
  /// If true or null, shows the track when scrollbar is visible.
  final bool? trackVisibility;

  /// Whether the scrollbar can be interacted with.
  ///
  /// If true, users can drag the scrollbar thumb to scroll.
  /// If false or null, the scrollbar is for display only.
  final bool? interactive;

  /// The margin around the scrollbar's cross axis.
  ///
  /// Controls the spacing from the edge of the scroll view.
  final double? crossAxisMargin;

  /// The margin around the scrollbar's main axis.
  ///
  /// Controls the spacing at the top and bottom of the scrollbar.
  final double? mainAxisMargin;

  /// The minimum length of the scrollbar thumb.
  ///
  /// Prevents the thumb from becoming too small when scrolling
  /// through very long content.
  final double? minThumbLength;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownScrollTheme copyWith({
    double? thickness,
    double? thumbWidth,
    double? trackWidth,
    Radius? radius,
    Color? thumbColor,
    Color? trackColor,
    Color? trackBorderColor,
    bool? alwaysVisible,
    bool? thumbVisibility,
    bool? trackVisibility,
    bool? interactive,
    double? crossAxisMargin,
    double? mainAxisMargin,
    double? minThumbLength,
  }) {
    return DropdownScrollTheme(
      thickness: thickness ?? this.thickness,
      thumbWidth: thumbWidth ?? this.thumbWidth,
      trackWidth: trackWidth ?? this.trackWidth,
      radius: radius ?? this.radius,
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      trackBorderColor: trackBorderColor ?? this.trackBorderColor,
      alwaysVisible: alwaysVisible ?? this.alwaysVisible,
      thumbVisibility: thumbVisibility ?? this.thumbVisibility,
      trackVisibility: trackVisibility ?? this.trackVisibility,
      interactive: interactive ?? this.interactive,
      crossAxisMargin: crossAxisMargin ?? this.crossAxisMargin,
      mainAxisMargin: mainAxisMargin ?? this.mainAxisMargin,
      minThumbLength: minThumbLength ?? this.minThumbLength,
    );
  }

  /// Default scroll theme with standard Material Design styling.
  static const DropdownScrollTheme defaultTheme = DropdownScrollTheme();
}
