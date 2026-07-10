import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// A domain type. Not a String, and it does not override `==`.
class Country {
  const Country(this.code, this.name, this.flag);

  final String code;
  final String name;
  final String flag;
}

const _countries = <Country>[
  Country('KR', 'South Korea', '🇰🇷'),
  Country('JP', 'Japan', '🇯🇵'),
  Country('US', 'United States', '🇺🇸'),
  Country('DE', 'Germany', '🇩🇪'),
  Country('FR', 'France', '🇫🇷'),
  Country('BR', 'Brazil', '🇧🇷'),
  Country('ZA', 'South Africa', '🇿🇦'),
  Country('AU', 'Australia', '🇦🇺'),
];

/// Shows the two features added in 2.4.0:
///
/// * `label` — text mode renders any `T`, keeping tooltips and search.
/// * `DropdownOverlayController` — build your own dropdown by holding one.
class DomainTypePage extends StatefulWidget {
  const DomainTypePage({super.key});

  @override
  State<DomainTypePage> createState() => _DomainTypePageState();
}

class _DomainTypePageState extends State<DomainTypePage> {
  Country? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Domain Types & Controller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text mode with a label extractor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Country is not a String. A label callback is all it takes — '
              'overflow handling, the tooltip and the search filter all follow.',
            ),
            const SizedBox(height: 16),
            FlutterDropdownButton<Country>.text(
              width: 280,
              items: _countries,
              value: _selected,
              label: (country) => '${country.flag}  ${country.name}',
              hint: 'Select a country',
              searchable: true, // filters by label; no searchFilter needed
              onChanged: (country) => setState(() => _selected = country),
            ),
            const SizedBox(height: 12),
            Text(
              _selected == null
                  ? 'Nothing selected'
                  : 'Selected: ${_selected!.code}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 40),
            const Text(
              'A dropdown built on DropdownOverlayController',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'The controller is the extension point. Hold one; the package\'s '
              'own dropdown holds the same object.',
            ),
            const SizedBox(height: 16),
            const _ColourMenuButton(),
          ],
        ),
      ),
    );
  }
}

/// A minimal custom dropdown. It owns a [DropdownOverlayController] rather
/// than inheriting from anything, and supplies a fresh spec on every build of
/// the overlay so the menu re-measures itself.
class _ColourMenuButton extends StatefulWidget {
  const _ColourMenuButton();

  @override
  State<_ColourMenuButton> createState() => _ColourMenuButtonState();
}

class _ColourMenuButtonState extends State<_ColourMenuButton>
    with SingleTickerProviderStateMixin {
  static const _colours = <String, Color>{
    'Crimson': Color(0xFFDC143C),
    'Teal': Color(0xFF008080),
    'Amber': Color(0xFFFFBF00),
    'Indigo': Color(0xFF4B0082),
  };

  String _selected = 'Teal';

  late final DropdownOverlayController _menu = DropdownOverlayController(
    vsync: this,
    spec:
        () => DropdownOverlaySpec(
          itemCount: _colours.length,
          actualItemHeight: 44,
          maxDropdownHeight: 200,
          borderThickness: 2,
        ),
    contentBuilder: _buildMenu,
    decorationBuilder:
        () => BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
    onOpenStateChanged: (_) => setState(() {}),
  );

  @override
  void dispose() {
    _menu.dispose();
    super.dispose();
  }

  Widget _buildMenu(double height) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in _colours.entries)
          InkWell(
            onTap: () {
              setState(() => _selected = entry.key);
              _menu.close();
            },
            child: SizedBox(
              height: 44,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  CircleAvatar(backgroundColor: entry.value, radius: 8),
                  const SizedBox(width: 12),
                  Text(entry.key),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: _menu.buttonKey,
          onTap: () => _menu.toggle(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: _colours[_selected], radius: 8),
                const SizedBox(width: 12),
                Expanded(child: Text(_selected)),
                RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(
                    CurvedAnimation(
                      parent: _menu.animation,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
