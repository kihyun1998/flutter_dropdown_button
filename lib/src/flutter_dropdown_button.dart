import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'buttons/dropdown_mixin.dart';
import 'buttons/menu_alignment.dart';
import 'config/text_dropdown_config.dart';
import 'theme/dropdown_scroll_theme.dart';
import 'theme/dropdown_style_theme.dart';
import 'theme/dropdown_theme.dart';
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
  })  : hintText = null,
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

  /// Whether this dropdown uses text mode rendering.
  bool get isTextMode => itemBuilder == null;

  /// Closes all currently open dropdown overlays.
  ///
  /// Useful before navigation to ensure no orphaned overlays remain.
  ///
  /// ```dart
  /// FlutterDropdownButton.closeAll();
  /// Navigator.pushReplacementNamed(context, '/home');
  /// ```
  static void closeAll() => DropdownMixin.closeAll();

  @override
  State<FlutterDropdownButton<T>> createState() =>
      _FlutterDropdownButtonState<T>();
}

class _FlutterDropdownButtonState<T> extends State<FlutterDropdownButton<T>>
    with
        SingleTickerProviderStateMixin,
        DropdownMixin<FlutterDropdownButton<T>> {
  // ===== Theme =====

  DropdownTheme get effectiveTheme =>
      widget.theme?.dropdown ?? DropdownTheme.defaultTheme;

  DropdownScrollTheme? get effectiveScrollTheme => widget.theme?.scroll;

  DropdownTooltipTheme get effectiveTooltipTheme =>
      widget.theme?.tooltip ?? DropdownTooltipTheme.defaultTheme;

  TextDropdownConfig get _textConfig =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  // ===== DropdownMixin implementation =====

  @override
  Duration get animationDuration => widget.animationDuration;

  @override
  double get itemHeight => widget.itemHeight;

  @override
  double get maxDropdownHeight => widget.height;

  @override
  int get itemCount => widget.items.length;

  @override
  bool get isEnabled => !_isSingleItemDisabled && widget.enabled;

  @override
  double get actualItemHeight {
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
    final decoration = _buildOverlayDecoration();
    if (decoration?.border != null) {
      final border = decoration!.border!;
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

  // ===== Single-item mode =====

  bool get _isSingleItemDisabled =>
      widget.disableWhenSingleItem && widget.items.length == 1;

  bool get _showTrailing =>
      !(_isSingleItemDisabled && widget.hideIconWhenSingleItem);

  // ===== Lifecycle =====

  ScrollController? _scrollController;
  final ValueNotifier<bool> _canScrollUp = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollDown = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    initializeDropdown();
    _autoSelectSingleItem();
  }

  @override
  void didUpdateWidget(FlutterDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _autoSelectSingleItem();
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

  @override
  void onDropdownItemSelected() => closeDropdown();

  @override
  BoxDecoration? buildOverlayDecoration() => _buildOverlayDecoration();

  BoxDecoration? _buildOverlayDecoration() {
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

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      key: dropdownButtonKey,
      width: widget.width,
      decoration: _buildButtonDecoration(),
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

    return _applyWidthConstraints(button);
  }

  BoxDecoration _buildButtonDecoration() {
    return effectiveTheme.buttonDecoration ??
        BoxDecoration(
          border: effectiveTheme.border ??
              Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
        );
  }

  Widget _buildButtonContent() {
    final effectiveContentHeight =
        effectiveTheme.buttonHeight ?? effectiveTheme.iconSize ?? 24.0;
    final effectiveIconSize = effectiveTheme.iconSize ?? 24.0;
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
          Flexible(
            child: SizedBox(
              height: effectiveContentHeight,
              child: widget.width != null || widget.expand
                  ? Container(
                      alignment: widget.isTextMode
                          ? _alignmentFromTextAlign(_textConfig.textAlign)
                          : Alignment.centerLeft,
                      child: _buildSelectedWidget(),
                    )
                  : Align(
                      alignment: widget.isTextMode
                          ? _alignmentFromTextAlign(_textConfig.textAlign)
                          : Alignment.centerLeft,
                      widthFactor: 1.0,
                      child: _buildSelectedWidget(),
                    ),
            ),
          ),
          if (_showTrailing)
            Padding(
              padding: effectiveTheme.iconPadding ??
                  const EdgeInsets.only(left: 8.0),
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

  // ===== Selected widget rendering =====

  Widget _buildSelectedWidget() {
    if (widget.isTextMode) {
      return _buildTextSelectedWidget();
    }
    return _buildCustomSelectedWidget();
  }

  Widget _buildCustomSelectedWidget() {
    final value = widget.value;
    if (value != null && widget.items.contains(value)) {
      if (widget.selectedBuilder != null) {
        return widget.selectedBuilder!(value);
      }
      return widget.itemBuilder!(value, true);
    }
    return widget.hintWidget ?? const SizedBox.shrink();
  }

  Widget _buildTextSelectedWidget() {
    final selectedText = widget.value as String?;
    final displayText = selectedText ?? widget.hintText ?? '';
    final isHint = selectedText == null;

    final textWidget = SmartTooltipText(
      text: displayText,
      tooltipTheme: effectiveTooltipTheme,
      style: isHint ? _textConfig.hintStyle : _textConfig.textStyle,
      textAlign: _textConfig.textAlign,
      maxLines: _textConfig.maxLines,
      overflow: _textConfig.overflow,
      softWrap: _textConfig.softWrap,
      textDirection: _textConfig.textDirection,
      locale: _textConfig.locale,
      textScaler: _textConfig.textScaler,
    );

    final leadingWidget = selectedText != null
        ? (widget.selectedLeading ?? widget.leading)
        : null;

    if (leadingWidget == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: widget.leadingPadding ?? const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: effectiveTheme.iconSize ?? 24.0,
            child: Center(child: leadingWidget),
          ),
        ),
        Flexible(child: textWidget),
      ],
    );
  }

  // ===== Item widget rendering =====

  Widget _buildItemWidget(T item, bool isSelected) {
    if (widget.isTextMode) {
      return _buildTextItemWidget(item as String, isSelected);
    }
    return widget.itemBuilder!(item, isSelected);
  }

  Widget _buildTextItemWidget(String item, bool isSelected) {
    final textWidget = SmartTooltipText(
      text: item,
      tooltipTheme: effectiveTooltipTheme,
      style: isSelected
          ? _textConfig.selectedTextStyle ?? _textConfig.textStyle
          : _textConfig.textStyle,
      textAlign: _textConfig.textAlign,
      maxLines: _textConfig.maxLines,
      overflow: _textConfig.overflow,
      softWrap: _textConfig.softWrap,
      textDirection: _textConfig.textDirection,
      locale: _textConfig.locale,
      textScaler: _textConfig.textScaler,
      semanticsLabel: _textConfig.semanticsLabel,
    );

    if (widget.leading == null) return textWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: widget.leadingPadding ?? const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: effectiveTheme.iconSize ?? 24.0,
            child: Center(child: widget.leading!),
          ),
        ),
        Flexible(child: textWidget),
      ],
    );
  }

  // ===== Overlay content =====

  @override
  Widget buildOverlayContent(double height) {
    final items = widget.items;
    final scrollTheme = effectiveScrollTheme;
    final padding = effectiveTheme.overlayPadding;
    final paddingVertical =
        padding != null ? (padding.top + padding.bottom) : 0.0;
    final availableContentHeight =
        height - overlayBorderThickness - paddingVertical;
    final totalItemsHeight = items.length * actualItemHeight;
    final needsScroll = totalItemsHeight > availableContentHeight;
    final itemAlignment = widget.isTextMode
        ? _alignmentFromTextAlign(_textConfig.textAlign)
        : Alignment.centerLeft;

    Widget content;

    if (needsScroll) {
      if (_scrollController == null) {
        _scrollController = ScrollController();
        _scrollController!.addListener(_updateScrollGradients);
      }

      _initializeScrollGradients();

      if (widget.scrollToSelectedItem && widget.value != null) {
        _scheduleScrollToSelectedItem();
      }

      content = ListView.builder(
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
            child: _buildItemWidget(item, isSelected),
          );
        },
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
            child: _buildItemWidget(item, isSelected),
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

    return content;
  }

  Alignment _alignmentFromTextAlign(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
        return Alignment.centerLeft;
    }
  }

  Widget _buildItemWrapper({
    required T item,
    required bool isSelected,
    required bool isFirst,
    required bool isLast,
    required Widget child,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: effectiveTheme.itemMargin,
        child: InkWell(
          onTap: () {
            widget.onChanged(item);
            onDropdownItemSelected();
          },
          splashColor:
              effectiveTheme.itemSplashColor ?? Theme.of(context).splashColor,
          highlightColor: effectiveTheme.itemHighlightColor ??
              Theme.of(context).highlightColor,
          hoverColor:
              effectiveTheme.itemHoverColor ?? Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(
            effectiveTheme.itemBorderRadius ??
                (isFirst || isLast ? effectiveTheme.borderRadius : 0.0),
          ),
          child: Ink(
            height: widget.itemHeight,
            width: double.infinity,
            padding: effectiveTheme.itemPadding,
            decoration: BoxDecoration(
              color: isSelected
                  ? effectiveTheme.selectedItemColor ??
                      Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: effectiveTheme.itemBorderRadius != null
                  ? BorderRadius.circular(effectiveTheme.itemBorderRadius!)
                  : null,
              border: (isLast && effectiveTheme.excludeLastItemBorder)
                  ? null
                  : effectiveTheme.itemBorder,
            ),
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
    final bool hasCustomWidths =
        scrollTheme.thumbWidth != null || scrollTheme.trackWidth != null;

    if (hasCustomWidths) {
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
    final double effectiveThumbWidth =
        scrollTheme.thumbWidth ?? scrollTheme.thickness ?? 8.0;
    final double effectiveTrackWidth =
        scrollTheme.trackWidth ?? scrollTheme.thickness ?? 8.0;

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
    final gradientHeight = scrollTheme.gradientHeight ?? 24.0;
    final List<Color> gradientColors;
    if (scrollTheme.gradientColors != null &&
        scrollTheme.gradientColors!.isNotEmpty) {
      gradientColors = scrollTheme.gradientColors!;
    } else {
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
