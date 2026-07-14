import 'package:flutter/material.dart';

import 'resolved_dropdown_style.dart';

/// Visual styling for a [FlutterDropdownButton]'s **button face** — the box the
/// selected value and the trailing arrow sit in.
///
/// One of the three surface sub-themes that replaced the monolithic
/// `DropdownTheme` in 4.0.0; the others are `DropdownOverlayTheme` (the menu
/// container) and `DropdownItemTheme` (the rows). Reached through the `button`
/// slot on `DropdownStyleTheme`.
///
/// **Inert in bare mode.** When a dropdown is given an `anchorBuilder`, the
/// caller draws the whole anchor and this theme is not consulted — the button
/// box it describes does not exist. Menu, item, scroll, search and tooltip
/// theming still apply.
///
/// [resolveButton] fills every slot, so the widget reads a decision rather than
/// making one. It needs no [BuildContext] — hand it a [DropdownAmbientColors].
class DropdownButtonTheme {
  /// Creates a button-face theme.
  const DropdownButtonTheme({
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.border,
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.height,
    this.icon,
    this.iconColor,
    this.iconDisabledColor,
    this.iconSize,
    this.iconPadding,
    this.disabledBackgroundColor,
    this.disabledBorder,
    this.disabledDecoration,
  });

  /// Corner radius of the button box, shared with its ink ripple.
  final double borderRadius;

  /// Background fill of the button. If null, the button is transparent (unless
  /// [decoration] provides a fill).
  final Color? backgroundColor;

  /// Border of the button. If null, the ambient divider colour at 1px.
  final Border? border;

  /// A complete decoration for the button, overriding [backgroundColor],
  /// [border] and [borderRadius]. For gradients, images, custom shadows.
  final BoxDecoration? decoration;

  /// Space between the button's edge and its content.
  final EdgeInsets padding;

  /// Pointer hover colour. If null, the ambient hover colour.
  final Color? hoverColor;

  /// Ink ripple colour. If null, the ambient splash colour.
  final Color? splashColor;

  /// Focus highlight colour. If null, the ambient highlight colour.
  final Color? highlightColor;

  /// Height of the row holding the value and the arrow. If null, falls back to
  /// the icon size.
  final double? height;

  /// The trailing arrow icon. If null, [Icons.keyboard_arrow_down].
  final IconData? icon;

  /// Arrow colour when enabled. If null, the ambient icon colour.
  final Color? iconColor;

  /// Arrow colour when disabled. If null, the ambient disabled colour.
  final Color? iconDisabledColor;

  /// Arrow size. If null, 24.
  final double? iconSize;

  /// Space between the value and the arrow. If null, `EdgeInsets.only(left: 8)`.
  final EdgeInsets? iconPadding;

  /// Background fill when the button is disabled. Pairs with [disabledBorder].
  final Color? disabledBackgroundColor;

  /// Border when the button is disabled. If null, falls back to [border].
  final Border? disabledBorder;

  /// A complete decoration for the disabled button, overriding
  /// [disabledBackgroundColor] and [disabledBorder].
  final BoxDecoration? disabledDecoration;

  /// The size the trailing arrow takes when [iconSize] is left unset.
  static const double defaultIconSize = 24.0;

  /// The size the trailing arrow will actually be drawn at.
  ///
  /// Exposed so a caller who needs only this number (the single-select widget,
  /// centring a leading widget) can read it without resolving the whole style,
  /// and so the fallback lives in one place.
  double get resolvedIconSize => iconSize ?? defaultIconSize;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownButtonTheme copyWith({
    double? borderRadius,
    Color? backgroundColor,
    Border? border,
    BoxDecoration? decoration,
    EdgeInsets? padding,
    Color? hoverColor,
    Color? splashColor,
    Color? highlightColor,
    double? height,
    IconData? icon,
    Color? iconColor,
    Color? iconDisabledColor,
    double? iconSize,
    EdgeInsets? iconPadding,
    Color? disabledBackgroundColor,
    Border? disabledBorder,
    BoxDecoration? disabledDecoration,
  }) {
    return DropdownButtonTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      decoration: decoration ?? this.decoration,
      padding: padding ?? this.padding,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      height: height ?? this.height,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconSize: iconSize ?? this.iconSize,
      iconPadding: iconPadding ?? this.iconPadding,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      disabledDecoration: disabledDecoration ?? this.disabledDecoration,
    );
  }

  /// The button as it should be drawn.
  ///
  /// [enabled] must be the button's *effective* enabled state: a single-item
  /// dropdown disabled by policy is disabled here too.
  ResolvedButtonStyle resolveButton(
    DropdownAmbientColors ambient, {
    required bool enabled,
  }) {
    final resolvedIconSize = this.resolvedIconSize;

    return ResolvedButtonStyle(
      decoration: _decoration(ambient, enabled: enabled),
      padding: padding,
      borderRadius: borderRadius,
      splashColor: splashColor ?? ambient.splash,
      highlightColor: highlightColor ?? ambient.highlight,
      hoverColor: hoverColor ?? ambient.hover,
      contentHeight: height ?? resolvedIconSize,
      iconSize: resolvedIconSize,
      icon: icon ?? Icons.keyboard_arrow_down,
      iconPadding: iconPadding ?? const EdgeInsets.only(left: 8.0),
      iconColor: enabled
          ? (iconColor ?? ambient.icon)
          : (iconDisabledColor ?? ambient.disabled),
    );
  }

  BoxDecoration _decoration(
    DropdownAmbientColors ambient, {
    required bool enabled,
  }) {
    if (!enabled) {
      if (disabledDecoration != null) return disabledDecoration!;

      if (disabledBackgroundColor != null || disabledBorder != null) {
        return BoxDecoration(
          color: disabledBackgroundColor,
          border:
              disabledBorder ?? border ?? Border.all(color: ambient.divider),
          borderRadius: BorderRadius.circular(borderRadius),
        );
      }
    }

    return decoration ??
        BoxDecoration(
          color: backgroundColor,
          border: border ?? Border.all(color: ambient.divider),
          borderRadius: BorderRadius.circular(borderRadius),
        );
  }

  /// Default theme.
  static const DropdownButtonTheme defaultTheme = DropdownButtonTheme();
}
