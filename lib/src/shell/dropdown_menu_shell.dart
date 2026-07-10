import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../buttons/menu_alignment.dart';
import '../overlay/dropdown_overlay_controller.dart';
import '../presentation/item_presentation.dart';
import '../search/dropdown_search_controller.dart';
import '../theme/dropdown_scroll_theme.dart';
import '../theme/dropdown_style_theme.dart';
import '../theme/dropdown_theme.dart';
import '../theme/resolved_dropdown_style.dart';
import '../theme/search_field_theme.dart';
import '../widgets/scroll_gradient_overlay.dart';

/// The button, the overlay, and everything between them.
///
/// **This file does not know what selection is.** It never sees a `value`, a
/// `Set`, or an `onChanged`. It is handed a predicate that says whether a row
/// is chosen and a callback for when one is tapped. What a caller does with
/// those is what makes a dropdown single- or multi-select; nothing in here
/// changes.
///
/// Not exported. It is an implementation detail shared by the public widgets,
/// and every parameter it takes is one of theirs.
class DropdownMenuShell<T> extends StatefulWidget {
  /// Creates the shell.
  const DropdownMenuShell({
    super.key,
    required this.items,
    required this.presentation,
    required this.isChosen,
    required this.onItemTap,
    required this.enabled,
    required this.showTrailing,
    required this.height,
    required this.itemHeight,
    required this.animationDuration,
    required this.expand,
    required this.menuAlignment,
    required this.searchable,
    this.scrollToItem,
    this.scrollToItemDuration,
    this.searchFilter,
    this.emptyBuilder,
    this.theme,
    this.trailing,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.minMenuWidth,
    this.maxMenuWidth,
  });

  /// Everything the menu may show, before the query narrows it.
  final List<T> items;

  /// How rows and the button's face are drawn.
  final DropdownItemPresentation<T> presentation;

  /// Whether [item] is currently chosen. Drives the row's selected styling.
  final bool Function(T item) isChosen;

  /// Called when a row is tapped. The menu closes afterwards.
  ///
  /// A checklist will want to stay open instead. That is a `closeOnTap` flag,
  /// and it arrives with the caller that needs it — a parameter no caller sets
  /// is a branch no test can reach.
  final void Function(T item) onItemTap;

  /// Whether the button responds to a tap.
  final bool enabled;

  /// Whether the trailing icon is drawn at all.
  final bool showTrailing;

  /// The row to reveal when the menu opens, if it is not already in view.
  ///
  /// Null means do not scroll. A caller with no notion of a single chosen row
  /// passes null and the machinery below never runs.
  final T? scrollToItem;

  /// How long the scroll to [scrollToItem] takes. Null jumps.
  final Duration? scrollToItemDuration;

  /// The menu's maximum height.
  final double height;

  /// The height of one row, before item margin.
  final double itemHeight;

  /// How long the open and close animation takes.
  final Duration animationDuration;

  /// Whether the button fills its parent's cross-axis space.
  final bool expand;

  /// Which edge of the button the menu lines up with.
  final MenuAlignment menuAlignment;

  /// Whether the menu carries a search field.
  final bool searchable;

  /// The caller's filter. Wins over the presentation's default.
  final bool Function(T item, String query)? searchFilter;

  /// Drawn when a query matches nothing.
  final Widget Function(String query)? emptyBuilder;

  /// Styling for the button, the menu, its scrollbar and its search field.
  final DropdownStyleTheme? theme;

  /// Replaces the trailing icon.
  final Widget? trailing;

  /// A fixed button width.
  final double? width;

  /// The button's minimum width, when [width] is null.
  final double? minWidth;

  /// The button's maximum width, when [width] is null.
  final double? maxWidth;

  /// The menu's minimum width.
  final double? minMenuWidth;

  /// The menu's maximum width.
  final double? maxMenuWidth;

  @override
  State<DropdownMenuShell<T>> createState() => _DropdownMenuShellState<T>();
}

class _DropdownMenuShellState<T> extends State<DropdownMenuShell<T>>
    with SingleTickerProviderStateMixin {
  late final DropdownOverlayController _menu = DropdownOverlayController(
    vsync: this,
    animationDuration: widget.animationDuration,
    spec: _buildSpec,
    contentBuilder: _buildOverlayContent,
    decorationBuilder: _buildOverlayDecoration,
    // Opening and closing both start the search over. The overlay's dismiss
    // barrier closes the menu without going through this State, so the reset
    // has to be driven from the controller rather than from our callers.
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
      effectiveTheme.resolveButton(_ambient, enabled: widget.enabled);

  ResolvedOverlayStyle get _overlayStyle =>
      effectiveTheme.resolveOverlay(_ambient);

  ResolvedSearchFieldStyle get _searchStyle =>
      effectiveSearchTheme.resolve(_ambient);

  /// Never null. Without one the menu used to fall through to the scrollbar
  /// Flutter's `MaterialScrollBehavior` inserts on desktop, which answers to
  /// nothing this package exposes and swells on hover.
  DropdownScrollTheme get effectiveScrollTheme =>
      widget.theme?.scroll ?? DropdownScrollTheme.defaultTheme;

  SearchFieldTheme get effectiveSearchTheme =>
      widget.theme?.search ?? SearchFieldTheme.defaultTheme;

  // ===== Overlay =====

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
  List<T> _visibleItems() => _search.visibleItems(
    widget.items,
    widget.searchFilter ?? widget.presentation.defaultSearchFilter,
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
  void didUpdateWidget(DropdownMenuShell<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Nothing to recompute: the visible items are derived, not stored. The
    // query belongs to the user — clearing it is the job of open and close,
    // which `_resetSearch()` already handles.
    //
    // The overlay lives in its own element subtree and does not rebuild when
    // this widget does. Without this, a menu that is already open keeps showing
    // the items it was opened with — a list that arrives asynchronously never
    // appears until the user closes and reopens the dropdown. It is also what
    // repaints a checklist's boxes after the owner rebuilds with a new
    // selection.
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

  // ===== Overlay =====

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
          onTap: widget.enabled ? _toggleDropdown : null,
          mouseCursor: widget.enabled
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
    final presentation = widget.presentation;

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
          if (widget.showTrailing)
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
    final presentation = widget.presentation;
    final items = _visibleItems();
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

      // The index below is taken against `widget.items`, not the filtered list,
      // so a query in flight would send us to the wrong row.
      if (widget.scrollToItem != null && _search.query.isEmpty) {
        _scheduleScrollToItem();
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
            final isSelected = widget.isChosen(item);
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
        final isSelected = widget.isChosen(item);
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
            widget.onItemTap(item);
            _menu.close();
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

  // ===== Scroll to a named row =====

  void _scheduleScrollToItem() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _scrollController == null ||
          !_scrollController!.hasClients) {
        return;
      }

      // Re-read after the frame: the widget may have been rebuilt since the
      // callback was scheduled.
      final target = widget.scrollToItem;
      if (target == null) return;

      final index = widget.items.indexOf(target);
      if (index == -1) return;

      final scrollOffset = index * actualItemHeight;
      final maxScrollExtent = _scrollController!.position.maxScrollExtent;
      final clampedOffset = scrollOffset.clamp(0.0, maxScrollExtent);

      if (widget.scrollToItemDuration != null) {
        _scrollController!.animateTo(
          clampedOffset,
          duration: widget.scrollToItemDuration!,
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController!.jumpTo(clampedOffset);
      }
    });
  }
}
