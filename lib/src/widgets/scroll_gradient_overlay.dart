import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Fades the content under a scroll view's edges, hinting at what is hidden
/// past them.
///
/// Owns the scroll listener and the two flags it drives. The dropdown that
/// hosts one hands it a [controller] and forgets about scroll position — the
/// notifiers and the listener used to live on the widget's `State`, which cared
/// about neither.
///
/// A fade is opaque **at** the edge it guards, washing the content out into
/// [fadeInto], and clears as it moves away. Supply [colors] to override that:
/// the first colour sits at the edge, the last towards the content.
class ScrollGradientOverlay extends StatefulWidget {
  /// Creates the overlay.
  const ScrollGradientOverlay({
    super.key,
    required this.controller,
    required this.fadeInto,
    required this.height,
    required this.borderRadius,
    required this.child,
    this.colors,
  });

  /// The scroll view being faded. Not owned; the caller disposes it.
  final ScrollController controller;

  /// The colour the content dissolves into — the menu's own background.
  final Color fadeInto;

  /// How tall each fade is.
  final double height;

  /// Clips the fades to the menu's corners.
  final double borderRadius;

  /// The scroll view.
  final Widget child;

  /// Overrides the fade's colours. Edge first, content last.
  final List<Color>? colors;

  /// How long a fade takes to appear or disappear.
  ///
  /// Shared by both edges: they are one effect, and a reader should not have to
  /// check that two numbers still agree.
  static const Duration fadeDuration = Duration(milliseconds: 150);

  @override
  State<ScrollGradientOverlay> createState() => _ScrollGradientOverlayState();
}

class _ScrollGradientOverlayState extends State<ScrollGradientOverlay> {
  final ValueNotifier<bool> _canScrollUp = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollDown = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    // A scroll view has no position until it has laid out once.
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(ScrollGradientOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
    // The list may have grown or shrunk under us.
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _canScrollUp.dispose();
    _canScrollDown.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    _canScrollUp.value = position.pixels > 0;
    _canScrollDown.value = position.pixels < position.maxScrollExtent;
  }

  /// Edge first, content last.
  List<Color> get _edgeToContent {
    final override = widget.colors;
    if (override != null && override.isNotEmpty) return override;
    return [widget.fadeInto, widget.fadeInto.withValues(alpha: 0.0)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _edgeToContent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _fade(_canScrollUp, colors),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _fade(_canScrollDown, colors.reversed.toList()),
          ),
        ],
      ),
    );
  }

  /// One fade, shown while [visible] is true. [colors] run top to bottom.
  Widget _fade(ValueListenable<bool> visible, List<Color> colors) {
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder:
          (context, show, _) => IgnorePointer(
            child: AnimatedOpacity(
              opacity: show ? 1.0 : 0.0,
              duration: ScrollGradientOverlay.fadeDuration,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: colors,
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
