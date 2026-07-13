import 'package:flutter/material.dart';

import 'resolved_dropdown_style.dart';

/// Styling for the checkbox drawn on each row of a [FlutterMultiSelectDropdown].
///
/// The menu is drawn in an [OverlayEntry] inserted at the root [Overlay], so a
/// local [Theme] wrapping the dropdown never reaches it — only an app-wide
/// [CheckboxThemeData] does, and that restyles every checkbox in the app. This
/// theme is how you recolour *just this dropdown's* boxes. Naming a field
/// overrides that slot; leaving it null defers to the ambient
/// [CheckboxThemeData]. See [resolve].
///
/// Only the fields that actually render are here. The box is drawn with
/// `onChanged: null` (it is presentational — a tap falls through to the row) and
/// with its semantics excluded (the row announces the checked state). That rules
/// out every focus/hover/splash/overlay/semantic-label field, which a
/// non-interactive, semantics-excluded checkbox never shows. [mouseCursor] is
/// the exception: its `MouseRegion` is installed whether or not the box is
/// interactive, so it is honoured here.
///
/// ```dart
/// FlutterMultiSelectDropdown<String>(
///   // …
///   theme: DropdownStyleTheme(
///     checkbox: DropdownCheckboxTheme(
///       activeColor: Colors.teal,        // fill of a checked box
///       checkColor: Colors.white,        // the checkmark
///       side: BorderSide(color: Colors.grey, width: 2), // unchecked outline
///       shape: RoundedRectangleBorder(
///         borderRadius: BorderRadius.circular(4),
///       ),
///     ),
///   ),
/// )
/// ```
class DropdownCheckboxTheme {
  /// Creates a checkbox theme configuration.
  const DropdownCheckboxTheme({
    this.activeColor,
    this.fillColor,
    this.checkColor,
    this.side,
    this.shape,
    this.materialTapTargetSize,
    this.visualDensity,
    this.mouseCursor,
  });

  /// The fill of a **checked** box.
  ///
  /// A convenience for the common case: it is resolved into [fillColor] for the
  /// selected state. The box is drawn with `onChanged: null`, which Flutter
  /// treats as `disabled`; a plain `Checkbox.activeColor` is dropped in that
  /// state, so this is routed through [fillColor] — which [Checkbox] consults
  /// first — to make it survive. If [fillColor] is also given, that wins and
  /// this is ignored.
  final Color? activeColor;

  /// The box's fill per [WidgetState], for full control.
  ///
  /// Takes precedence over [activeColor]. To colour the checked box, return a
  /// colour for the `selected` state (it arrives alongside `disabled`, since the
  /// box is non-interactive) and null otherwise, so an unchecked box keeps the
  /// ambient default.
  final WidgetStateProperty<Color?>? fillColor;

  /// The colour of the checkmark. If null, the ambient [CheckboxThemeData]
  /// decides.
  final Color? checkColor;

  /// The outline of an **unchecked** box. A checked box draws no outline — its
  /// fill covers it. If null, the ambient [CheckboxThemeData] decides.
  final BorderSide? side;

  /// The box's shape — rounded corners, say. If null, the ambient
  /// [CheckboxThemeData] decides.
  final OutlinedBorder? shape;

  /// The size class the box occupies. If null, the ambient [CheckboxThemeData]
  /// decides.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// The density adjustment applied to the box's size. If null, the ambient
  /// [CheckboxThemeData] decides.
  final VisualDensity? visualDensity;

  /// The cursor shown while a pointer is over the box.
  ///
  /// The box's `MouseRegion` is installed regardless of its (non-)interactivity,
  /// so this is honoured even though the box is drawn `onChanged: null`. The box
  /// sits inside the row's ink well, which shows a click cursor; by default the
  /// box's own cursor differs over its small area, so set this to
  /// [SystemMouseCursors.click] to make the whole row read as one target. If
  /// null, the ambient [CheckboxThemeData] decides.
  final MouseCursor? mouseCursor;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownCheckboxTheme copyWith({
    Color? activeColor,
    WidgetStateProperty<Color?>? fillColor,
    Color? checkColor,
    BorderSide? side,
    OutlinedBorder? shape,
    MaterialTapTargetSize? materialTapTargetSize,
    VisualDensity? visualDensity,
    MouseCursor? mouseCursor,
  }) {
    return DropdownCheckboxTheme(
      activeColor: activeColor ?? this.activeColor,
      fillColor: fillColor ?? this.fillColor,
      checkColor: checkColor ?? this.checkColor,
      side: side ?? this.side,
      shape: shape ?? this.shape,
      materialTapTargetSize:
          materialTapTargetSize ?? this.materialTapTargetSize,
      visualDensity: visualDensity ?? this.visualDensity,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  /// The checkbox as it should be drawn.
  ///
  /// Pure — it reads no [BuildContext]. Its one job is turning the convenience
  /// [activeColor] into a [fillColor] that answers for the selected state
  /// whether or not `disabled` is also present, which is the state the box is
  /// actually in. Every other field is passed straight through, and an unset
  /// field stays null so the ambient [CheckboxThemeData] keeps control.
  ResolvedCheckboxStyle resolve() {
    return ResolvedCheckboxStyle(
      fillColor: fillColor ?? _fillFromActiveColor(),
      checkColor: checkColor,
      side: side,
      shape: shape,
      materialTapTargetSize: materialTapTargetSize,
      visualDensity: visualDensity,
      mouseCursor: mouseCursor,
    );
  }

  /// [activeColor] as a [fillColor]: the accent when the box is selected — with
  /// or without `disabled` — and null (defer to ambient) when it is not.
  WidgetStateProperty<Color?>? _fillFromActiveColor() {
    final accent = activeColor;
    if (accent == null) return null;
    return WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? accent : null,
    );
  }

  /// Default theme: every slot deferred to the ambient [CheckboxThemeData].
  static const DropdownCheckboxTheme defaultTheme = DropdownCheckboxTheme();
}
