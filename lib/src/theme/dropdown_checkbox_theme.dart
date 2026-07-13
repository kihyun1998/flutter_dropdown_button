import 'package:flutter/material.dart';
import 'package:flutter_checkbox/flutter_checkbox.dart';

/// Styling for the checkbox drawn on each row of a [FlutterMultiSelectDropdown].
///
/// The box is a [FlutterCheckbox] (the `flutter_checkbox` package), not Flutter's
/// built-in [Checkbox]. It is drawn presentationally — `onChanged: null` so a tap
/// falls through to the row's ink well, and with its semantics excluded so the
/// row announces the checked state. A `FlutterCheckbox` with `onChanged: null`
/// stays at full opacity (it is not forced into a disabled look the way Material
/// is), so the accent set here shows on a checked box directly.
///
/// Only the fields that actually render on a presentational box are here. That
/// rules out `flutter_checkbox`'s hover/focus/splash-ring and disabled-opacity
/// fields — a non-interactive, ring-less box never shows them — and its
/// animation-timing fields, which are left at the package default. [mouseCursor]
/// is the exception: the box's `MouseRegion` is installed regardless of
/// interactivity, so it is honoured.
///
/// The menu is drawn in an [OverlayEntry] at the root [Overlay], out of a local
/// [Theme]'s subtree, so only an app-wide theme would otherwise reach the box.
/// This theme recolours *just this dropdown's* boxes. A field left null keeps
/// [CheckboxStyle]'s default, which [FlutterCheckbox] resolves against the
/// ambient [ThemeData] — so an unset colour still follows the app theme.
///
/// ```dart
/// FlutterMultiSelectDropdown<String>(
///   // …
///   theme: DropdownStyleTheme(
///     checkbox: DropdownCheckboxTheme(
///       activeColor: Colors.teal,          // fill of a checked box
///       checkColor: Colors.white,          // the checkmark
///       borderColor: Colors.grey,          // unchecked outline
///       shape: CheckboxShape.circle,       // rectangle (default) or circle
///     ),
///   ),
/// )
/// ```
class DropdownCheckboxTheme {
  /// Creates a checkbox theme configuration.
  const DropdownCheckboxTheme({
    this.activeColor,
    this.checkColor,
    this.inactiveColor,
    this.borderColor,
    this.borderWidth,
    this.shape,
    this.borderRadius,
    this.size,
    this.checkStrokeWidth,
    this.checkScale,
    this.mouseCursor,
  });

  /// The fill of a **checked** box. If null, defers to the ambient theme's
  /// primary colour.
  final Color? activeColor;

  /// The colour of the checkmark. If null, defers to white.
  final Color? checkColor;

  /// The fill of an **unchecked** box. If null, transparent.
  final Color? inactiveColor;

  /// The outline of an **unchecked** box. A checked box draws no outline — its
  /// fill covers it. If null, defers to the ambient theme's outline colour.
  final Color? borderColor;

  /// The width of the unchecked box's outline. If null, `2`.
  final double? borderWidth;

  /// The box's shape — [CheckboxShape.rectangle] (default) or
  /// [CheckboxShape.circle]. If null, rectangle.
  final CheckboxShape? shape;

  /// The corner radius of a rectangle box. Ignored for a circle. If null, `4`.
  final double? borderRadius;

  /// The width and height of the box in logical pixels. If null, `24`.
  final double? size;

  /// The stroke width of the checkmark. If null, `2.5`.
  final double? checkStrokeWidth;

  /// A scale for the checkmark within the box, about its centre — `0.7` draws a
  /// smaller tick with more padding. If null, `1.0`.
  final double? checkScale;

  /// The cursor shown while a pointer is over the box.
  ///
  /// The box's `MouseRegion` is installed even though it is drawn
  /// `onChanged: null`. The box sits inside the row's ink well, which shows a
  /// click cursor; set this to [SystemMouseCursors.click] to make the whole row
  /// read as one target. If null, defers to [FlutterCheckbox]'s own default.
  final MouseCursor? mouseCursor;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownCheckboxTheme copyWith({
    Color? activeColor,
    Color? checkColor,
    Color? inactiveColor,
    Color? borderColor,
    double? borderWidth,
    CheckboxShape? shape,
    double? borderRadius,
    double? size,
    double? checkStrokeWidth,
    double? checkScale,
    MouseCursor? mouseCursor,
  }) {
    return DropdownCheckboxTheme(
      activeColor: activeColor ?? this.activeColor,
      checkColor: checkColor ?? this.checkColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
      size: size ?? this.size,
      checkStrokeWidth: checkStrokeWidth ?? this.checkStrokeWidth,
      checkScale: checkScale ?? this.checkScale,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  /// The box's style, in the shape [FlutterCheckbox] takes.
  ///
  /// Pure — it reads no [BuildContext]. Each named field is set on the returned
  /// [CheckboxStyle]; each unset field keeps [CheckboxStyle]'s own default, and
  /// [FlutterCheckbox] resolves those defaults (and any null colour) against the
  /// ambient [ThemeData] at build time. [mouseCursor] is not part of the style —
  /// it is a constructor argument of [FlutterCheckbox] — so it is read directly.
  CheckboxStyle resolve() {
    return const CheckboxStyle().copyWith(
      activeColor: activeColor,
      checkColor: checkColor,
      inactiveColor: inactiveColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      shape: shape,
      borderRadius: borderRadius,
      size: size,
      checkStrokeWidth: checkStrokeWidth,
      checkScale: checkScale,
    );
  }

  /// Default theme: every slot deferred to the ambient [ThemeData].
  static const DropdownCheckboxTheme defaultTheme = DropdownCheckboxTheme();
}
