import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/dropdown_scroll_theme.dart';
import '../theme/dropdown_style_theme.dart';
import '../theme/dropdown_theme.dart';
import '../theme/tooltip_theme.dart';
import 'dropdown_mixin.dart';
import 'menu_alignment.dart';

/// Abstract base class for all dropdown button variants.
///
/// This class provides common properties and structure for different dropdown
/// implementations while allowing each variant to customize their specific
/// rendering and behavior through abstract methods.
///
/// Common features provided:
/// - Value management (selection state)
/// - Callback handling (onChanged)
/// - Sizing constraints (width, minWidth, maxWidth)
/// - Theme support
/// - Animation and overlay configuration
/// - Enabled/disabled state
///
/// Subclasses must implement:
/// - Item management (how items are stored and accessed)
/// - Widget rendering (how selected values and items are displayed)
abstract class BaseDropdownButton<T> extends StatefulWidget {
  /// Creates a base dropdown button widget.
  ///
  /// The [onChanged] parameter is required. All other parameters have
  /// sensible defaults but can be customized as needed.
  const BaseDropdownButton({
    super.key,
    required this.onChanged,
    this.value,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.width,
    this.maxWidth,
    this.minWidth,
    this.theme,
    this.enabled = true,
    this.scrollToSelectedItem = true,
    this.scrollToSelectedDuration,
    this.expand = false,
    this.trailing,
    this.showSeparator = false,
    this.separator,
    this.minMenuWidth,
    this.maxMenuWidth,
    this.menuAlignment = MenuAlignment.left,
  }) : assert(
          minMenuWidth == null ||
              maxMenuWidth == null ||
              minMenuWidth <= maxMenuWidth,
          'minMenuWidth must be less than or equal to maxMenuWidth',
        );

  /// Called when the user selects an item from the dropdown.
  ///
  /// The callback receives the value of the selected item, or null if
  /// no item is selected or if selection is cleared.
  final ValueChanged<T?> onChanged;

  /// The currently selected value.
  ///
  /// If this value is not null and matches one of the item values,
  /// that item will be highlighted in the dropdown and displayed
  /// as the current selection.
  final T? value;

  /// The maximum height of the dropdown overlay.
  ///
  /// If the content exceeds this height, the dropdown becomes scrollable.
  /// Defaults to 200.0.
  final double height;

  /// The height of each individual dropdown item.
  ///
  /// All items will have the same height for consistent appearance.
  /// Defaults to 48.0.
  final double itemHeight;

  /// The duration of the dropdown show/hide animation.
  ///
  /// The dropdown uses a combination of scale and opacity animations.
  /// Defaults to 200 milliseconds.
  final Duration animationDuration;

  /// The fixed width of the dropdown button and overlay.
  ///
  /// If null, the dropdown will size itself based on content
  /// within the constraints of [minWidth] and [maxWidth].
  final double? width;

  /// The maximum width of the dropdown button and overlay.
  ///
  /// When [width] is null, the dropdown will size itself based on content
  /// but will not exceed this maximum width. If content is longer,
  /// it will be handled according to the specific dropdown implementation.
  ///
  /// If null, no maximum width constraint is applied.
  final double? maxWidth;

  /// The minimum width of the dropdown button and overlay.
  ///
  /// When [width] is null, the dropdown will size itself based on content
  /// but will be at least this wide. Useful for ensuring consistent
  /// minimum button size regardless of content length.
  ///
  /// Defaults to null (no minimum width constraint).
  final double? minWidth;

  /// Custom theme configuration for the dropdown appearance and behavior.
  ///
  /// Accepts [DropdownStyleTheme] which allows you to configure both dropdown
  /// styling and scrollbar appearance. If null, uses [DropdownStyleTheme.defaultTheme]
  /// with theme-appropriate colors.
  final DropdownStyleTheme? theme;

  /// Whether the dropdown is enabled for user interaction.
  ///
  /// When false, the dropdown appears dimmed and does not respond
  /// to taps or other user input. Defaults to true.
  final bool enabled;

  /// Whether to automatically scroll to the selected item when dropdown opens.
  ///
  /// When true, the dropdown will scroll to show the currently selected item
  /// when opened. This is especially useful when there are many items and
  /// scrolling is required.
  ///
  /// The scroll behavior depends on [scrollToSelectedDuration]:
  /// - If null: instantly jumps to the selected item
  /// - If provided: animates smoothly to the selected item
  ///
  /// Defaults to true.
  final bool scrollToSelectedItem;

  /// The duration for scrolling animation to the selected item.
  ///
  /// If null, the dropdown will instantly jump to the selected item position.
  /// If provided, the dropdown will smoothly animate to the selected item
  /// over this duration.
  ///
  /// Only takes effect when [scrollToSelectedItem] is true.
  ///
  /// Defaults to null (instant jump).
  final Duration? scrollToSelectedDuration;

  /// Whether the dropdown should expand to fill available space in a flex container.
  ///
  /// When true, the dropdown will be wrapped in an Expanded widget, making it
  /// fill the remaining space in a Row, Column, or Flex parent. This is useful
  /// when you want the dropdown to take up available space alongside other widgets.
  ///
  /// When false (default), the dropdown sizes itself based on its content and
  /// width constraints (width, minWidth, maxWidth).
  ///
  /// Example:
  /// ```dart
  /// Row(
  ///   children: [
  ///     Text('Label:'),
  ///     TextOnlyDropdownButton(
  ///       expand: true,  // Takes remaining space
  ///       maxWidth: 200,
  ///       ...
  ///     ),
  ///   ],
  /// )
  /// ```
  ///
  /// Defaults to false.
  final bool expand;

  /// An optional widget to replace the default dropdown arrow icon.
  ///
  /// This widget will be automatically wrapped with a [RotationTransition]
  /// that rotates it 180 degrees when the dropdown opens/closes.
  ///
  /// The height is constrained to [DropdownTheme.iconSize]. If null,
  /// the default arrow icon from the theme will be used.
  ///
  /// Example:
  /// ```dart
  /// TextOnlyDropdownButton(
  ///   trailing: Icon(Icons.expand_more),
  ///   items: ['Option 1', 'Option 2'],
  ///   ...
  /// )
  /// ```
  final Widget? trailing;

  /// Whether to show separators between dropdown items.
  ///
  /// When true, a separator widget will be inserted between each item
  /// in the dropdown overlay. The separator can be customized using
  /// the [separator] parameter.
  ///
  /// Defaults to false.
  ///
  /// **Deprecated**: Use [DropdownTheme.itemBorder] instead for better control
  /// and proper height calculation. For example:
  /// ```dart
  /// DropdownTheme(
  ///   itemBorder: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
  /// )
  /// ```
  @Deprecated('Use DropdownTheme.itemBorder instead. Will be removed in 2.0.0')
  final bool showSeparator;

  /// The widget to use as a separator between dropdown items.
  ///
  /// Only used when [showSeparator] is true. If null, a default
  /// [Divider] widget will be used.
  ///
  /// Example:
  /// ```dart
  /// TextOnlyDropdownButton(
  ///   showSeparator: true,
  ///   separator: Divider(color: Colors.grey, height: 1),
  ///   items: ['Option 1', 'Option 2'],
  ///   ...
  /// )
  /// ```
  ///
  /// **Deprecated**: Use [DropdownTheme.itemBorder] instead for better control
  /// and proper height calculation.
  @Deprecated('Use DropdownTheme.itemBorder instead. Will be removed in 2.0.0')
  final Widget? separator;

  /// The minimum width of the dropdown menu overlay.
  ///
  /// When set, the menu will be at least this wide even if the button
  /// is narrower. Useful for ensuring menu items are fully visible.
  ///
  /// Example:
  /// ```dart
  /// TextOnlyDropdownButton(
  ///   items: ['Short', 'A very long item text'],
  ///   width: 100,
  ///   minMenuWidth: 200,  // Menu will be 200px wide
  ///   ...
  /// )
  /// ```
  final double? minMenuWidth;

  /// The maximum width of the dropdown menu overlay.
  ///
  /// When set, the menu will not exceed this width even if the button
  /// is wider. Useful for preventing excessively wide menus.
  ///
  /// Example:
  /// ```dart
  /// TextOnlyDropdownButton(
  ///   items: items,
  ///   maxWidth: 500,  // Button max 500px
  ///   maxMenuWidth: 300,  // Menu max 300px
  ///   ...
  /// )
  /// ```
  final double? maxMenuWidth;

  /// Defines how the dropdown menu should be aligned relative to the button
  /// when the menu is wider than the button.
  ///
  /// This only takes effect when the menu is wider than the button
  /// (e.g., when [minMenuWidth] is larger than the button width).
  ///
  /// - [MenuAlignment.left] (default): Left edges align, menu extends right
  /// - [MenuAlignment.center]: Menu centered over button
  /// - [MenuAlignment.right]: Right edges align, menu extends left
  ///
  /// Example:
  /// ```dart
  /// TextOnlyDropdownButton(
  ///   items: items,
  ///   width: 100,
  ///   minMenuWidth: 200,
  ///   menuAlignment: MenuAlignment.center,  // Menu centered over button
  ///   ...
  /// )
  /// ```
  ///
  /// Defaults to [MenuAlignment.left].
  final MenuAlignment menuAlignment;
}

/// Abstract base state class for all dropdown button variants.
///
/// This class provides common functionality for dropdown state management,
/// including overlay rendering, animations, positioning, and user interaction
/// handling. It uses [DropdownMixin] for core dropdown behavior and adds
/// the shared rendering logic that all dropdown variants use.
///
/// Subclasses must implement:
/// - [buildSelectedWidget]: How to render the currently selected value
/// - [buildItemWidget]: How to render individual dropdown items
/// - [getItems]: How to access the list of available items
abstract class BaseDropdownButtonState<W extends BaseDropdownButton<T>, T>
    extends State<W> with SingleTickerProviderStateMixin, DropdownMixin<W> {
  /// Gets the effective dropdown theme from the DropdownStyleTheme.
  DropdownTheme get effectiveTheme {
    return widget.theme?.dropdown ?? DropdownTheme.defaultTheme;
  }

  /// Gets the effective scroll theme if available.
  DropdownScrollTheme? get effectiveScrollTheme {
    return widget.theme?.scroll;
  }

  /// Gets the effective tooltip theme from the DropdownStyleTheme.
  DropdownTooltipTheme get effectiveTooltipTheme {
    return widget.theme?.tooltip ?? DropdownTooltipTheme.defaultTheme;
  }

  // DropdownMixin implementation
  @override
  Duration get animationDuration => widget.animationDuration;

  @override
  double get itemHeight => widget.itemHeight;

  @override
  double get maxDropdownHeight => widget.height;

  @override
  int get itemCount => getItems().length;

  @override
  bool get isEnabled => widget.enabled;

  @override
  double get actualItemHeight {
    // Calculate the actual height including margins
    final itemMargin = effectiveTheme.itemMargin;
    final marginHeight =
        itemMargin != null ? (itemMargin.top + itemMargin.bottom) : 0.0;
    return widget.itemHeight + marginHeight;
  }

  @override
  double get overlayElevation => effectiveTheme.elevation;

  @override
  double get overlayBorderRadius => effectiveTheme.borderRadius;

  @override
  double get overlayBorderThickness {
    final overlayDecoration = buildOverlayDecoration();
    if (overlayDecoration?.border != null) {
      final border = overlayDecoration!.border!;
      if (border is Border) {
        return border.top.width + border.bottom.width;
      }
    }
    return 0.0;
  }

  @override
  Color? get overlayShadowColor => effectiveTheme.shadowColor;

  @override
  EdgeInsets? get overlayPadding => effectiveTheme.overlayPadding;

  @override
  double? get minMenuWidth => widget.minMenuWidth;

  @override
  double? get maxMenuWidth => widget.maxMenuWidth;

  @override
  MenuAlignment get menuAlignment => widget.menuAlignment;

  @override
  void initState() {
    super.initState();
    initializeDropdown();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_updateScrollGradients);
    _scrollController?.dispose();
    _canScrollUp.dispose();
    _canScrollDown.dispose();
    disposeDropdown();
    super.dispose();
  }

  /// Updates the scroll gradient visibility based on current scroll position.
  void _updateScrollGradients() {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    final position = _scrollController!.position;
    _canScrollUp.value = position.pixels > 0;
    _canScrollDown.value = position.pixels < position.maxScrollExtent;
  }

  /// Initializes scroll gradients after the first frame.
  void _initializeScrollGradients() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null && _scrollController!.hasClients) {
        _updateScrollGradients();
      }
    });
  }

  @override
  void onDropdownItemSelected() {
    closeDropdown();
  }

  @override
  BoxDecoration? buildOverlayDecoration() {
    return effectiveTheme.overlayDecoration ??
        BoxDecoration(
          color: effectiveTheme.backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          border: effectiveTheme.border ??
              Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
        );
  }

  // ScrollController for custom scrollbar
  ScrollController? _scrollController;

  // ValueNotifiers for scroll gradient visibility
  final ValueNotifier<bool> _canScrollUp = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollDown = ValueNotifier<bool>(false);

  /// Builds the common dropdown overlay content with items.
  ///
  /// This method handles the common structure that all dropdown variants share:
  /// - Scrollable container with custom scrollbar theming (only when needed)
  /// - Item iteration and selection state
  /// - Theme application and interaction handling
  /// - First/last item border radius logic
  ///
  /// Each item's actual content is delegated to [buildItemWidget].
  @override
  Widget buildOverlayContent(double height) {
    final items = getItems();
    final scrollTheme = effectiveScrollTheme;

    // Calculate overlay padding
    final padding = effectiveTheme.overlayPadding;
    final paddingVertical =
        padding != null ? (padding.top + padding.bottom) : 0.0;

    // Calculate total items height with margins
    // Note: height already includes border thickness and overlay padding from calculateDropdownPosition
    final availableContentHeight =
        height - overlayBorderThickness - paddingVertical;
    final totalItemsHeight = items.length * actualItemHeight;
    final needsScroll = totalItemsHeight > availableContentHeight;

    Widget content;

    // Only apply scrolling if needed
    if (needsScroll) {
      // Create ScrollController if not already created
      // Controller is needed for both scrollbar theming and scroll-to-selected functionality
      if (_scrollController == null) {
        _scrollController = ScrollController();
        _scrollController!.addListener(_updateScrollGradients);
      }

      // Initialize gradient visibility after first frame
      _initializeScrollGradients();

      // Schedule scroll to selected item after overlay is displayed
      if (widget.scrollToSelectedItem && widget.value != null) {
        _scheduleScrollToSelectedItem();
      }

      // Use ListView.builder for better performance with many items (lazy loading)
      // ClampingScrollPhysics prevents bouncing effect which can cause performance issues
      content = ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _calculateItemCount(items.length),
        itemBuilder: (context, index) =>
            _buildListItem(items, index, items.length),
      );

      // Apply custom scrollbar theme if provided
      if (scrollTheme != null) {
        // Check if custom width control is needed
        final bool hasCustomWidths =
            scrollTheme.thumbWidth != null || scrollTheme.trackWidth != null;

        if (hasCustomWidths) {
          // Use custom scrollbar implementation with independent width control
          content = _buildCustomScrollbar(content, scrollTheme);
        } else {
          // Use standard Scrollbar with unified thickness
          // First wrap content with Scrollbar
          Widget scrollbarWidget = Scrollbar(
            controller: _scrollController,
            thickness: scrollTheme.thickness,
            radius: scrollTheme.radius,
            thumbVisibility: scrollTheme.thumbVisibility,
            trackVisibility: scrollTheme.trackVisibility,
            interactive: scrollTheme.interactive,
            child: content,
          );

          // Then wrap Scrollbar with ScrollbarTheme for colors
          // ScrollbarTheme must be OUTSIDE Scrollbar to affect it
          if (scrollTheme.thumbColor != null ||
              scrollTheme.trackColor != null ||
              scrollTheme.trackBorderColor != null ||
              scrollTheme.crossAxisMargin != null ||
              scrollTheme.mainAxisMargin != null ||
              scrollTheme.minThumbLength != null) {
            content = ScrollbarTheme(
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
          } else {
            content = scrollbarWidget;
          }
        }
      }

      // Add scroll gradient indicators if enabled
      if (scrollTheme?.showScrollGradient == true) {
        content = _buildScrollGradientOverlay(content, scrollTheme!);
      }
    } else {
      // Build the items column for non-scrollable content
      final List<Widget> itemWidgets = [];
      for (int index = 0; index < items.length; index++) {
        final item = items[index];
        final isSelected = isItemSelected(item);
        final isFirst = index == 0;
        final isLast = index == items.length - 1;

        // Add the item
        itemWidgets.add(
          _buildItemWrapper(
            item: item,
            isSelected: isSelected,
            isFirst: isFirst,
            isLast: isLast,
            child: buildItemWidget(item, isSelected),
          ),
        );

        // Add separator after item (except for the last item)
        // ignore: deprecated_member_use_from_same_package
        if (widget.showSeparator && !isLast) {
          // ignore: deprecated_member_use_from_same_package
          itemWidgets.add(widget.separator ?? const Divider(height: 1));
        }
      }

      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: itemWidgets,
      );
    }

    // Apply overlay padding if specified
    if (padding != null) {
      content = Padding(
        padding: padding,
        child: content,
      );
    }

    return content;
  }

  /// Calculates the total item count for ListView.builder including separators.
  int _calculateItemCount(int itemsLength) {
    // ignore: deprecated_member_use_from_same_package
    if (widget.showSeparator) {
      // items + separators (n items + n-1 separators = 2n - 1)
      return itemsLength * 2 - 1;
    }
    return itemsLength;
  }

  /// Builds a list item or separator for ListView.builder.
  Widget _buildListItem(List<T> items, int index, int itemsLength) {
    // ignore: deprecated_member_use_from_same_package
    if (widget.showSeparator) {
      // Even indices are items, odd indices are separators
      if (index.isOdd) {
        // ignore: deprecated_member_use_from_same_package
        return widget.separator ?? const Divider(height: 1);
      }
      // Convert ListView index to item index
      final itemIndex = index ~/ 2;
      return _buildItemAtIndex(items, itemIndex, itemsLength);
    }
    return _buildItemAtIndex(items, index, itemsLength);
  }

  /// Builds an item widget at the given index.
  Widget _buildItemAtIndex(List<T> items, int itemIndex, int itemsLength) {
    final item = items[itemIndex];
    final isSelected = isItemSelected(item);
    final isFirst = itemIndex == 0;
    final isLast = itemIndex == itemsLength - 1;

    return _buildItemWrapper(
      item: item,
      isSelected: isSelected,
      isFirst: isFirst,
      isLast: isLast,
      child: buildItemWidget(item, isSelected),
    );
  }

  /// Builds the common item wrapper with theme and interaction handling.
  Widget _buildItemWrapper({
    required T item,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: effectiveTheme.itemMargin,
        child: InkWell(
          onTap: () {
            onItemTap(item);
            onDropdownItemSelected();
          },
          // Custom splash and highlight colors from theme
          splashColor:
              effectiveTheme.itemSplashColor ?? Theme.of(context).splashColor,
          highlightColor: effectiveTheme.itemHighlightColor ??
              Theme.of(context).highlightColor,
          hoverColor:
              effectiveTheme.itemHoverColor ?? Theme.of(context).hoverColor,
          // Apply item-specific border radius if provided, otherwise use overlay radius for edges
          borderRadius: BorderRadius.circular(effectiveTheme.itemBorderRadius ??
              (isFirst || isLast ? effectiveTheme.borderRadius : 0.0)),
          child: Ink(
            height: widget.itemHeight,
            width: double.infinity,
            padding: effectiveTheme.itemPadding,
            decoration: BoxDecoration(
              // Highlight selected item with theme or primary color
              color: isSelected
                  ? effectiveTheme.selectedItemColor ??
                      Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              // Apply item-specific border radius if provided
              borderRadius: effectiveTheme.itemBorderRadius != null
                  ? BorderRadius.circular(effectiveTheme.itemBorderRadius!)
                  : null,
              // Apply item border, excluding last item if configured
              border: (isLast && effectiveTheme.excludeLastItemBorder)
                  ? null
                  : effectiveTheme.itemBorder,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the dropdown button with common structure and constraints.
  @override
  Widget build(BuildContext context) {
    Widget dropdownButton = Container(
      key: dropdownButtonKey,
      width: widget.width,
      decoration: buildButtonDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? toggleDropdown : null,
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          splashColor:
              effectiveTheme.buttonSplashColor ?? Theme.of(context).splashColor,
          highlightColor: effectiveTheme.buttonHighlightColor ??
              Theme.of(context).highlightColor,
          hoverColor:
              effectiveTheme.buttonHoverColor ?? Theme.of(context).hoverColor,
          child: Padding(
            padding: effectiveTheme.buttonPadding,
            child: _buildButtonContent(),
          ),
        ),
      ),
    );

    // Apply opacity for disabled state
    if (!isEnabled) {
      dropdownButton = Opacity(opacity: 0.6, child: dropdownButton);
    }

    // Apply width constraints if specified
    return _applyWidthConstraints(dropdownButton);
  }

  /// Builds the button content with proper height handling.
  Widget _buildButtonContent() {
    // Calculate effective heights
    final effectiveContentHeight =
        effectiveTheme.buttonHeight ?? effectiveTheme.iconSize ?? 24.0;
    final effectiveIconSize = effectiveTheme.iconSize ?? 24.0;

    // Use the larger of content height or icon size to prevent overflow
    final rowHeight = effectiveContentHeight > effectiveIconSize
        ? effectiveContentHeight
        : effectiveIconSize;

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
          // Selected content
          Flexible(
            child: SizedBox(
              height: effectiveContentHeight,
              child: widget.width != null || widget.expand
                  ? Container(
                      alignment: Alignment.centerLeft,
                      child: buildSelectedWidget(),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1.0,
                      child: buildSelectedWidget(),
                    ),
            ),
          ),

          // Trailing widget (with rotation animation)
          if (showTrailing)
            Padding(
              padding:
                  effectiveTheme.iconPadding ?? const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                height: effectiveIconSize,
                child: Center(
                  child: RotationTransition(
                    turns: dropdownIconRotationAnimation,
                    child: widget.trailing ??
                        Icon(
                          effectiveTheme.icon ?? Icons.keyboard_arrow_down,
                          size: effectiveIconSize,
                          color: widget.enabled
                              ? (effectiveTheme.iconColor ??
                                  Theme.of(context).iconTheme.color)
                              : (effectiveTheme.iconDisabledColor ??
                                  Theme.of(context).disabledColor),
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the decoration for the dropdown button.
  BoxDecoration buildButtonDecoration() {
    return effectiveTheme.buttonDecoration ??
        BoxDecoration(
          border: effectiveTheme.border ??
              Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
        );
  }

  /// Applies width constraints to the dropdown button.
  Widget _applyWidthConstraints(Widget child) {
    // First apply width constraints if specified
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

    // Then wrap with Expanded if expand is true
    if (widget.expand) {
      child = Expanded(child: child);
    }

    return child;
  }

  /// Schedules scrolling to the selected item after the overlay is displayed.
  ///
  /// This method uses [SchedulerBinding.addPostFrameCallback] to ensure that
  /// the scroll happens after the overlay has been rendered and the scroll
  /// controller is properly attached to the scrollable widget.
  void _scheduleScrollToSelectedItem() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _scrollController == null ||
          !_scrollController!.hasClients) {
        return;
      }

      final selectedIndex = _findSelectedItemIndex();
      if (selectedIndex == -1) {
        return;
      }

      // Calculate the exact scroll offset for the selected item
      // offset = selectedIndex * (itemHeight + margin)
      final scrollOffset = selectedIndex * actualItemHeight;

      // Ensure the offset is within valid scroll range
      final maxScrollExtent = _scrollController!.position.maxScrollExtent;
      final clampedOffset = scrollOffset.clamp(0.0, maxScrollExtent);

      // Scroll to the selected item
      if (widget.scrollToSelectedDuration != null) {
        // Animate to the position
        _scrollController!.animateTo(
          clampedOffset,
          duration: widget.scrollToSelectedDuration!,
          curve: Curves.easeInOut,
        );
      } else {
        // Jump immediately to the position
        _scrollController!.jumpTo(clampedOffset);
      }
    });
  }

  /// Finds the index of the currently selected item.
  ///
  /// Returns -1 if no item is selected or if the selected value
  /// doesn't match any item in the list.
  int _findSelectedItemIndex() {
    if (widget.value == null) {
      return -1;
    }

    final items = getItems();
    for (int i = 0; i < items.length; i++) {
      if (isItemSelected(items[i])) {
        return i;
      }
    }

    return -1;
  }

  /// Builds a custom scrollbar with independent thumb and track width control.
  ///
  /// This method creates a scrollbar where the thumb and track can have
  /// different widths, which is not possible with the standard Scrollbar widget.
  Widget _buildCustomScrollbar(Widget child, DropdownScrollTheme scrollTheme) {
    final double effectiveThumbWidth =
        scrollTheme.thumbWidth ?? scrollTheme.thickness ?? 8.0;
    final double effectiveTrackWidth =
        scrollTheme.trackWidth ?? scrollTheme.thickness ?? 8.0;

    // Build theme data for the scrollbar
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

    // If track width is different from thumb width, we need custom rendering
    if (effectiveTrackWidth != effectiveThumbWidth &&
        scrollTheme.trackVisibility == true) {
      // Use RawScrollbar for more control
      return ScrollbarTheme(
        data: scrollbarThemeData.copyWith(
          // Set track thickness separately
          trackColor: scrollTheme.trackColor != null
              ? WidgetStateProperty.all(scrollTheme.trackColor)
              : null,
        ),
        child: RawScrollbar(
          controller: _scrollController,
          thickness: effectiveThumbWidth,
          radius: scrollTheme.radius,
          thumbVisibility: scrollTheme.thumbVisibility ?? false,
          trackVisibility: scrollTheme.trackVisibility ?? false,
          interactive: scrollTheme.interactive ?? true,
          thumbColor: scrollTheme.thumbColor,
          trackColor: scrollTheme.trackColor,
          trackBorderColor: scrollTheme.trackBorderColor,
          crossAxisMargin: scrollTheme.crossAxisMargin ?? 0,
          mainAxisMargin: scrollTheme.mainAxisMargin ?? 0,
          minThumbLength: scrollTheme.minThumbLength ?? 18,
          child: child,
        ),
      );
    }

    // Otherwise use standard Scrollbar with theme
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

  /// Builds a scroll gradient overlay that shows fade indicators
  /// at the top and bottom when content is scrollable.
  Widget _buildScrollGradientOverlay(
    Widget child,
    DropdownScrollTheme scrollTheme,
  ) {
    final gradientHeight = scrollTheme.gradientHeight ?? 24.0;
    // Use gradient colors from theme, or create default gradient from background color
    final List<Color> gradientColors;
    if (scrollTheme.gradientColors != null &&
        scrollTheme.gradientColors!.isNotEmpty) {
      gradientColors = scrollTheme.gradientColors!;
    } else {
      // Fallback: create default gradient from background color
      final baseColor =
          effectiveTheme.backgroundColor ?? Theme.of(context).cardColor;
      gradientColors = [
        baseColor.withValues(alpha: 0.0),
        baseColor,
      ];
    }
    final borderRadius = BorderRadius.circular(overlayBorderRadius);

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          child,
          // Top gradient (visible when can scroll up)
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
          // Bottom gradient (visible when can scroll down)
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

  /// Whether to show the trailing widget (dropdown icon).
  ///
  /// Subclasses can override this to conditionally hide the trailing widget.
  /// Defaults to true.
  bool get showTrailing => true;

  // Abstract methods that subclasses must implement

  /// Builds the widget displayed when an item is selected or showing hint.
  ///
  /// This widget appears in the dropdown button (not in the overlay).
  /// Should handle both selected state and hint/empty state appropriately.
  Widget buildSelectedWidget();

  /// Builds the widget for an individual dropdown item in the overlay.
  ///
  /// The [item] is the data for this dropdown item.
  /// The [isSelected] indicates if this item is currently selected.
  Widget buildItemWidget(T item, bool isSelected);

  /// Returns the list of items available in this dropdown.
  ///
  /// This abstraction allows different dropdown types to manage their
  /// items differently (e.g., `List<String>` vs `List<DropdownItem<T>>`).
  List<T> getItems();

  /// Determines if the given item is currently selected.
  ///
  /// Default implementation compares with widget.value, but subclasses
  /// can override for custom selection logic.
  bool isItemSelected(T item) => widget.value == item;

  /// Called when an item is tapped. Should trigger the onChanged callback.
  ///
  /// Default implementation calls widget.onChanged, but subclasses can
  /// override for custom handling (e.g., additional callbacks).
  void onItemTap(T item) {
    widget.onChanged(item);
  }
}
