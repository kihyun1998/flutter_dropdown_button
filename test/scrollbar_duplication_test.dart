import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// On desktop, `MaterialScrollBehavior` wraps every scroll view in a
/// `Scrollbar` of its own. The menu drew one too, so two were stacked.
///
/// Neither carried a thickness unless the caller named one, and
/// `material/scrollbar.dart:303` swells a thickness-less scrollbar from 8 to 12
/// the moment a pointer hovers a visible track.
///
/// `debugDefaultTargetPlatformOverride` must be restored inside the test body —
/// `tearDown` is too late, and `flutter_test` fails the test for it.

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

Future<void> openMenu(WidgetTester tester, DropdownScrollTheme scroll) async {
  await tester.pumpWidget(
    host(
      FlutterDropdownButton<String>.text(
        width: 200,
        height: 100,
        items: const ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
        hint: 'pick',
        theme: DropdownStyleTheme(scroll: scroll),
        onChanged: (_) {},
      ),
    ),
  );
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

List<Scrollbar> scrollbars(WidgetTester tester) =>
    tester.widgetList<Scrollbar>(find.byType(Scrollbar)).toList();

/// Runs [body] with [platform] in force, restoring it before the test ends.
Future<void> on(TargetPlatform platform, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  const platforms = [
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
    TargetPlatform.android,
  ];

  for (final platform in platforms) {
    testWidgets('$platform: the menu draws exactly one scrollbar', (
      tester,
    ) async {
      await on(platform, () async {
        await openMenu(tester, const DropdownScrollTheme());

        expect(scrollbars(tester), hasLength(1));
      });
    });

    testWidgets('$platform: the thickness is never null', (tester) async {
      await on(platform, () async {
        // A thickness-less scrollbar with a visible track swells from 8 to 12
        // the moment a pointer enters. Naming a thickness pins it.
        await openMenu(
          tester,
          const DropdownScrollTheme(trackVisibility: true),
        );

        expect(scrollbars(tester), hasLength(1));
        expect(scrollbars(tester).first.thickness, isNotNull);
      });
    });
  }

  // One platform per test. Reopening the menu on the same `tester` taps the
  // button a second time, which closes it.
  testWidgets("desktop keeps Flutter's 8px default", (tester) async {
    await on(TargetPlatform.windows, () async {
      await openMenu(tester, const DropdownScrollTheme());

      expect(scrollbars(tester).first.thickness, 8.0);
    });
  });

  testWidgets("Android keeps Flutter's halved 4px default", (tester) async {
    await on(TargetPlatform.android, () async {
      await openMenu(tester, const DropdownScrollTheme());

      expect(
        scrollbars(tester).first.thickness,
        4.0,
        reason: 'a flat 8.0 would double the bar on every Android build',
      );
    });
  });

  testWidgets('a themed thickness still wins', (tester) async {
    await on(TargetPlatform.windows, () async {
      await openMenu(tester, const DropdownScrollTheme(thickness: 6));

      expect(scrollbars(tester), hasLength(1));
      expect(scrollbars(tester).first.thickness, 6.0);
    });
  });

  testWidgets('a themed thumbWidth still wins', (tester) async {
    await on(TargetPlatform.windows, () async {
      await openMenu(tester, const DropdownScrollTheme(thumbWidth: 4));

      expect(scrollbars(tester), hasLength(1));
      expect(scrollbars(tester).first.thickness, 4.0);
    });
  });

  testWidgets('a menu with no scroll theme still gets ours', (tester) async {
    // `DropdownScrollTheme` was optional, and without one `_applyScrollbarTheme`
    // never ran. The menu fell through to Flutter's automatic scrollbar, which
    // answers to nothing this package exposes.
    await on(TargetPlatform.windows, () async {
      await tester.pumpWidget(
        host(
          FlutterDropdownButton<String>.text(
            width: 200,
            height: 100,
            items: const ['a', 'b', 'c', 'd', 'e', 'f'],
            hint: 'pick',
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();

      expect(scrollbars(tester), hasLength(1));
      expect(scrollbars(tester).first.thickness, 8.0);
    });
  });

  testWidgets('an app-wide ScrollbarTheme still sets the thickness', (
    tester,
  ) async {
    // Pinning a thickness must not silently overrule the app's own theme.
    await on(TargetPlatform.windows, () async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            scrollbarTheme: ScrollbarThemeData(
              thickness: WidgetStateProperty.all(10.0),
            ),
          ),
          home: Scaffold(
            body: Center(
              child: FlutterDropdownButton<String>.text(
                width: 200,
                height: 100,
                items: const ['a', 'b', 'c', 'd', 'e', 'f'],
                hint: 'pick',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FlutterDropdownButton<String>));
      await tester.pumpAndSettle();

      expect(scrollbars(tester).first.thickness, 10.0);
    });
  });

  testWidgets('interactive: false is still honoured', (tester) async {
    // This already worked — our scrollbar owns the gesture, not Flutter's.
    // Pinned so that suppressing the automatic one cannot quietly change it.
    await on(TargetPlatform.windows, () async {
      await openMenu(
        tester,
        const DropdownScrollTheme(thumbVisibility: true, interactive: false),
      );

      final controller = tester
          .widget<ListView>(find.byType(ListView))
          .controller!;
      final box = tester.getRect(find.byType(ListView));

      await tester.dragFrom(
        Offset(box.right - 2, box.top + 5),
        const Offset(0, 40),
      );
      await tester.pumpAndSettle();

      expect(controller.offset, 0, reason: 'nobody may drag this thumb');
    });
  });
}
