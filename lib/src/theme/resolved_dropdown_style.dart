import 'package:flutter/material.dart';

/// The ambient values a dropdown falls back to when its theme leaves a slot
/// empty, lifted out of [ThemeData] as plain colours.
///
/// Resolution takes one of these rather than a [BuildContext]. Pulling values
/// *out of* a context depends on the element tree; *deciding* with them does
/// not, and only the second half is worth testing.
class DropdownAmbientColors {
  /// Creates the ambient palette.
  const DropdownAmbientColors({
    required this.card,
    required this.divider,
    required this.splash,
    required this.highlight,
    required this.hover,
    required this.primary,
    required this.disabled,
    this.icon,
    this.hint,
  });

  /// Reads the palette from the enclosing [Theme].
  factory DropdownAmbientColors.of(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownAmbientColors(
      card: theme.cardColor,
      divider: theme.dividerColor,
      splash: theme.splashColor,
      highlight: theme.highlightColor,
      hover: theme.hoverColor,
      primary: theme.primaryColor,
      disabled: theme.disabledColor,
      icon: theme.iconTheme.color,
      hint: theme.hintColor,
    );
  }

  /// Background of surfaces that sit above the page — the menu.
  final Color card;

  /// Hairline borders.
  final Color divider;

  /// Ink ripple.
  final Color splash;

  /// Focus highlight.
  final Color highlight;

  /// Pointer hover wash.
  final Color hover;

  /// Accent, used to tint the selected item.
  final Color primary;

  /// Foreground of anything switched off.
  final Color disabled;

  /// Default icon colour. Null when the ambient theme leaves it unset.
  final Color? icon;

  /// Foreground of placeholder text — the empty-search message.
  final Color? hint;
}

/// The tooltip's appearance, with every slot the theme touches filled in.
class ResolvedTooltipStyle {
  /// Creates a resolved tooltip style.
  const ResolvedTooltipStyle({this.decoration});

  /// The tooltip's box, or null to leave it to Flutter.
  ///
  /// Null means the theme named no box property, so the ambient [TooltipTheme]
  /// — or, failing that, [Tooltip]'s own default — keeps control. Handing
  /// [Tooltip] a decoration *replaces* that default outright rather than
  /// merging with it, so a partially-specified box would blank every slot it
  /// did not restate. Non-null therefore always means complete.
  final Decoration? decoration;
}

/// The search field's appearance, with every slot filled in.
class ResolvedSearchFieldStyle {
  /// Creates a resolved search field style.
  const ResolvedSearchFieldStyle({
    required this.decoration,
    required this.fieldHeight,
    required this.margin,
    required this.cursorWidth,
    required this.keyboardType,
    required this.textInputAction,
    required this.textAlign,
    required this.autofocus,
    required this.dividerHeight,
    required this.totalHeight,
    this.textStyle,
    this.cursorColor,
    this.cursorHeight,
    this.cursorRadius,
    this.padding,
    this.divider,
  });

  /// The text field's decoration, already merged with the theme's borders.
  final InputDecoration decoration;

  /// Height of the field itself, excluding margin and divider.
  final double fieldHeight;

  /// Space around the field.
  final EdgeInsets margin;

  /// Cursor width.
  final double cursorWidth;

  /// Soft keyboard type.
  final TextInputType keyboardType;

  /// Soft keyboard action button.
  final TextInputAction textInputAction;

  /// Horizontal alignment of the query text.
  final TextAlign textAlign;

  /// Whether the field takes focus when the menu opens.
  final bool autofocus;

  /// Height reserved for [divider], and the height it is drawn at.
  final double dividerHeight;

  /// Everything the search field occupies: field, margin and divider.
  ///
  /// This is what the overlay reserves as chrome. Reserving less than the
  /// field draws overflows the item list.
  final double totalHeight;

  /// Style of the query text.
  final TextStyle? textStyle;

  /// Cursor colour.
  final Color? cursorColor;

  /// Cursor height.
  final double? cursorHeight;

  /// Cursor corner radius.
  final Radius? cursorRadius;

  /// Padding inside the field's container.
  final EdgeInsets? padding;

  /// Separator between the field and the item list.
  final Widget? divider;
}

/// The scrollbar's measurements, with every slot filled in.
class ResolvedScrollStyle {
  /// Creates a resolved scroll style.
  const ResolvedScrollStyle({
    required this.thumbWidth,
    required this.trackWidth,
    required this.gradientHeight,
    required this.hasCustomWidths,
    required this.thumbVisibility,
    required this.trackVisibility,
    required this.interactive,
    required this.crossAxisMargin,
    required this.mainAxisMargin,
    required this.minThumbLength,
  });

  /// Width of the thumb.
  final double thumbWidth;

  /// Width of the track.
  final double trackWidth;

  /// Height of the fade shown when the list can scroll.
  final double gradientHeight;

  /// Whether the caller asked for widths the stock `Scrollbar` cannot honour.
  final bool hasCustomWidths;

  /// Whether the thumb is always shown.
  final bool thumbVisibility;

  /// Whether the track is always shown.
  final bool trackVisibility;

  /// Whether the thumb can be dragged.
  final bool interactive;

  /// Distance from the scroll view's edge.
  final double crossAxisMargin;

  /// Distance from the scroll view's ends.
  final double mainAxisMargin;

  /// Shortest the thumb is allowed to become.
  final double minThumbLength;
}

/// The button's appearance, with every slot filled in.
class ResolvedButtonStyle {
  /// Creates a resolved button style.
  const ResolvedButtonStyle({
    required this.decoration,
    required this.padding,
    required this.borderRadius,
    required this.splashColor,
    required this.highlightColor,
    required this.hoverColor,
    required this.contentHeight,
    required this.iconSize,
    required this.icon,
    required this.iconPadding,
    this.iconColor,
  });

  /// The button's box, already switched for enabled or disabled.
  final BoxDecoration decoration;

  /// Space between the button's edge and its content.
  final EdgeInsets padding;

  /// Corner radius, shared with the ink ripple.
  final double borderRadius;

  /// Ink ripple colour.
  final Color splashColor;

  /// Focus highlight colour.
  final Color highlightColor;

  /// Pointer hover colour.
  final Color hoverColor;

  /// Height of the row holding the selected value and the arrow.
  final double contentHeight;

  /// Size of the trailing arrow.
  final double iconSize;

  /// The trailing arrow.
  final IconData icon;

  /// Space between the value and the arrow.
  final EdgeInsets iconPadding;

  /// Arrow colour, already switched for enabled or disabled.
  final Color? iconColor;
}

/// The menu container's appearance, with every slot filled in.
class ResolvedOverlayStyle {
  /// Creates a resolved overlay style.
  const ResolvedOverlayStyle({
    required this.decoration,
    required this.backgroundColor,
    required this.borderRadius,
    required this.elevation,
    required this.borderThickness,
    this.shadowColor,
    this.padding,
  });

  /// The menu's box.
  final BoxDecoration decoration;

  /// The menu's fill, exposed for the scroll gradient to fade into.
  final Color backgroundColor;

  /// Corner radius.
  final double borderRadius;

  /// Shadow depth.
  final double elevation;

  /// Top plus bottom border width, which the placement module reserves.
  final double borderThickness;

  /// Shadow colour.
  final Color? shadowColor;

  /// Space between the menu's edge and its item list.
  final EdgeInsets? padding;
}

/// One item row's appearance, with every slot filled in.
class ResolvedItemStyle {
  /// Creates a resolved item style.
  const ResolvedItemStyle({
    required this.decoration,
    required this.padding,
    required this.inkBorderRadius,
    required this.splashColor,
    required this.highlightColor,
    required this.hoverColor,
    this.margin,
  });

  /// The row's box, already switched for selection and for its position.
  final BoxDecoration decoration;

  /// Space between the row's edge and its content.
  final EdgeInsets padding;

  /// Corner radius of the ink ripple, which is not always the box's.
  final double inkBorderRadius;

  /// Ink ripple colour.
  final Color splashColor;

  /// Focus highlight colour.
  final Color highlightColor;

  /// Pointer hover colour.
  final Color hoverColor;

  /// Space around the row.
  final EdgeInsets? margin;
}
