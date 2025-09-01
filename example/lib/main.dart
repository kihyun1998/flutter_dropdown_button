import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Dropdown Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? selectedFruit;
  int? selectedNumber;

  final List<DropdownItem<String>> fruitItems = [
    const DropdownItem(
      value: 'apple',
      child: Row(
        children: [
          Icon(Icons.apple, color: Colors.red),
          SizedBox(width: 8),
          Text('Apple'),
        ],
      ),
    ),
    const DropdownItem(
      value: 'banana',
      child: Row(
        children: [
          Icon(Icons.emoji_food_beverage, color: Colors.yellow),
          SizedBox(width: 8),
          Text('Banana'),
        ],
      ),
    ),
    const DropdownItem(
      value: 'orange',
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.orange),
          SizedBox(width: 8),
          Text('Orange'),
        ],
      ),
    ),
    const DropdownItem(
      value: 'grape',
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.purple),
          SizedBox(width: 8),
          Text('Grape'),
        ],
      ),
    ),
  ];

  final List<DropdownItem<int>> numberItems = List.generate(
    10,
    (index) => DropdownItem(
      value: index + 1,
      child: Text('Number ${index + 1}'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Custom Dropdown Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a fruit:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomDropdown<String>(
              items: fruitItems,
              value: selectedFruit,
              hint: const Text('Choose a fruit'),
              onChanged: (value) {
                setState(() {
                  selectedFruit = value;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Select a number:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomDropdown<int>(
              items: numberItems,
              value: selectedNumber,
              hint: const Text('Choose a number'),
              height: 150,
              onChanged: (value) {
                setState(() {
                  selectedNumber = value;
                });
              },
            ),
            const SizedBox(height: 32),
            if (selectedFruit != null || selectedNumber != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected values:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (selectedFruit != null)
                      Text('Fruit: $selectedFruit'),
                    if (selectedNumber != null)
                      Text('Number: $selectedNumber'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}