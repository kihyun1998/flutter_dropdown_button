import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

import '../data/style_presets.dart';

enum DropdownType { textOnly, dynamic, basic }

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  // --- Dropdown type ---
  DropdownType _type = DropdownType.textOnly;

  // --- Items ---
  List<String> _items = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  String? _selectedValue;
  final _itemController = TextEditingController();
  int _itemCounter = 4;

  // --- Common settings ---
  double _height = 200;
  double _itemHeight = 48;
  bool _enabled = true;
  bool _scrollToSelected = true;
  int _animationMs = 200;
  String _themeName = 'Material Design';
  bool _useCustomTrailing = false;
  double _trailingSize = 20;
  MenuAlignment _menuAlignment = MenuAlignment.left;
  double? _minMenuWidth;
  double? _maxMenuWidth;

  // --- TextOnly specific ---
  double _fixedWidth = 250;
  String _hint = 'Select an option';
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _maxLines = 1;
  TextAlign _textAlign = TextAlign.start;

  // --- Dynamic specific ---
  double? _minWidth;
  double? _maxWidth = 300;
  bool _disableWhenSingleItem = true;
  bool _hideIconWhenSingleItem = true;
  bool _showLeading = false;
  double _leadingSize = 14;
  bool _expand = false;

  // --- Item presets ---
  static const _presets = {
    'Basic (4)': ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
    'Long Text': [
      'Short',
      'Medium length text here',
      'This is a very long option that will demonstrate ellipsis overflow',
      'Another extremely long text option that might need truncation',
    ],
    'Countries (15)': [
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
    ],
    'Single Item': ['Only Option'],
  };

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  DropdownStyleTheme _getTheme() {
    return stylePresets
        .firstWhere(
          (s) => s.name == _themeName,
          orElse: () => stylePresets[0],
        )
        .theme;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dropdown Playground'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Overlay Bug Test',
            onPressed: () =>
                Navigator.pushNamed(context, '/dropdown-bug-test'),
          ),
        ],
      ),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: _buildSettingsPanel(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _buildPreview()),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSettingsPanel(),
                  const Divider(height: 1),
                  SizedBox(height: 400, child: _buildPreview()),
                ],
              ),
            ),
    );
  }

  // ──────────────────────────────────────────────
  // Settings Panel
  // ──────────────────────────────────────────────

  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Dropdown Type'),
          SegmentedButton<DropdownType>(
            segments: const [
              ButtonSegment(value: DropdownType.textOnly, label: Text('TextOnly')),
              ButtonSegment(value: DropdownType.dynamic, label: Text('Dynamic')),
              ButtonSegment(value: DropdownType.basic, label: Text('Basic')),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() {
              _type = v.first;
              _selectedValue = null;
            }),
          ),
          const SizedBox(height: 20),

          // --- Items ---
          _sectionTitle('Items'),
          _buildItemPresets(),
          const SizedBox(height: 8),
          _buildItemEditor(),
          const SizedBox(height: 8),
          _buildItemChips(),
          const SizedBox(height: 20),

          // --- Common ---
          _sectionTitle('Common Settings'),
          _sliderRow('height', _height, 100, 400,
              (v) => setState(() => _height = v)),
          _sliderRow('itemHeight', _itemHeight, 24, 80,
              (v) => setState(() => _itemHeight = v)),
          _sliderRow('animation (ms)', _animationMs.toDouble(), 0, 600,
              (v) => setState(() => _animationMs = v.round()),
              divisions: 12),
          _switchRow('enabled', _enabled,
              (v) => setState(() => _enabled = v)),
          _switchRow('scrollToSelectedItem', _scrollToSelected,
              (v) => setState(() => _scrollToSelected = v)),
          _switchRow('Custom trailing', _useCustomTrailing,
              (v) => setState(() => _useCustomTrailing = v)),
          if (_useCustomTrailing)
            _sliderRow('trailing size', _trailingSize, 10, 40,
                (v) => setState(() => _trailingSize = v)),
          const SizedBox(height: 8),
          _buildThemeSelector(),
          const SizedBox(height: 8),
          _buildMenuAlignmentSelector(),
          _buildOptionalDouble('minMenuWidth', _minMenuWidth,
              (v) => setState(() => _minMenuWidth = v)),
          _buildOptionalDouble('maxMenuWidth', _maxMenuWidth,
              (v) => setState(() => _maxMenuWidth = v)),
          const SizedBox(height: 20),

          // --- Type-specific ---
          if (_type == DropdownType.textOnly) ..._buildTextOnlySettings(),
          if (_type == DropdownType.dynamic) ..._buildDynamicSettings(),
          if (_type == DropdownType.textOnly || _type == DropdownType.dynamic)
            ..._buildTextConfigSettings(),
        ],
      ),
    );
  }

  List<Widget> _buildTextOnlySettings() {
    return [
      _sectionTitle('TextOnly Settings'),
      _sliderRow('width (required)', _fixedWidth, 80, 400,
          (v) => setState(() => _fixedWidth = v)),
      _buildHintField(),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildDynamicSettings() {
    return [
      _sectionTitle('Dynamic Settings'),
      _buildOptionalDouble('minWidth', _minWidth,
          (v) => setState(() => _minWidth = v)),
      _buildOptionalDouble('maxWidth', _maxWidth,
          (v) => setState(() => _maxWidth = v)),
      _switchRow('disableWhenSingleItem', _disableWhenSingleItem,
          (v) => setState(() => _disableWhenSingleItem = v)),
      _switchRow('hideIconWhenSingleItem', _hideIconWhenSingleItem,
          (v) => setState(() => _hideIconWhenSingleItem = v)),
      _switchRow('leading icon', _showLeading,
          (v) => setState(() => _showLeading = v)),
      if (_showLeading)
        _sliderRow('leading size', _leadingSize, 8, 32,
            (v) => setState(() => _leadingSize = v)),
      _switchRow('expand', _expand,
          (v) => setState(() => _expand = v)),
      _buildHintField(),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildTextConfigSettings() {
    return [
      _sectionTitle('TextDropdownConfig'),
      _buildOverflowSelector(),
      _sliderRow('maxLines', _maxLines.toDouble(), 1, 5,
          (v) => setState(() => _maxLines = v.round()),
          divisions: 4),
      _buildTextAlignSelector(),
      const SizedBox(height: 20),
    ];
  }

  // ──────────────────────────────────────────────
  // Preview
  // ──────────────────────────────────────────────

  Widget _buildPreview() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    _type.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_type == DropdownType.dynamic && _expand)
                    Row(children: [_buildDropdown()])
                  else
                    _buildDropdown(),
                  const SizedBox(height: 16),
                  Text(
                    'Selected: ${_selectedValue ?? '(none)'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items: ${_items.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final theme = _getTheme();
    final config = TextDropdownConfig(
      overflow: _overflow,
      maxLines: _maxLines,
      textAlign: _textAlign,
    );
    final trailing = _useCustomTrailing
        ? Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_drop_down, size: _trailingSize,
                color: Colors.blue.shade700),
          )
        : null;

    switch (_type) {
      case DropdownType.textOnly:
        return TextOnlyDropdownButton(
          items: _items,
          value: _selectedValue,
          hint: _hint,
          width: _fixedWidth,
          height: _height,
          itemHeight: _itemHeight,
          enabled: _enabled,
          scrollToSelectedItem: _scrollToSelected,
          animationDuration: Duration(milliseconds: _animationMs),
          theme: theme,
          config: config,
          trailing: trailing,
          minMenuWidth: _minMenuWidth,
          maxMenuWidth: _maxMenuWidth,
          menuAlignment: _menuAlignment,
          onChanged: (v) => setState(() => _selectedValue = v),
        );

      case DropdownType.dynamic:
        return DynamicTextBaseDropdownButton(
          items: _items,
          value: _selectedValue,
          hint: _hint,
          minWidth: _minWidth,
          maxWidth: _maxWidth,
          height: _height,
          itemHeight: _itemHeight,
          enabled: _enabled,
          scrollToSelectedItem: _scrollToSelected,
          animationDuration: Duration(milliseconds: _animationMs),
          theme: theme,
          config: config,
          trailing: trailing,
          disableWhenSingleItem: _disableWhenSingleItem,
          hideIconWhenSingleItem: _hideIconWhenSingleItem,
          expand: _expand,
          leading: _showLeading
              ? Icon(Icons.circle, size: _leadingSize, color: Colors.grey)
              : null,
          selectedLeading: _showLeading
              ? Icon(Icons.circle, size: _leadingSize, color: Colors.blue)
              : null,
          minMenuWidth: _minMenuWidth,
          maxMenuWidth: _maxMenuWidth,
          menuAlignment: _menuAlignment,
          onChanged: (v) => setState(() => _selectedValue = v),
        );

      case DropdownType.basic:
        return BasicDropdownButton<String>(
          items: _items
              .map((item) => DropdownItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          value: _selectedValue,
          hint: const Text('Select an option'),
          height: _height,
          itemHeight: _itemHeight,
          enabled: _enabled,
          scrollToSelectedItem: _scrollToSelected,
          animationDuration: Duration(milliseconds: _animationMs),
          theme: theme,
          trailing: trailing,
          minMenuWidth: _minMenuWidth,
          maxMenuWidth: _maxMenuWidth,
          menuAlignment: _menuAlignment,
          onChanged: (v) => setState(() => _selectedValue = v),
        );
    }
  }

  // ──────────────────────────────────────────────
  // UI Helpers
  // ──────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max,
      ValueChanged<double> onChanged, {int? divisions}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions ?? (max - min).round(),
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              value.round().toString(),
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildOptionalDouble(
      String label, double? value, ValueChanged<double?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Switch(
            value: value != null,
            onChanged: (on) => onChanged(on ? 200 : null),
          ),
          if (value != null)
            Expanded(
              child: Slider(
                value: value.clamp(50, 500),
                min: 50,
                max: 500,
                divisions: 45,
                label: value.round().toString(),
                onChanged: (v) => onChanged(v),
              ),
            ),
          if (value != null)
            SizedBox(
              width: 40,
              child: Text(
                value.round().toString(),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      children: [
        const SizedBox(
          width: 60,
          child: Text('Theme', style: TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: _themeName,
            isExpanded: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            items: stylePresets
                .map((s) => DropdownMenuItem(
                      value: s.name,
                      child: Text(s.name, style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _themeName = v!),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuAlignmentSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text('menuAlignment', style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: SegmentedButton<MenuAlignment>(
              segments: const [
                ButtonSegment(value: MenuAlignment.left, label: Text('L')),
                ButtonSegment(value: MenuAlignment.center, label: Text('C')),
                ButtonSegment(value: MenuAlignment.right, label: Text('R')),
              ],
              selected: {_menuAlignment},
              onSelectionChanged: (v) =>
                  setState(() => _menuAlignment = v.first),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text('overflow', style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: SegmentedButton<TextOverflow>(
              segments: const [
                ButtonSegment(value: TextOverflow.ellipsis, label: Text('...')),
                ButtonSegment(value: TextOverflow.fade, label: Text('fade')),
                ButtonSegment(value: TextOverflow.clip, label: Text('clip')),
                ButtonSegment(
                    value: TextOverflow.visible, label: Text('visible')),
              ],
              selected: {_overflow},
              onSelectionChanged: (v) => setState(() => _overflow = v.first),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextAlignSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text('textAlign', style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: SegmentedButton<TextAlign>(
              segments: const [
                ButtonSegment(value: TextAlign.start, label: Text('start')),
                ButtonSegment(value: TextAlign.center, label: Text('center')),
                ButtonSegment(value: TextAlign.end, label: Text('end')),
              ],
              selected: {_textAlign},
              onSelectionChanged: (v) => setState(() => _textAlign = v.first),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 60,
            child: Text('hint', style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: _hint),
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _hint = v,
              onSubmitted: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPresets() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _presets.entries.map((e) {
        return ActionChip(
          label: Text(e.key, style: const TextStyle(fontSize: 11)),
          onPressed: () => setState(() {
            _items = List.from(e.value);
            _selectedValue = null;
            _itemCounter = _items.length;
          }),
        );
      }).toList(),
    );
  }

  Widget _buildItemEditor() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _itemController,
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'New item (or leave empty)',
              hintStyle: TextStyle(fontSize: 11),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _addItem(),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: _addItem,
          tooltip: 'Add item',
        ),
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: _items.isNotEmpty ? _removeLastItem : null,
          tooltip: 'Remove last',
        ),
      ],
    );
  }

  Widget _buildItemChips() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: _items.map((item) {
        final isSelected = item == _selectedValue;
        return Chip(
          label: Text(
            item.length > 20 ? '${item.substring(0, 20)}...' : item,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          backgroundColor: isSelected ? Colors.blue.shade100 : null,
          deleteIcon: const Icon(Icons.close, size: 14),
          onDeleted: () => setState(() {
            _items.remove(item);
            if (_selectedValue == item) _selectedValue = null;
          }),
        );
      }).toList(),
    );
  }

  void _addItem() {
    setState(() {
      final text = _itemController.text.trim();
      if (text.isEmpty) {
        _itemCounter++;
        _items.add('Option $_itemCounter');
      } else {
        _items.add(text);
        _itemController.clear();
      }
    });
  }

  void _removeLastItem() {
    if (_items.isNotEmpty) {
      setState(() {
        final removed = _items.removeLast();
        if (_selectedValue == removed) _selectedValue = null;
      });
    }
  }
}
