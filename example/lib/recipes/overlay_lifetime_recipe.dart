/// Closing the menu before the route under it goes away.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// **How to watch this happen:**
///
/// 1. open the dropdown below and *leave it open*;
/// 2. press one of the three buttons behind it;
/// 3. look at what is left on the screen you land on.
///
/// The menu lives in an `Overlay`, not in the route that opened it. Replace
/// that route while a menu is open and the menu has outlived its owner: a
/// floating layer over a page that knows nothing about it, swallowing every tap
/// that lands on it.
///
/// *Navigate, no cleanup* is the case that used to strand one. It is safe today
/// — the widget's `dispose` takes the entry with it — and it is here because a
/// route replacement is not the only way a page goes away, and the ones that do
/// not run `dispose` first are exactly the ones this API exists for.
///
/// [FlutterDropdownButton.closeAll] is that API. It closes every open menu in
/// the app, whoever opened it, without needing a reference to any of them.
/// `animate: false` is the form to reach for **before navigating**: the default
/// plays the close animation, and the frames it needs are frames the outgoing
/// route may not get.
///
/// The `Navigator` below is this recipe's own. Paste this into an app and delete
/// it — yours is already there. It is here because the thing being shown is a
/// route replacement, and a recipe that pushed onto the app's navigator would
/// replace the gallery around it.
class OverlayLifetimeRecipe extends StatefulWidget {
  const OverlayLifetimeRecipe({super.key});

  @override
  State<OverlayLifetimeRecipe> createState() => _OverlayLifetimeRecipeState();
}

class _OverlayLifetimeRecipeState extends State<OverlayLifetimeRecipe> {
  final _navigator = GlobalKey<NavigatorState>();

  void _land(String how) {
    _navigator.currentState!.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => _Landed(how: how)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Navigator(
        key: _navigator,
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (context) => _Start(
            onNoCleanup: () => _land('no cleanup'),
            onCloseThenGo: () {
              FlutterDropdownButton.closeAll();
              _land('closeAll(), then navigate');
            },
            onCloseNowThenGo: () {
              // No animation frames are asked for, because the route that would
              // have drawn them is about to go.
              FlutterDropdownButton.closeAll(animate: false);
              _land('closeAll(animate: false), then navigate');
            },
          ),
        ),
      ),
    );
  }
}

class _Start extends StatefulWidget {
  const _Start({
    required this.onNoCleanup,
    required this.onCloseThenGo,
    required this.onCloseNowThenGo,
  });

  final VoidCallback onNoCleanup;
  final VoidCallback onCloseThenGo;
  final VoidCallback onCloseNowThenGo;

  @override
  State<_Start> createState() => _StartState();
}

class _StartState extends State<_Start> {
  static const _items = ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo'];

  String? _value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterDropdownButton<String>.text(
              width: 240,
              items: _items,
              value: _value,
              hint: 'Open me, then leave me open',
              onChanged: (v) => setState(() => _value = v),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: widget.onNoCleanup,
                  child: const Text('Navigate, no cleanup'),
                ),
                FilledButton.tonal(
                  onPressed: widget.onCloseThenGo,
                  child: const Text('closeAll(), then navigate'),
                ),
                FilledButton(
                  onPressed: widget.onCloseNowThenGo,
                  child: const Text('closeAll(animate: false)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the three buttons land. It draws nothing from this package on purpose:
/// anything still floating here came from the route that is gone.
class _Landed extends StatelessWidget {
  const _Landed({required this.how});

  final String how;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 48),
            const SizedBox(height: 16),
            Text('Arrived via $how'),
            const SizedBox(height: 8),
            const Text('If a menu is still on screen, it outlived its route.'),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const OverlayLifetimeRecipe(),
                ),
                (route) => false,
              ),
              child: const Text('Start over'),
            ),
          ],
        ),
      ),
    );
  }
}
