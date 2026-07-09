import 'package:flutter/material.dart';

import '../overlay/dropdown_overlay_controller.dart';
import '../placement/dropdown_placement.dart';
import 'menu_alignment.dart';

/// Position calculation result for dropdown overlay positioning.
class DropdownPositionResult {
  /// Creates a position result with calculated values.
  const DropdownPositionResult({
    required this.height,
    required this.openDown,
    required this.transformAlignment,
    required this.topPosition,
  });

  /// The calculated height for the dropdown overlay.
  final double height;

  /// Whether the dropdown should open downward (true) or upward (false).
  final bool openDown;

  /// The transform alignment for animations.
  final Alignment transformAlignment;

  /// The calculated top position for the overlay.
  final double topPosition;
}

/// A mixin that provides dropdown positioning, animation and overlay
/// management to a [State].
///
/// **Deprecated.** Hold a [DropdownOverlayController] instead of inheriting
/// from this. The controller does the same work behind four members rather
/// than twenty-three, can be tested without a [State], and is what this
/// package's own dropdown uses.
///
/// ```dart
/// // Before
/// class _MyDropdownState extends State<MyDropdown>
///     with SingleTickerProviderStateMixin, DropdownMixin<MyDropdown> {
///   @override
///   Widget buildOverlayContent(double height) => ListView(...);
///   @override
///   int get itemCount => widget.items.length;
///   // ...twenty more members
/// }
///
/// // After
/// class _MyDropdownState extends State<MyDropdown>
///     with SingleTickerProviderStateMixin {
///   late final _menu = DropdownOverlayController(
///     vsync: this,
///     spec: () => DropdownOverlaySpec(
///       itemCount: widget.items.length,
///       actualItemHeight: 48,
///       maxDropdownHeight: 200,
///     ),
///     contentBuilder: (height) => ListView(...),
///     decorationBuilder: () => null,
///     onOpenStateChanged: (_) => setState(() {}),
///   );
/// }
/// ```
///
/// This mixin now delegates to a controller, so a dropdown built on it and one
/// built on the controller share the same "only one menu open" rule and both
/// respond to [closeAll]. It will be removed in 3.0.0.
@Deprecated(
  'Hold a DropdownOverlayController instead of mixing this in. '
  'This mixin will be removed in 3.0.0.',
)
mixin DropdownMixin<T extends StatefulWidget> on State<T>, TickerProvider {
  DropdownOverlayController? _controller;

  DropdownOverlayController get _menu {
    final controller = _controller;
    assert(controller != null, 'Call initializeDropdown() from initState().');
    return controller!;
  }

  /// Global key to access the dropdown button's render object for positioning.
  GlobalKey get dropdownButtonKey => _menu.buttonKey;

  /// Whether the dropdown is currently open.
  bool get isDropdownOpen => _controller?.isOpen ?? false;

  /// Controls the dropdown show/hide animations.
  AnimationController get dropdownAnimationController => _menu.animation;

  /// Animation for the dropdown scale effect (grows from 0.8 to 1.0).
  Animation<double> get dropdownScaleAnimation => _scale;

  /// Animation for the dropdown opacity (fades from 0.0 to 1.0).
  Animation<double> get dropdownOpacityAnimation => _opacity;

  /// Animation for the dropdown icon rotation (rotates 180 degrees).
  Animation<double> get dropdownIconRotationAnimation => _iconRotation;

  late final Animation<double> _scale = Tween<double>(begin: 0.8, end: 1.0)
      .animate(
          CurvedAnimation(parent: _menu.animation, curve: Curves.easeOutBack));

  late final Animation<double> _opacity = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _menu.animation, curve: Curves.easeOut));

  late final Animation<double> _iconRotation =
      Tween<double>(begin: 0.0, end: 0.5).animate(
          CurvedAnimation(parent: _menu.animation, curve: Curves.easeInOut));

  // Abstract members the using class supplies. All of these collapse into a
  // single DropdownOverlaySpec when you move to the controller.

  /// The duration of the dropdown animations.
  Duration get animationDuration;

  /// The height of each individual dropdown item.
  double get itemHeight;

  /// The total vertical space each item occupies, including margins.
  double get actualItemHeight;

  /// The maximum height of the dropdown overlay.
  double get maxDropdownHeight;

  /// The number of items in the dropdown.
  int get itemCount;

  /// Whether the dropdown is enabled for interaction.
  bool get isEnabled => true;

  /// Additional margin from screen edges for safety.
  double get screenMargin => 8.0;

  /// Gap between button and dropdown overlay.
  double get buttonGap => 4.0;

  /// Minimum number of visible items when space is constrained.
  int get minVisibleItems => 2;

  /// The elevation of the dropdown overlay Material.
  double get overlayElevation => 8.0;

  /// The border radius for the dropdown overlay.
  double get overlayBorderRadius => 8.0;

  /// The total vertical border thickness (top + bottom) of the overlay.
  double get overlayBorderThickness => 0.0;

  /// The shadow color for the dropdown overlay Material.
  Color? get overlayShadowColor => null;

  /// The padding applied to the dropdown overlay container.
  EdgeInsets? get overlayPadding => null;

  /// Vertical space inside the overlay taken by furniture that is not an item.
  double get chromeHeight => 0.0;

  /// The minimum width of the dropdown menu overlay.
  double? get minMenuWidth => null;

  /// The maximum width of the dropdown menu overlay.
  double? get maxMenuWidth => null;

  /// The alignment of the menu relative to the button when wider.
  MenuAlignment get menuAlignment => MenuAlignment.left;

  /// Builds the content of the dropdown overlay with the given height.
  Widget buildOverlayContent(double height);

  /// Builds the decoration for the dropdown overlay container.
  BoxDecoration? buildOverlayDecoration();

  /// Called when an item is selected from the dropdown.
  void onDropdownItemSelected();

  DropdownOverlaySpec _buildSpec() => DropdownOverlaySpec(
        itemCount: itemCount,
        actualItemHeight: actualItemHeight,
        maxDropdownHeight: maxDropdownHeight,
        chromeHeight: chromeHeight,
        borderThickness: overlayBorderThickness,
        overlayPadding: overlayPadding,
        screenMargin: screenMargin,
        buttonGap: buttonGap,
        minVisibleItems: minVisibleItems,
        minMenuWidth: minMenuWidth,
        maxMenuWidth: maxMenuWidth,
        menuAlignment: menuAlignment,
        elevation: overlayElevation,
        borderRadius: overlayBorderRadius,
        shadowColor: overlayShadowColor,
      );

  /// Initializes the dropdown. Call from [initState].
  void initializeDropdown() {
    _controller = DropdownOverlayController(
      vsync: this,
      animationDuration: animationDuration,
      spec: _buildSpec,
      contentBuilder: buildOverlayContent,
      decorationBuilder: buildOverlayDecoration,
      onOpenStateChanged: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  /// Disposes of the dropdown resources. Call from [dispose].
  void disposeDropdown() => _controller?.dispose();

  /// Closes whichever dropdown menus are open.
  ///
  /// Menus built on this mixin and menus built directly on
  /// [DropdownOverlayController] share one registry, so this closes both.
  static void closeAll({bool animate = true}) =>
      DropdownOverlayController.closeAll(animate: animate);

  /// Marks the overlay entry as needing rebuild.
  void rebuildOverlay() => _controller?.rebuild();

  /// Toggles the dropdown between open and closed states.
  void toggleDropdown() {
    if (!isEnabled) return;
    _menu.toggle(context);
  }

  /// Opens the dropdown.
  void openDropdown() {
    if (!isEnabled) return;
    _menu.open(context);
  }

  /// Closes the dropdown.
  void closeDropdown() => _controller?.close();

  /// Measures the button and resolves where the menu should sit.
  DropdownPlacementResult? measurePlacement() =>
      _controller?.measurePlacement();

  /// The render box of the [Overlay] the menu is inserted into.
  RenderBox? get overlayRenderBox =>
      Overlay.of(context).context.findRenderObject() as RenderBox?;

  DropdownPlacementResult _resolve(
    Offset buttonOffset,
    Size buttonSize, {
    double? pinnedWidth,
  }) {
    final overlayBox = overlayRenderBox;
    final mediaQuery = MediaQuery.of(context);
    final spec = _buildSpec();

    return DropdownPlacement.resolve(
      DropdownPlacementInput(
        screenSize: overlayBox?.size ?? mediaQuery.size,
        safeInsetTop: mediaQuery.padding.top,
        safeInsetBottom: mediaQuery.padding.bottom,
        buttonOffset: buttonOffset,
        buttonSize: buttonSize,
        itemCount: spec.itemCount,
        actualItemHeight: spec.actualItemHeight,
        maxDropdownHeight: spec.maxDropdownHeight,
        chromeHeight: spec.totalChromeHeight,
        screenMargin: spec.screenMargin,
        buttonGap: spec.buttonGap,
        minVisibleItems: spec.minVisibleItems,
        minMenuWidth: pinnedWidth ?? spec.minMenuWidth,
        maxMenuWidth: pinnedWidth ?? spec.maxMenuWidth,
        menuAlignment: spec.menuAlignment,
      ),
    );
  }

  /// Calculates the optimal position and height for the dropdown overlay.
  DropdownPositionResult calculateDropdownPosition(
    Offset buttonOffset,
    Size buttonSize,
  ) {
    final placement = _resolve(buttonOffset, buttonSize);

    return DropdownPositionResult(
      height: placement.height,
      openDown: placement.openDown,
      transformAlignment: placement.transformAlignment,
      topPosition: placement.top,
    );
  }

  /// Calculates the effective width for the dropdown menu.
  @Deprecated(
    'Use DropdownOverlayController.measurePlacement() and read .width. '
    'This method will be removed in 3.0.0.',
  )
  double calculateMenuWidth(double buttonWidth) =>
      _resolve(Offset.zero, Size(buttonWidth, 0)).width;

  /// Calculates the left position for the dropdown menu based on alignment.
  @Deprecated(
    'Use DropdownOverlayController.measurePlacement() and read .left. '
    'This method will be removed in 3.0.0.',
  )
  double calculateMenuLeftPosition(
    double buttonLeft,
    double buttonWidth,
    double menuWidth,
  ) =>
      _resolve(
        Offset(buttonLeft, 0),
        Size(buttonWidth, 0),
        pinnedWidth: menuWidth,
      ).left;
}
