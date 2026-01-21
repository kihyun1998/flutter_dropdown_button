import 'package:flutter/material.dart';

/// 성능 최적화된 앱 드롭다운 컴포넌트
///
/// 주요 성능 최적화 내역:
/// 1. ListView.builder 사용 - lazy loading으로 대량 아이템 처리
/// 2. ValueNotifier로 gradient 상태 관리 - 전체 위젯 리빌드 방지
/// 3. 스마트 포지셔닝 - 화면 공간에 따라 자동으로 위/아래 결정
/// 4. AnimatedBuilder child 재사용 - 애니메이션 중 불필요한 리빌드 방지
/// 5. ClampingScrollPhysics 사용 - 바운스 효과 제거로 성능 개선
class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.enabled = true,
    this.itemLabelBuilder,
  });

  /// 드롭다운 아이템 목록
  final List<T> items;

  /// 현재 선택된 값
  final T? value;

  /// 힌트 텍스트
  final String? hint;

  /// 활성화 여부
  final bool enabled;

  /// 값 변경 콜백
  final ValueChanged<T?> onChanged;

  /// 아이템 라벨 빌더 (기본값: toString())
  final String Function(T item)? itemLabelBuilder;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5, // 180도 회전 (0.5 * 2 * pi)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  String _getLabel(T item) {
    if (widget.itemLabelBuilder != null) {
      return widget.itemLabelBuilder!(item);
    }
    return item.toString();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _animationController.reverse();
    _removeOverlay();
    setState(() {
      _isOpen = false;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    _closeDropdown();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    // 스마트 포지셔닝: 화면 공간 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - position.dy - size.height;
    final spaceAbove = position.dy;

    // 드롭다운 최대 높이
    const maxDropdownHeight = 224.0;

    // 아래쪽 또는 위쪽 공간 결정
    final openUpward = spaceBelow < maxDropdownHeight && spaceAbove > spaceBelow;
    final availableSpace = openUpward ? spaceAbove : spaceBelow;
    final dropdownHeight = availableSpace < maxDropdownHeight
        ? availableSpace - 8 // 여유 공간 8px
        : maxDropdownHeight;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: openUpward
                    ? Offset(0, -dropdownHeight - 4) // 위로 열기
                    : Offset(0, size.height + 4), // 아래로 열기
                child: Material(
                  color: Colors.transparent,
                  child: _buildDropdownMenu(size.width, dropdownHeight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMenu(double width, double height) {
    return _DropdownMenu<T>(
      width: width,
      height: height,
      items: widget.items,
      getLabel: _getLabel,
      onSelectItem: _selectItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;
    final displayText =
        hasValue ? _getLabel(widget.value as T) : (widget.hint ?? '');

    // AnimatedBuilder child 재사용 최적화
    final arrowIcon = const SVGIcon(
      icon: AppSVGAsset.dropdownArrow,
      size: 12,
      color: Palette.coolGray09,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _buttonKey,
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isOpen ? Palette.blue04 : Palette.coolGray04,
            ),
            boxShadow: _isOpen
                ? const [
                    BoxShadow(
                      color: Palette.shadow5,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: hasValue ? AppFont.body1 : AppFont.body1Sub,
                ),
              ),
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: child,
                  );
                },
                child: arrowIcon, // child 재사용
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 성능 최적화된 드롭다운 메뉴 (ListView.builder + ValueNotifier)
class _DropdownMenu<T> extends StatefulWidget {
  const _DropdownMenu({
    required this.width,
    required this.height,
    required this.items,
    required this.getLabel,
    required this.onSelectItem,
  });

  final double width;
  final double height;
  final List<T> items;
  final String Function(T item) getLabel;
  final void Function(T item) onSelectItem;

  @override
  State<_DropdownMenu<T>> createState() => _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  final ScrollController _scrollController = ScrollController();

  // ValueNotifier로 gradient 상태 관리 (setState 대신)
  final ValueNotifier<bool> _showTopGradient = ValueNotifier(false);
  final ValueNotifier<bool> _showBottomGradient = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // addPostFrameCallback는 한 번만 실행됨 (메모리 누수 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollExtent();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showTopGradient.dispose();
    _showBottomGradient.dispose();
    super.dispose();
  }

  void _onScroll() {
    _checkScrollExtent();
  }

  void _checkScrollExtent() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final atTop = position.pixels <= 0;
    final atBottom = position.pixels >= position.maxScrollExtent;
    final canScroll = position.maxScrollExtent > 0;

    // ValueNotifier 업데이트 (전체 위젯 리빌드 방지)
    _showTopGradient.value = !atTop && canScroll;
    _showBottomGradient.value = !atBottom && canScroll;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.width,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.blue04),
        boxShadow: const [
          BoxShadow(
            color: Palette.shadow5,
            offset: Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // ListView.builder로 lazy loading (대량 아이템 처리 최적화)
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              physics: const ClampingScrollPhysics(), // 바운스 효과 제거
              shrinkWrap: true,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isLast = index == widget.items.length - 1;
                return _buildMenuItem(item, isLast);
              },
            ),
            // ValueListenableBuilder로 gradient만 독립적으로 리빌드
            ValueListenableBuilder<bool>(
              valueListenable: _showTopGradient,
              builder: (context, showTop, child) {
                if (!showTop) return const SizedBox.shrink();
                return Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _showBottomGradient,
              builder: (context, showBottom, child) {
                if (!showBottom) return const SizedBox.shrink();
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(T item, bool isLast) {
    return GestureDetector(
      onTap: () => widget.onSelectItem(item),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 8,
          bottom: isLast ? 4 : 8,
        ),
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Palette.shadow10,
                  ),
                ),
              ),
        child: Text(
          widget.getLabel(item),
          style: AppFont.body1Content,
        ),
      ),
    );
  }
}
