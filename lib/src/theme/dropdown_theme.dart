import 'package:flutter/material.dart';

import 'resolved_dropdown_style.dart';

/// Visual styling for [FlutterDropdownButton]'s button, overlay and items.
///
/// The theme fills in its own gaps: [resolveButton], [resolveOverlay] and
/// [resolveItem] return styles whose slots are all filled, so the widget reads
/// a decision rather than making one.
///
/// Example:
/// ```dart
/// DropdownTheme(
///   borderRadius: 12.0,
///   elevation: 4.0,
///   backgroundColor: Colors.white,
///   border: Border.all(color: Colors.grey),
/// )
/// ```
class DropdownTheme {
  /// Creates a dropdown theme configuration.
  const DropdownTheme({
    this.borderRadius = 8.0,
    this.elevation = 8.0,
    this.backgroundColor,
    this.border,
    this.selectedItemColor,
    this.itemHoverColor,
    this.itemSplashColor,
    this.itemHighlightColor,
    this.buttonHoverColor,
    this.buttonSplashColor,
    this.buttonHighlightColor,
    this.shadowColor,
    this.overlayDecoration,
    this.buttonDecoration,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.buttonPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.itemMargin,
    this.itemBorderRadius,
    this.iconColor,
    this.iconDisabledColor,
    this.icon,
    this.iconSize,
    this.buttonHeight,
    this.iconPadding,
    this.overlayPadding,
    this.itemBorder,
    this.excludeLastItemBorder = true,
    this.disabledBackgroundColor,
    this.disabledBorder,
    this.disabledButtonDecoration,
  });

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

  /// The color of the ripple effect when tapping dropdown items.
  ///
  /// If null, uses the theme's splash color. This affects the
  /// Material ink splash animation on item interaction.
  final Color? itemSplashColor;

  /// The color of the highlight effect for focused dropdown items.
  ///
  /// If null, uses the theme's highlight color. This affects
  /// keyboard navigation and accessibility focus indicators.
  final Color? itemHighlightColor;

  /// The background color for the dropdown button on hover.
  ///
  /// If null, uses the theme's hover color. This provides
  /// visual feedback when hovering over the dropdown button.
  final Color? buttonHoverColor;

  /// The color of the ripple effect when tapping the dropdown button.
  ///
  /// If null, uses the theme's splash color. This affects the
  /// Material ink splash animation on button interaction.
  final Color? buttonSplashColor;

  /// The color of the highlight effect for the focused dropdown button.
  ///
  /// If null, uses the theme's highlight color. This affects
  /// keyboard navigation and accessibility focus indicators for the button.
  final Color? buttonHighlightColor;

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

  /// Margin applied around each dropdown item.
  ///
  /// Controls the external spacing between dropdown items.
  /// Creates visual separation between items for better UX.
  final EdgeInsets? itemMargin;

  /// Border radius applied to each individual dropdown item.
  ///
  /// If null, items will not have rounded corners.
  /// Allows for rounded item styling independent of overlay border radius.
  final double? itemBorderRadius;

  /// The color of the dropdown button icon (arrow) when enabled.
  ///
  /// If null, uses the theme's icon color.
  /// This allows customization of the dropdown arrow color
  /// independent of the global icon theme.
  final Color? iconColor;

  /// The color of the dropdown button icon (arrow) when disabled.
  ///
  /// If null, uses the theme's disabled color.
  /// This allows customization of the disabled dropdown arrow color.
  final Color? iconDisabledColor;

  /// The icon to display for the dropdown button.
  ///
  /// If null, uses the default [Icons.keyboard_arrow_down].
  /// This allows customization of the dropdown arrow icon.
  final IconData? icon;

  /// The size of the dropdown button icon.
  ///
  /// If null, uses the default size of 24.0.
  /// This allows customization of the dropdown arrow size.
  final double? iconSize;

  /// The height of the dropdown button content area.
  ///
  /// This controls the height of the selected value display area
  /// in the dropdown button. If null, falls back to iconSize (or 24.0).
  /// Setting this independently from iconSize allows for better control
  /// over button proportions when using different icon and text sizes.
  final double? buttonHeight;

  /// Padding applied around the dropdown button icon.
  ///
  /// If null, uses the default padding of EdgeInsets.only(left: 8.0).
  /// This controls the spacing between the selected value and the icon.
  final EdgeInsets? iconPadding;

  /// Padding applied to the dropdown overlay container.
  ///
  /// Controls the internal spacing of the dropdown menu container,
  /// creating space between the container edges and the item list.
  /// This is useful for creating consistent spacing at the top and bottom
  /// of the dropdown menu, especially when using itemMargin.
  ///
  /// For example, if itemMargin creates 8px spacing between items,
  /// setting overlayPadding to EdgeInsets.symmetric(vertical: 8) will
  /// create matching 8px spacing at the top and bottom of the menu.
  ///
  /// If null, no padding is applied to the overlay container.
  final EdgeInsets? overlayPadding;

  /// Border applied to each dropdown item.
  ///
  /// This allows you to add borders to individual items without using separators.
  /// Commonly used to add a bottom border between items:
  ///
  /// Example:
  /// ```dart
  /// DropdownTheme(
  ///   itemBorder: Border(
  ///     bottom: BorderSide(color: Colors.grey.shade300, width: 1),
  ///   ),
  /// )
  /// ```
  ///
  /// By default, the border is NOT applied to the last item when
  /// [excludeLastItemBorder] is true, creating a clean bottom edge.
  ///
  /// If null, no border is applied to items.
  final Border? itemBorder;

  /// Whether to exclude the border from the last dropdown item.
  ///
  /// When true (default), the [itemBorder] will not be applied to the last item
  /// in the dropdown list. This is the typical design pattern for dropdown menus
  /// with item borders, as it prevents a redundant border at the bottom of the list.
  ///
  /// When false, all items including the last one will have the [itemBorder] applied.
  ///
  /// This property only has an effect when [itemBorder] is not null.
  ///
  /// Defaults to true.
  final bool excludeLastItemBorder;

  /// The background color of the dropdown button when disabled.
  ///
  /// If null, falls back to the regular button background (transparent /
  /// [buttonDecoration]). Use this together with [disabledBorder] to give
  /// the disabled button a visually distinct appearance.
  final Color? disabledBackgroundColor;

  /// The border of the dropdown button when disabled.
  ///
  /// If null, falls back to the regular [border]. Only applied when
  /// [disabledButtonDecoration] is not provided.
  final Border? disabledBorder;

  /// Custom decoration for the dropdown button when disabled.
  ///
  /// If provided, this takes full precedence over [disabledBackgroundColor]
  /// and [disabledBorder] when the button is disabled. If null, the disabled
  /// appearance is composed from [disabledBackgroundColor] and
  /// [disabledBorder], falling back to [buttonDecoration] / [border].
  final BoxDecoration? disabledButtonDecoration;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownTheme copyWith({
    double? borderRadius,
    double? elevation,
    Color? backgroundColor,
    Border? border,
    Color? selectedItemColor,
    Color? itemHoverColor,
    Color? itemSplashColor,
    Color? itemHighlightColor,
    Color? buttonHoverColor,
    Color? buttonSplashColor,
    Color? buttonHighlightColor,
    Color? shadowColor,
    BoxDecoration? overlayDecoration,
    BoxDecoration? buttonDecoration,
    EdgeInsets? itemPadding,
    EdgeInsets? buttonPadding,
    EdgeInsets? itemMargin,
    double? itemBorderRadius,
    Color? iconColor,
    Color? iconDisabledColor,
    IconData? icon,
    double? iconSize,
    double? buttonHeight,
    EdgeInsets? iconPadding,
    EdgeInsets? overlayPadding,
    Border? itemBorder,
    bool? excludeLastItemBorder,
    Color? disabledBackgroundColor,
    Border? disabledBorder,
    BoxDecoration? disabledButtonDecoration,
  }) {
    return DropdownTheme(
      // ignore: deprecated_member_use_from_same_package
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      itemHoverColor: itemHoverColor ?? this.itemHoverColor,
      itemSplashColor: itemSplashColor ?? this.itemSplashColor,
      itemHighlightColor: itemHighlightColor ?? this.itemHighlightColor,
      buttonHoverColor: buttonHoverColor ?? this.buttonHoverColor,
      buttonSplashColor: buttonSplashColor ?? this.buttonSplashColor,
      buttonHighlightColor: buttonHighlightColor ?? this.buttonHighlightColor,
      shadowColor: shadowColor ?? this.shadowColor,
      overlayDecoration: overlayDecoration ?? this.overlayDecoration,
      buttonDecoration: buttonDecoration ?? this.buttonDecoration,
      itemPadding: itemPadding ?? this.itemPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      itemMargin: itemMargin ?? this.itemMargin,
      itemBorderRadius: itemBorderRadius ?? this.itemBorderRadius,
      iconColor: iconColor ?? this.iconColor,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      icon: icon ?? this.icon,
      iconSize: iconSize ?? this.iconSize,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      iconPadding: iconPadding ?? this.iconPadding,
      overlayPadding: overlayPadding ?? this.overlayPadding,
      itemBorder: itemBorder ?? this.itemBorder,
      excludeLastItemBorder:
          excludeLastItemBorder ?? this.excludeLastItemBorder,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledBorder: disabledBorder ?? this.disabledBorder,
      disabledButtonDecoration:
          disabledButtonDecoration ?? this.disabledButtonDecoration,
    );
  }

  /// Default theme that works well with Material Design.
  static const DropdownTheme defaultTheme = DropdownTheme();

  // ===== Resolution =====
  //
  // Every fallback the doc comments above promise is honoured here, once.
  // Callers read the result; they do not decide. None of this needs a
  // BuildContext — hand it a [DropdownAmbientColors] and it is a pure
  // function, testable without mounting a widget.

  /// The size the trailing arrow takes when [iconSize] is left unset.
  static const double defaultIconSize = 24.0;

  /// The size the trailing arrow will actually be drawn at.
  ///
  /// This is the one part of [resolveButton]'s answer that owes nothing to the
  /// ambient palette. It is exposed so that a caller who needs only this number
  /// can read it without resolving a whole [ResolvedButtonStyle] — and so that
  /// the fallback lives in exactly one place.
  double get resolvedIconSize => iconSize ?? defaultIconSize;

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
      decoration: _buttonDecoration(ambient, enabled: enabled),
      padding: buttonPadding,
      borderRadius: borderRadius,
      splashColor: buttonSplashColor ?? ambient.splash,
      highlightColor: buttonHighlightColor ?? ambient.highlight,
      hoverColor: buttonHoverColor ?? ambient.hover,
      contentHeight: buttonHeight ?? resolvedIconSize,
      iconSize: resolvedIconSize,
      icon: icon ?? Icons.keyboard_arrow_down,
      iconPadding: iconPadding ?? const EdgeInsets.only(left: 8.0),
      iconColor: enabled
          ? (iconColor ?? ambient.icon)
          : (iconDisabledColor ?? ambient.disabled),
    );
  }

  BoxDecoration _buttonDecoration(
    DropdownAmbientColors ambient, {
    required bool enabled,
  }) {
    if (!enabled) {
      // A full decoration overrides everything else.
      if (disabledButtonDecoration != null) return disabledButtonDecoration!;

      // Otherwise a disabled colour or border is enough to build one.
      if (disabledBackgroundColor != null || disabledBorder != null) {
        return BoxDecoration(
          color: disabledBackgroundColor,
          border:
              disabledBorder ?? border ?? Border.all(color: ambient.divider),
          borderRadius: BorderRadius.circular(borderRadius),
        );
      }
      // With no disabled styling at all, fall through to the enabled look.
    }

    return buttonDecoration ??
        BoxDecoration(
          border: border ?? Border.all(color: ambient.divider),
          borderRadius: BorderRadius.circular(borderRadius),
        );
  }

  /// The menu container as it should be drawn.
  ResolvedOverlayStyle resolveOverlay(DropdownAmbientColors ambient) {
    final background = backgroundColor ?? ambient.card;
    final decoration =
        overlayDecoration ??
        BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: ambient.divider, width: 1),
        );

    final decorationBorder = decoration.border;

    return ResolvedOverlayStyle(
      decoration: decoration,
      backgroundColor: background,
      borderRadius: borderRadius,
      elevation: elevation,
      shadowColor: shadowColor,
      padding: overlayPadding,
      borderThickness: decorationBorder is Border
          ? decorationBorder.top.width + decorationBorder.bottom.width
          : 0.0,
    );
  }

  /// One item row as it should be drawn.
  ///
  /// [isFirst] and [isLast] matter because, absent an explicit
  /// [itemBorderRadius], only the end rows are rounded — they sit against the
  /// menu's own corners.
  ResolvedItemStyle resolveItem(
    DropdownAmbientColors ambient, {
    required bool selected,
    required bool isFirst,
    required bool isLast,
  }) {
    return ResolvedItemStyle(
      decoration: BoxDecoration(
        color: selected
            ? selectedItemColor ?? ambient.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: itemBorderRadius != null
            ? BorderRadius.circular(itemBorderRadius!)
            : null,
        border: (isLast && excludeLastItemBorder) ? null : itemBorder,
      ),
      padding: itemPadding,
      margin: itemMargin,
      inkBorderRadius:
          itemBorderRadius ?? (isFirst || isLast ? borderRadius : 0.0),
      splashColor: itemSplashColor ?? ambient.splash,
      highlightColor: itemHighlightColor ?? ambient.highlight,
      hoverColor: itemHoverColor ?? ambient.hover,
    );
  }
}
