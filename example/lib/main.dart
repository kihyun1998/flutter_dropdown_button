import 'package:flutter/material.dart';
import 'pages/playground_page.dart';
import 'pages/bug_test_page.dart';
import 'pages/domain_type_page.dart';
import 'pages/multi_select_page.dart';
import 'pages/bare_anchor_page.dart';
import 'pages/result_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Dropdown Button Playground',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PlaygroundPage(),
      routes: {
        '/dropdown-bug-test': (context) => const DropdownBugTestPage(),
        '/domain-type': (context) => const DomainTypePage(),
        '/multi-select': (context) => const MultiSelectPage(),
        '/bare-anchor': (context) => const BareAnchorPage(),
        '/result-page': (context) => const ResultPage(),
      },
    );
  }
}
