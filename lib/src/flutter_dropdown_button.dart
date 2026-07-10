import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'buttons/menu_alignment.dart';
import 'config/text_dropdown_config.dart';
import 'overlay/dropdown_overlay_controller.dart';
import 'presentation/item_presentation.dart';
import 'search/dropdown_search_controller.dart';
import 'theme/dropdown_scroll_theme.dart';
import 'theme/dropdown_style_theme.dart';
import 'theme/dropdown_theme.dart';
import 'theme/resolved_dropdown_style.dart';
import 'theme/search_field_theme.dart';
import 'theme/tooltip_theme.dart';
import 'widgets/scroll_gradient_overlay.dart';
import 'widgets/smart_tooltip_text.dart';

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
  }) : hintText = hint,
       hintWidget = null,
       itemBuilder = null,
       selectedBuilder = null,
       assert(
         minMenuWidth == null ||
             maxMenuWidth == null ||
             minMenuWidth <= maxMenuWidth,
         'minMenuWidth must be less than or equal to maxMenuWidth',
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

class _FlutterDropdownButtonState<T> extends State<FlutterDropdownButton<T>>
    with SingleTickerProviderStateMixin {
  late final DropdownOverlayController _menu = DropdownOverlayController(
    vsync: this,
    animationDuration: widget.animationDuration,
    spec: _buildSpec,
    contentBuilder: _buildOverlayContent,
    decorationBuilder: _buildOverlayDecoration,
    // Opening, closing and selecting all start the search over. The overlay's
    // dismiss barrier closes the menu without going through this State, so the
    // reset has to be driven from the controller rather than from our callers.
    onOpenStateChanged: (_) {
      _resetSearch();
      if (mounted) setState(() {});
    },
  );

  /// The trailing icon turns half a revolution while the menu is open.
  late final Animation<double> _iconRotation = Tween<double>(
    begin: 0.0,
    end: 0.5,
  ).animate(CurvedAnimation(parent: _menu.animation, curve: Curves.easeInOut));

  // ===== Theme =====

  DropdownTheme get effectiveTheme =>
      widget.theme?.dropdown ?? DropdownTheme.defaultTheme;

  DropdownAmbientColors get _ambient => DropdownAmbientColors.of(context);

  ResolvedButtonStyle get _buttonStyle =>
      effectiveTheme.resolveButton(_ambient, enabled: isEnabled);

  ResolvedOverlayStyle get _overlayStyle =>
      effectiveTheme.resolveOverlay(_ambient);

  ResolvedSearchFieldStyle get _searchStyle =>
      effectiveSearchTheme.resolve(_ambient);

  /// Never null. Without one the menu used to fall through to the scrollbar
  /// Flutter's `MaterialScrollBehavior` inserts on desktop, which answers to
  /// nothing this package exposes and swells on hover.
  DropdownScrollTheme get effectiveScrollTheme =>
      widget.theme?.scroll ?? DropdownScrollTheme.defaultTheme;

  DropdownTooltipTheme get effectiveTooltipTheme =>
      widget.theme?.tooltip ?? DropdownTooltipTheme.defaultTheme;

  SearchFieldTheme get effectiveSearchTheme =>
      widget.theme?.search ?? SearchFieldTheme.defaultTheme;

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
      leadingHeight: effectiveTheme.resolvedIconSize,
      leading: widget.leading,
      selectedLeading: widget.selectedLeading,
      leadingPadding: widget.leadingPadding,
    );
  }

  // ===== Overlay =====

  bool get isEnabled => !_isSingleItemDisabled && widget.enabled;

  double get actualItemHeight {
    final itemMargin = effectiveTheme.itemMargin;
    return widget.itemHeight + (itemMargin?.vertical ?? 0.0);
  }

  double get overlayBorderThickness => _overlayStyle.borderThickness;

  /// Read afresh on every overlay build, so a menu open while its items or
  /// theme change re-measures against the new values.
  DropdownOverlaySpec _buildSpec() {
    return DropdownOverlaySpec(
      itemCount: widget.items.length,
      actualItemHeight: actualItemHeight,
      maxDropdownHeight: widget.height,
      chromeHeight: _searchFieldHeight,
      borderThickness: overlayBorderThickness,
      overlayPadding: effectiveTheme.overlayPadding,
      minMenuWidth: widget.minMenuWidth,
      maxMenuWidth: widget.maxMenuWidth,
      menuAlignment: widget.menuAlignment,
      elevation: effectiveTheme.elevation,
      borderRadius: effectiveTheme.borderRadius,
      shadowColor: effectiveTheme.shadowColor,
    );
  }

  // ===== Single-item mode =====

  bool get _isSingleItemDisabled =>
      widget.disableWhenSingleItem && widget.items.length == 1;

  bool get _showTrailing =>
      !(_isSingleItemDisabled && widget.hideIconWhenSingleItem);

  // ===== Search =====

  late final DropdownSearchController<T> _search = DropdownSearchController<T>(
    enabled: widget.searchable,
  );

  /// The items the menu should show right now.
  ///
  /// Derived from `items` and the query on every read rather than cached in a
  /// field. A cache here has to be invalidated from `didUpdateWidget`, from
  /// the search callback, and from open/close/select — and every past defect
  /// in this area was a missed invalidation.
  ///
  /// The caller's `searchFilter` wins; failing that, the presentation supplies
  /// the default its mode can offer, and text mode is the only one that can.
  ///
  /// Takes the [presentation] rather than reaching for `_presentation`, so the
  /// one build that needs both does not construct two.
  List<T> _visibleItems(DropdownItemPresentation<T> presentation) =>
      _search.visibleItems(
        widget.items,
        widget.searchFilter ?? presentation.defaultSearchFilter,
      );

  /// The height occupied by the search field including margin and divider.
  double get _searchFieldHeight =>
      widget.searchable ? _searchStyle.totalHeight : 0.0;

  void _onSearchChanged(String query) {
    _search.onQueryChanged(query);

    // Reset scroll position
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.jumpTo(0);
    }

    // Rebuild overlay with new filtered items
    _menu.rebuild();
  }

  // ===== Lifecycle =====

  ScrollController? _scrollController;

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

    // Nothing to recompute: the visible items are derived, not stored. The
    // query belongs to the user — clearing it is the job of open, close and
    // select, which `_resetSearch()` already handles.
    //
    // The overlay lives in its own element subtree and does not rebuild when
    // this widget does. Without this, a menu that is already open keeps showing
    // the items it was opened with — a list that arrives asynchronously never
    // appears until the user closes and reopens the dropdown.
    //
    // Deferred to after the frame: the overlay's element is not a descendant
    // of this one, so marking it dirty mid-build is not allowed.
    if (_menu.isOpen) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _menu.rebuild();
      });
    }

    // Handle searchable toggled at runtime
    if (widget.searchable != oldWidget.searchable) {
      _search.enabled = widget.searchable;
    }
  }

  @override
  void dispose() {
    // The menu goes first: tearing it down unmounts the ScrollGradientOverlay,
    // which listens to the controller disposed on the next line.
    _menu.dispose();
    _scrollController?.dispose();
    _search.dispose();
    super.dispose();
  }

  void _autoSelectSingleItem() {
    if (_isSingleItemDisabled && widget.value != widget.items.first) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(widget.items.first);
        }
      });
    }
  }

  // ===== Overlay =====

  void _onItemSelected() => _menu.close();

  void _resetSearch() => _search.reset();

  void _openDropdown() {
    _menu.open(context);
    if (widget.searchable && effectiveSearchTheme.autofocus) {
      // Request focus after overlay is inserted
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _search.requestFocus();
      });
    }
  }

  void _toggleDropdown() => _menu.isOpen ? _menu.close() : _openDropdown();

  BoxDecoration? _buildOverlayDecoration() => _overlayStyle.decoration;

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    final style = _buttonStyle;

    Widget button = Container(
      key: _menu.buttonKey,
      width: widget.width,
      decoration: style.decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _toggleDropdown : null,
          mouseCursor: isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          borderRadius: BorderRadius.circular(style.borderRadius),
          splashColor: style.splashColor,
          highlightColor: style.highlightColor,
          hoverColor: style.hoverColor,
          child: Padding(
            padding: style.padding,
            child: _buildButtonContent(style),
          ),
        ),
      ),
    );

    return _applyWidthConstraints(button);
  }

  Widget _buildButtonContent(ResolvedButtonStyle style) {
    final effectiveContentHeight = style.contentHeight;
    final effectiveIconSize = style.iconSize;
    final rowHeight = effectiveContentHeight > effectiveIconSize
        ? effectiveContentHeight
        : effectiveIconSize;
    final presentation = _presentation;

    // A button given a width, or told to expand, fills it; one sized to its
    // content hugs it. Three layout decisions turn on the same question.
    final fillsWidth = widget.width != null || widget.expand;

    return SizedBox(
      height: rowHeight,
      child: Row(
        mainAxisAlignment: fillsWidth
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        mainAxisSize: fillsWidth ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SizedBox(
              height: effectiveContentHeight,
              child: fillsWidth
                  ? Container(
                      alignment: presentation.contentAlignment,
                      child: presentation.buildSelected(),
                    )
                  : Align(
                      alignment: presentation.contentAlignment,
                      widthFactor: 1.0,
                      child: presentation.buildSelected(),
                    ),
            ),
          ),
          if (_showTrailing)
            Padding(
              padding: style.iconPadding,
              child: SizedBox(
                height: effectiveIconSize,
                child: Center(
                  child: RotationTransition(
                    turns: _iconRotation,
                    child:
                        widget.trailing ??
                        Icon(
                          style.icon,
                          size: effectiveIconSize,
                          color: style.iconColor,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _applyWidthConstraints(Widget child) {
    if (widget.width == null &&
        (widget.minWidth != null || widget.maxWidth != null)) {
      child = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? 0,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: child,
      );
    }

    if (widget.expand) {
      child = Expanded(child: child);
    }

    return child;
  }

  // ===== Overlay content =====

  Widget _buildOverlayContent(double height) {
    final presentation = _presentation;
    final items = _visibleItems(presentation);
    final scrollTheme = effectiveScrollTheme;
    final padding = effectiveTheme.overlayPadding;

    // The same quantity `DropdownPlacement` grew the menu by, asked of the same
    // spec rather than re-added here. When these two disagreed, the item list
    // overflowed — twice, in 2.3.2 and again in 2.5.0.
    final availableContentHeight = (height - _buildSpec().totalChromeHeight)
        .clamp(0.0, double.infinity);
    final totalItemsHeight = items.length * actualItemHeight;
    final needsScroll = totalItemsHeight > availableContentHeight;
    final itemAlignment = presentation.contentAlignment;

    Widget content;

    if (items.isEmpty && widget.searchable && _search.query.isNotEmpty) {
      // Empty state for search with no results
      content = SizedBox(
        height: availableContentHeight,
        child:
            widget.emptyBuilder?.call(_search.query) ??
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No results found',
                  style: TextStyle(color: _ambient.hint, fontSize: 14),
                ),
              ),
            ),
      );
    } else if (needsScroll) {
      _scrollController ??= ScrollController();

      if (widget.scrollToSelectedItem &&
          widget.value != null &&
          _search.query.isEmpty) {
        _scheduleScrollToSelectedItem();
      }

      content = SizedBox(
        height: availableContentHeight,
        child: ListView.builder(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = widget.value == item;
            return _buildItemWrapper(
              item: item,
              isSelected: isSelected,
              isFirst: index == 0,
              isLast: index == items.length - 1,
              alignment: itemAlignment,
              child: presentation.buildItem(item, isSelected),
            );
          },
        ),
      );

      content = _applyScrollbarTheme(content, scrollTheme);

      if (scrollTheme.showScrollGradient == true) {
        content = ScrollGradientOverlay(
          controller: _scrollController!,
          fadeInto: _overlayStyle.backgroundColor,
          height: scrollTheme.resolve().gradientHeight,
          borderRadius: _overlayStyle.borderRadius,
          colors: scrollTheme.gradientColors,
          child: content,
        );
      }
    } else {
      final List<Widget> itemWidgets = [];
      for (int index = 0; index < items.length; index++) {
        final item = items[index];
        final isSelected = widget.value == item;
        itemWidgets.add(
          _buildItemWrapper(
            item: item,
            isSelected: isSelected,
            isFirst: index == 0,
            isLast: index == items.length - 1,
            alignment: itemAlignment,
            child: presentation.buildItem(item, isSelected),
          ),
        );
      }

      content = Column(mainAxisSize: MainAxisSize.min, children: itemWidgets);
    }

    if (padding != null) {
      content = Padding(padding: padding, child: content);
    }

    if (widget.searchable) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchField(),
          Flexible(child: content),
        ],
      );
    }

    return content;
  }

  // ===== Search field =====

  Widget _buildSearchField() {
    final style = _searchStyle;

    Widget field = Container(
      margin: style.margin,
      padding: style.padding,
      height: style.fieldHeight,
      child: TextField(
        controller: _search.textController,
        focusNode: _search.focusNode,
        onChanged: _onSearchChanged,
        style: style.textStyle,
        cursorColor: style.cursorColor,
        cursorWidth: style.cursorWidth,
        cursorHeight: style.cursorHeight,
        cursorRadius: style.cursorRadius,
        textAlign: style.textAlign,
        keyboardType: style.keyboardType,
        textInputAction: style.textInputAction,
        decoration: style.decoration,
      ),
    );

    if (style.divider != null) {
      field = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          field,
          // Constrained to the height reserved for it in the resolved style,
          // so what the overlay set aside and what gets drawn cannot disagree.
          SizedBox(height: style.dividerHeight, child: style.divider),
        ],
      );
    }

    return field;
  }

  Widget _buildItemWrapper({
    required T item,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
    required Widget child,
    Alignment alignment = Alignment.centerLeft,
  }) {
    final style = effectiveTheme.resolveItem(
      _ambient,
      selected: isSelected,
      isFirst: isFirst,
      isLast: isLast,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: style.margin,
        child: InkWell(
          onTap: () {
            widget.onChanged(item);
            _onItemSelected();
          },
          mouseCursor: SystemMouseCursors.click,
          splashColor: style.splashColor,
          highlightColor: style.highlightColor,
          hoverColor: style.hoverColor,
          borderRadius: BorderRadius.circular(style.inkBorderRadius),
          child: Ink(
            height: widget.itemHeight,
            width: double.infinity,
            padding: style.padding,
            decoration: style.decoration,
            child: Align(alignment: alignment, child: child),
          ),
        ),
      ),
    );
  }

  // ===== Scrollbar =====

  /// The thickness this scrollbar would rest at if we named none.
  ///
  /// Naming it is what stops Flutter swelling a track-showing scrollbar from 8
  /// to 12 while a pointer hovers (`material/scrollbar.dart:303`). But the value
  /// must be the one the caller would otherwise have got, or pinning it becomes
  /// a silent restyle:
  ///
  /// * an app-wide [ScrollbarTheme] is asked first, at rest;
  /// * failing that, Flutter's own default — **halved on Android**, so a flat
  ///   `8.0` would double the bar on every Android build.
  double get _restingScrollbarThickness {
    final ambient = ScrollbarTheme.of(
      context,
    ).thickness?.resolve(<WidgetState>{});
    if (ambient != null) return ambient;

    return Theme.of(context).platform == TargetPlatform.android ? 4.0 : 8.0;
  }

  Widget _applyScrollbarTheme(Widget content, DropdownScrollTheme scrollTheme) {
    final style = scrollTheme.resolve();

    final scrollbar = Scrollbar(
      controller: _scrollController,
      // Never null. Flutter swells a thickness-less scrollbar from 8 to 12
      // while a pointer hovers a visible track (`material/scrollbar.dart:303`);
      // naming the thickness it would have used anyway pins it without changing
      // how the bar looks at rest.
      thickness: style.thickness ?? _restingScrollbarThickness,
      radius: style.radius,
      thumbVisibility: style.thumbVisibility,
      trackVisibility: style.trackVisibility,
      interactive: style.interactive,
      child: content,
    );

    // Desktop's `MaterialScrollBehavior` wraps every scroll view in a
    // `Scrollbar` of its own. Ours would sit on top of it, two bars deep, and
    // the one underneath answers to nothing this theme says.
    final only = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: scrollbar,
    );

    if (!style.overridesScrollbarTheme) return only;

    return ScrollbarTheme(data: style.scrollbarTheme, child: only);
  }

  // ===== Scroll gradients =====

  // ===== Scroll to selected =====

  void _scheduleScrollToSelectedItem() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _scrollController == null ||
          !_scrollController!.hasClients) {
        return;
      }

      final selectedIndex = _findSelectedItemIndex();
      if (selectedIndex == -1) return;

      final scrollOffset = selectedIndex * actualItemHeight;
      final maxScrollExtent = _scrollController!.position.maxScrollExtent;
      final clampedOffset = scrollOffset.clamp(0.0, maxScrollExtent);

      if (widget.scrollToSelectedDuration != null) {
        _scrollController!.animateTo(
          clampedOffset,
          duration: widget.scrollToSelectedDuration!,
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController!.jumpTo(clampedOffset);
      }
    });
  }

  int _findSelectedItemIndex() {
    if (widget.value == null) return -1;
    for (int i = 0; i < widget.items.length; i++) {
      if (widget.value == widget.items[i]) return i;
    }
    return -1;
  }
}
