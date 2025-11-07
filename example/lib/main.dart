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

// Style presets
class StylePreset {
  final String name;
  final DropdownStyleTheme theme;

  const StylePreset(this.name, this.theme);
}

final List<StylePreset> stylePresets = [
  StylePreset(
    'Material Design',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 8.0,
        elevation: 8.0,
        animationDuration: Duration(milliseconds: 200),
        selectedItemColor: Color(0x1A6750A4),
        itemHoverColor: Color(0x0A6750A4),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  ),
  StylePreset(
    'iOS/Cupertino',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 12.0,
        elevation: 2.0,
        animationDuration: const Duration(milliseconds: 150),
        backgroundColor: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        selectedItemColor: const Color(0x1A007AFF),
        itemHoverColor: const Color(0x0A007AFF),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  ),
  StylePreset(
    'Minimal Hover',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 12.0,
        elevation: 4.0,
        itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBorderRadius: 8.0,
        itemHoverColor: const Color(0xFFE0E0E0),
        selectedItemColor: const Color(0xFFD0D0D0),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        overlayPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
    ),
  ),
  StylePreset(
    'Custom Scrollbar',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 10.0,
        elevation: 6.0,
        selectedItemColor: Color(0x1A1976D2),
        itemHoverColor: Color(0x0A1976D2),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      scroll: DropdownScrollTheme(
        thickness: 8.0,
        radius: const Radius.circular(4.0),
        thumbColor: Colors.blue.shade400,
        trackColor: Colors.blue.shade50,
        trackBorderColor: Colors.blue.shade200,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
      ),
    ),
  ),
  StylePreset(
    'Vibrant',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 16.0,
        elevation: 12.0,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.deepPurple.shade50,
        selectedItemColor: const Color(0x40673AB7),
        itemHoverColor: const Color(0x20673AB7),
        itemSplashColor: const Color(0x60FF9800),
        itemPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
        iconColor: Colors.deepPurple, // Custom icon color
      ),
    ),
  ),
  StylePreset(
    'Glassmorphism',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 16.0,
        elevation: 8.0,
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        selectedItemColor: Colors.white.withValues(alpha: 0.3),
        itemHoverColor: Colors.white.withValues(alpha: 0.2),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    ),
  ),
  StylePreset(
    'Thick Border',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 12.0,
        elevation: 4.0,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0x1AFF5722),
        itemHoverColor: const Color(0x0AFF5722),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(
          color: Colors.deepOrange,
          width: 3.0, // Thick border for testing
        ),
      ),
    ),
  ),
  StylePreset(
    'Extra Thick Border',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 8.0,
        elevation: 2.0,
        backgroundColor: Colors.blue.shade50,
        selectedItemColor: const Color(0x402196F3),
        itemHoverColor: const Color(0x202196F3),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(
          color: Colors.blue.shade700,
          width: 5.0, // Extra thick border for testing
        ),
      ),
    ),
  ),
  StylePreset(
    'Black with White Border',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 8.0,
        elevation: 6.0,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white.withValues(alpha: 0.2),
        itemHoverColor: Colors.white.withValues(alpha: 0.1),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
    ),
  ),
  StylePreset(
    'Custom Icon & Size',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 12.0,
        elevation: 4.0,
        selectedItemColor: Color(0x1A4CAF50),
        itemHoverColor: Color(0x0A4CAF50),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Icons.expand_more, // Custom icon
        iconSize: 32.0, // Larger icon size
        iconColor: Colors.green,
        iconDisabledColor: Colors.grey,
      ),
    ),
  ),
  StylePreset(
    'Tiny Arrow',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 8.0,
        elevation: 2.0,
        selectedItemColor: Color(0x1AFF9800),
        itemHoverColor: Color(0x0AFF9800),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Icons.arrow_drop_down, // Different icon
        iconSize: 16.0, // Smaller icon size
        iconColor: Colors.orange,
      ),
    ),
  ),
  StylePreset(
    'Wide Icon Spacing',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 10.0,
        elevation: 4.0,
        selectedItemColor: Color(0x1A9C27B0),
        itemHoverColor: Color(0x0A9C27B0),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        iconPadding: EdgeInsets.only(left: 24.0), // Wide spacing
        iconColor: Colors.purple,
        iconSize: 28.0,
      ),
    ),
  ),
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Style selections for each feature card
  String? basicTextStyle = 'Material Design';
  String? longTextStyle = 'Material Design';
  String? multiLineStyle = 'Material Design';
  String? iconTextStyle = 'Material Design';
  String? scrollListStyle = 'Custom Scrollbar';
  String? centerAlignStyle = 'iOS/Cupertino';
  String? fixedWidthStyle = 'Material Design';
  String? darkModeStyle = 'Black with White Border';
  String? customIconStyle = 'Custom Icon & Size';
  String? disabledStyle = 'Tiny Arrow';

  // Selected values for demo dropdowns
  String? basicValue;
  String? longTextValue;
  String? multiLineValue;
  String? iconValue;
  String? scrollValue;
  String? centerValue;
  String? fixedWidthValue;
  String? darkModeValue;
  String? customIconValue;
  String? disabledValue;

  final List<String> basicItems = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
  ];

  final List<String> longTextItems = [
    'Short',
    'Medium length text here',
    'This is a very long option that will demonstrate ellipsis overflow behavior in the dropdown',
    'Another extremely long text option that might need to be truncated',
  ];

  final List<String> multiLineItems = [
    'Single line',
    'This is a longer text\nthat spans multiple\nlines in the dropdown',
    'Multi-line option with\nexplicit line breaks',
  ];

  final List<DropdownItem<String>> iconItems = [
    const DropdownItem(
      value: 'home',
      child: Row(
        children: [
          Icon(Icons.home, size: 20),
          SizedBox(width: 8),
          Text('Home'),
        ],
      ),
    ),
    const DropdownItem(
      value: 'settings',
      child: Row(
        children: [
          Icon(Icons.settings, size: 20),
          SizedBox(width: 8),
          Text('Settings'),
        ],
      ),
    ),
    const DropdownItem(
      value: 'profile',
      child: Row(
        children: [
          Icon(Icons.person, size: 20),
          SizedBox(width: 8),
          Text('Profile'),
        ],
      ),
    ),
    const DropdownItem(
      value: 'notifications',
      child: Row(
        children: [
          Icon(Icons.notifications, size: 20),
          SizedBox(width: 8),
          Text('Notifications'),
        ],
      ),
    ),
  ];

  final List<String> countries = [
    'United States',
    'United Kingdom',
    'Germany',
    'France',
    'Japan',
    'South Korea',
    'Australia',
    'Canada',
    'Brazil',
    'India',
    'China',
    'Russia',
    'Italy',
    'Spain',
    'Mexico',
  ];

  final List<String> mixedLengthItems = [
    'S',
    'Medium',
    'This is a very long text that will overflow with ellipsis',
    'OK',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dropdown Feature Showcase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dropdown Button Features',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore different features with customizable styles',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Grid of feature cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.3,
                      children: [
                        _buildFeatureCard(
                          title: 'Basic Text Dropdown',
                          description: 'Simple text options with single line',
                          selectedStyle: basicTextStyle,
                          onStyleChanged: (style) =>
                              setState(() => basicTextStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: basicValue,
                            hint: 'Select an option',
                            maxWidth: 280,
                            theme: _getTheme(basicTextStyle),
                            onChanged: (value) =>
                                setState(() => basicValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Long Text with Ellipsis',
                          description: 'Text overflow handling with ellipsis',
                          selectedStyle: longTextStyle,
                          onStyleChanged: (style) =>
                              setState(() => longTextStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: longTextItems,
                            value: longTextValue,
                            hint: 'Select long text option',
                            maxWidth: 280,
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            theme: _getTheme(longTextStyle),
                            onChanged: (value) =>
                                setState(() => longTextValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Multi-line Text',
                          description: 'Multiple lines with word wrapping',
                          selectedStyle: multiLineStyle,
                          onStyleChanged: (style) =>
                              setState(() => multiLineStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: multiLineItems,
                            value: multiLineValue,
                            hint: 'Multi-line demo',
                            maxWidth: 280,
                            itemHeight: 70,
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.visible,
                              maxLines: 3,
                              softWrap: true,
                            ),
                            theme: _getTheme(multiLineStyle),
                            onChanged: (value) =>
                                setState(() => multiLineValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Icon + Text Dropdown',
                          description: 'Rich content with icons and text',
                          selectedStyle: iconTextStyle,
                          onStyleChanged: (style) =>
                              setState(() => iconTextStyle = style),
                          demoDropdown: BasicDropdownButton<String>(
                            items: iconItems,
                            value: iconValue,
                            hint: const Text('Choose option'),
                            maxWidth: 280,
                            theme: _getTheme(iconTextStyle),
                            onChanged: (value) =>
                                setState(() => iconValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Long Scrollable List',
                          description: 'Many items with custom scrollbar',
                          selectedStyle: scrollListStyle,
                          onStyleChanged: (style) =>
                              setState(() => scrollListStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: countries,
                            value: scrollValue,
                            hint: 'Select a country',
                            maxWidth: 280,
                            height: 200,
                            theme: _getTheme(scrollListStyle),
                            onChanged: (value) =>
                                setState(() => scrollValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Center-Aligned Text',
                          description: 'Text aligned to center',
                          selectedStyle: centerAlignStyle,
                          onStyleChanged: (style) =>
                              setState(() => centerAlignStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: centerValue,
                            hint: 'Center aligned',
                            maxWidth: 280,
                            config: const TextDropdownConfig(
                              textAlign: TextAlign.center,
                            ),
                            theme: _getTheme(centerAlignStyle),
                            onChanged: (value) =>
                                setState(() => centerValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Fixed Width Dropdown',
                          description:
                              'Fixed width (200px) with dynamic content',
                          selectedStyle: fixedWidthStyle,
                          onStyleChanged: (style) =>
                              setState(() => fixedWidthStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: mixedLengthItems,
                            value: fixedWidthValue,
                            hint: 'Select any length',
                            width: 200, // Fixed width instead of maxWidth
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            theme: _getTheme(fixedWidthStyle),
                            onChanged: (value) =>
                                setState(() => fixedWidthValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Dark Mode Style',
                          description: 'Black background with white border',
                          selectedStyle: darkModeStyle,
                          onStyleChanged: (style) =>
                              setState(() => darkModeStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: darkModeValue,
                            hint: 'Select option',
                            maxWidth: 280,
                            config: const TextDropdownConfig(
                              textStyle: TextStyle(color: Colors.white),
                              hintStyle: TextStyle(color: Colors.white70),
                            ),
                            theme: _getTheme(darkModeStyle),
                            onChanged: (value) =>
                                setState(() => darkModeValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Custom Icon & Size',
                          description:
                              'Different icon (expand_more) and larger size',
                          selectedStyle: customIconStyle,
                          onStyleChanged: (style) =>
                              setState(() => customIconStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: customIconValue,
                            hint: 'Custom icon demo',
                            maxWidth: 280,
                            theme: _getTheme(customIconStyle),
                            onChanged: (value) =>
                                setState(() => customIconValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Disabled Dropdown',
                          description: 'Shows disabled icon color',
                          selectedStyle: disabledStyle,
                          onStyleChanged: (style) =>
                              setState(() => disabledStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: disabledValue,
                            hint: 'Disabled state',
                            maxWidth: 280,
                            enabled:
                                false, // Disabled to show iconDisabledColor
                            theme: _getTheme(disabledStyle),
                            onChanged: (value) =>
                                setState(() => disabledValue = value),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required String? selectedStyle,
    required ValueChanged<String?> onStyleChanged,
    required Widget demoDropdown,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Style selector
            Row(
              children: [
                Text(
                  'Style: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextOnlyDropdownButton(
                    items: stylePresets.map((s) => s.name).toList(),
                    value: selectedStyle,
                    hint: 'Select style',
                    maxWidth: 180,
                    config: const TextDropdownConfig(
                      textStyle: TextStyle(fontSize: 12),
                    ),
                    theme: const DropdownStyleTheme(
                      dropdown: DropdownTheme(
                        borderRadius: 8.0,
                        elevation: 2.0,
                        itemPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    onChanged: onStyleChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Demo dropdown
            demoDropdown,
          ],
        ),
      ),
    );
  }

  DropdownStyleTheme _getTheme(String? styleName) {
    final preset = stylePresets.firstWhere(
      (s) => s.name == styleName,
      orElse: () => stylePresets[0],
    );
    return preset.theme;
  }
}
