import 'package:flutter/material.dart';

import 'resolved_dropdown_style.dart';

/// Visual styling for the dropdown **menu container** — the box the item list is
/// drawn inside, floating in the overlay.
///
/// One of the three surface sub-themes that replaced the monolithic
/// `DropdownTheme` in 4.0.0; the others are `DropdownButtonTheme` (the button
/// face) and `DropdownItemTheme` (the rows). Reached through the `overlay` slot
/// on `DropdownStyleTheme`, and used by both the single- and multi-select menus.
///
/// [resolveOverlay] fills every slot and needs no [BuildContext] — hand it a
/// [DropdownAmbientColors].
class DropdownOverlayTheme {
  /// Creates a menu-container theme.
  const DropdownOverlayTheme({
    this.borderRadius = 8.0,
    this.elevation = 8.0,
    this.backgroundColor,
    this.border,
    this.shadowColor,
    this.padding,
    this.decoration,
  });

  /// Corner radius of the menu. The end rows round to this too, so they sit
  /// flush against the corners.
  final double borderRadius;

  /// Shadow depth of the menu material.
  final double elevation;

  /// Menu fill. If null, the ambient card colour.
  final Color? backgroundColor;

  /// Menu border. If null, the ambient divider colour at 1px.
  final Border? border;

  /// Shadow colour of the menu material. If null, the Material default.
  final Color? shadowColor;

  /// Space between the menu's edge and its item list.
  final EdgeInsets? padding;

  /// A complete decoration for the menu, overriding [backgroundColor], [border]
  /// and [borderRadius]. For gradients, images, custom shadows.
  final BoxDecoration? decoration;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownOverlayTheme copyWith({
    double? borderRadius,
    double? elevation,
    Color? backgroundColor,
    Border? border,
    Color? shadowColor,
    EdgeInsets? padding,
    BoxDecoration? decoration,
  }) {
    return DropdownOverlayTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      shadowColor: shadowColor ?? this.shadowColor,
      padding: padding ?? this.padding,
      decoration: decoration ?? this.decoration,
    );
  }

  /// The menu container as it should be drawn.
  ResolvedOverlayStyle resolveOverlay(DropdownAmbientColors ambient) {
    final background = backgroundColor ?? ambient.card;
    final resolved =
        decoration ??
        BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: ambient.divider, width: 1),
        );

    final resolvedBorder = resolved.border;

    return ResolvedOverlayStyle(
      decoration: resolved,
      backgroundColor: background,
      borderRadius: borderRadius,
      elevation: elevation,
      shadowColor: shadowColor,
      padding: padding,
      borderThickness: resolvedBorder is Border
          ? resolvedBorder.top.width + resolvedBorder.bottom.width
          : 0.0,
    );
  }

  /// Default theme.
  static const DropdownOverlayTheme defaultTheme = DropdownOverlayTheme();
}
