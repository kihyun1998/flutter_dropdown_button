import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    this.emptyStateHeight = 0.0,
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

  /// Vertical room reserved for an empty state when [itemCount] is zero.
  ///
  /// Zero — the default — keeps a spec written before this field existed
  /// meaning what it meant: an empty menu holds chrome only.
  final double emptyStateHeight;

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
      chromeHeight + borderThickness + (overlayPadding?.vertical ?? 0.0);
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
       ) {
    _instances.add(this);
  }

  /// Attach this to the button so the controller can measure it.
  final GlobalKey buttonKey = GlobalKey();

  /// Whether this controller's anchor currently accepts a tap.
  ///
  /// Set from the owning widget's `build`, the same way [positioningKey] is,
  /// and read only while *another* menu's dismiss barrier decides whether to
  /// stand down over this trigger (see [_RenderSiblingTriggerVeto]).
  ///
  /// It has to be published rather than inferred. A disabled anchor still takes
  /// part in hit-testing — `InkWell` sets `HitTestBehavior.opaque`
  /// unconditionally (`material/ink_well.dart:1418`), and the bare path does the
  /// same — so the barrier cannot tell an enabled trigger from a disabled one by
  /// looking. Standing down over a disabled one would leave the tap claimed by
  /// nobody and the open menu up, where today it dismisses.
  bool triggerEnabled = true;

  /// An outer box to position the menu against, instead of [buttonKey].
  ///
  /// Null — the default — measures the anchor itself: the menu drops below it,
  /// left-aligns to it, and defaults to its width. Set to a [GlobalKey] on some
  /// enclosing box and the menu measures *that* box instead — it drops below,
  /// left-aligns to, and defaults to the width of the enclosing box, while the
  /// anchor keeps drawing and toggling where it is. The reference for a compact
  /// dropdown embedded at the head of a wider field.
  ///
  /// The box is measured on every overlay build, not tracked per frame: a box
  /// that moves *while the menu is open* is not followed, the same as the anchor.
  /// It must live in the same [Overlay] coordinate space the anchor does.
  ///
  /// Mutable: the owning widget reassigns it as its own parameter changes.
  GlobalKey? positioningKey;

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

  /// Whether a close is in flight.
  ///
  /// [isOpen] cannot answer this — it is `_entry != null`, and the entry lives
  /// for the whole close animation. Kept separate so [open] can tell a menu
  /// that is open from one that is on its way out.
  bool _closing = false;

  /// Settles a close whose animation never ticks. See [close].
  Timer? _closeFallback;

  /// The open menu in each [Overlay], so opening one closes its neighbour.
  ///
  /// Keyed by Overlay rather than held in a single static field: two menus in
  /// two different Overlays — a side panel and the root — do not contend.
  static final Map<OverlayState, DropdownOverlayController> _openPerOverlay =
      {};

  /// Every live controller, so an open menu's barrier can recognise a *sibling*
  /// trigger and let the tap through to it.
  ///
  /// [_openPerOverlay] cannot answer this — it holds only the controller that is
  /// currently open, and the trigger we need to recognise belongs to one that is
  /// closed. Registration is therefore by lifetime, not by open state: added
  /// here on construction and removed in [dispose].
  ///
  /// Unlike [_openPerOverlay], which `_teardown` prunes on every close, nothing
  /// prunes this on its own — a controller a third party constructs and never
  /// disposes stays reachable for the process. Reads filter for a mounted,
  /// attached anchor, so a leaked entry costs memory rather than behaviour: the
  /// same bargain as an `AnimationController` nobody disposed.
  static final Set<DropdownOverlayController> _instances =
      <DropdownOverlayController>{};

  /// Shared between the barrier's recognizer and the render object that decides
  /// for it. Lives on the controller because the entry is rebuilt on every
  /// animation frame while the recognizer must outlast that.
  final _BarrierVeto _veto = _BarrierVeto();

  /// The render objects a barrier owned by [self] should stand down for.
  ///
  /// Its *own* trigger is excluded: tapping the trigger of an open menu already
  /// dismisses through the barrier, and routing it to the anchor's own toggle
  /// instead would trade a measured behaviour for an identical one at the price
  /// of a new same-tap-reopen window.
  static Set<RenderObject> _siblingTriggersFor(DropdownOverlayController self) {
    final targets = <RenderObject>{};
    for (final controller in _instances) {
      if (identical(controller, self) || !controller.triggerEnabled) continue;
      final anchor = controller.buttonKey.currentContext?.findRenderObject();
      if (anchor != null && anchor.attached) targets.add(anchor);
    }
    return targets;
  }

  /// Whether the menu is showing.
  ///
  /// True for the whole close animation as well — the entry is still mounted
  /// and still painting. [open] accounts for that itself, so a call that lands
  /// mid-close reopens rather than being dropped; a caller reading this to
  /// decide whether to open does not have to.
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
  ///
  /// Called while this menu is closing, it takes the close back and the menu
  /// stays up — so `closeAll()` immediately followed by `open()` shows the
  /// menu rather than silently doing nothing.
  void open(BuildContext context) {
    if (isOpen) {
      // A close in flight still counts as open, so without this the call is
      // dropped and the menu the caller just asked for finishes closing
      // instead. `closeAll()` immediately followed by `open()` — the obvious
      // "close everything, then show mine" — is exactly that sequence.
      if (!_closing) return;
      _cancelClose();
      _context = context;
      _animation.forward();
      rebuild();
      return;
    }

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
  ///
  /// The menu goes away either way. The animation is decoration, not the
  /// mechanism: an owner whose `TickerMode` is disabled — anything under a
  /// route that has been pushed over — would otherwise keep the entry mounted
  /// forever, over the new page, swallowing every tap.
  void close({bool animate = true}) {
    if (!isOpen) return;

    if (!animate) {
      _animation.reset();
      _teardown();
      return;
    }

    _closing = true;
    _animation.reverse().then((_) {
      // The owner may have been disposed while the animation ran.
      if (!_disposed && _closing) _teardown();
    });

    // The reverse only advances while the owner's `TickerMode` is enabled, and
    // a route pushed over an open menu mutes it. Without this the entry stayed
    // mounted *above the new page*, swallowing every tap, until the user
    // navigated back — measured `page2Taps=0` three taps running (#106).
    //
    // Asking the tree whether the ticker runs is not open to us: `TickerMode.of`
    // is deprecated after 3.35, and this repo's analyze gate exits 1 on a single
    // info, while `TickerMode.valuesOf` does not exist at our 3.32 floor. Both
    // CI jobs close that door from opposite sides. A timer is not ticker-gated,
    // so it settles the teardown either way; whichever arrives first wins and
    // `_cancelClose` makes the loser a no-op.
    _closeFallback?.cancel();
    _closeFallback = Timer(_animation.duration ?? Duration.zero, () {
      if (!_disposed && _closing) {
        _animation.reset();
        _teardown();
      }
    });
  }

  void _cancelClose() {
    _closing = false;
    _closeFallback?.cancel();
    _closeFallback = null;
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
    _cancelClose();
    _instances.remove(this);
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
    _cancelClose();
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

    // The menu positions against [positioningKey]'s box when one is given, else
    // the anchor's own. Only which RenderBox is read changes; the offset and
    // size it yields feed the same pure placement resolve() unchanged.
    final measureKey = positioningKey ?? buttonKey;
    final button = measureKey.currentContext?.findRenderObject() as RenderBox?;
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
        emptyStateHeight: current.emptyStateHeight,
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

        return RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: <Type, GestureRecognizerFactory>{
            _VetoableTapRecognizer:
                GestureRecognizerFactoryWithHandlers<_VetoableTapRecognizer>(
                  () => _VetoableTapRecognizer(_veto),
                  (instance) => instance.onTap = close,
                ),
          },
          // The barrier is a gesture, not a control. Left annotating the tree,
          // it put a screen-sized node carrying `tap`, with no label and no
          // role, *above* the whole menu — so the rows were its children and a
          // non-interactive empty state merged into it, naming the screen after
          // itself. Measured: `#5 800x600 label="No results found"
          // acts=[tap]` on an 800×600 view.
          //
          // `excludeFromSemantics`, not `ExcludeSemantics`: the latter prunes
          // the subtree and would take the menu with it. This drops only the
          // detector's own annotation, and nothing else about the barrier —
          // hit-testing is untouched.
          //
          // Nothing is lost. The trigger stays in the tree while its menu is
          // open and still carries `tap`, so assistive technology dismisses by
          // activating the control that opened it, which is where a user would
          // look anyway. Pinned in `dismiss_barrier_semantics_test.dart`.
          excludeFromSemantics: true,
          child: _SiblingTriggerVeto(
            veto: _veto,
            triggers: () => _siblingTriggersFor(this),
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
                        borderRadius: BorderRadius.circular(
                          current.borderRadius,
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: position.height,
                          ),
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
                      builder: (context, child) => Transform.scale(
                        scale: _scale.value,
                        alignment: position.transformAlignment,
                        child: Opacity(opacity: _opacity.value, child: child),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Carries "do not claim this pointer" from the render object that decides it
/// to the recognizer that acts on it.
///
/// Keyed by pointer id rather than held as one flag: two fingers landing in the
/// same frame each get their own answer, and a flag set by one would otherwise
/// be spent by the other.
class _BarrierVeto {
  final Set<int> _pointers = <int>{};

  void raise(int pointer) => _pointers.add(pointer);

  /// True once, for the pointer it was raised for.
  bool take(int pointer) => _pointers.remove(pointer);
}

/// The barrier's tap recognizer, which can decline to compete for a pointer.
///
/// Declining is not the same as losing. A recognizer that joins the arena and
/// then rejects itself still denies the tap to everyone below it for the frames
/// it was a member; one that never calls `super.addAllowedPointer` was never
/// there, so the anchor underneath wins on its own merits.
class _VetoableTapRecognizer extends TapGestureRecognizer {
  _VetoableTapRecognizer(this._veto);

  final _BarrierVeto _veto;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (_veto.take(event.pointer)) return;
    super.addAllowedPointer(event);
  }
}

/// Decides, for each pointer, whether the barrier above it should stand down.
///
/// The decision cannot be made in [hitTest]. The barrier is hit-tested first —
/// measured at index 0 of a 41-entry path, with the sibling trigger's own render
/// objects arriving at index 10 — so at that moment the answer does not exist
/// yet. Reconstructing it from geometry instead is what an earlier design tried,
/// and it is not reconstructable: a trigger's rect is honest and unchanged while
/// an `IgnorePointer`, an `Offstage`, an ancestor `ClipRect`, a `Transform` or a
/// modal route makes it unreachable. Measured worst case: a dropdown behind a
/// dialog reports a rect byte-identical to its uncovered one, so a barrier that
/// stood down there would send the tap to the dialog's own barrier and dismiss
/// the dialog.
///
/// So it is made in [handleEvent], which runs at dispatch, when the path is
/// complete — and it runs *before* the recognizer above sees the pointer,
/// because a child is added to the hit path ahead of its parent. The shape is
/// Flutter's own: `RenderTapRegionSurface` caches the live result against its
/// entry and tests membership of `result.path` rather than comparing rectangles
/// (`widgets/tap_region.dart`).
///
/// Membership also settles a case geometry would have needed a guard for: when
/// the menu absorbs the hit, `RenderTheatre` stops before the entries below
/// (`widgets/overlay.dart` — `while (!isHit …)`), so no trigger can be in the
/// path and no veto can be raised over the menu's own area.
class _SiblingTriggerVeto extends SingleChildRenderObjectWidget {
  const _SiblingTriggerVeto({
    required this.veto,
    required this.triggers,
    required Widget super.child,
  });

  final _BarrierVeto veto;
  final ValueGetter<Set<RenderObject>> triggers;

  @override
  _RenderSiblingTriggerVeto createRenderObject(BuildContext context) =>
      _RenderSiblingTriggerVeto(veto, triggers);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSiblingTriggerVeto renderObject,
  ) {
    renderObject
      ..veto = veto
      ..triggers = triggers;
  }
}

class _RenderSiblingTriggerVeto extends RenderProxyBoxWithHitTestBehavior {
  _RenderSiblingTriggerVeto(this.veto, this.triggers)
    : super(behavior: HitTestBehavior.translucent);

  _BarrierVeto veto;
  ValueGetter<Set<RenderObject>> triggers;

  /// The result each entry of ours was appended to, so [handleEvent] can read
  /// the finished path. An `Expando` rather than a field: several pointers may
  /// be in flight, each with its own result.
  final Expando<BoxHitTestResult> _results = Expando<BoxHitTestResult>();

  // Mirrors RenderProxyBoxWithHitTestBehavior.hitTest, keeping a reference to
  // the result the entry goes into. Behaviour is otherwise identical, and the
  // barrier stays translucent — what is behind an open menu still receives the
  // pointer, exactly as before.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    var hitTarget = false;
    if (size.contains(position)) {
      hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget || behavior == HitTestBehavior.translucent) {
        final entry = BoxHitTestEntry(this, position);
        _results[entry] = result;
        result.add(entry);
      }
    }
    return hitTarget;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    // Only the primary button. A secondary-button press over a sibling trigger
    // opens nothing and dismisses nothing today, and this keeps that: the veto
    // would have suppressed the dismissal without anything replacing it.
    // Deliberately not filtered by `PointerDeviceKind` — a veto scoped to touch
    // passes every widget test, which defaults to touch, while doing nothing on
    // desktop and web.
    if (event is! PointerDownEvent || event.buttons != kPrimaryButton) return;

    final targets = triggers();
    if (targets.isEmpty) return;

    // `?? const []` rather than an early return: the entry is alive for the
    // whole dispatch, so a missing result is unreachable, and a branch nothing
    // can reach is a line the 100% coverage floor could never cover.
    final path = _results[entry]?.path ?? const <HitTestEntry>[];
    for (final hit in path) {
      if (targets.contains(hit.target)) {
        veto.raise(event.pointer);
        return;
      }
    }
  }
}
