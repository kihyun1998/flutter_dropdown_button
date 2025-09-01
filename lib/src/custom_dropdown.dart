import 'package:flutter/material.dart';
import 'dropdown_item.dart';

class CustomDropdown<T> extends StatefulWidget {
  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.height = 200.0,
    this.itemHeight = 48.0,
    this.borderRadius = 8.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.decoration,
  });

  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final Widget? hint;
  final double height;
  final double itemHeight;
  final double borderRadius;
  final Duration animationDuration;
  final BoxDecoration? decoration;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _closeDropdown();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen) return;

    final renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = _createOverlayEntry(offset, size);
    Overlay.of(context).insert(_overlayEntry!);

    _isOpen = true;
    _animationController.forward();
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    });
  }

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
                width: size.width,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.topCenter,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: widget.height,
                            ),
                            decoration: widget.decoration ?? BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(widget.borderRadius),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.items.map((item) {
                                  final isSelected = widget.value == item.value;
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      widget.onChanged(item.value);
                                      item.onTap?.call();
                                      _closeDropdown();
                                    },
                                    child: Container(
                                      height: widget.itemHeight,
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                                            : Colors.transparent,
                                        borderRadius: widget.items.indexOf(item) == 0
                                            ? BorderRadius.only(
                                                topLeft: Radius.circular(widget.borderRadius),
                                                topRight: Radius.circular(widget.borderRadius),
                                              )
                                            : widget.items.indexOf(item) == widget.items.length - 1
                                                ? BorderRadius.only(
                                                    bottomLeft: Radius.circular(widget.borderRadius),
                                                    bottomRight: Radius.circular(widget.borderRadius),
                                                  )
                                                : null,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: item.child,
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

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items.where((item) => item.value == widget.value).firstOrNull;

    return GestureDetector(
      key: _buttonKey,
      onTap: _toggleDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: selectedItem?.child ?? widget.hint ?? const SizedBox.shrink(),
            ),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }
}