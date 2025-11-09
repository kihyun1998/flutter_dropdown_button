import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/dropdown_scroll_theme.dart';
import '../theme/dropdown_style_theme.dart';
import '../theme/dropdown_theme.dart';
import 'dropdown_mixin.dart';

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
  });

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
  void initState() {
    super.initState();
    initializeDropdown();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    disposeDropdown();
    super.dispose();
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

    // Build the items column
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = isItemSelected(item);
        final isFirst = index == 0;
        final isLast = index == items.length - 1;

        return _buildItemWrapper(
          item: item,
          isSelected: isSelected,
          isFirst: isFirst,
          isLast: isLast,
          child: buildItemWidget(item, isSelected),
        );
      }).toList(),
    );

    // Only apply scrolling if needed
    if (needsScroll) {
      // Create ScrollController if not already created
      // Controller is needed for both scrollbar theming and scroll-to-selected functionality
      _scrollController ??= ScrollController();

      // Schedule scroll to selected item after overlay is displayed
      if (widget.scrollToSelectedItem && widget.value != null) {
        _scheduleScrollToSelectedItem();
      }

      // Wrap with SingleChildScrollView
      content = SingleChildScrollView(
        controller: _scrollController,
        child: content,
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
          // Apply ScrollbarTheme for colors first
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
              child: content,
            );
          }

          // Then wrap with Scrollbar
          content = Scrollbar(
            controller: _scrollController,
            thickness: scrollTheme.thickness,
            radius: scrollTheme.radius,
            thumbVisibility: scrollTheme.thumbVisibility,
            trackVisibility: scrollTheme.trackVisibility,
            interactive: scrollTheme.interactive,
            child: content,
          );
        }
      }
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
          child: Container(
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
    Widget dropdownButton = GestureDetector(
      key: dropdownButtonKey,
      onTap: toggleDropdown,
      child: Container(
        width: widget.width,
        padding: effectiveTheme.buttonPadding,
        decoration: buildButtonDecoration(),
        child: Row(
          mainAxisAlignment: widget.width != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          mainAxisSize:
              widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: SizedBox(
                height: effectiveTheme.iconSize ?? 24.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: buildSelectedWidget(),
                ),
              ),
            ),
            Padding(
              padding: effectiveTheme.iconPadding ??
                  const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                height: effectiveTheme.iconSize ?? 24.0,
                child: Center(
                  child: RotationTransition(
                    turns: dropdownIconRotationAnimation,
                    child: Icon(
                      effectiveTheme.icon ?? Icons.keyboard_arrow_down,
                      size: effectiveTheme.iconSize ?? 24.0,
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
      ),
    );

    // Apply opacity for disabled state
    if (!widget.enabled) {
      dropdownButton = Opacity(opacity: 0.6, child: dropdownButton);
    }

    // Apply width constraints if specified
    return _applyWidthConstraints(dropdownButton);
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
    if (widget.width == null &&
        (widget.minWidth != null || widget.maxWidth != null)) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? 0,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: child,
      );
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
