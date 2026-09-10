/// Your own dropdown, on this package's parts — the overlay and the text rows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// A dropdown assembled from the two pieces the README advertises rather than
/// from `FlutterDropdownButton`.
///
/// * [DropdownOverlayController] owns the overlay's lifetime, the open/close
///   animation and the "only one menu open" rule. You hold one; the package's
///   own dropdown holds the same object.
/// * [TextItemPresentation] draws the rows and the button face, and brings
///   overflow handling, the automatic tooltip and a default search filter with
///   it. Writing rows by hand gets you `Text` widgets and none of that.
///
/// **Row selection is announced, not merely coloured.** `buildItem`'s second
/// argument is what a screen reader hears; on screen the difference is a
/// colour, and a colour reaches nobody using one. That is the reason to reach
/// for a presentation rather than to draw a `ListTile` — and it is why the
/// other implementations exist too: [CustomItemPresentation] for arbitrary
/// widgets, [MultiSelectPresentation] for a checklist, both announcing the
/// vocabulary their cardinality calls for.
class BuildYourOwnRecipe extends StatefulWidget {
  const BuildYourOwnRecipe({super.key});

  @override
  State<BuildYourOwnRecipe> createState() => _BuildYourOwnRecipeState();
}

class _BuildYourOwnRecipeState extends State<BuildYourOwnRecipe>
    with SingleTickerProviderStateMixin {
  static const _colours = <String>['Crimson', 'Teal', 'Amber', 'Indigo'];
  static const _itemHeight = 44.0;

  String? _selected = 'Teal';

  late final DropdownOverlayController _menu = DropdownOverlayController(
    vsync: this,
    // A callback rather than a value: it is re-read on every overlay build, so
    // a menu open while the item list changes re-measures instead of keeping
    // the height it opened with.
    spec: () => DropdownOverlaySpec(
      itemCount: _colours.length,
      actualItemHeight: _itemHeight,
      maxDropdownHeight: 200,
      borderThickness: 1,
    ),
    contentBuilder: _buildMenu,
    decorationBuilder: () => BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    onOpenStateChanged: (_) => setState(() {}),
  );

  /// Built fresh each time, because a presentation holds plain values and no
  /// `BuildContext`: whatever it needs from the element tree, you read first
  /// and hand over.
  TextItemPresentation<String> _presentation() => TextItemPresentation<String>(
    label: (colour) => colour,
    value: _selected,
    hintText: 'Pick a colour',
    config: TextDropdownConfig.defaultConfig,
    tooltipTheme: const DropdownTooltipTheme(),
    enabled: true,
    leadingHeight: _itemHeight,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A surrounding Scrollable rebuilds its scroll position from its own
    // didChangeDependencies — a theme change is enough — and an open menu would
    // be left listening to the disposed one, its scroll dismissal silently
    // dead. Nothing throws without this line; it just stops working.
    _menu.refreshScrollables(context);
  }

  @override
  void dispose() {
    // Not optional. A leaked OverlayEntry is a dead layer over the whole app,
    // swallowing taps, with nothing left to remove it once this State is gone.
    _menu.dispose();
    super.dispose();
  }

  Widget _buildMenu(double height) {
    final presentation = _presentation();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final colour in _colours)
          InkWell(
            onTap: () {
              setState(() => _selected = colour);
              _menu.close();
            },
            child: SizedBox(
              height: _itemHeight,
              child: Align(
                alignment: presentation.contentAlignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: presentation.buildItem(colour, colour == _selected),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: _menu.buttonKey,
            onTap: () => _menu.toggle(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: _presentation().buildSelected()),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(
                      CurvedAnimation(
                        parent: _menu.animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
