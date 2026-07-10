import 'package:flutter/material.dart';

import '../buttons/menu_alignment.dart';
import '../placement/dropdown_placement.dart';

/// Everything the overlay needs to know about the menu it is about to show.
///
/// Read afresh on every overlay build — the item count, the theme and the
/// search field's height all change while the menu is open — so a controller
/// takes a [DropdownOverlaySpecBuilder] rather than one of these directly.
class DropdownOverlaySpec {
  /// Describes one rendering of the menu.
  const DropdownOverlaySpec({
    required this.itemCount,
    required this.actualItemHeight,
    required this.maxDropdownHeight,
    this.chromeHeight = 0.0,
    this.borderThickness = 0.0,
    this.overlayPadding,
    this.screenMargin = 8.0,
    this.buttonGap = 4.0,
    this.minVisibleItems = 2,
    this.minMenuWidth,
    this.maxMenuWidth,
    this.menuAlignment = MenuAlignment.left,
    this.elevation = 8.0,
    this.borderRadius = 8.0,
    this.shadowColor,
  });

  /// How many items the menu holds.
  final int itemCount;

  /// The vertical space one item occupies, including its margin.
  final double actualItemHeight;

  /// The tallest the item list may grow.
  final double maxDropdownHeight;

  /// Vertical space taken by furniture that is not an item — a search field.
  final double chromeHeight;

  /// Total thickness of the overlay's top and bottom borders.
  final double borderThickness;

  /// Padding inside the overlay container.
  final EdgeInsets? overlayPadding;

  /// The gap kept between the menu and the edge of the safe area.
  final double screenMargin;

  /// The gap kept between the button and the menu.
  final double buttonGap;

  /// How many items stay visible when space runs out.
  final int minVisibleItems;

  /// The narrowest the menu may be, even if the button is narrower.
  final double? minMenuWidth;

  /// The widest the menu may be, even if the button is wider.
  final double? maxMenuWidth;

  /// How the menu lines up with the button when it is the wider of the two.
  final MenuAlignment menuAlignment;

  /// Shadow depth of the overlay material.
  final double elevation;

  /// Corner radius of the overlay.
  final double borderRadius;

  /// Shadow colour of the overlay material.
  final Color? shadowColor;

  /// Everything in the overlay that is not an item.
  double get totalChromeHeight =>
      chromeHeight +
      borderThickness +
      (overlayPadding == null
          ? 0.0
          : overlayPadding!.top + overlayPadding!.bottom);
}

/// Supplies a fresh [DropdownOverlaySpec] each time the overlay builds.
typedef DropdownOverlaySpecBuilder = DropdownOverlaySpec Function();

/// Drives a dropdown menu: its overlay's lifetime, its open/close animation,
/// the widget tree it is drawn into, and the rule that only one menu is open
/// at a time within an [Overlay].
///
/// Hold one; do not inherit from it. A widget's `State` owns a controller the
/// same way this package's own dropdown does, so third parties build on the
/// same module rather than on a copy of it.
///
/// ```dart
/// late final _menu = DropdownOverlayController(
///   vsync: this,
///   spec: () => DropdownOverlaySpec(itemCount: items.length, ...),
///   contentBuilder: (height) => ListView(...),
///   decorationBuilder: () => null,
///   onOpenStateChanged: (_) => setState(() {}),
/// );
/// ```
class DropdownOverlayController {
  /// Creates a controller. Call [dispose] from the owner's `dispose`.
  DropdownOverlayController({
    required TickerProvider vsync,
    required this.spec,
    required this.contentBuilder,
    required this.decorationBuilder,
    Duration animationDuration = const Duration(milliseconds: 200),
    this.onOpenStateChanged,
  }) : _animation = AnimationController(
         duration: animationDuration,
         vsync: vsync,
       );

  /// Attach this to the button so the controller can measure it.
  final GlobalKey buttonKey = GlobalKey();

  /// Describes the menu as it should be drawn right now.
  final DropdownOverlaySpecBuilder spec;

  /// Builds the menu's scrollable content, given the height available to it.
  final Widget Function(double height) contentBuilder;

  /// Decorates the overlay container. Return null for a themed default.
  final BoxDecoration? Function() decorationBuilder;

  /// Called after the menu opens or closes, so the owner can rebuild.
  final ValueChanged<bool>? onOpenStateChanged;

  final AnimationController _animation;
  OverlayEntry? _entry;
  BuildContext? _context;
  bool _disposed = false;

  /// The open menu in each [Overlay], so opening one closes its neighbour.
  ///
  /// Keyed by Overlay rather than held in a single static field: two menus in
  /// two different Overlays — a side panel and the root — do not contend.
  static final Map<OverlayState, DropdownOverlayController> _openPerOverlay =
      {};

  /// Whether the menu is showing.
  bool get isOpen => _entry != null;

  /// Runs forward as the menu opens and backward as it closes.
  ///
  /// Owners drive their own transitions from it — a trailing icon that rotates
  /// while the menu is open, say. The menu's own scale and fade are internal.
  AnimationController get animation => _animation;

  late final Animation<double> _scale = Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutBack));

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOut));

  /// Shows the menu, closing whichever menu is open in the same [Overlay].
  void open(BuildContext context) {
    if (isOpen) return;

    final overlay = Overlay.of(context);
    _openPerOverlay[overlay]?.close();

    _context = context;
    _entry = _buildEntry();
    overlay.insert(_entry!);
    _openPerOverlay[overlay] = this;

    _animation.forward();
    onOpenStateChanged?.call(true);
  }

  /// Hides the menu.
  ///
  /// With [animate] true the close animation plays first, so the trailing icon
  /// rotates back. Pass false to tear the overlay down at once — the owner may
  /// be disposed before an animation could finish.
  void close({bool animate = true}) {
    if (!isOpen) return;

    if (!animate) {
      _animation.reset();
      _teardown();
      return;
    }

    _animation.reverse().then((_) {
      // The owner may have been disposed while the animation ran.
      if (!_disposed && isOpen) _teardown();
    });
  }

  /// Opens the menu if closed, closes it if open.
  void toggle(BuildContext context) => isOpen ? close() : open(context);

  /// Rebuilds the menu in place, re-measuring it.
  ///
  /// The overlay is not a descendant of its owner, so it does not rebuild when
  /// the owner does. Call this after the items or the theme change. Not legal
  /// during a build — defer to a post-frame callback.
  void rebuild() => _entry?.markNeedsBuild();

  /// Releases the animation and removes the overlay without animating.
  void dispose() {
    _disposed = true;
    // Silent: the owner is being torn down and must not be asked to rebuild.
    if (isOpen) _teardown(notify: false);
    _animation.dispose();
  }

  /// Closes whichever menus are open, in every [Overlay].
  static void closeAll({bool animate = true}) {
    for (final controller in _openPerOverlay.values.toList()) {
      controller.close(animate: animate);
    }
  }

  void _teardown({bool notify = true}) {
    try {
      _entry?.remove();
    } catch (_) {
      // The overlay may already be gone — during a route transition, say.
    } finally {
      _entry = null;
      _openPerOverlay.removeWhere(
        (_, controller) => identical(controller, this),
      );
      if (notify) onOpenStateChanged?.call(false);
    }
  }

  /// Measures the button and resolves where the menu should sit.
  ///
  /// Called on every overlay build rather than once at open time, so a menu
  /// whose items change underneath it re-sizes and, if the taller menu no
  /// longer fits below the button, flips above it.
  DropdownPlacementResult? measurePlacement() {
    final context = _context;
    if (context == null || !context.mounted) return null;

    final button = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null || !button.attached || !button.hasSize) return null;

    // The menu is positioned inside the Overlay's Stack, so the button must be
    // measured against the same origin. Against the root view instead, the menu
    // would shift by the Overlay's own offset whenever it is not at (0, 0).
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final mediaQuery = MediaQuery.of(context);
    final current = spec();

    return DropdownPlacement.resolve(
      DropdownPlacementInput(
        screenSize: overlayBox?.size ?? mediaQuery.size,
        safeInsetTop: mediaQuery.padding.top,
        safeInsetBottom: mediaQuery.padding.bottom,
        buttonOffset: button.localToGlobal(Offset.zero, ancestor: overlayBox),
        buttonSize: button.size,
        itemCount: current.itemCount,
        actualItemHeight: current.actualItemHeight,
        maxDropdownHeight: current.maxDropdownHeight,
        chromeHeight: current.totalChromeHeight,
        screenMargin: current.screenMargin,
        buttonGap: current.buttonGap,
        minVisibleItems: current.minVisibleItems,
        minMenuWidth: current.minMenuWidth,
        maxMenuWidth: current.maxMenuWidth,
        menuAlignment: current.menuAlignment,
      ),
    );
  }

  OverlayEntry _buildEntry() {
    return OverlayEntry(
      builder: (context) {
        final position = measurePlacement();
        if (position == null) return const SizedBox.shrink();

        final current = spec();

        return GestureDetector(
          onTap: close,
          behavior: HitTestBehavior.translucent,
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  left: position.left,
                  top: position.top,
                  width: position.width,
                  child: AnimatedBuilder(
                    animation: _animation,
                    // Built once and reused across animation frames.
                    child: Material(
                      elevation: current.elevation,
                      shadowColor: current.shadowColor,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(current.borderRadius),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: position.height),
                        decoration:
                            decorationBuilder() ??
                            BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                current.borderRadius,
                              ),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                        child: contentBuilder(position.height),
                      ),
                    ),
                    builder:
                        (context, child) => Transform.scale(
                          scale: _scale.value,
                          alignment: position.transformAlignment,
                          child: Opacity(opacity: _opacity.value, child: child),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
