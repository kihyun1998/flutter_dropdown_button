import 'package:flutter/material.dart';
import 'dropdown_theme.dart';
import 'text_dropdown_config.dart';

/// A dropdown widget specifically designed for text-only content.
///
/// This widget provides precise control over text rendering, overflow behavior,
/// and typography while maintaining the visual consistency defined by [DropdownTheme].
/// Unlike [CustomDropdown], this widget only accepts string values, allowing
/// for better text-specific optimizations and controls.
///
/// Features:
/// - Text overflow control (ellipsis, fade, clip, visible)
/// - Multi-line text support
/// - Custom text styling and alignment
/// - Shared theme with other dropdown variants
/// - Smooth animations and outside-tap dismissal
///
/// Example:
/// ```dart
/// TextOnlyDropdown(
///   items: ['Apple', 'Banana', 'Very Long Orange Name That Might Overflow'],
///   value: selectedValue,
///   hint: 'Select a fruit',
///   theme: DropdownTheme(borderRadius: 12.0),
///   config: TextDropdownConfig(
///     overflow: TextOverflow.ellipsis,
///     maxLines: 1,
///     textStyle: TextStyle(fontSize: 16),
///   ),
///   onChanged: (value) => setState(() => selectedValue = value),
/// )
/// ```
class TextOnlyDropdown extends StatefulWidget {
  /// Creates a text-only dropdown widget.
  ///
  /// The [items] and [onChanged] parameters are required.
  const TextOnlyDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.theme,
    this.config,
    this.width,
    this.maxWidth,
    this.minWidth,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.enabled = true,
  });

  /// The list of text options to display in the dropdown.
  ///
  /// Each string represents both the display text and the value.
  /// Empty strings are allowed but may not be visually clear to users.
  final List<String> items;

  /// Called when the user selects an item from the dropdown.
  ///
  /// The callback receives the selected string value, or null if
  /// no item is selected.
  final ValueChanged<String?> onChanged;

  /// The currently selected value.
  ///
  /// Must be one of the strings in [items] or null.
  /// If the value is not in [items], no item will be highlighted.
  final String? value;

  /// The text to display when no item is selected.
  ///
  /// If null, the dropdown will show empty space when no item is selected.
  final String? hint;

  /// The visual theme shared across all dropdown variants.
  ///
  /// Controls animations, colors, borders, and other visual aspects.
  /// If null, uses [DropdownTheme.defaultTheme].
  final DropdownTheme? theme;

  /// Configuration specific to text rendering and behavior.
  ///
  /// Controls text overflow, styling, alignment, and other text-specific
  /// properties. If null, uses [TextDropdownConfig.defaultConfig].
  final TextDropdownConfig? config;

  /// The fixed width of the dropdown button and overlay.
  ///
  /// If null, the dropdown will size itself based on content
  /// within the constraints of [minWidth] and [maxWidth].
  final double? width;

  /// The maximum width of the dropdown button and overlay.
  ///
  /// Only applied when [width] is null. Prevents the dropdown
  /// from becoming too wide with long text content.
  final double? maxWidth;

  /// The minimum width of the dropdown button and overlay.
  ///
  /// Only applied when [width] is null. Ensures consistent
  /// minimum size regardless of content length.
  final double? minWidth;

  /// The maximum height of the dropdown overlay.
  ///
  /// If the content exceeds this height, the dropdown becomes scrollable.
  final double height;

  /// The height of each individual dropdown item.
  ///
  /// Should be large enough to accommodate the text with the
  /// specified padding and font size.
  final double itemHeight;

  /// Whether the dropdown is enabled for user interaction.
  ///
  /// When false, the dropdown appears dimmed and does not respond
  /// to taps or other user input.
  final bool enabled;

  @override
  State<TextOnlyDropdown> createState() => _TextOnlyDropdownState();
}

/// The state class for [TextOnlyDropdown].
///
/// Manages the dropdown's open/closed state, animations, and overlay positioning.
class _TextOnlyDropdownState extends State<TextOnlyDropdown>
    with SingleTickerProviderStateMixin {
  /// Global key to access the dropdown button's render object for positioning.
  final GlobalKey _buttonKey = GlobalKey();

  /// The overlay entry that contains the dropdown options when open.
  OverlayEntry? _overlayEntry;

  /// Whether the dropdown is currently open.
  bool _isOpen = false;

  /// Controls the dropdown show/hide animations.
  late AnimationController _animationController;

  /// Animation for the dropdown scale effect.
  late Animation<double> _scaleAnimation;

  /// Animation for the dropdown opacity.
  late Animation<double> _opacityAnimation;

  /// The effective theme, using provided theme or default.
  DropdownTheme get _theme => widget.theme ?? DropdownTheme.defaultTheme;

  /// The effective config, using provided config or default.
  TextDropdownConfig get _config =>
      widget.config ?? TextDropdownConfig.defaultConfig;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: _theme.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    _animationController.dispose();
    super.dispose();
  }

  /// Toggles the dropdown between open and closed states.
  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  /// Opens the dropdown by creating and inserting an overlay entry.
  void _openDropdown() {
    if (_isOpen || !widget.enabled) return;

    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(offset, size);
    Overlay.of(context).insert(_overlayEntry!);

    _isOpen = true;
    _animationController.forward();
  }

  /// Closes the dropdown by reversing the animation and removing the overlay.
  void _closeDropdown() {
    if (!_isOpen) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    });
  }

  /// Creates the overlay entry containing the dropdown options.
  OverlayEntry _createOverlayEntry(Offset offset, Size size) {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 4,
                width: widget.width ?? size.width,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Material(
                          elevation: _theme.elevation,
                          shadowColor: _theme.shadowColor,
                          borderRadius: BorderRadius.circular(
                            _theme.borderRadius,
                          ),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: widget.height,
                              minWidth: widget.minWidth ?? 0,
                              maxWidth: widget.maxWidth ?? double.infinity,
                            ),
                            decoration:
                                _theme.overlayDecoration ??
                                BoxDecoration(
                                  color:
                                      _theme.backgroundColor ??
                                      Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    _theme.borderRadius,
                                  ),
                                  border:
                                      _theme.border ??
                                      Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 1,
                                      ),
                                ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.items.map((item) {
                                  final isSelected = widget.value == item;
                                  final itemIndex = widget.items.indexOf(item);
                                  final isFirst = itemIndex == 0;
                                  final isLast =
                                      itemIndex == widget.items.length - 1;

                                  return GestureDetector(
                                    onTap: () {
                                      widget.onChanged(item);
                                      _closeDropdown();
                                    },
                                    child: Container(
                                      height: widget.itemHeight,
                                      width: double.infinity,
                                      padding: _theme.itemPadding,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _theme.selectedItemColor ??
                                                  Theme.of(context).primaryColor
                                                      .withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: isFirst
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  _theme.borderRadius,
                                                ),
                                                topRight: Radius.circular(
                                                  _theme.borderRadius,
                                                ),
                                              )
                                            : isLast
                                            ? BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                  _theme.borderRadius,
                                                ),
                                                bottomRight: Radius.circular(
                                                  _theme.borderRadius,
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          item,
                                          style: isSelected
                                              ? _config.selectedTextStyle ??
                                                    _config.textStyle
                                              : _config.textStyle,
                                          textAlign: _config.textAlign,
                                          maxLines: _config.maxLines,
                                          overflow: _config.overflow,
                                          softWrap: _config.softWrap,
                                          textDirection: _config.textDirection,
                                          locale: _config.locale,
                                          textScaleFactor:
                                              _config.textScaleFactor,
                                          semanticsLabel:
                                              _config.semanticsLabel,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
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
        ),
      ),
    );
  }

  /// Builds the dropdown button widget.
  Widget _buildDropdownButton() {
    final selectedText = widget.value;
    final displayText = selectedText ?? widget.hint ?? '';
    final isHint = selectedText == null;

    return GestureDetector(
      key: _buttonKey,
      onTap: _toggleDropdown,
      child: Container(
        width: widget.width,
        padding: _theme.buttonPadding,
        decoration:
            _theme.buttonDecoration ??
            BoxDecoration(
              border:
                  _theme.border ??
                  Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(_theme.borderRadius),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: widget.width != null
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                displayText,
                style: isHint ? _config.hintStyle : _config.textStyle,
                textAlign: _config.textAlign,
                maxLines: _config.maxLines,
                overflow: _config.overflow,
                softWrap: _config.softWrap,
                textDirection: _config.textDirection,
                locale: _config.locale,
                textScaleFactor: _config.textScaleFactor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: widget.enabled
                  ? Theme.of(context).iconTheme.color
                  : Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget dropdownButton = _buildDropdownButton();

    // Apply opacity for disabled state
    if (!widget.enabled) {
      dropdownButton = Opacity(opacity: 0.6, child: dropdownButton);
    }

    // Apply width constraints if specified
    if (widget.width == null &&
        (widget.minWidth != null || widget.maxWidth != null)) {
      dropdownButton = ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? 0,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: dropdownButton,
      );
    }

    return dropdownButton;
  }
}
