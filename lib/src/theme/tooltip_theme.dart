import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';

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
class DropdownTooltipTheme {
  /// Creates a tooltip theme configuration.
  const DropdownTooltipTheme({
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.decoration,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
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
  /// If null, uses Flutter's default tooltip background color (dark grey).
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
  /// [borderRadius], [borderColor], [borderWidth], and [shadow].
  ///
  /// If null, a BoxDecoration is created from the individual style properties.
  /// Customize this to match your app's design system.
  final Decoration? decoration;

  /// The border radius of the tooltip.
  ///
  /// If null, uses Flutter's default rounded corners.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final BorderRadius? borderRadius;

  /// The border color of the tooltip.
  ///
  /// If null, no border is displayed.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final Color? borderColor;

  /// The border width of the tooltip.
  ///
  /// Only applies if [borderColor] is also set.
  /// Defaults to 1.0 if [borderColor] is provided.
  /// This is a convenience property that creates a BoxDecoration internally.
  /// If [decoration] is provided, this property is ignored.
  final double? borderWidth;

  /// The shadow for the tooltip.
  ///
  /// If null, uses Flutter's default tooltip shadow.
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
    Color? borderColor,
    double? borderWidth,
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
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
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

  /// Default theme that works well with Material Design.
  static const DropdownTooltipTheme defaultTheme = DropdownTooltipTheme();
}
