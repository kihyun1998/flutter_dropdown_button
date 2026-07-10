import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import 'resolved_dropdown_style.dart';

/// Theme configuration for tooltip styling and behavior in dropdown widgets.
///
/// This class contains all tooltip-related properties including visual styling
/// (colors, borders, padding, shadows) and behavioral settings (when to show,
/// durations, trigger modes, positioning).
///
/// Example:
/// ```dart
/// DropdownTooltipTheme(
///   // Visual styling
///   backgroundColor: Colors.black87,
///   textStyle: TextStyle(color: Colors.white, fontSize: 14),
///   borderRadius: BorderRadius.circular(8),
///   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
///   shadow: [
///     BoxShadow(
///       color: Colors.black26,
///       blurRadius: 8,
///       offset: Offset(0, 2),
///     ),
///   ],
///   // Behavioral settings
///   enabled: true,
///   mode: TooltipMode.onlyWhenOverflow,
///   waitDuration: Duration(milliseconds: 500),
///   showDuration: Duration(seconds: 3),
/// )
/// ```
///
/// Naming any one of [backgroundColor], [borderRadius], [border] or [shadow]
/// hands this theme the tooltip's whole box; the ones left unset fall back to
/// [Tooltip]'s own defaults. Naming none of them leaves the box alone, so an
/// app-wide [TooltipTheme] still applies. See [resolve].
class DropdownTooltipTheme {
  /// Creates a tooltip theme configuration.
  const DropdownTooltipTheme({
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.decoration,
    this.borderRadius,
    this.border,
    this.shadow,
    this.padding,
    this.margin,
    this.constraints,
    this.textAlign,
    this.enabled = true,
    this.mode = TooltipMode.onlyWhenOverflow,
    this.waitDuration = const Duration(milliseconds: 500),
    this.showDuration = const Duration(seconds: 3),
    this.exitDuration = const Duration(milliseconds: 100),
    this.verticalOffset,
    this.preferBelow,
    this.enableTapToDismiss,
    this.triggerMode,
  });

  /// The background color of the tooltip.
  ///
  /// If null, uses Flutter's own tooltip background — dark grey on a light
  /// theme, off-white on a dark one.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final Color? backgroundColor;

  /// The text color for tooltip content.
  ///
  /// If null, uses Flutter's default tooltip text color (white).
  /// This is a convenience property that creates a TextStyle internally.
  /// If [textStyle] is provided, this property is ignored.
  final Color? textColor;

  /// The text style for tooltip content.
  ///
  /// If provided, this takes precedence over [textColor].
  /// If null, uses Flutter's default tooltip text style (white text).
  final TextStyle? textStyle;

  /// The decoration for the tooltip background.
  ///
  /// If provided, this takes precedence over [backgroundColor],
  /// [borderRadius], [border] and [shadow], and the tooltip's box is entirely
  /// yours.
  ///
  /// If null, a [BoxDecoration] is built from the individual style properties
  /// — but only if at least one of them is set. Naming one of them hands the
  /// whole box to this theme, so the rest fall back to [Tooltip]'s own
  /// defaults rather than to nothing. Naming none of them leaves the box to
  /// the ambient [TooltipTheme].
  final Decoration? decoration;

  /// The border radius of the tooltip.
  ///
  /// If null, uses Flutter's own tooltip corners — a 4-pixel radius.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final BorderRadius? borderRadius;

  /// The border of the tooltip.
  ///
  /// If null, no border is displayed.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final BoxBorder? border;

  /// The shadow for the tooltip.
  ///
  /// If null, the tooltip casts no shadow, as Flutter's own does not.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final List<BoxShadow>? shadow;

  /// The padding inside the tooltip.
  ///
  /// If null, uses Flutter's default tooltip padding.
  final EdgeInsetsGeometry? padding;

  /// The margin around the tooltip.
  ///
  /// Controls the spacing between the tooltip and the target widget.
  /// If null, uses Flutter's default tooltip margin.
  final EdgeInsetsGeometry? margin;

  /// The constraints for the tooltip's dimensions.
  ///
  /// Allows flexible sizing control using BoxConstraints.
  /// You can control min/max width and height of the tooltip.
  ///
  /// If null, uses Flutter's default tooltip constraints.
  ///
  /// Example:
  /// ```dart
  /// constraints: BoxConstraints(
  ///   minHeight: 32,
  ///   maxHeight: 200,
  ///   maxWidth: 300,
  /// )
  /// ```
  final BoxConstraints? constraints;

  /// The horizontal alignment of the tooltip text.
  ///
  /// Controls how the tooltip message is aligned horizontally.
  /// If null, uses Flutter's default (left-aligned).
  final TextAlign? textAlign;

  /// Whether to enable tooltip functionality for text content.
  ///
  /// When true, tooltips will be shown based on [mode].
  /// When false, tooltips are completely disabled.
  /// Defaults to true.
  final bool enabled;

  /// Determines when tooltips should be displayed.
  ///
  /// - [TooltipMode.onlyWhenOverflow]: Show tooltip only when text is clipped (default, recommended)
  /// - [TooltipMode.always]: Always show tooltip on hover/long-press
  /// - [TooltipMode.disabled]: Never show tooltips (same as setting [enabled] to false)
  ///
  /// Defaults to [TooltipMode.onlyWhenOverflow] for optimal UX.
  final TooltipMode mode;

  /// The duration to wait before showing the tooltip after hovering.
  ///
  /// On desktop platforms, this is the delay between mouse hover and tooltip appearance.
  /// Defaults to 500 milliseconds.
  final Duration waitDuration;

  /// How long the tooltip remains visible after it appears.
  ///
  /// After this duration, the tooltip will automatically dismiss.
  /// Defaults to 3 seconds.
  final Duration showDuration;

  /// The duration for the tooltip to fade out when hiding.
  ///
  /// This controls how long it takes for the tooltip to disappear after
  /// the pointer stops hovering or the showDuration expires.
  /// Defaults to 100 milliseconds.
  final Duration exitDuration;

  /// The vertical gap between the widget and the displayed tooltip.
  ///
  /// When [preferBelow] is true, this is the space between the
  /// widget's bottom edge and the tooltip's top edge.
  /// When false, this is the space between the widget's top edge and
  /// the tooltip's bottom edge.
  /// If null, uses Flutter's default vertical offset.
  final double? verticalOffset;

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
  final bool? preferBelow;

  /// Whether the tooltip can be dismissed by tapping on it.
  ///
  /// If true, tapping the tooltip will dismiss it.
  /// If false, the tooltip can only be dismissed by un-hovering or waiting
  /// for the [showDuration] to expire.
  /// If null, uses Flutter's default behavior (typically true).
  final bool? enableTapToDismiss;

  /// Determines how the tooltip is triggered.
  ///
  /// Controls whether the tooltip appears on hover, long press, tap, or manually.
  /// If null, uses Flutter's default trigger mode (typically long press on mobile,
  /// hover on desktop).
  final TooltipTriggerMode? triggerMode;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownTooltipTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    TextStyle? textStyle,
    Decoration? decoration,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? shadow,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxConstraints? constraints,
    TextAlign? textAlign,
    bool? enabled,
    TooltipMode? mode,
    Duration? waitDuration,
    Duration? showDuration,
    Duration? exitDuration,
    double? verticalOffset,
    bool? preferBelow,
    bool? enableTapToDismiss,
    TooltipTriggerMode? triggerMode,
  }) {
    return DropdownTooltipTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      constraints: constraints ?? this.constraints,
      textAlign: textAlign ?? this.textAlign,
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      exitDuration: exitDuration ?? this.exitDuration,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      preferBelow: preferBelow ?? this.preferBelow,
      enableTapToDismiss: enableTapToDismiss ?? this.enableTapToDismiss,
      triggerMode: triggerMode ?? this.triggerMode,
    );
  }

  /// The tooltip as it should be drawn.
  ///
  /// Pure: hand it the ambient [Brightness], not a [BuildContext]. Unlike the
  /// other themes this one takes no [DropdownAmbientColors] — a tooltip's
  /// defaults come from [Tooltip] itself, which switches on brightness alone
  /// and never consults [ThemeData]'s palette.
  ResolvedTooltipStyle resolve(Brightness brightness) {
    return ResolvedTooltipStyle(decoration: _resolveDecoration(brightness));
  }

  /// Flutter's own tooltip corner radius.
  static const BorderRadius _defaultRadius = BorderRadius.all(
    Radius.circular(4),
  );

  /// Flutter's own tooltip background, which flips with the ambient brightness.
  static Color _defaultBackground(Brightness brightness) =>
      brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.9)
          : Colors.grey.shade700.withValues(alpha: 0.9);

  Decoration? _resolveDecoration(Brightness brightness) {
    if (decoration != null) return decoration;

    final touchesTheBox =
        backgroundColor != null ||
        borderRadius != null ||
        border != null ||
        shadow != null;
    if (!touchesTheBox) return null;

    return BoxDecoration(
      color: backgroundColor ?? _defaultBackground(brightness),
      borderRadius: borderRadius ?? _defaultRadius,
      border: border,
      boxShadow: shadow,
    );
  }

  /// Default theme that works well with Material Design.
  static const DropdownTooltipTheme defaultTheme = DropdownTooltipTheme();
}
