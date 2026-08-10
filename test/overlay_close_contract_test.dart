import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// The controller's two lifetime contracts, both invisible through the widgets
/// because the dismiss barrier keeps the pointer away from the trigger (#95).
///
/// - #106: `close()` promises to hide the menu. It gated teardown on an
///   animation that need not tick, so a muted `TickerMode` — a pushed route is
///   the common one — left the entry mounted forever.
/// - #107: `isOpen` is `_entry != null`, which stays true for the whole close
///   animation, so `open()` was a silent no-op while a close was in flight.

class Bare extends StatefulWidget {
  const Bare({super.key});

  @override
  State<Bare> createState() => BareState();
}

class BareState extends State<Bare> with SingleTickerProviderStateMixin {
  late final DropdownOverlayController menu = DropdownOverlayController(
    vsync: this,
    spec: () => const DropdownOverlaySpec(
      itemCount: 2,
      actualItemHeight: 40,
      maxDropdownHeight: 200,
    ),
    contentBuilder: (height) => const Column(
      mainAxisSize: MainAxisSize.min,
      children: [Text('MENU-ROW'), Text('two')],
    ),
    decorationBuilder: () => null,
  );

  @override
  void dispose() {
    menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: menu.buttonKey,
      onTap: () => menu.toggle(context),
      child: const SizedBox(width: 120, height: 40, child: Text('open me')),
    );
  }
}

Finder menuRow() => find.text('MENU-ROW');

void main() {
  group('#106 — close() completes without a running ticker', () {
    testWidgets('a muted TickerMode still tears the menu down', (tester) async {
      var enabled = true;
      late StateSetter setOuter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuter = setState;
                return TickerMode(
                  enabled: enabled,
                  child: const Center(child: Bare()),
                );
              },
            ),
          ),
        ),
      );
      final state = tester.state<BareState>(find.byType(Bare));

      await tester.tap(find.text('open me'));
      await tester.pumpAndSettle();
      expect(menuRow(), findsOneWidget);

      // No Navigator involved: muting the ticker is the whole condition.
      setOuter(() => enabled = false);
      await tester.pump();

      state.menu.close();
      await tester.pump(const Duration(seconds: 1));

      expect(menuRow(), findsNothing, reason: 'the entry must be gone');
      expect(state.menu.isOpen, isFalse);
    });

    testWidgets('the owner is told the menu closed', (tester) async {
      // The state change is what a caller rebuilds on; a teardown that does
      // not announce itself leaves the trigger drawn as if still open.
      var closes = 0;
      var enabled = true;
      late StateSetter setOuter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setOuter = setState;
                return TickerMode(
                  enabled: enabled,
                  child: Center(child: _Counting(onClosed: () => closes++)),
                );
              },
            ),
          ),
        ),
      );
      final state = tester.state<_CountingState>(find.byType(_Counting));

      await tester.tap(find.text('open me'));
      await tester.pumpAndSettle();

      setOuter(() => enabled = false);
      await tester.pump();

      state.menu.close();
      await tester.pump(const Duration(seconds: 1));

      expect(closes, 1);
    });

    testWidgets('a route pushed over an open menu does not lock the page', (
      tester,
    ) async {
      var page2Taps = 0;
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<String>.text(
                width: 150,
                items: const ['Alpha 1', 'Alpha 2'],
                hint: 'Alpha',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(find.text('Alpha 2'), findsOneWidget);

      navKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => page2Taps++,
                child: const Text('PAGE2'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The first tap may still be spent dismissing the menu — that is #95,
      // not this contract. What must not happen is the page staying dead.
      await tester.tap(find.text('PAGE2'), warnIfMissed: false);
      // Not `pumpAndSettle`: the route mutes the ticker, so the close animation
      // schedules no frame and a settle would return without moving the clock.
      // The fallback timer is what has to fire here, and it needs real time.
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Alpha 2'), findsNothing, reason: 'menu must be gone');

      await tester.tap(find.text('PAGE2'));
      await tester.pumpAndSettle();

      expect(page2Taps, greaterThan(0), reason: 'the new page must be usable');
    });
  });

  group('#107 — isOpen distinguishes open from closing', () {
    testWidgets('open() during the close animation keeps the menu', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Bare())),
        ),
      );
      final state = tester.state<BareState>(find.byType(Bare));

      await tester.tap(find.text('open me'));
      await tester.pumpAndSettle();

      state.menu.close();
      await tester.pump(const Duration(milliseconds: 100)); // mid-reverse

      state.menu.open(tester.element(find.text('open me')));
      await tester.pumpAndSettle();

      expect(state.menu.isOpen, isTrue);
      expect(menuRow(), findsOneWidget, reason: 'open() must not be dropped');
    });

    testWidgets('closeAll() then open() shows the menu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Bare())),
        ),
      );
      final state = tester.state<BareState>(find.byType(Bare));

      await tester.tap(find.text('open me'));
      await tester.pumpAndSettle();

      // The documented "close everything, then show mine" idiom.
      DropdownOverlayController.closeAll();
      state.menu.open(tester.element(find.text('open me')));
      await tester.pumpAndSettle();

      expect(state.menu.isOpen, isTrue);
      expect(menuRow(), findsOneWidget);
    });

    testWidgets('an ordinary close still closes', (tester) async {
      // The guard against fixing #107 by never closing at all.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Bare())),
        ),
      );
      final state = tester.state<BareState>(find.byType(Bare));

      await tester.tap(find.text('open me'));
      await tester.pumpAndSettle();
      expect(menuRow(), findsOneWidget);

      state.menu.close();
      await tester.pumpAndSettle();

      expect(state.menu.isOpen, isFalse);
      expect(menuRow(), findsNothing);
    });
  });
}

class _Counting extends StatefulWidget {
  const _Counting({required this.onClosed});

  final VoidCallback onClosed;

  @override
  State<_Counting> createState() => _CountingState();
}

class _CountingState extends State<_Counting>
    with SingleTickerProviderStateMixin {
  late final DropdownOverlayController menu = DropdownOverlayController(
    vsync: this,
    spec: () => const DropdownOverlaySpec(
      itemCount: 2,
      actualItemHeight: 40,
      maxDropdownHeight: 200,
    ),
    contentBuilder: (height) => const Text('MENU-ROW'),
    decorationBuilder: () => null,
    onOpenStateChanged: (isOpen) {
      if (!isOpen) widget.onClosed();
    },
  );

  @override
  void dispose() {
    menu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: menu.buttonKey,
      onTap: () => menu.toggle(context),
      child: const SizedBox(width: 120, height: 40, child: Text('open me')),
    );
  }
}
