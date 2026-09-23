import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// A mouse-wheel notch over an overflowing menu glides to where it would have
/// jumped. `DropdownScrollTheme.wheelMotion` decides how, and a zero duration
/// jumps.

const items = [
  'i0',
  'i1',
  'i2',
  'i3',
  'i4',
  'i5',
  'i6',
  'i7',
  'i8',
  'i9',
  'i10',
  'i11',
];

const notch = 40.0;

const instant = DropdownScrollTheme(
  wheelMotion: WheelMotion.spring(duration: Duration.zero),
);

Widget host({DropdownScrollTheme? scroll, bool searchable = false}) =>
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: FlutterDropdownButton<String>.text(
            width: 200,
            height: 150,
            items: items,
            hint: 'Pick one',
            searchable: searchable,
            theme: scroll == null ? null : DropdownStyleTheme(scroll: scroll),
            onChanged: (_) {},
          ),
        ),
      ),
    );

double offset(WidgetTester tester) =>
    tester.widget<ListView>(find.byType(ListView)).controller!.offset;

Future<void> open(WidgetTester tester) async {
  await tester.tap(find.byType(FlutterDropdownButton<String>));
  await tester.pumpAndSettle();
}

Future<void> wheel(WidgetTester tester) async {
  final mouse = TestPointer(1, PointerDeviceKind.mouse);
  await tester.sendEventToBinding(
    mouse.hover(tester.getCenter(find.byType(ListView))),
  );
  await tester.sendEventToBinding(mouse.scroll(const Offset(0, notch)));
}

void main() {
  testWidgets('a wheel notch glides to where it would have jumped', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await open(tester);

    await wheel(tester);
    expect(offset(tester), 0, reason: 'nothing has moved before a frame');

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(offset(tester), greaterThan(0));
    expect(offset(tester), lessThan(notch), reason: 'still on its way');

    await tester.pumpAndSettle();
    expect(offset(tester), notch);
  });

  testWidgets('the default motion has settled by 300 ms', (tester) async {
    await tester.pumpWidget(host());
    await open(tester);

    await wheel(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(offset(tester), notch);
  });

  testWidgets('a trackpad scroll signal jumps, as on the web', (tester) async {
    await tester.pumpWidget(host());
    await open(tester);

    final trackpad = TestPointer(2, PointerDeviceKind.trackpad);
    await tester.sendEventToBinding(
      trackpad.hover(tester.getCenter(find.byType(ListView))),
    );
    await tester.sendEventToBinding(trackpad.scroll(const Offset(0, notch)));

    expect(offset(tester), notch);
  });

  testWidgets('a zero duration jumps, as a plain ScrollController does', (
    tester,
  ) async {
    await tester.pumpWidget(host(scroll: instant));
    await open(tester);

    await wheel(tester);

    expect(offset(tester), notch);
  });

  testWidgets('a motion changed while the menu is open applies to the next '
      'notch', (tester) async {
    await tester.pumpWidget(host());
    await open(tester);

    await tester.pumpWidget(host(scroll: instant));
    await tester.pump();
    await wheel(tester);

    expect(offset(tester), notch);
  });

  testWidgets('a motion changed while the menu is closed applies on reopen', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await tester.pumpWidget(host(scroll: instant));
    await open(tester);
    await wheel(tester);

    expect(offset(tester), notch);
  });

  testWidgets('a search query mid-glide sends the list to the top, and it '
      'stays there', (tester) async {
    await tester.pumpWidget(host(searchable: true));
    await open(tester);

    await wheel(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(offset(tester), greaterThan(0), reason: 'the glide is under way');

    await tester.enterText(find.byType(TextField), 'i');
    await tester.pumpAndSettle();

    expect(offset(tester), 0);
  });

  testWidgets('closing the menu mid-glide leaves nothing running', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await open(tester);

    await wheel(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(offset(tester), greaterThan(0), reason: 'the glide is under way');

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsNothing);

    await open(tester);
    expect(offset(tester), 0, reason: 'a reopened menu starts at the top');
  });

  testWidgets('removing the dropdown mid-glide leaves nothing running', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await open(tester);

    await wheel(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('a notch past the end of a gliding menu scrolls the page around '
      'it, which closes the menu', (tester) async {
    final page = ScrollController();
    addTearDown(page.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: page,
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  child: Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (_) => Center(
                          child: FlutterDropdownButton<String>.text(
                            width: 200,
                            height: 150,
                            items: items,
                            hint: 'Pick one',
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    );
    await open(tester);

    final menu = tester.widget<ListView>(find.byType(ListView)).controller!;
    menu.jumpTo(menu.position.maxScrollExtent - 10);
    await tester.pump();

    // The first notch heads for the end; the second arrives while it is still
    // on its way there.
    await wheel(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await wheel(tester);
    await tester.pumpAndSettle();

    expect(page.offset, greaterThan(0));
    expect(find.byType(ListView), findsNothing, reason: 'scroll dismissal');
  });
}
