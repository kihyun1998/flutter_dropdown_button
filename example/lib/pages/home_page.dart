import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

import '../data/style_presets.dart';

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
  String? dynamicStyle = 'Material Design';
  String? tooltipBasicStyle = 'Material Design';
  String? tooltipCustomStyle = 'Vibrant';
  String? separatorBasicStyle = 'Material Design';
  String? separatorCustomStyle = 'Vibrant';
  String? minWidthLeftStyle = 'Material Design';
  String? minWidthCenterStyle = 'iOS/Cupertino';
  String? minWidthRightStyle = 'Vibrant';
  String? maxWidthStyle = 'Material Design';
  String? combinedWidthStyle = 'Minimal Hover';

  // Selected values for demo dropdowns
  String? basicValue;
  String? longTextValue;
  String? multiLineValue;
  String? iconValue;
  String? scrollValue =
      'South Korea'; // Pre-selected to test scroll-to-selected
  String? centerValue;
  String? fixedWidthValue;
  String? darkModeValue;
  String? customIconValue;
  String? disabledValue;
  String? dynamicValue;
  String? tooltipBasicValue;
  String? tooltipCustomValue;
  String? separatorBasicValue;
  String? separatorCustomValue;
  String? minWidthLeftValue;
  String? minWidthCenterValue;
  String? minWidthRightValue;
  String? maxWidthValue;
  String? combinedWidthValue;

  // Dynamic dropdown items for interactive demo
  List<String> dynamicItems = ['Option 1'];
  final TextEditingController _dynamicItemController = TextEditingController();
  int _itemCounter = 1;

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
  void dispose() {
    _dynamicItemController.dispose();
    super.dispose();
  }

  void _addDynamicItem() {
    setState(() {
      final text = _dynamicItemController.text.trim();
      if (text.isEmpty) {
        // Add default value
        _itemCounter++;
        dynamicItems.add('Option $_itemCounter');
      } else {
        // Add custom text
        dynamicItems.add(text);
        _dynamicItemController.clear();
      }
    });
  }

  void _deleteDynamicItem() {
    if (dynamicItems.isNotEmpty) {
      setState(() {
        final removedItem = dynamicItems.removeLast();
        // If the removed item was selected, clear selection
        if (dynamicValue == removedItem) {
          dynamicValue = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dropdown Feature Showcase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Dropdown Overlay Bug Test',
            onPressed: () {
              Navigator.pushNamed(context, '/dropdown-bug-test');
            },
          ),
        ],
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
                            width: 280,
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
                            width: 280,
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
                          title: 'Smart Tooltip (Auto)',
                          description:
                              'Hover long text to see tooltip. Auto-positioned.',
                          selectedStyle: tooltipBasicStyle,
                          onStyleChanged: (style) =>
                              setState(() => tooltipBasicStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: longTextItems,
                            value: tooltipBasicValue,
                            hint: 'Hover to see tooltip',
                            width: 280,
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            theme: _getTheme(tooltipBasicStyle),
                            onChanged: (value) =>
                                setState(() => tooltipBasicValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Custom Styled Tooltip',
                          description:
                              'Tooltip with custom colors, border & shadow',
                          selectedStyle: tooltipCustomStyle,
                          onStyleChanged: (style) =>
                              setState(() => tooltipCustomStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: longTextItems,
                            value: tooltipCustomValue,
                            hint: 'Styled tooltip demo',
                            width: 280,
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            theme: _getTheme(tooltipCustomStyle).copyWith(
                              tooltip: DropdownTooltipTheme(
                                enabled: true,
                                mode: TooltipMode.onlyWhenOverflow,
                                waitDuration: const Duration(milliseconds: 300),
                                verticalOffset: 8,
                                backgroundColor: Colors.deepPurple,
                                textColor: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                borderColor: Colors.deepPurple.shade300,
                                borderWidth: 2.0,
                                shadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => tooltipCustomValue = value),
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
                            width: 280,
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
                          description:
                              'Scroll gradient fade at edges + auto-scroll to selected',
                          selectedStyle: scrollListStyle,
                          onStyleChanged: (style) =>
                              setState(() => scrollListStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: countries,
                            value: scrollValue,
                            hint: 'Select a country',
                            width: 280,
                            height: 200,
                            scrollToSelectedItem: true, // Enable auto-scroll
                            scrollToSelectedDuration: const Duration(
                              milliseconds: 100,
                            ), // Smooth animation
                            theme: _getTheme(scrollListStyle).copyWith(
                              scroll: DropdownScrollTheme(
                                showScrollGradient: true,
                                gradientHeight: 20.0,
                                gradientColors: [
                                  Colors.white.withValues(alpha: 0.8),
                                  Colors.white.withValues(alpha: 0.5),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
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
                            width: 280,
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
                            width: 280,
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
                            width: 280,
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
                            width: 280,
                            enabled:
                                false, // Disabled to show iconDisabledColor
                            theme: _getTheme(disabledStyle),
                            onChanged: (value) =>
                                setState(() => disabledValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Custom Trailing Widget',
                          description:
                              'Custom trailing widget with rotation animation',
                          selectedStyle: basicValue,
                          onStyleChanged: (style) =>
                              setState(() => basicValue = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: basicValue,
                            hint: 'Custom trailing',
                            width: 280,
                            trailing: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            theme: _getTheme(basicValue),
                            onChanged: (value) =>
                                setState(() => basicValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Basic Separator',
                          description: 'Default divider between dropdown items',
                          selectedStyle: separatorBasicStyle,
                          onStyleChanged: (style) =>
                              setState(() => separatorBasicStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: separatorBasicValue,
                            hint: 'With separator',
                            width: 280,
                            showSeparator: true,
                            theme: _getTheme(separatorBasicStyle),
                            onChanged: (value) =>
                                setState(() => separatorBasicValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Custom Separator',
                          description:
                              'Custom styled separator with color and thickness',
                          selectedStyle: separatorCustomStyle,
                          onStyleChanged: (style) =>
                              setState(() => separatorCustomStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: countries.take(8).toList(),
                            value: separatorCustomValue,
                            hint: 'Custom separator',
                            width: 280,
                            showSeparator: true,
                            separator: Divider(
                              height: 8,
                              thickness: 2,
                              color: Colors.deepPurple.shade200,
                              indent: 16,
                              endIndent: 16,
                            ),
                            theme: _getTheme(separatorCustomStyle),
                            onChanged: (value) =>
                                setState(() => separatorCustomValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Min Menu Width (Left)',
                          description:
                              'Button 120px, Menu 250px - Left aligned (default)',
                          selectedStyle: minWidthLeftStyle,
                          onStyleChanged: (style) =>
                              setState(() => minWidthLeftStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: minWidthLeftValue,
                            hint: 'Narrow button',
                            width: 120,
                            minMenuWidth: 250,
                            menuAlignment: MenuAlignment.left,
                            theme: _getTheme(minWidthLeftStyle),
                            onChanged: (value) =>
                                setState(() => minWidthLeftValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Min Menu Width (Center)',
                          description:
                              'Button 120px, Menu 250px - Center aligned',
                          selectedStyle: minWidthCenterStyle,
                          onStyleChanged: (style) =>
                              setState(() => minWidthCenterStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: minWidthCenterValue,
                            hint: 'Narrow button',
                            width: 120,
                            minMenuWidth: 250,
                            menuAlignment: MenuAlignment.center,
                            theme: _getTheme(minWidthCenterStyle),
                            onChanged: (value) =>
                                setState(() => minWidthCenterValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Min Menu Width (Right)',
                          description:
                              'Button 120px, Menu 250px - Right aligned',
                          selectedStyle: minWidthRightStyle,
                          onStyleChanged: (style) =>
                              setState(() => minWidthRightStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: basicItems,
                            value: minWidthRightValue,
                            hint: 'Narrow button',
                            width: 120,
                            minMenuWidth: 250,
                            menuAlignment: MenuAlignment.right,
                            theme: _getTheme(minWidthRightStyle),
                            onChanged: (value) =>
                                setState(() => minWidthRightValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Max Menu Width',
                          description: 'Button auto-sizes, Menu max 200px wide',
                          selectedStyle: maxWidthStyle,
                          onStyleChanged: (style) =>
                              setState(() => maxWidthStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: longTextItems,
                            value: maxWidthValue,
                            hint: 'Very long text with limits',
                            width: 300,
                            maxMenuWidth: 200,
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            theme: _getTheme(maxWidthStyle),
                            onChanged: (value) =>
                                setState(() => maxWidthValue = value),
                          ),
                        ),
                        _buildFeatureCard(
                          title: 'Min & Max Combined',
                          description:
                              'Menu constrained between 180px and 280px',
                          selectedStyle: combinedWidthStyle,
                          onStyleChanged: (style) =>
                              setState(() => combinedWidthStyle = style),
                          demoDropdown: TextOnlyDropdownButton(
                            items: mixedLengthItems,
                            value: combinedWidthValue,
                            hint: 'Flexible menu',
                            width: 200,
                            minMenuWidth: 180,
                            maxMenuWidth: 280,
                            menuAlignment: MenuAlignment.center,
                            config: const TextDropdownConfig(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            theme: _getTheme(combinedWidthStyle),
                            onChanged: (value) =>
                                setState(() => combinedWidthValue = value),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Interactive Dynamic Dropdown Card (full width)
                _buildInteractiveDynamicCard(),
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
                TextOnlyDropdownButton(
                  items: stylePresets.map((s) => s.name).toList(),
                  value: selectedStyle,
                  hint: 'Select style',
                  width: 180,
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

  Widget _buildInteractiveDynamicCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dynamic Dropdown (Interactive)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Add/remove items to see behavior change. Single item = non-interactive, multiple items = normal dropdown',
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
                TextOnlyDropdownButton(
                  items: stylePresets.map((s) => s.name).toList(),
                  value: dynamicStyle,
                  hint: 'Select style',
                  width: 180,
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
                  onChanged: (value) => setState(() => dynamicStyle = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Item count indicator
            Row(
              children: [
                Icon(Icons.list, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Current items: ${dynamicItems.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: dynamicItems.length == 1
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dynamicItems.length == 1
                        ? 'Non-interactive'
                        : 'Interactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: dynamicItems.length == 1
                          ? Colors.orange.shade900
                          : Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Add/Delete controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dynamicItemController,
                    decoration: InputDecoration(
                      hintText: 'Enter item text (or leave empty for default)',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onSubmitted: (_) => _addDynamicItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addDynamicItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: dynamicItems.isNotEmpty
                      ? _deleteDynamicItem
                      : null,
                  icon: const Icon(Icons.remove, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Current items list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dynamicItems.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Demo dropdown
            Builder(
              builder: (context) => DynamicTextBaseDropdownButton(
                items: dynamicItems,
                value: dynamicValue,
                hint: 'Select option',
                maxWidth: MediaQuery.of(context).size.width * 0.45,
                theme: _getTheme(dynamicStyle),
                config: const TextDropdownConfig(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // Same icon for all items
                leading: const Icon(Icons.circle, size: 16, color: Colors.grey),
                // Different color for selected item
                selectedLeading: const Icon(
                  Icons.circle,
                  size: 16,
                  color: Colors.blue,
                ),
                leadingPadding: const EdgeInsets.only(right: 8.0),
                // Custom trailing widget (rotates on multi-item, static on single-item)
                trailing: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                ),
                onChanged: (value) => setState(() => dynamicValue = value),
              ),
            ),
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
