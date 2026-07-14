import 'package:flutter/material.dart';

import 'buttons/menu_alignment.dart';
import 'config/text_dropdown_config.dart';
import 'overlay/dropdown_overlay_controller.dart';
import 'presentation/item_presentation.dart';
import 'shell/dropdown_menu_shell.dart';
import 'theme/dropdown_button_theme.dart';
import 'theme/dropdown_style_theme.dart';
import 'theme/tooltip_theme.dart';

/// A highly customizable dropdown button widget with overlay-based rendering.
///
/// This widget provides two modes of operation:
///
/// **Custom mode** (default constructor): Use [itemBuilder] to render any widget
/// as dropdown items. Suitable for complex layouts with icons, images, etc.
///
/// **Text mode** ([FlutterDropdownButton.text]): Optimized for text-only content
/// with automatic text overflow handling, tooltip support, and optional leading widgets.
///
/// Features:
/// - Smart positioning (opens up/down based on available space)
/// - Smooth scale and opacity animations
/// - Outside-tap dismissal
/// - Custom scrollbar theming
/// - Scroll gradient indicators
/// - Single-item mode (auto-disable when only one option)
/// - Menu width independent of button width
///
/// Example (custom mode):
/// ```dart
/// FlutterDropdownButton<String>(
///   items: ['apple', 'banana'],
///   value: selected,
///   itemBuilder: (item, isSelected) => Text(item),
///   onChanged: (value) => setState(() => selected = value),
/// )
/// ```
///
/// Example (text mode):
/// ```dart
/// FlutterDropdownButton<String>.text(
///   items: ['Apple', 'Banana', 'Cherry'],
///   value: selected,
///   hint: 'Select a fruit',
///   onChanged: (value) => setState(() => selected = value),
/// )
/// ```
class FlutterDropdownButton<T> extends StatefulWidget {
  /// Creates a dropdown button with custom widget rendering.
  ///
  /// Use [itemBuilder] to define how each item appears in the dropdown list.
  /// Use [selectedBuilder] to customize how the selected item appears on the button.
  /// If [selectedBuilder] is null, [itemBuilder] is used with `isSelected: true`.
  const FlutterDropdownButton({
    super.key,
    required this.items,
    required this.onChanged,
    required Widget Function(T item, bool isSelected) this.itemBuilder,
    this.selectedBuilder,
    this.hintWidget,
    this.value,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.theme,
    this.enabled = true,
    this.scrollToSelectedItem = true,
    this.scrollToSelectedDuration,
    this.expand = false,
    this.trailing,
    this.minMenuWidth,
    this.maxMenuWidth,
    this.menuAlignment = MenuAlignment.left,
    this.disableWhenSingleItem = false,
    this.hideIconWhenSingleItem = true,
    this.searchable = false,
    this.searchFilter,
    this.emptyBuilder,
    this.anchorBuilder,
  }) : hintText = null,
       label = null,
       config = null,
       leading = null,
       selectedLeading = null,
       leadingPadding = null,
       assert(
         minMenuWidth == null ||
             maxMenuWidth == null ||
             minMenuWidth <= maxMenuWidth,
         'minMenuWidth must be less than or equal to maxMenuWidth',
       ),
       assert(
         anchorBuilder == null ||
             (width == null &&
                 minWidth == null &&
                 maxWidth == null &&
                 !expand &&
                 trailing == null),
         'anchorBuilder draws the whole anchor, so the button-box params it '
         'replaces do not apply: drop width, minWidth, maxWidth, expand and '
         'trailing when supplying one. Menu, scrollbar, search and tooltip '
         'theming still take effect.',
       );

  /// Creates a text-only dropdown button.
  ///
  /// Optimized for string content with automatic text overflow handling,
  /// tooltip support, and optional leading widgets.
  ///
  /// Use [config] to control text styling, overflow, and alignment.
  /// Use [leading] and [selectedLeading] to add widgets before the text.
  const FlutterDropdownButton.text({
    super.key,
    required this.items,
    required this.onChanged,
    String? hint,
    this.label,
    this.config,
    this.leading,
    this.selectedLeading,
    this.leadingPadding,
    this.value,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.theme,
    this.enabled = true,
    this.scrollToSelectedItem = true,
    this.scrollToSelectedDuration,
    this.expand = false,
    this.trailing,
    this.minMenuWidth,
    this.maxMenuWidth,
    this.menuAlignment = MenuAlignment.left,
    this.disableWhenSingleItem = false,
    this.hideIconWhenSingleItem = true,
    this.searchable = false,
    this.searchFilter,
    this.emptyBuilder,
    this.anchorBuilder,
  }) : hintText = hint,
       hintWidget = null,
       itemBuilder = null,
       selectedBuilder = null,
       assert(
         minMenuWidth == null ||
             maxMenuWidth == null ||
             minMenuWidth <= maxMenuWidth,
         'minMenuWidth must be less than or equal to maxMenuWidth',
       ),
       assert(
         anchorBuilder == null ||
             (width == null &&
                 minWidth == null &&
                 maxWidth == null &&
                 !expand &&
                 trailing == null),
         'anchorBuilder draws the whole anchor, so the button-box params it '
         'replaces do not apply: drop width, minWidth, maxWidth, expand and '
         'trailing when supplying one. Menu, scrollbar, search and tooltip '
         'theming still take effect.',
       );

  /// The list of items available in this dropdown.
  final List<T> items;

  /// Called when the user selects an item.
  final ValueChanged<T?> onChanged;

  /// The currently selected value.
  ///
  /// Drawn on the button whether or not it appears in [items]. A list that
  /// refreshes can drop the chosen row while this still names it; the button
  /// keeps showing it rather than quietly reverting to the hint, because this
  /// value belongs to the caller. The menu is a separate matter — it iterates
  /// [items], so an absent value is never a row.
  final T? value;

  // --- Custom mode fields ---

  /// Builds the widget for each dropdown item (custom mode only).
  ///
  /// In text mode, items are rendered automatically using [SmartTooltipText].
  final Widget Function(T item, bool isSelected)? itemBuilder;

  /// Builds the widget for the selected item displayed on the button face.
  ///
  /// If null in custom mode, [itemBuilder] is used with `isSelected: true`.
  final Widget Function(T item)? selectedBuilder;

  /// Widget displayed when no item is selected (custom mode only).
  final Widget? hintWidget;

  // --- Text mode fields ---

  /// Text displayed when no item is selected (text mode only).
  final String? hintText;

  /// Extracts the text to display for an item (text mode only).
  ///
  /// Supply this to use text mode with any type:
  ///
  /// ```dart
  /// FlutterDropdownButton<User>.text(
  ///   items: users,
  ///   label: (user) => user.name,
  /// )
  /// ```
  ///
  /// The label drives rendering, overflow handling, the tooltip, and the
  /// default search filter.
  ///
  /// May be omitted only when `T` is [String], in which case the item is its
  /// own label. Omitting it for any other type throws in debug builds.
  final String Function(T item)? label;

  /// Text rendering configuration (text mode only).
  ///
  /// Controls text overflow, styling, alignment, and other text-specific
  /// properties. If null, uses [TextDropdownConfig.defaultConfig].
  final TextDropdownConfig? config;

  /// Widget displayed before text in dropdown items (text mode only).
  ///
  /// If [selectedLeading] is provided, it will be used for the selected
  /// item instead of this widget.
  final Widget? leading;

  /// Widget displayed before text in the selected item (text mode only).
  ///
  /// Falls back to [leading] if null.
  final Widget? selectedLeading;

  /// Padding around the leading widget (text mode only).
  ///
  /// Defaults to `EdgeInsets.only(right: 8.0)`.
  final EdgeInsets? leadingPadding;

  // --- Common fields ---

  /// Fixed width of the button. If null, sizes to content.
  final double? width;

  /// Minimum width constraint when [width] is null.
  final double? minWidth;

  /// Maximum width constraint when [width] is null.
  final double? maxWidth;

  /// Maximum height of the dropdown overlay. Defaults to 200.0.
  final double height;

  /// Height of each dropdown item. Defaults to 48.0.
  final double itemHeight;

  /// Duration of show/hide animations. Defaults to 200ms.
  final Duration animationDuration;

  /// Theme configuration for styling.
  ///
  /// Accepts [DropdownStyleTheme] which allows you to configure dropdown
  /// styling, scrollbar appearance, and tooltip behavior.
  final DropdownStyleTheme? theme;

  /// Whether the dropdown is interactive. Defaults to true.
  final bool enabled;

  /// Whether to scroll to the selected item when opened. Defaults to true.
  final bool scrollToSelectedItem;

  /// Duration for scroll-to-selected animation. If null, jumps instantly.
  final Duration? scrollToSelectedDuration;

  /// Whether to expand to fill available flex space. Defaults to false.
  final bool expand;

  /// Custom trailing widget replacing the default arrow icon.
  ///
  /// Automatically wrapped with a [RotationTransition] that rotates
  /// 180 degrees when the dropdown opens/closes.
  final Widget? trailing;

  /// Minimum width of the dropdown menu (can differ from button width).
  final double? minMenuWidth;

  /// Maximum width of the dropdown menu.
  final double? maxMenuWidth;

  /// Menu alignment relative to button when menu is wider.
  ///
  /// Defaults to [MenuAlignment.left].
  final MenuAlignment menuAlignment;

  /// Whether to disable interaction when only one item exists.
  ///
  /// When true, a single-item dropdown becomes non-interactive and
  /// auto-selects the only available item. Defaults to false.
  final bool disableWhenSingleItem;

  /// Whether to hide the arrow icon when only one item exists.
  ///
  /// Only applies when [disableWhenSingleItem] is true. Defaults to true.
  final bool hideIconWhenSingleItem;

  // --- Search fields ---

  /// Whether the dropdown supports searching/filtering items.
  ///
  /// When true, a search text field is displayed at the top of the
  /// dropdown overlay. Items are filtered in real-time as the user types.
  ///
  /// For text mode, items are filtered using case-insensitive `contains`
  /// matching by default. For custom mode, [searchFilter] must be provided.
  ///
  /// The search field appearance can be customized via [DropdownStyleTheme.search].
  ///
  /// Defaults to false.
  final bool searchable;

  /// Custom filter function for search.
  ///
  /// Called for each item with the current search query to determine
  /// if the item should be shown. Return true to include the item.
  ///
  /// Required for custom mode when [searchable] is true.
  /// Optional for text mode (defaults to case-insensitive contains matching).
  ///
  /// Example:
  /// ```dart
  /// searchFilter: (item, query) =>
  ///   item.name.toLowerCase().contains(query.toLowerCase()),
  /// ```
  final bool Function(T item, String query)? searchFilter;

  /// Builder for the empty state when search yields no results.
  ///
  /// Called with the current search query. If null, a default
  /// "No results found" text is displayed.
  ///
  /// Example:
  /// ```dart
  /// emptyBuilder: (query) => Center(
  ///   child: Text('No items matching "$query"'),
  /// ),
  /// ```
  final Widget Function(String query)? emptyBuilder;

  /// Draws the anchor itself, dropping the button chrome (bare mode).
  ///
  /// Supply this to embed the dropdown inside another field — a field-scope
  /// selector at the head of a search box, `[All ▾] │ search…` — where the
  /// button's own background, border and fixed width would nest a box inside a
  /// box. The widget you return becomes the whole anchor; the overlay (theme,
  /// keyboard navigation, [searchable], the menu) still hangs off it exactly as
  /// before. Only the button face is yours now.
  ///
  /// The builder is handed whether the menu is currently open — the one thing
  /// it cannot read for itself — so an inline chevron can turn. It is not handed
  /// a label: build the face from the [value] you already hold.
  ///
  /// ```dart
  /// FlutterDropdownButton<String>.text(
  ///   items: fields,
  ///   value: field,
  ///   onChanged: onField,
  ///   anchorBuilder: (context, isOpen) => Row(
  ///     mainAxisSize: MainAxisSize.min,
  ///     children: [
  ///       Text(field),
  ///       AnimatedRotation(
  ///         turns: isOpen ? 0.5 : 0.0,
  ///         duration: const Duration(milliseconds: 200),
  ///         child: const Icon(Icons.expand_more, size: 16),
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```
  ///
  /// The button-box params it replaces — [width], [minWidth], [maxWidth],
  /// [expand] and [trailing] — must be left unset; combining them asserts.
  final Widget Function(BuildContext context, bool isOpen)? anchorBuilder;

  /// Whether this dropdown was built by [FlutterDropdownButton.text].
  ///
  /// Informational. Nothing inside the widget branches on this: rendering is
  /// chosen once, by building a `DropdownItemPresentation`, and every render
  /// site asks that what to draw. Adding a third mode therefore does not add a
  /// third answer here.
  bool get isTextMode => itemBuilder == null;

  /// Closes all currently open dropdown overlays.
  ///
  /// Useful before navigation to ensure no orphaned overlays remain.
  ///
  /// With [animate] true (the default) the menu plays its close animation, so
  /// the trailing icon rotates back. Pass false to remove the overlay at once
  /// — the widget may be disposed before an animation could finish.
  ///
  /// ```dart
  /// FlutterDropdownButton.closeAll();
  ///
  /// // Right before navigating away:
  /// FlutterDropdownButton.closeAll(animate: false);
  /// Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  /// ```
  static void closeAll({bool animate = true}) =>
      DropdownOverlayController.closeAll(animate: animate);

  @override
  State<FlutterDropdownButton<T>> createState() =>
      _FlutterDropdownButtonState<T>();
}

class _FlutterDropdownButtonState<T> extends State<FlutterDropdownButton<T>> {
  // ===== Theme =====

  DropdownButtonTheme get effectiveButtonTheme =>
      widget.theme?.button ?? DropdownButtonTheme.defaultTheme;

  DropdownTooltipTheme get effectiveTooltipTheme =>
      widget.theme?.tooltip ?? DropdownTooltipTheme.defaultTheme;

  TextDropdownConfig get _textConfig =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  /// How this dropdown draws its items and its button face.
  ///
  /// **The one place the rendering mode is decided.** Everything downstream
  /// asks the presentation what to draw rather than asking which constructor
  /// was used. A third mode is a third implementation and a third branch here,
  /// not another conditional at every render site.
  DropdownItemPresentation<T> get _presentation {
    final itemBuilder = widget.itemBuilder;
    if (itemBuilder != null) {
      return CustomItemPresentation<T>(
        itemBuilder: itemBuilder,
        value: widget.value,
        selectedBuilder: widget.selectedBuilder,
        hintWidget: widget.hintWidget,
      );
    }

    return TextItemPresentation<T>(
      label: widget.label,
      value: widget.value,
      hintText: widget.hintText,
      config: _textConfig,
      tooltipTheme: effectiveTooltipTheme,
      enabled: isEnabled,
      // Read off the theme, not off `_buttonStyle`. Resolving the whole button
      // to reach one number would build a BoxDecoration and lift the ambient
      // palette, on every access — and this getter is read on every keystroke.
      leadingHeight: effectiveButtonTheme.resolvedIconSize,
      leading: widget.leading,
      selectedLeading: widget.selectedLeading,
      leadingPadding: widget.leadingPadding,
    );
  }

  // ===== Single-item mode =====

  /// A dropdown with one item and [FlutterDropdownButton.disableWhenSingleItem]
  /// set has nothing to choose, so it does not open.
  bool get _isSingleItemDisabled =>
      widget.disableWhenSingleItem && widget.items.length == 1;

  bool get isEnabled => !_isSingleItemDisabled && widget.enabled;

  bool get _showTrailing =>
      !(_isSingleItemDisabled && widget.hideIconWhenSingleItem);

  // ===== Lifecycle =====

  @override
  void initState() {
    super.initState();
    // The `label`-or-String invariant is asserted by TextItemPresentation,
    // which is built during the first build — still before anything paints.
    _autoSelectSingleItem();
  }

  @override
  void didUpdateWidget(FlutterDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _autoSelectSingleItem();
  }

  /// The only item is chosen for the caller, once, after the frame.
  ///
  /// Single-select policy. The menu below knows nothing about it — it is handed
  /// an `enabled` that is already false.
  void _autoSelectSingleItem() {
    if (_isSingleItemDisabled && widget.value != widget.items.first) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(widget.items.first);
        }
      });
    }
  }

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    return DropdownMenuShell<T>(
      items: widget.items,
      presentation: _presentation,
      // What single selection means, said once. Everything below reads the
      // answer rather than the `value`.
      isChosen: (item) => widget.value == item,
      onItemTap: widget.onChanged,
      closeOnTap: true,
      scrollToItem: widget.scrollToSelectedItem ? widget.value : null,
      scrollToItemDuration: widget.scrollToSelectedDuration,
      enabled: isEnabled,
      showTrailing: _showTrailing,
      trailing: widget.trailing,
      theme: widget.theme,
      width: widget.width,
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
      height: widget.height,
      itemHeight: widget.itemHeight,
      animationDuration: widget.animationDuration,
      expand: widget.expand,
      minMenuWidth: widget.minMenuWidth,
      maxMenuWidth: widget.maxMenuWidth,
      menuAlignment: widget.menuAlignment,
      searchable: widget.searchable,
      searchFilter: widget.searchFilter,
      emptyBuilder: widget.emptyBuilder,
      anchorBuilder: widget.anchorBuilder,
    );
  }
}
