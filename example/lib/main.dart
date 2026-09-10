import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import 'app/destinations.dart';
import 'pages/bare_anchor_page.dart';
import 'pages/bug_test_page.dart';
import 'pages/domain_type_page.dart';
import 'pages/multi_select_page.dart';
import 'pages/result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeController = ExampleThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scope sits above MaterialApp so the controller outlives any route,
    // and the builder sits inside so a change of mode rebuilds the app rather
    // than only the page that asked for it.
    //
    // A light/dark toggle is not decoration for this package: it is a
    // verification surface. `DropdownTooltipTheme.resolve` takes a `Brightness`
    // directly and `DropdownAmbientColors.of` reads one from the tree, so
    // without a way to flip it half the ambient resolution path never runs in
    // this example even once.
    return ExampleThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) => MaterialApp(
          title: 'Flutter Dropdown Button',
          debugShowCheckedModeBanner: false,
          theme: exampleTheme(Brightness.light),
          darkTheme: exampleTheme(Brightness.dark),
          themeMode: _themeController.mode,
          home: ShellPage(
            // Deliberately not defaulted upstream: a shell with a fallback
            // title is one that ships somebody else's product name when a
            // caller forgets.
            title: 'Flutter Dropdown Button',
            createDestinations: DropdownDestinations.new,
          ),
          // The named routes stay exactly as they were, and are load-bearing
          // for as long as the old pages are: `bug_test_page` pushes
          // `/result-page` and `result_page` pushes `/`, which is this
          // `home:`. They retire with the pages that use them, not here.
          routes: {
            '/dropdown-bug-test': (context) => const DropdownBugTestPage(),
            '/domain-type': (context) => const DomainTypePage(),
            '/multi-select': (context) => const MultiSelectPage(),
            '/bare-anchor': (context) => const BareAnchorPage(),
            '/result-page': (context) => const ResultPage(),
          },
        ),
      ),
    );
  }
}
