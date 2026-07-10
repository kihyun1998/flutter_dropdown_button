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
///   trackColor: Colors.grey.withValues(alpha: 0.2),
///   thumbVisibility: true,
///   trackVisibility: true,
/// )
/// ```
///
/// **A colour is not a request.** [trackColor] and [trackBorderColor] say what
/// the track looks like once it is drawn; [trackVisibility] is what draws it.
/// Naming a track colour and leaving [trackVisibility] null paints nothing.
///
/// **Null is not "off".** Every `bool?` here defaults to null, which means *let
/// the ambient `ScrollbarTheme` decide, and failing that Flutter*. For
/// [interactive] that resolves to **draggable** on desktop, not to "display
/// only". Pass `false` when you mean off.
class DropdownScrollTheme {
  /// Creates a dropdown scroll theme configuration.
  const DropdownScrollTheme({
    this.thickness,
    this.thumbWidth,
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
  /// If null, the ambient `ScrollbarTheme` decides, and failing that Flutter's
  /// own default: **8 logical pixels, halved to 4 on Android.**
  ///
  /// Whatever the source, the menu hands `Scrollbar` a concrete number rather
  /// than null. Flutter swells a thickness-less scrollbar from 8 to 12 while a
  /// pointer hovers a visible track; pinning the resting value stops that
  /// without changing how the bar looks at rest.
  ///
  /// [thumbWidth] wins over this.
  final double? thickness;

  /// Width of the scrollbar, named from the thumb's point of view.
  ///
  /// Wins over [thickness]; failing both, `8.0`.
  ///
  /// The track is drawn at this width too — Flutter's scrollbars have one
  /// thickness, not two.
  final double? thumbWidth;

  /// Radius of the scrollbar thumb corners.
  ///
  /// If null, the ambient `ScrollbarTheme` decides, and failing that Flutter's
  /// own default: **`Radius.circular(8)` on desktop, square on Android.**
  final Radius? radius;

  /// Color of the scrollbar thumb — the draggable part.
  ///
  /// If null, the ambient `ScrollbarTheme` decides, and failing that Flutter's
  /// own default, which fades between an idle and a hovered shade.
  final Color? thumbColor;

  /// Color of the scrollbar track — the channel the thumb slides along.
  ///
  /// **Only drawn when [trackVisibility] is true.** A colour on its own paints
  /// nothing: Flutter resolves the track's colour to transparent whenever the
  /// track is hidden, and the track is hidden by default.
  ///
  /// If null while the track *is* visible, the ambient `ScrollbarTheme`
  /// decides, and failing that Flutter tints it from `ColorScheme.onSurface`.
  final Color? trackColor;

  /// Color of the outline around the scrollbar track.
  ///
  /// **Only drawn when [trackVisibility] is true**, on the same terms as
  /// [trackColor].
  final Color? trackBorderColor;

  /// Whether the thumb stays visible once scrolling stops.
  ///
  /// If **true**, the thumb is pinned on screen.
  ///
  /// If **false or null** — these behave identically — the thumb fades in while
  /// the list scrolls and fades out shortly after it stops. Neither value hides
  /// it outright.
  ///
  /// Setting [trackVisibility] to true raises this to true, because Flutter
  /// cannot draw a track without a thumb.
  final bool? thumbVisibility;

  /// Whether the track is drawn behind the thumb.
  ///
  /// If **null**, the ambient `ScrollbarTheme` decides, and failing that
  /// Flutter's own default: **false**. There is no track, and [trackColor] and
  /// [trackBorderColor] paint nothing.
  ///
  /// If **true**, the track is drawn and [thumbVisibility] is raised to true
  /// along with it, because Flutter cannot draw a track without a thumb.
  ///
  /// Flutter widens a thickness-less scrollbar from 8 to 12 while a pointer
  /// hovers a visible track. The menu hands `Scrollbar` a concrete [thickness]
  /// whatever this theme says, so the bar keeps its width. Nothing to do here.
  final bool? trackVisibility;

  /// Whether the user may drag the thumb.
  ///
  /// If **null**, the ambient `ScrollbarTheme` decides, and failing that
  /// Flutter's own default, which is **draggable on desktop** and not on
  /// Android. Null does not mean "display only".
  ///
  /// Pass **false** for a scrollbar that is drawn but cannot be grabbed.
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
  ///   Colors.white.withValues(alpha: 0.5),
  ///   Colors.white.withValues(alpha: 0.0),
  /// ]
  /// ```
  ///
  /// If null, auto-detects from dropdown background color.
  final List<Color>? gradientColors;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownScrollTheme copyWith({
    double? thickness,
    double? thumbWidth,
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
    final custom = thumbWidth != null;

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
