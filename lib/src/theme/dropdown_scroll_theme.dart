import 'package:flutter/material.dart';

import 'resolved_dropdown_style.dart';

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
///   thumbVisibility: true,
/// )
/// ```
class DropdownScrollTheme {
  /// Creates a dropdown scroll theme configuration.
  const DropdownScrollTheme({
    this.thickness,
    this.thumbWidth,
    @Deprecated(
      'Never applied. Flutter draws the track at the thumb thickness; use '
      'thumbWidth or thickness. This field will be removed in 4.0.0.',
    )
    this.trackWidth,
    this.radius,
    this.thumbColor,
    this.trackColor,
    this.trackBorderColor,
    this.thumbVisibility,
    this.trackVisibility,
    this.interactive,
    this.crossAxisMargin,
    this.mainAxisMargin,
    this.minThumbLength,
    this.showScrollGradient,
    this.gradientHeight,
    this.gradientColors,
  }) : assert(
         !(trackVisibility == true && thumbVisibility == false),
         'A scrollbar track cannot be drawn without a thumb.\n'
         'Either drop `thumbVisibility: false`, in which case the thumb is '
         'shown alongside the track, or drop `trackVisibility: true`.',
       );

  /// Thickness of the scrollbar — both its thumb and its track.
  ///
  /// If null, the ambient `ScrollbarTheme` decides, then Flutter's own
  /// platform-dependent default. [thumbWidth] wins over this.
  final double? thickness;

  /// Width of the scrollbar, named from the thumb's point of view.
  ///
  /// Wins over [thickness]; falls back to it, then to `8.0`.
  ///
  /// The track is drawn at this width too — Flutter's scrollbars have one
  /// thickness, not two, which is why `trackWidth` is deprecated.
  final double? thumbWidth;

  /// Width of the scrollbar track (the background area).
  ///
  /// **Deprecated, and it never worked.** Flutter's `Scrollbar` and
  /// `RawScrollbar` draw the track at the thumb's thickness; neither exposes a
  /// separate track width, so this value was never handed to anything. Setting
  /// it changed nothing, and combining it with `trackVisibility: true` used to
  /// crash the menu on open.
  ///
  /// Use [thumbWidth] — or [thickness] — to size the scrollbar.
  ///
  /// Removed in 4.0.0.
  @Deprecated(
    'Never applied. Flutter draws the track at the thumb thickness; use '
    'thumbWidth or thickness. This field will be removed in 4.0.0.',
  )
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

  /// Whether to show gradient fade indicators when content is scrollable.
  ///
  /// When true, a gradient fade will appear at the top when there's
  /// content above the visible area, and at the bottom when there's
  /// content below.
  ///
  /// If null, defaults to false (no gradient indicators).
  final bool? showScrollGradient;

  /// The height of the gradient fade indicator.
  ///
  /// Controls how tall the gradient fade effect is at the top and bottom
  /// edges of the scrollable content.
  ///
  /// If null, defaults to 24.0 pixels.
  final double? gradientHeight;

  /// The colors for the gradient fade indicator.
  ///
  /// Defines a gradient that fades from the edge towards the content.
  /// The first color appears at the edge (visible when scrolled),
  /// and the last color appears towards the content (typically transparent).
  ///
  /// Example:
  /// ```dart
  /// gradientColors: [
  ///   Colors.white,
  ///   Colors.white.withOpacity(0.5),
  ///   Colors.white.withOpacity(0.0),
  /// ]
  /// ```
  ///
  /// If null, auto-detects from dropdown background color.
  final List<Color>? gradientColors;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownScrollTheme copyWith({
    double? thickness,
    double? thumbWidth,
    @Deprecated(
      'Never applied. Flutter draws the track at the thumb thickness; use '
      'thumbWidth or thickness. This field will be removed in 4.0.0.',
    )
    double? trackWidth,
    Radius? radius,
    Color? thumbColor,
    Color? trackColor,
    Color? trackBorderColor,
    bool? thumbVisibility,
    bool? trackVisibility,
    bool? interactive,
    double? crossAxisMargin,
    double? mainAxisMargin,
    double? minThumbLength,
    bool? showScrollGradient,
    double? gradientHeight,
    List<Color>? gradientColors,
  }) {
    return DropdownScrollTheme(
      thickness: thickness ?? this.thickness,
      thumbWidth: thumbWidth ?? this.thumbWidth,
      // ignore: deprecated_member_use_from_same_package
      trackWidth: trackWidth ?? this.trackWidth,
      radius: radius ?? this.radius,
      thumbColor: thumbColor ?? this.thumbColor,
      trackColor: trackColor ?? this.trackColor,
      trackBorderColor: trackBorderColor ?? this.trackBorderColor,
      thumbVisibility: thumbVisibility ?? this.thumbVisibility,
      trackVisibility: trackVisibility ?? this.trackVisibility,
      interactive: interactive ?? this.interactive,
      crossAxisMargin: crossAxisMargin ?? this.crossAxisMargin,
      mainAxisMargin: mainAxisMargin ?? this.mainAxisMargin,
      minThumbLength: minThumbLength ?? this.minThumbLength,
      showScrollGradient: showScrollGradient ?? this.showScrollGradient,
      gradientHeight: gradientHeight ?? this.gradientHeight,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }

  /// The scrollbar as it should be drawn.
  ///
  /// Pure: it needs no ambient palette and no [BuildContext].
  ///
  /// Slots this theme does not name are left null, so an app-wide
  /// [ScrollbarTheme] keeps its say. Only [overridesScrollbarTheme] slots that
  /// were actually asked for.
  ResolvedScrollStyle resolve() {
    // ignore: deprecated_member_use_from_same_package
    final custom = thumbWidth != null || trackWidth != null;

    return ResolvedScrollStyle(
      thumbWidth: thumbWidth ?? thickness ?? 8.0,
      gradientHeight: gradientHeight ?? 24.0,
      hasCustomWidths: custom,
      thickness: custom ? (thumbWidth ?? thickness ?? 8.0) : thickness,
      radius: radius,
      // Flutter asserts a track is never drawn without a thumb. Asking for one
      // implies the other, so the illegal pair cannot be built from here.
      thumbVisibility:
          thumbVisibility ?? (trackVisibility == true ? true : null),
      trackVisibility: trackVisibility,
      interactive: interactive,
      overridesScrollbarTheme:
          thumbColor != null ||
          trackColor != null ||
          trackBorderColor != null ||
          crossAxisMargin != null ||
          mainAxisMargin != null ||
          minThumbLength != null,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: _all(thumbColor),
        trackColor: _all(trackColor),
        trackBorderColor: _all(trackBorderColor),
        crossAxisMargin: crossAxisMargin,
        mainAxisMargin: mainAxisMargin,
        minThumbLength: minThumbLength,
      ),
    );
  }

  static WidgetStateProperty<Color?>? _all(Color? color) =>
      color == null ? null : WidgetStateProperty.all(color);

  /// Default scroll theme with standard Material Design styling.
  static const DropdownScrollTheme defaultTheme = DropdownScrollTheme();
}
