import 'package:flutter/material.dart';

import 'buttons/menu_alignment.dart';
import 'config/text_dropdown_config.dart';
import 'overlay/dropdown_overlay_controller.dart';
import 'presentation/item_presentation.dart';
import 'shell/dropdown_menu_shell.dart';
import 'theme/dropdown_style_theme.dart';
import 'theme/tooltip_theme.dart';

/// A dropdown whose menu is a checklist: several items may be chosen, and the
/// menu stays open while they are.
///
/// Anchored rather than modal. There is no scrim and no confirm button — a tap
/// on a row calls [onChanged] at once with a **new** `Set`, and an outside tap
/// dismisses the menu.
///
/// ```dart
/// FlutterMultiSelectDropdown<String>(
///   items: osFamilies,
///   selected: chosen,
///   onChanged: (next) => setState(() => chosen = next),
///   labelBuilder: (s) => switch (s.length) {
///     0 => 'All',
///     1 => s.first,
///     _ => '${s.length} selected',
///   },
///   searchable: true,
///   itemTrailingBuilder: (v) => Text('${counts[v]}'),
/// )
/// ```
///
/// [selected] is **yours**. This widget renders what you hand it and never
/// edits it: a value that is no longer in [items] still counts towards
/// [labelBuilder], though it draws no row. A list refresh that drops the data
/// behind a chosen value therefore cannot make the widget throw, nor silently
/// discard the choice. Offer a way to clear it.
///
/// `T` must implement `==` **and** `hashCode` consistently. A `Set` needs both,
/// where single-select's `value == item` needed only the first.
///
/// Rows render as text, so `T` must be a [String] or [label] must say how to
/// make one.
class FlutterMultiSelectDropdown<T> extends StatelessWidget {
  /// Creates a multi-select dropdown.
  const FlutterMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.labelBuilder,
    this.label,
    this.itemTrailingBuilder,
    this.config,
    this.theme,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enabled = true,
    this.expand = false,
    this.trailing,
    this.minMenuWidth,
    this.maxMenuWidth,
    this.menuAlignment = MenuAlignment.left,
    this.searchable = false,
    this.searchFilter,
    this.emptyBuilder,
  });

  /// The items the menu offers.
  final List<T> items;

  /// The items currently chosen. Owned by the caller.
  final Set<T> selected;

  /// Called with a new `Set` the moment a row is tapped.
  ///
  /// The `Set` passed to this widget is never mutated; a copy is made.
  final ValueChanged<Set<T>> onChanged;

  /// Turns [selected] into the button's face.
  final String Function(Set<T> selected) labelBuilder;

  /// Turns an item into the string its row shows. Required unless `T` is
  /// [String].
  final String Function(T item)? label;

  /// Drawn at the end of each row — a count, a badge.
  ///
  /// The row's ink well merges its descendants' semantics, so this widget's
  /// text becomes part of what a screen reader announces for the row.
  final Widget Function(T item)? itemTrailingBuilder;

  /// Text rendering rules: overflow, alignment, styles.
  final TextDropdownConfig? config;

  /// Styling for the button, the menu, its scrollbar and its search field.
  final DropdownStyleTheme? theme;

  /// A fixed button width.
  final double? width;

  /// The button's minimum width, when [width] is null.
  final double? minWidth;

  /// The button's maximum width, when [width] is null.
  final double? maxWidth;

  /// The menu's maximum height. It scrolls beyond this.
  final double height;

  /// The height of one row.
  final double itemHeight;

  /// How long the open and close animation takes.
  final Duration animationDuration;

  /// Whether the button responds to a tap.
  final bool enabled;

  /// Whether the button fills its parent's cross-axis space.
  final bool expand;

  /// Replaces the trailing icon.
  final Widget? trailing;

  /// The menu's minimum width.
  final double? minMenuWidth;

  /// The menu's maximum width.
  final double? maxMenuWidth;

  /// Which edge of the button the menu lines up with.
  final MenuAlignment menuAlignment;

  /// Whether the menu carries a search field.
  ///
  /// The query survives a tick: the menu does not close, and only opening and
  /// closing reset it.
  final bool searchable;

  /// Overrides the default case-insensitive `contains` over each item's label.
  final bool Function(T item, String query)? searchFilter;

  /// Drawn when a query matches nothing.
  final Widget Function(String query)? emptyBuilder;

  /// Closes every open dropdown overlay, of either kind.
  ///
  /// Single-open coordination lives in a registry keyed by `Overlay`, so this
  /// and [FlutterDropdownButton.closeAll] do the same thing.
  static void closeAll({bool animate = true}) =>
      DropdownOverlayController.closeAll(animate: animate);

  /// [item] added if it was absent, removed if it was present.
  ///
  /// Always a fresh `Set`. The caller's may be unmodifiable, and is theirs.
  void _toggle(T item) {
    final next = <T>{...selected};
    if (!next.remove(item)) next.add(item);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenuShell<T>(
      items: items,
      presentation: MultiSelectPresentation<T>(
        selected: selected,
        label: label,
        labelBuilder: labelBuilder,
        config: config ?? TextDropdownConfig.defaultConfig,
        tooltipTheme: theme?.tooltip ?? DropdownTooltipTheme.defaultTheme,
        enabled: enabled,
        itemTrailingBuilder: itemTrailingBuilder,
      ),
      // What multi-selection means, said once.
      isChosen: selected.contains,
      onItemTap: _toggle,
      closeOnTap: false,
      // There is no single chosen row to reveal, so the shell never scrolls.
      scrollToItem: null,
      enabled: enabled,
      showTrailing: true,
      trailing: trailing,
      theme: theme,
      width: width,
      minWidth: minWidth,
      maxWidth: maxWidth,
      height: height,
      itemHeight: itemHeight,
      animationDuration: animationDuration,
      expand: expand,
      minMenuWidth: minMenuWidth,
      maxMenuWidth: maxMenuWidth,
      menuAlignment: menuAlignment,
      searchable: searchable,
      searchFilter: searchFilter,
      emptyBuilder: emptyBuilder,
    );
  }
}
