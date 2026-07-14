import 'package:flutter/material.dart';

import 'resolved_dropdown_style.dart';

/// Visual styling for the **rows** of a dropdown menu — one item each.
///
/// One of the three surface sub-themes that replaced the monolithic
/// `DropdownTheme` in 4.0.0; the others are `DropdownButtonTheme` (the button
/// face) and `DropdownOverlayTheme` (the menu container). Reached through the
/// `item` slot on `DropdownStyleTheme`, and used by both the single-select menu
/// and the multi-select checklist (the checkbox on a checklist row is styled
/// separately, via `DropdownCheckboxTheme`).
///
/// [resolveItem] fills every slot. Besides a [DropdownAmbientColors] it takes the
/// menu's corner radius: absent an explicit [borderRadius], the first and last
/// rows round to the menu's corners so they sit flush against them — the one
/// place a row's styling depends on the container's.
class DropdownItemTheme {
  /// Creates a row theme.
  const DropdownItemTheme({
    this.selectedColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin,
    this.borderRadius,
    this.border,
    this.excludeLastItemBorder = true,
  });

  /// Background of a **selected** row. If null, the ambient primary at 10%.
  final Color? selectedColor;

  /// Pointer hover colour. If null, the ambient hover colour.
  final Color? hoverColor;

  /// Ink ripple colour. If null, the ambient splash colour.
  final Color? splashColor;

  /// Focus highlight colour. If null, the ambient highlight colour.
  final Color? highlightColor;

  /// Space between a row's edge and its content.
  final EdgeInsets padding;

  /// Space around each row.
  final EdgeInsets? margin;

  /// Corner radius of each row. If null, only the first and last rows round —
  /// to the menu's corner radius — and the rest are square.
  final double? borderRadius;

  /// Border drawn on each row — a divider between items, say. If null, none.
  final Border? border;

  /// Whether the last row skips [border], for a clean bottom edge. Defaults to
  /// true; only matters when [border] is set.
  final bool excludeLastItemBorder;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownItemTheme copyWith({
    Color? selectedColor,
    Color? hoverColor,
    Color? splashColor,
    Color? highlightColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? borderRadius,
    Border? border,
    bool? excludeLastItemBorder,
  }) {
    return DropdownItemTheme(
      selectedColor: selectedColor ?? this.selectedColor,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      excludeLastItemBorder:
          excludeLastItemBorder ?? this.excludeLastItemBorder,
    );
  }

  /// One item row as it should be drawn.
  ///
  /// [menuBorderRadius] is the enclosing menu's corner radius — the end rows
  /// round to it when [borderRadius] is unset.
  ResolvedItemStyle resolveItem(
    DropdownAmbientColors ambient, {
    required bool selected,
    required bool isFirst,
    required bool isLast,
    required double menuBorderRadius,
  }) {
    return ResolvedItemStyle(
      decoration: BoxDecoration(
        color: selected
            ? selectedColor ?? ambient.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : null,
        border: (isLast && excludeLastItemBorder) ? null : border,
      ),
      padding: padding,
      margin: margin,
      inkBorderRadius:
          borderRadius ?? (isFirst || isLast ? menuBorderRadius : 0.0),
      splashColor: splashColor ?? ambient.splash,
      highlightColor: highlightColor ?? ambient.highlight,
      hoverColor: hoverColor ?? ambient.hover,
    );
  }

  /// Default theme.
  static const DropdownItemTheme defaultTheme = DropdownItemTheme();
}
