import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

enum DropdownType { text, custom }

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  // ── Dropdown type ───────────────────────────────────────────────────────
  DropdownType _type = DropdownType.text;

  // ── Items ───────────────────────────────────────────────────────────────
  List<String> _items = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];
  String? _selectedValue;
  final _itemController = TextEditingController();
  int _itemCounter = 4;

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

  // ── FlutterDropdownButton (common) ──────────────────────────────────────
  double _height = 200;
  double _itemHeight = 48;
  bool _enabled = true;
  bool _scrollToSelected = true;
  int _animationMs = 200;
  bool _useCustomTrailing = false;
  double _trailingSize = 20;
  MenuAlignment _menuAlignment = MenuAlignment.left;
  double? _minMenuWidth;
  double? _maxMenuWidth;

  // ── TextDropdownButton specific ─────────────────────────────────────────
  double? _fixedWidth = 250;
  String _hint = 'Select an option';
  bool _disableWhenSingleItem = false;
  bool _hideIconWhenSingleItem = true;
  bool _showLeading = false;
  double _leadingSize = 14;
  bool _expand = false;
  double? _minWidth;
  double? _maxWidth = 300;

  // ── TextDropdownConfig ──────────────────────────────────────────────────
  TextOverflow _overflow = TextOverflow.ellipsis;
  int _cfgMaxLines = 1;
  TextAlign _textAlign = TextAlign.start;
  bool _softWrap = true;

  // ── DropdownTheme ───────────────────────────────────────────────────────
  double _dtBorderRadius = 8.0;
  double _dtElevation = 8.0;
  Color? _dtBackgroundColor;
  bool _dtBorderEnabled = false;
  Color _dtBorderColor = Colors.grey;
  double _dtBorderWidth = 1.0;
  Color? _dtSelectedItemColor = const Color(0x1A6750A4);
  Color? _dtItemHoverColor = const Color(0x0A6750A4);
  Color? _dtItemSplashColor;
  Color? _dtButtonHoverColor;
  double _dtItemPaddingH = 16;
  double _dtItemPaddingV = 12;
  double _dtButtonPaddingH = 16;
  double _dtButtonPaddingV = 12;
  bool _dtItemMarginEnabled = false;
  double _dtItemMarginH = 8;
  double _dtItemMarginV = 4;
  double? _dtItemBorderRadius;
  Color? _dtIconColor;
  Color? _dtIconDisabledColor;
  IconData? _dtIcon;
  double? _dtIconSize;
  double? _dtButtonHeight;
  double? _dtIconPaddingLeft;
  bool _dtOverlayPaddingEnabled = false;
  double _dtOverlayPaddingH = 0;
  double _dtOverlayPaddingV = 4;
  bool _dtItemBorderEnabled = false;
  Color _dtItemBorderColor = Colors.grey;
  double _dtItemBorderWidth = 1.0;
  bool _dtExcludeLastItemBorder = true;

  // ── DropdownScrollTheme ─────────────────────────────────────────────────
  bool _dstEnabled = false;
  double? _dstThumbWidth;
  double? _dstTrackWidth;
  double? _dstRadius;
  Color? _dstThumbColor;
  Color? _dstTrackColor;
  Color? _dstTrackBorderColor;
  bool _dstThumbVisibility = false;
  bool _dstTrackVisibility = false;
  bool _dstInteractive = false;
  bool _dstShowScrollGradient = false;
  double _dstGradientHeight = 24.0;

  // ── DropdownTooltipTheme ────────────────────────────────────────────────
  bool _dttEnabled = true;
  TooltipMode _dttMode = TooltipMode.onlyWhenOverflow;
  int _dttWaitMs = 500;
  int _dttShowMs = 3000;
  Color? _dttBackgroundColor;
  Color? _dttTextColor;

  // ── Color palette ───────────────────────────────────────────────────────
  static final _solidColors = <Color?>[
    null,
    Colors.white,
    Colors.grey.shade50,
    Colors.grey.shade100,
    Colors.grey.shade200,
    Colors.grey.shade400,
    Colors.grey,
    Colors.blueGrey.shade900,
    Colors.black,
    Colors.blue.shade50,
    Colors.blue.shade100,
    Colors.blue,
    Colors.lightBlue,
    Colors.indigo,
    Colors.purple.shade50,
    Colors.purple,
    Colors.deepPurple,
    Colors.green.shade50,
    Colors.green,
    Colors.teal,
    Colors.orange.shade50,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
  ];

  static const _overlayColors = <Color?>[
    Color(0x0A6750A4),
    Color(0x1A6750A4),
    Color(0x406750A4),
    Color(0x0A2196F3),
    Color(0x1A2196F3),
    Color(0x402196F3),
    Color(0x0A4CAF50),
    Color(0x1A4CAF50),
    Color(0x0AFF5722),
    Color(0x1AFF5722),
    Color(0x1A673AB7),
    Color(0x401976D2),
    Color(0x20E0E0E0),
    Color(0x40E0E0E0),
    Color(0x10000000),
    Color(0x20000000),
    Color(0x20FFFFFF),
    Color(0x40FFFFFF),
    Color(0x60FFFFFF),
  ];

  static const _iconOptions = <IconData?>[
    null,
    Icons.keyboard_arrow_down,
    Icons.arrow_drop_down,
    Icons.expand_more,
    Icons.arrow_downward,
    Icons.unfold_more,
    Icons.chevron_right,
  ];

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  // ── Theme builders ──────────────────────────────────────────────────────
  DropdownStyleTheme _buildStyleTheme() {
    return DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: _dtBorderRadius,
        elevation: _dtElevation,
        backgroundColor: _dtBackgroundColor,
        border: _dtBorderEnabled
            ? Border.all(color: _dtBorderColor, width: _dtBorderWidth)
            : null,
        selectedItemColor: _dtSelectedItemColor,
        itemHoverColor: _dtItemHoverColor,
        itemSplashColor: _dtItemSplashColor,
        buttonHoverColor: _dtButtonHoverColor,
        itemPadding: EdgeInsets.symmetric(
          horizontal: _dtItemPaddingH,
          vertical: _dtItemPaddingV,
        ),
        buttonPadding: EdgeInsets.symmetric(
          horizontal: _dtButtonPaddingH,
          vertical: _dtButtonPaddingV,
        ),
        itemMargin: _dtItemMarginEnabled
            ? EdgeInsets.symmetric(
                horizontal: _dtItemMarginH,
                vertical: _dtItemMarginV,
              )
            : null,
        itemBorderRadius: _dtItemBorderRadius,
        iconColor: _dtIconColor,
        iconDisabledColor: _dtIconDisabledColor,
        icon: _dtIcon,
        iconSize: _dtIconSize,
        buttonHeight: _dtButtonHeight,
        iconPadding: _dtIconPaddingLeft != null
            ? EdgeInsets.only(left: _dtIconPaddingLeft!)
            : null,
        overlayPadding: _dtOverlayPaddingEnabled
            ? EdgeInsets.symmetric(
                horizontal: _dtOverlayPaddingH,
                vertical: _dtOverlayPaddingV,
              )
            : null,
        itemBorder: _dtItemBorderEnabled
            ? Border(
                bottom: BorderSide(
                  color: _dtItemBorderColor,
                  width: _dtItemBorderWidth,
                ),
              )
            : null,
        excludeLastItemBorder: _dtExcludeLastItemBorder,
      ),
      scroll: _dstEnabled
          ? DropdownScrollTheme(
              thumbWidth: _dstThumbWidth,
              trackWidth: _dstTrackWidth,
              radius: _dstRadius != null ? Radius.circular(_dstRadius!) : null,
              thumbColor: _dstThumbColor,
              trackColor: _dstTrackColor,
              trackBorderColor: _dstTrackBorderColor,
              thumbVisibility: _dstThumbVisibility,
              trackVisibility: _dstTrackVisibility,
              interactive: _dstInteractive,
              showScrollGradient: _dstShowScrollGradient,
              gradientHeight: _dstGradientHeight,
            )
          : const DropdownScrollTheme(),
      tooltip: DropdownTooltipTheme(
        enabled: _dttEnabled,
        mode: _dttMode,
        waitDuration: Duration(milliseconds: _dttWaitMs),
        showDuration: Duration(milliseconds: _dttShowMs),
        backgroundColor: _dttBackgroundColor,
        textColor: _dttTextColor,
      ),
    );
  }

  TextDropdownConfig _buildTextConfig() {
    return TextDropdownConfig(
      overflow: _overflow,
      maxLines: _cfgMaxLines,
      textAlign: _textAlign,
      softWrap: _softWrap,
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────
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
            onPressed: () => Navigator.pushNamed(context, '/dropdown-bug-test'),
          ),
        ],
      ),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 420, child: _buildSettingsPanel()),
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

  // ── Settings Panel ──────────────────────────────────────────────────────
  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildItemsSection(),
          _buildDropdownButtonSection(),
          if (_type == DropdownType.text) _buildTextDropdownButtonSection(),
          if (_type == DropdownType.text) _buildTextDropdownConfigSection(),
          _buildDropdownThemeSection(),
          _buildScrollThemeSection(),
          _buildTooltipThemeSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Section: Items ──────────────────────────────────────────────────────
  Widget _buildItemsSection() {
    return ExpansionTile(
      title: const Text(
        'Items',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: true,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        Wrap(
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
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _itemController,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  hintText: 'New item (or leave empty for auto)',
                  hintStyle: TextStyle(fontSize: 11),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addItem(),
              ),
            ),
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
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: _items.map((item) {
            final isSelected = item == _selectedValue;
            return Chip(
              label: Text(
                item.length > 20 ? '${item.substring(0, 20)}…' : item,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
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
        ),
      ],
    );
  }

  // ── Section: FlutterDropdownButton ──────────────────────────────────────
  Widget _buildDropdownButtonSection() {
    return ExpansionTile(
      title: const Text(
        'FlutterDropdownButton',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: true,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              const SizedBox(
                width: 100,
                child: Text('type', style: TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: SegmentedButton<DropdownType>(
                  segments: const [
                    ButtonSegment(
                      value: DropdownType.text,
                      label: Text('text'),
                    ),
                    ButtonSegment(
                      value: DropdownType.custom,
                      label: Text('custom'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (v) => setState(() {
                    _type = v.first;
                    _selectedValue = null;
                  }),
                ),
              ),
            ],
          ),
        ),
        _sliderRow(
          'height',
          _height,
          100,
          400,
          (v) => setState(() => _height = v),
        ),
        _sliderRow(
          'itemHeight',
          _itemHeight,
          24,
          80,
          (v) => setState(() => _itemHeight = v),
        ),
        _sliderRow(
          'animationDuration (ms)',
          _animationMs.toDouble(),
          0,
          600,
          (v) => setState(() => _animationMs = v.round()),
          divisions: 12,
        ),
        _switchRow('enabled', _enabled, (v) => setState(() => _enabled = v)),
        _switchRow(
          'scrollToSelectedItem',
          _scrollToSelected,
          (v) => setState(() => _scrollToSelected = v),
        ),
        Padding(
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
                    ButtonSegment(
                      value: MenuAlignment.center,
                      label: Text('C'),
                    ),
                    ButtonSegment(
                      value: MenuAlignment.right,
                      label: Text('R'),
                    ),
                  ],
                  selected: {_menuAlignment},
                  onSelectionChanged: (v) =>
                      setState(() => _menuAlignment = v.first),
                ),
              ),
            ],
          ),
        ),
        _optionalSliderRow(
          'minMenuWidth',
          _minMenuWidth,
          50,
          400,
          (v) => setState(() => _minMenuWidth = v),
          enableDefault: 200,
        ),
        _optionalSliderRow(
          'maxMenuWidth',
          _maxMenuWidth,
          50,
          500,
          (v) => setState(() => _maxMenuWidth = v),
          enableDefault: 300,
        ),
        _switchRow(
          'customTrailing',
          _useCustomTrailing,
          (v) => setState(() => _useCustomTrailing = v),
        ),
        if (_useCustomTrailing)
          _sliderRow(
            'trailingSize',
            _trailingSize,
            10,
            40,
            (v) => setState(() => _trailingSize = v),
          ),
      ],
    );
  }

  // ── Section: TextDropdownButton ─────────────────────────────────────────
  Widget _buildTextDropdownButtonSection() {
    return ExpansionTile(
      title: const Text(
        'TextDropdownButton',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        _optionalSliderRow(
          'width (fixed)',
          _fixedWidth,
          50,
          500,
          (v) => setState(() => _fixedWidth = v),
          enableDefault: 250,
        ),
        _optionalSliderRow(
          'minWidth',
          _minWidth,
          50,
          400,
          (v) => setState(() => _minWidth = v),
          enableDefault: 150,
        ),
        _optionalSliderRow(
          'maxWidth',
          _maxWidth,
          50,
          500,
          (v) => setState(() => _maxWidth = v),
          enableDefault: 300,
        ),
        _switchRow('expand', _expand, (v) => setState(() => _expand = v)),
        _switchRow(
          'disableWhenSingleItem',
          _disableWhenSingleItem,
          (v) => setState(() => _disableWhenSingleItem = v),
        ),
        _switchRow(
          'hideIconWhenSingleItem',
          _hideIconWhenSingleItem,
          (v) => setState(() => _hideIconWhenSingleItem = v),
        ),
        _switchRow(
          'leading icon',
          _showLeading,
          (v) => setState(() => _showLeading = v),
        ),
        if (_showLeading)
          _sliderRow(
            'leadingSize',
            _leadingSize,
            8,
            32,
            (v) => setState(() => _leadingSize = v),
          ),
        Padding(
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _hint = v,
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section: TextDropdownConfig ─────────────────────────────────────────
  Widget _buildTextDropdownConfigSection() {
    return ExpansionTile(
      title: const Text(
        'TextDropdownConfig',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        Padding(
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
                    ButtonSegment(
                      value: TextOverflow.ellipsis,
                      label: Text('...'),
                    ),
                    ButtonSegment(
                      value: TextOverflow.fade,
                      label: Text('fade'),
                    ),
                    ButtonSegment(
                      value: TextOverflow.clip,
                      label: Text('clip'),
                    ),
                    ButtonSegment(
                      value: TextOverflow.visible,
                      label: Text('vis'),
                    ),
                  ],
                  selected: {_overflow},
                  onSelectionChanged: (v) =>
                      setState(() => _overflow = v.first),
                ),
              ),
            ],
          ),
        ),
        _sliderRow(
          'maxLines',
          _cfgMaxLines.toDouble(),
          1,
          5,
          (v) => setState(() => _cfgMaxLines = v.round()),
          divisions: 4,
        ),
        Padding(
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
                    ButtonSegment(
                      value: TextAlign.start,
                      label: Text('start'),
                    ),
                    ButtonSegment(
                      value: TextAlign.center,
                      label: Text('center'),
                    ),
                    ButtonSegment(
                      value: TextAlign.end,
                      label: Text('end'),
                    ),
                  ],
                  selected: {_textAlign},
                  onSelectionChanged: (v) =>
                      setState(() => _textAlign = v.first),
                ),
              ),
            ],
          ),
        ),
        _switchRow(
          'softWrap',
          _softWrap,
          (v) => setState(() => _softWrap = v),
        ),
      ],
    );
  }

  // ── Section: DropdownTheme ──────────────────────────────────────────────
  Widget _buildDropdownThemeSection() {
    return ExpansionTile(
      title: const Text(
        'DropdownTheme',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        _sliderRow(
          'borderRadius',
          _dtBorderRadius,
          0,
          32,
          (v) => setState(() => _dtBorderRadius = v),
        ),
        _sliderRow(
          'elevation',
          _dtElevation,
          0,
          24,
          (v) => setState(() => _dtElevation = v),
        ),
        _colorRow(
          'backgroundColor',
          _dtBackgroundColor,
          (c) => setState(() => _dtBackgroundColor = c),
        ),
        const _SubSectionLabel('Border'),
        _switchRow(
          'border',
          _dtBorderEnabled,
          (v) => setState(() => _dtBorderEnabled = v),
        ),
        if (_dtBorderEnabled) ...[
          _colorRow(
            '  borderColor',
            _dtBorderColor,
            (c) => setState(() => _dtBorderColor = c ?? Colors.grey),
            solidOnly: true,
          ),
          _sliderRow(
            '  borderWidth',
            _dtBorderWidth,
            0.5,
            8,
            (v) => setState(() => _dtBorderWidth = v),
            divisions: 15,
          ),
        ],
        const _SubSectionLabel('Item Colors'),
        _colorRow(
          'selectedItemColor',
          _dtSelectedItemColor,
          (c) => setState(() => _dtSelectedItemColor = c),
          solidOnly: false,
        ),
        _colorRow(
          'itemHoverColor',
          _dtItemHoverColor,
          (c) => setState(() => _dtItemHoverColor = c),
          solidOnly: false,
        ),
        _colorRow(
          'itemSplashColor',
          _dtItemSplashColor,
          (c) => setState(() => _dtItemSplashColor = c),
          solidOnly: false,
        ),
        _colorRow(
          'buttonHoverColor',
          _dtButtonHoverColor,
          (c) => setState(() => _dtButtonHoverColor = c),
          solidOnly: false,
        ),
        const _SubSectionLabel('Padding'),
        _sliderRow(
          'itemPadding H',
          _dtItemPaddingH,
          0,
          32,
          (v) => setState(() => _dtItemPaddingH = v),
        ),
        _sliderRow(
          'itemPadding V',
          _dtItemPaddingV,
          0,
          32,
          (v) => setState(() => _dtItemPaddingV = v),
        ),
        _sliderRow(
          'buttonPadding H',
          _dtButtonPaddingH,
          0,
          32,
          (v) => setState(() => _dtButtonPaddingH = v),
        ),
        _sliderRow(
          'buttonPadding V',
          _dtButtonPaddingV,
          0,
          32,
          (v) => setState(() => _dtButtonPaddingV = v),
        ),
        const _SubSectionLabel('Item Margin & Radius'),
        _switchRow(
          'itemMargin',
          _dtItemMarginEnabled,
          (v) => setState(() => _dtItemMarginEnabled = v),
        ),
        if (_dtItemMarginEnabled) ...[
          _sliderRow(
            '  itemMargin H',
            _dtItemMarginH,
            0,
            24,
            (v) => setState(() => _dtItemMarginH = v),
          ),
          _sliderRow(
            '  itemMargin V',
            _dtItemMarginV,
            0,
            24,
            (v) => setState(() => _dtItemMarginV = v),
          ),
        ],
        _optionalSliderRow(
          'itemBorderRadius',
          _dtItemBorderRadius,
          0,
          24,
          (v) => setState(() => _dtItemBorderRadius = v),
          enableDefault: 8,
        ),
        const _SubSectionLabel('Icon'),
        _colorRow(
          'iconColor',
          _dtIconColor,
          (c) => setState(() => _dtIconColor = c),
        ),
        _colorRow(
          'iconDisabledColor',
          _dtIconDisabledColor,
          (c) => setState(() => _dtIconDisabledColor = c),
        ),
        _iconSelectorRow('icon', _dtIcon, (i) => setState(() => _dtIcon = i)),
        _optionalSliderRow(
          'iconSize',
          _dtIconSize,
          12,
          48,
          (v) => setState(() => _dtIconSize = v),
          enableDefault: 24,
        ),
        _optionalSliderRow(
          'buttonHeight',
          _dtButtonHeight,
          16,
          64,
          (v) => setState(() => _dtButtonHeight = v),
          enableDefault: 24,
        ),
        _optionalSliderRow(
          'iconPaddingLeft',
          _dtIconPaddingLeft,
          0,
          32,
          (v) => setState(() => _dtIconPaddingLeft = v),
          enableDefault: 8,
        ),
        const _SubSectionLabel('Overlay Padding'),
        _switchRow(
          'overlayPadding',
          _dtOverlayPaddingEnabled,
          (v) => setState(() => _dtOverlayPaddingEnabled = v),
        ),
        if (_dtOverlayPaddingEnabled) ...[
          _sliderRow(
            '  overlayPadding H',
            _dtOverlayPaddingH,
            0,
            24,
            (v) => setState(() => _dtOverlayPaddingH = v),
          ),
          _sliderRow(
            '  overlayPadding V',
            _dtOverlayPaddingV,
            0,
            24,
            (v) => setState(() => _dtOverlayPaddingV = v),
          ),
        ],
        const _SubSectionLabel('Item Border'),
        _switchRow(
          'itemBorder (bottom)',
          _dtItemBorderEnabled,
          (v) => setState(() => _dtItemBorderEnabled = v),
        ),
        if (_dtItemBorderEnabled) ...[
          _colorRow(
            '  itemBorderColor',
            _dtItemBorderColor,
            (c) => setState(() => _dtItemBorderColor = c ?? Colors.grey),
            solidOnly: true,
          ),
          _sliderRow(
            '  itemBorderWidth',
            _dtItemBorderWidth,
            0.5,
            4,
            (v) => setState(() => _dtItemBorderWidth = v),
            divisions: 7,
          ),
          _switchRow(
            '  excludeLastItemBorder',
            _dtExcludeLastItemBorder,
            (v) => setState(() => _dtExcludeLastItemBorder = v),
          ),
        ],
      ],
    );
  }

  // ── Section: DropdownScrollTheme ────────────────────────────────────────
  Widget _buildScrollThemeSection() {
    return ExpansionTile(
      title: const Text(
        'DropdownScrollTheme',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        _switchRow(
          'enable custom scroll',
          _dstEnabled,
          (v) => setState(() => _dstEnabled = v),
        ),
        if (_dstEnabled) ...[
          const _SubSectionLabel('Size'),
          _optionalSliderRow(
            'thumbWidth',
            _dstThumbWidth,
            2,
            20,
            (v) => setState(() => _dstThumbWidth = v),
            enableDefault: 8,
          ),
          _optionalSliderRow(
            'trackWidth',
            _dstTrackWidth,
            2,
            20,
            (v) => setState(() => _dstTrackWidth = v),
            enableDefault: 8,
          ),
          _optionalSliderRow(
            'radius',
            _dstRadius,
            0,
            10,
            (v) => setState(() => _dstRadius = v),
            enableDefault: 4,
          ),
          const _SubSectionLabel('Colors'),
          _colorRow(
            'thumbColor',
            _dstThumbColor,
            (c) => setState(() => _dstThumbColor = c),
          ),
          _colorRow(
            'trackColor',
            _dstTrackColor,
            (c) => setState(() => _dstTrackColor = c),
          ),
          _colorRow(
            'trackBorderColor',
            _dstTrackBorderColor,
            (c) => setState(() => _dstTrackBorderColor = c),
          ),
          const _SubSectionLabel('Visibility'),
          _switchRow(
            'thumbVisibility',
            _dstThumbVisibility,
            (v) => setState(() => _dstThumbVisibility = v),
          ),
          _switchRow(
            'trackVisibility',
            _dstTrackVisibility,
            (v) => setState(() => _dstTrackVisibility = v),
          ),
          _switchRow(
            'interactive',
            _dstInteractive,
            (v) => setState(() => _dstInteractive = v),
          ),
          const _SubSectionLabel('Gradient'),
          _switchRow(
            'showScrollGradient',
            _dstShowScrollGradient,
            (v) => setState(() => _dstShowScrollGradient = v),
          ),
          if (_dstShowScrollGradient)
            _sliderRow(
              'gradientHeight',
              _dstGradientHeight,
              8,
              64,
              (v) => setState(() => _dstGradientHeight = v),
            ),
        ],
      ],
    );
  }

  // ── Section: DropdownTooltipTheme ───────────────────────────────────────
  Widget _buildTooltipThemeSection() {
    return ExpansionTile(
      title: const Text(
        'DropdownTooltipTheme',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: const Text(
        'text type only',
        style: TextStyle(fontSize: 11),
      ),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        _switchRow(
          'enabled',
          _dttEnabled,
          (v) => setState(() => _dttEnabled = v),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text('mode', style: TextStyle(fontSize: 12)),
              ),
              Expanded(
                child: SegmentedButton<TooltipMode>(
                  segments: const [
                    ButtonSegment(
                      value: TooltipMode.onlyWhenOverflow,
                      label: Text(
                        'overflow',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                    ButtonSegment(
                      value: TooltipMode.always,
                      label: Text('always', style: TextStyle(fontSize: 10)),
                    ),
                    ButtonSegment(
                      value: TooltipMode.disabled,
                      label: Text('off', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                  selected: {_dttMode},
                  onSelectionChanged: (v) =>
                      setState(() => _dttMode = v.first),
                ),
              ),
            ],
          ),
        ),
        _sliderRow(
          'waitDuration (ms)',
          _dttWaitMs.toDouble(),
          0,
          2000,
          (v) => setState(() => _dttWaitMs = v.round()),
          divisions: 20,
        ),
        _sliderRow(
          'showDuration (ms)',
          _dttShowMs.toDouble(),
          500,
          10000,
          (v) => setState(() => _dttShowMs = v.round()),
          divisions: 19,
        ),
        const _SubSectionLabel('Colors'),
        _colorRow(
          'backgroundColor',
          _dttBackgroundColor,
          (c) => setState(() => _dttBackgroundColor = c),
        ),
        _colorRow(
          'textColor',
          _dttTextColor,
          (c) => setState(() => _dttTextColor = c),
        ),
      ],
    );
  }

  // ── Preview ─────────────────────────────────────────────────────────────
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
                  if (_type == DropdownType.text && _expand)
                    Row(children: [_buildDropdown()])
                  else
                    _buildDropdown(),
                  const SizedBox(height: 16),
                  Text(
                    'Selected: ${_selectedValue ?? '(none)'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items: ${_items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
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
    final theme = _buildStyleTheme();
    final config = _buildTextConfig();
    final trailing = _useCustomTrailing
        ? Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_drop_down,
              size: _trailingSize,
              color: Colors.blue.shade700,
            ),
          )
        : null;

    switch (_type) {
      case DropdownType.text:
        return FlutterDropdownButton<String>.text(
          items: _items,
          value: _selectedValue,
          hint: _hint,
          width: _fixedWidth,
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

      case DropdownType.custom:
        return FlutterDropdownButton<String>(
          items: _items,
          value: _selectedValue,
          hintWidget: const Text('Select an option'),
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
          itemBuilder: (item, isSelected) => Text(item),
          onChanged: (v) => setState(() => _selectedValue = v),
        );
    }
  }

  // ── UI Helpers ──────────────────────────────────────────────────────────
  Widget _sliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
            width: 36,
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _optionalSliderRow(
    String label,
    double? value,
    double min,
    double max,
    ValueChanged<double?> onChanged, {
    double enableDefault = 100,
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Switch(
            value: value != null,
            onChanged: (on) => onChanged(on ? enableDefault : null),
          ),
          if (value != null) ...[
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
              width: 36,
              child: Text(
                value.round().toString(),
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _colorRow(
    String label,
    Color? value,
    ValueChanged<Color?> onChange, {
    bool solidOnly = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(value, onChange, solidOnly: solidOnly),
            child: Container(
              width: 32,
              height: 22,
              decoration: BoxDecoration(
                color: value,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(3),
              ),
              child: value == null
                  ? const Center(
                      child: Text(
                        '∅',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
    Color? current,
    ValueChanged<Color?> onChange, {
    bool solidOnly = true,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Color', style: TextStyle(fontSize: 15)),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!solidOnly) ...[
                  const Text(
                    'Solid',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                ],
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _solidColors.map((c) {
                    return _colorSwatch(c, c == current, () {
                      onChange(c);
                      Navigator.pop(ctx);
                    });
                  }).toList(),
                ),
                if (!solidOnly) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Overlay (semi-transparent)',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _overlayColors.map((c) {
                      return _colorSwatch(c, c == current, () {
                        onChange(c);
                        Navigator.pop(ctx);
                      });
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _colorSwatch(Color? color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: color == null
            ? const Center(
                child: Text(
                  '∅',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : null,
      ),
    );
  }

  Widget _iconSelectorRow(
    String label,
    IconData? value,
    ValueChanged<IconData?> onChange,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _iconOptions.map((icon) {
                  final isSelected = icon == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => onChange(icon),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade50 : null,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: icon == null
                              ? const Text(
                                  'def',
                                  style: TextStyle(fontSize: 9),
                                )
                              : Icon(icon, size: 18),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
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

// ── Sub-section label ────────────────────────────────────────────────────────
class _SubSectionLabel extends StatelessWidget {
  const _SubSectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
