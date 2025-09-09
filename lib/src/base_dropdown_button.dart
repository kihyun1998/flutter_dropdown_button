import 'package:flutter/material.dart';

import 'dropdown_mixin.dart';
import 'dropdown_theme.dart';

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
  /// If null, uses [DropdownTheme.defaultTheme] with theme-appropriate colors.
  /// Allows customization of colors, animations, and interaction effects.
  final DropdownTheme? theme;

  /// Whether the dropdown is enabled for user interaction.
  ///
  /// When false, the dropdown appears dimmed and does not respond
  /// to taps or other user input. Defaults to true.
  final bool enabled;
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
  
  /// Gets the effective theme, using provided theme or default.
  DropdownTheme get effectiveTheme => widget.theme ?? DropdownTheme.defaultTheme;

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
  double get overlayElevation => effectiveTheme.elevation;

  @override
  double get overlayBorderRadius => effectiveTheme.borderRadius;

  @override
  Color? get overlayShadowColor => effectiveTheme.shadowColor;

  @override
  void initState() {
    super.initState();
    initializeDropdown();
  }

  @override
  void dispose() {
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

  /// Builds the common dropdown overlay content with items.
  ///
  /// This method handles the common structure that all dropdown variants share:
  /// - Scrollable container
  /// - Item iteration and selection state
  /// - Theme application and interaction handling
  /// - First/last item border radius logic
  ///
  /// Each item's actual content is delegated to [buildItemWidget].
  @override
  Widget buildOverlayContent(double height) {
    final items = getItems();
    
    return SingleChildScrollView(
      child: Column(
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
      ),
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
          splashColor: effectiveTheme.itemSplashColor ?? Theme.of(context).splashColor,
          highlightColor: effectiveTheme.itemHighlightColor ?? Theme.of(context).highlightColor,
          hoverColor: effectiveTheme.itemHoverColor ?? Theme.of(context).hoverColor,
          // Apply item-specific border radius if provided, otherwise use overlay radius for edges
          borderRadius: BorderRadius.circular(
            effectiveTheme.itemBorderRadius ?? 
            (isFirst || isLast ? effectiveTheme.borderRadius : 0.0)
          ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Flexible(child: buildSelectedWidget()),
            const SizedBox(width: 8),
            Icon(
              isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: widget.enabled
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
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
  /// items differently (e.g., List<String> vs List<DropdownItem<T>>).
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