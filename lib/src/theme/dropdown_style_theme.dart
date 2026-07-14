import 'dropdown_button_theme.dart';
import 'dropdown_checkbox_theme.dart';
import 'dropdown_item_theme.dart';
import 'dropdown_overlay_theme.dart';
import 'dropdown_scroll_theme.dart';
import 'search_field_theme.dart';
import 'tooltip_theme.dart';

/// Main theme container for all dropdown styling.
///
/// Composes one sub-theme per surface. The three that replaced the monolithic
/// `DropdownTheme` in 4.0.0 — [button], [overlay], [item] — sit beside the ones
/// that were always separate: [scroll], [tooltip], [search], [checkbox].
///
/// ```dart
/// DropdownStyleTheme(
///   button: DropdownButtonTheme(borderRadius: 12, backgroundColor: Colors.white),
///   overlay: DropdownOverlayTheme(elevation: 4),
///   item: DropdownItemTheme(selectedColor: Colors.teal),
/// )
/// ```
class DropdownStyleTheme {
  /// Creates a dropdown style theme.
  const DropdownStyleTheme({
    this.button = const DropdownButtonTheme(),
    this.overlay = const DropdownOverlayTheme(),
    this.item = const DropdownItemTheme(),
    this.scroll = const DropdownScrollTheme(),
    this.tooltip = const DropdownTooltipTheme(),
    this.search = const SearchFieldTheme(),
    this.checkbox = const DropdownCheckboxTheme(),
  });

  /// The button face — the box the value and the arrow sit in.
  ///
  /// Ignored in bare mode (`anchorBuilder`): the caller draws the anchor, so
  /// the button box this styles does not exist.
  final DropdownButtonTheme button;

  /// The menu container — the box the item list floats in.
  final DropdownOverlayTheme overlay;

  /// The rows of the menu.
  final DropdownItemTheme item;

  /// The scrollbar shown when the item list overflows.
  final DropdownScrollTheme scroll;

  /// The tooltip shown when an item's text overflows.
  final DropdownTooltipTheme tooltip;

  /// The search field shown at the top of a searchable menu.
  final SearchFieldTheme search;

  /// The checkbox on each row of a [FlutterMultiSelectDropdown].
  ///
  /// Ignored by the single-select [FlutterDropdownButton], which draws no
  /// checkbox. The menu is drawn in the root [Overlay], out of a local [Theme]'s
  /// reach, so naming a field here recolours just this dropdown's boxes where an
  /// app-wide theme cannot.
  final DropdownCheckboxTheme checkbox;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownStyleTheme copyWith({
    DropdownButtonTheme? button,
    DropdownOverlayTheme? overlay,
    DropdownItemTheme? item,
    DropdownScrollTheme? scroll,
    DropdownTooltipTheme? tooltip,
    SearchFieldTheme? search,
    DropdownCheckboxTheme? checkbox,
  }) {
    return DropdownStyleTheme(
      button: button ?? this.button,
      overlay: overlay ?? this.overlay,
      item: item ?? this.item,
      scroll: scroll ?? this.scroll,
      tooltip: tooltip ?? this.tooltip,
      search: search ?? this.search,
      checkbox: checkbox ?? this.checkbox,
    );
  }

  /// Default theme that works well with Material Design.
  static const DropdownStyleTheme defaultTheme = DropdownStyleTheme();
}
