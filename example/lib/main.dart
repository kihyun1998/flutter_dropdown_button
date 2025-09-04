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
      title: 'Flutter Dropdown Button Demo',
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
  String? selectedDynamic;
  String? selectedFixed;
  String? selectedTextOverflow;
  String? selectedMultiLine;

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
    (index) =>
        DropdownItem(value: index + 1, child: Text('Number ${index + 1}')),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Dropdown Button Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a fruit:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BasicDropdownButton<String>(
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
              'Select a number with custom theme colors:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BasicDropdownButton<int>(
              items: numberItems,
              value: selectedNumber,
              hint: const Text('Choose a number'),
              height: 150,
              theme: const DropdownTheme(
                selectedItemColor: Color(0x1A4CAF50), // Light green
                itemHoverColor: Color(0x0A2196F3), // Light blue hover
                itemSplashColor: Color(0x40FF9800), // Orange splash
                itemHighlightColor: Color(0x20E91E63), // Pink highlight
                borderRadius: 12.0,
                animationDuration: Duration(milliseconds: 250),
              ),
              onChanged: (value) {
                setState(() {
                  selectedNumber = value;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Dynamic width dropdown (maxWidth: 200):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BasicDropdownButton<String>(
              items: [
                const DropdownItem(value: 'short', child: Text('Short')),
                const DropdownItem(
                  value: 'medium',
                  child: Text('Medium length text'),
                ),
                const DropdownItem(
                  value: 'long',
                  child: Text(
                    'This is a very long text that should be constrained by maxWidth',
                  ),
                ),
              ],
              value: selectedDynamic,
              hint: const Text('Select text length'),
              maxWidth: 200,
              onChanged: (value) {
                setState(() {
                  selectedDynamic = value;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Fixed width dropdown (width: 300):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BasicDropdownButton<String>(
              items: [
                const DropdownItem(value: 'option1', child: Text('Option 1')),
                const DropdownItem(value: 'option2', child: Text('Option 2')),
              ],
              value: selectedFixed,
              hint: const Text('Fixed width'),
              width: 300,
              onChanged: (value) {
                setState(() {
                  selectedFixed = value;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'TextOnlyDropdownButton with overflow control:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextOnlyDropdownButton(
              items: [
                'Short',
                'Medium length text',
                'This is a very long text that will demonstrate ellipsis overflow behavior',
                'Another extremely long option that might be cut off depending on the settings',
              ],
              value: selectedTextOverflow,
              hint: 'Select overflow demo',
              maxWidth: 250,
              config: const TextDropdownConfig(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textStyle: TextStyle(fontSize: 14),
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              theme: const DropdownTheme(
                borderRadius: 12.0,
                animationDuration: Duration(milliseconds: 300),
              ),
              onChanged: (value) {
                setState(() {
                  selectedTextOverflow = value;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Multi-line TextOnlyDropdownButton:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextOnlyDropdownButton(
              items: [
                'Single line',
                'This is a longer text that will wrap to multiple lines when displayed',
                'Another multi-line option\nthat contains explicit line breaks',
              ],
              value: selectedMultiLine,
              hint: 'Select multi-line demo',
              width: 300,
              itemHeight: 60,
              config: const TextDropdownConfig(
                overflow: TextOverflow.visible,
                maxLines: 3,
                textStyle: TextStyle(fontSize: 14),
                softWrap: true,
              ),
              onChanged: (value) {
                setState(() {
                  selectedMultiLine = value;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Custom themed dropdown with vibrant colors:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BasicDropdownButton<String>(
              items: fruitItems,
              value: selectedFruit,
              hint: const Text('Vibrant theme demo'),
              theme: const DropdownTheme(
                selectedItemColor: Color(0x2000BCD4), // Cyan selection
                itemHoverColor: Color(0x1000BCD4), // Cyan hover
                itemSplashColor: Color(0x60FF5722), // Deep orange splash
                itemHighlightColor: Color(0x303F51B5), // Indigo highlight
                borderRadius: 16.0,
                animationDuration: Duration(milliseconds: 300),
                elevation: 12.0,
                itemPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (value) {
                setState(() {
                  selectedFruit = value;
                });
              },
            ),
            const SizedBox(height: 32),
            if (selectedFruit != null ||
                selectedNumber != null ||
                selectedDynamic != null ||
                selectedFixed != null ||
                selectedTextOverflow != null ||
                selectedMultiLine != null)
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
                    if (selectedFruit != null) Text('Fruit: $selectedFruit'),
                    if (selectedNumber != null) Text('Number: $selectedNumber'),
                    if (selectedDynamic != null)
                      Text('Dynamic: $selectedDynamic'),
                    if (selectedFixed != null) Text('Fixed: $selectedFixed'),
                    if (selectedTextOverflow != null)
                      Text('Text Overflow: $selectedTextOverflow'),
                    if (selectedMultiLine != null)
                      Text('Multi-line: $selectedMultiLine'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
