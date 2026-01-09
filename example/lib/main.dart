import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/bug_test_page.dart';
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
      title: 'Flutter Dropdown Button Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      routes: {
        '/dropdown-bug-test': (context) => const DropdownBugTestPage(),
        '/result-page': (context) => const ResultPage(),
      },
    );
  }
}
