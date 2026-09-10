/// How an open menu goes away — and the three ways that are not a tap on it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// Three dismissal behaviours, none of which is named by any parameter.
///
/// That is why this file exists rather than a knob: there is nothing to set.
/// The behaviour is the widget's, it is documented, and until now nothing
/// demonstrated it — which also means the API-coverage gate cannot see it
/// regress, because a gate that counts named arguments has nothing to count
/// here.
///
/// **Tap the other dropdown while this one is open.** One tap, not two. A
/// dismiss barrier sits over the app while a menu is open, and a barrier that
/// merely swallowed the tap would make every switch between neighbours cost two
/// — so the first dropdown closes *and* the second opens, from the one tap that
/// landed on it. (ADR 0002 is where that behaviour and its arena participation
/// are recorded.)
///
/// **Scroll the page with a menu open.** The menu is positioned against its
/// button, and the button is moving. It follows rather than hanging where it
/// was opened — a menu anchored to nothing over content that has slid out from
/// under it is the shape #103 fixed.
///
/// **Use the keyboard.** Arrow keys move through the rows, Enter chooses,
/// Escape closes. None of that is a parameter either.
class DismissalRecipe extends StatelessWidget {
  const DismissalRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Tap one, then tap the other — in one tap.',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _Neighbour(hint: 'Left', items: _left),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _Neighbour(hint: 'Right', items: _right),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Now open one and scroll this list. The menu follows its button.',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        const _Neighbour(hint: 'Scroll me', items: _left),
        // Enough room below to make scrolling possible at any viewport.
        const SizedBox(height: 900),
        const Center(child: Text('— bottom —')),
      ],
    );
  }
}

const _left = ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo'];
const _right = ['One', 'Two', 'Three', 'Four', 'Five'];

class _Neighbour extends StatefulWidget {
  const _Neighbour({required this.hint, required this.items});

  final String hint;
  final List<String> items;

  @override
  State<_Neighbour> createState() => _NeighbourState();
}

class _NeighbourState extends State<_Neighbour> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return FlutterDropdownButton<String>.text(
      expand: true,
      items: widget.items,
      value: _value,
      hint: widget.hint,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
