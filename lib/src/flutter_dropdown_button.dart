import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'buttons/menu_alignment.dart';
import 'config/text_dropdown_config.dart';
import 'overlay/dropdown_overlay_controller.dart';
import 'presentation/item_presentation.dart';
import 'theme/dropdown_scroll_theme.dart';
import 'theme/dropdown_style_theme.dart';
import 'theme/dropdown_theme.dart';
import 'theme/resolved_dropdown_style.dart';
import 'theme/search_field_theme.dart';
import 'theme/tooltip_theme.dart';
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
  })  : hintText = null,
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
  })  : hintText = hint,
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
  late final Animation<double> _iconRotation =
      Tween<double>(begin: 0.0, end: 0.5).animate(
    CurvedAnimation(parent: _menu.animation, curve: Curves.easeInOut),
  );

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

  DropdownScrollTheme? get effectiveScrollTheme => widget.theme?.scroll;

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
        items: widget.items,
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
      leadingHeight: _buttonStyle.iconSize,
      leading: widget.leading,
      selectedLeading: widget.selectedLeading,
      leadingPadding: widget.leadingPadding,
    );
  }

  // ===== Overlay =====

  bool get isEnabled => !_isSingleItemDisabled && widget.enabled;

  double get actualItemHeight {
    final itemMargin = effectiveTheme.itemMargin;
    final marginHeight =
        itemMargin != null ? (itemMargin.top + itemMargin.bottom) : 0.0;
    return widget.itemHeight + marginHeight;
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

  TextEditingController? _searchController;
  FocusNode? _searchFocusNode;
  String _searchQuery = '';

  /// The items the menu should show right now.
  ///
  /// Derived from `items` and the query on every read rather than cached in a
  /// field. A cache here has to be invalidated from `didUpdateWidget`, from
  /// the search callback, and from open/close/select — and every past defect
  /// in this area was a missed invalidation.
  List<T> get _visibleItems => widget.searchable
      ? _applyFilter(widget.items, _searchQuery)
      : widget.items;

  /// The height occupied by the search field including margin and divider.
  double get _searchFieldHeight =>
      widget.searchable ? _searchStyle.totalHeight : 0.0;

  /// Case-insensitive `contains` over the item's label. The default in text
  /// mode, whatever `T` is.
  /// The items [query] leaves visible. A pure function of its arguments.
  List<T> _applyFilter(List<T> items, String query) {
    if (query.isEmpty) return List<T>.from(items);

    final filter = widget.searchFilter ?? _presentation.defaultSearchFilter;
    if (filter == null) return List<T>.from(items);

    return items.where((item) => filter(item, query)).toList();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;

    // Reset scroll position
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.jumpTo(0);
    }

    // Rebuild overlay with new filtered items
    _menu.rebuild();
  }

  // ===== Lifecycle =====

  ScrollController? _scrollController;
  final ValueNotifier<bool> _canScrollUp = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollDown = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // The `label`-or-String invariant is asserted by TextItemPresentation,
    // which is built during the first build — still before anything paints.
    _autoSelectSingleItem();
    if (widget.searchable) {
      _searchController = TextEditingController();
      _searchFocusNode = FocusNode();
    }
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

    // Handle searchable toggled on at runtime
    if (widget.searchable && _searchController == null) {
      _searchController = TextEditingController();
      _searchFocusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_updateScrollGradients);
    _scrollController?.dispose();
    _canScrollUp.dispose();
    _canScrollDown.dispose();
    _searchController?.dispose();
    _searchFocusNode?.dispose();
    _menu.dispose();
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

  void _resetSearch() {
    _searchQuery = '';
    _searchController?.clear();
  }

  void _openDropdown() {
    _menu.open(context);
    if (widget.searchable && effectiveSearchTheme.autofocus) {
      // Request focus after overlay is inserted
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode?.requestFocus();
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

    return SizedBox(
      height: rowHeight,
      child: Row(
        mainAxisAlignment: widget.width != null || widget.expand
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        mainAxisSize: widget.width != null || widget.expand
            ? MainAxisSize.max
            : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SizedBox(
              height: effectiveContentHeight,
              child: widget.width != null || widget.expand
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
                    child: widget.trailing ??
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
    final items = _visibleItems;
    final scrollTheme = effectiveScrollTheme;
    final padding = effectiveTheme.overlayPadding;
    final paddingVertical =
        padding != null ? (padding.top + padding.bottom) : 0.0;
    final searchHeight = _searchFieldHeight;
    final availableContentHeight =
        (height - overlayBorderThickness - paddingVertical - searchHeight)
            .clamp(0.0, double.infinity);
    final totalItemsHeight = items.length * actualItemHeight;
    final needsScroll = totalItemsHeight > availableContentHeight;
    final presentation = _presentation;
    final itemAlignment = presentation.contentAlignment;

    Widget content;

    if (items.isEmpty && widget.searchable && _searchQuery.isNotEmpty) {
      // Empty state for search with no results
      content = SizedBox(
        height: availableContentHeight,
        child: widget.emptyBuilder?.call(_searchQuery) ??
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
      if (_scrollController == null) {
        _scrollController = ScrollController();
        _scrollController!.addListener(_updateScrollGradients);
      }

      _initializeScrollGradients();

      if (widget.scrollToSelectedItem &&
          widget.value != null &&
          _searchQuery.isEmpty) {
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

      if (scrollTheme != null) {
        content = _applyScrollbarTheme(content, scrollTheme);
      }

      if (scrollTheme?.showScrollGradient == true) {
        content = _buildScrollGradientOverlay(content, scrollTheme!);
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

      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: itemWidgets,
      );
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
        controller: _searchController,
        focusNode: _searchFocusNode,
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
            child: Align(
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ===== Scrollbar =====

  Widget _applyScrollbarTheme(Widget content, DropdownScrollTheme scrollTheme) {
    if (scrollTheme.resolve().hasCustomWidths) {
      return _buildCustomScrollbar(content, scrollTheme);
    }

    Widget scrollbarWidget = Scrollbar(
      controller: _scrollController,
      thickness: scrollTheme.thickness,
      radius: scrollTheme.radius,
      thumbVisibility: scrollTheme.thumbVisibility,
      trackVisibility: scrollTheme.trackVisibility,
      interactive: scrollTheme.interactive,
      child: content,
    );

    if (scrollTheme.thumbColor != null ||
        scrollTheme.trackColor != null ||
        scrollTheme.trackBorderColor != null ||
        scrollTheme.crossAxisMargin != null ||
        scrollTheme.mainAxisMargin != null ||
        scrollTheme.minThumbLength != null) {
      return ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: scrollTheme.thumbColor != null
              ? WidgetStateProperty.all(scrollTheme.thumbColor)
              : null,
          trackColor: scrollTheme.trackColor != null
              ? WidgetStateProperty.all(scrollTheme.trackColor)
              : null,
          trackBorderColor: scrollTheme.trackBorderColor != null
              ? WidgetStateProperty.all(scrollTheme.trackBorderColor)
              : null,
          crossAxisMargin: scrollTheme.crossAxisMargin,
          mainAxisMargin: scrollTheme.mainAxisMargin,
          minThumbLength: scrollTheme.minThumbLength,
        ),
        child: scrollbarWidget,
      );
    }

    return scrollbarWidget;
  }

  Widget _buildCustomScrollbar(
    Widget child,
    DropdownScrollTheme scrollTheme,
  ) {
    final resolved = scrollTheme.resolve();
    final double effectiveThumbWidth = resolved.thumbWidth;
    final double effectiveTrackWidth = resolved.trackWidth;

    final scrollbarThemeData = ScrollbarThemeData(
      thumbColor: scrollTheme.thumbColor != null
          ? WidgetStateProperty.all(scrollTheme.thumbColor)
          : null,
      trackColor: scrollTheme.trackColor != null
          ? WidgetStateProperty.all(scrollTheme.trackColor)
          : null,
      trackBorderColor: scrollTheme.trackBorderColor != null
          ? WidgetStateProperty.all(scrollTheme.trackBorderColor)
          : null,
      thickness: WidgetStateProperty.all(effectiveThumbWidth),
      radius: scrollTheme.radius,
      crossAxisMargin: scrollTheme.crossAxisMargin,
      mainAxisMargin: scrollTheme.mainAxisMargin,
      minThumbLength: scrollTheme.minThumbLength,
    );

    if (effectiveTrackWidth != effectiveThumbWidth &&
        scrollTheme.trackVisibility == true) {
      return ScrollbarTheme(
        data: scrollbarThemeData.copyWith(
          trackColor: scrollTheme.trackColor != null
              ? WidgetStateProperty.all(scrollTheme.trackColor)
              : null,
        ),
        child: RawScrollbar(
          controller: _scrollController,
          thickness: effectiveThumbWidth,
          radius: scrollTheme.radius,
          thumbVisibility: resolved.thumbVisibility,
          trackVisibility: resolved.trackVisibility,
          interactive: resolved.interactive,
          thumbColor: scrollTheme.thumbColor,
          trackColor: scrollTheme.trackColor,
          trackBorderColor: scrollTheme.trackBorderColor,
          crossAxisMargin: resolved.crossAxisMargin,
          mainAxisMargin: resolved.mainAxisMargin,
          minThumbLength: resolved.minThumbLength,
          child: child,
        ),
      );
    }

    return ScrollbarTheme(
      data: scrollbarThemeData,
      child: Scrollbar(
        controller: _scrollController,
        thickness: effectiveThumbWidth,
        radius: scrollTheme.radius,
        thumbVisibility: scrollTheme.thumbVisibility,
        trackVisibility: scrollTheme.trackVisibility,
        interactive: scrollTheme.interactive,
        child: child,
      ),
    );
  }

  // ===== Scroll gradients =====

  void _updateScrollGradients() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final position = _scrollController!.position;
    _canScrollUp.value = position.pixels > 0;
    _canScrollDown.value = position.pixels < position.maxScrollExtent;
  }

  void _initializeScrollGradients() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null && _scrollController!.hasClients) {
        _updateScrollGradients();
      }
    });
  }

  Widget _buildScrollGradientOverlay(
    Widget child,
    DropdownScrollTheme scrollTheme,
  ) {
    final gradientHeight = scrollTheme.resolve().gradientHeight;
    final List<Color> gradientColors;
    if (scrollTheme.gradientColors != null &&
        scrollTheme.gradientColors!.isNotEmpty) {
      gradientColors = scrollTheme.gradientColors!;
    } else {
      final baseColor = _overlayStyle.backgroundColor;
      gradientColors = [
        baseColor.withValues(alpha: 0.0),
        baseColor,
      ];
    }
    final borderRadius = BorderRadius.circular(_overlayStyle.borderRadius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          child,
          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _canScrollUp,
              builder: (context, canScrollUp, _) {
                return IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: canScrollUp ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      height: gradientHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _canScrollDown,
              builder: (context, canScrollDown, _) {
                return IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: canScrollDown ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Container(
                      height: gradientHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: gradientColors.reversed.toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
