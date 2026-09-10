/// A checklist dropdown filtering a list — the set is yours, the rows are ours.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// One row of the fake server list the filter runs over.
class Node {
  const Node(this.name, this.os);

  final String name;
  final String os;
}

/// An icon per value. This is why `itemLeadingBuilder` is a builder and not a
/// single widget: every row wants a different one.
const _osIcon = <String, IconData>{
  'Windows Active Directory': Icons.window,
  'Linux': Icons.terminal,
  'macOS': Icons.laptop_mac,
  'Solaris': Icons.wb_sunny_outlined,
  'AIX': Icons.dns_outlined,
  'FreeBSD': Icons.memory,
  'OpenBSD': Icons.shield_outlined,
  'Plan 9': Icons.science_outlined,
  'Haiku': Icons.eco_outlined,
};

const _allNodes = <Node>[
  Node('web-01', 'Windows Active Directory'),
  Node('web-02', 'Windows Active Directory'),
  Node('db-01', 'Linux'),
  Node('db-02', 'Linux'),
  Node('db-03', 'Linux'),
  Node('build-01', 'macOS'),
  Node('legacy-01', 'Solaris'),
  Node('mainframe-01', 'AIX'),
  Node('edge-01', 'FreeBSD'),
  Node('edge-02', 'OpenBSD'),
  Node('lab-01', 'Plan 9'),
  Node('lab-02', 'Haiku'),
];

/// The case `FlutterMultiSelectDropdown` was built for: a narrow panel filtering
/// a list by a field whose values are finite and discovered at runtime, several
/// values ORed together, applied the instant they are ticked.
///
/// Two things here that a screenshot cannot show:
///
///  * **Long values do not break the layout.** `Windows Active Directory` would
///    eat a whole row as a chip. As a list row it ellipsises, with the full
///    string in a tooltip.
///  * **A chosen value may disappear from `items`.** Tick *Solaris*, then turn
///    on `solarisDropped`: the row goes, the choice stays, and the face still
///    counts it. Nothing throws and no row is invented — because the set is not
///    the dropdown's to prune. `selected` belongs to you.
///
/// The OR semantics below are the caller's too. The widget has none of its own.
class MultiSelectRecipe extends StatefulWidget {
  const MultiSelectRecipe({
    super.key,
    this.searchable = true,
    this.solarisDropped = false,
  });

  /// Whether the menu carries a search field.
  final bool searchable;

  /// Removes Solaris from the data, so a ticked value can be watched surviving
  /// the disappearance of its rows.
  final bool solarisDropped;

  @override
  State<MultiSelectRecipe> createState() => _MultiSelectRecipeState();
}

class _MultiSelectRecipeState extends State<MultiSelectRecipe> {
  Set<String> _chosen = {};

  List<Node> get _nodes => widget.solarisDropped
      ? _allNodes.where((n) => n.os != 'Solaris').toList()
      : _allNodes;

  /// Values, and how many nodes carry each, come from the data.
  Map<String, int> get _counts {
    final counts = <String, int>{};
    for (final node in _nodes) {
      counts[node.os] = (counts[node.os] ?? 0) + 1;
    }
    return counts;
  }

  List<Node> get _filtered => _chosen.isEmpty
      ? _nodes
      : _nodes.where((n) => _chosen.contains(n.os)).toList();

  @override
  Widget build(BuildContext context) {
    final counts = _counts;
    final values = counts.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operating system',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          FlutterMultiSelectDropdown<String>(
            // A width, not `expand`. `expand` is implemented as `Expanded`, so
            // it fills the *main* axis of the Flex it is in — inside this
            // `Column` that is the vertical one, and the button becomes a tall
            // empty box with its label floating in the middle. Reach for it in
            // a `Row`, or wrap the dropdown in one.
            //
            // This does **not** fully explain what is on screen: the button is
            // still drawn far taller and wider than 318 asks for. Left here,
            // unexplained and reproducible, rather than bisected away — see
            // the issue.
            width: 318,
            height: 260,
            items: values,
            selected: _chosen,
            searchable: widget.searchable,
            labelBuilder: (s) => switch (s.length) {
              0 => 'All operating systems',
              1 => s.first,
              _ => '${s.length} selected',
            },
            // The row checkbox, scoped to this dropdown. An app-wide
            // `CheckboxThemeData` is the only ambient way to reach a box drawn
            // in the root overlay, and it would restyle every checkbox in the
            // app.
            theme: const DropdownStyleTheme(
              checkbox: DropdownCheckboxTheme(
                activeColor: Colors.indigo,
                checkColor: Colors.white,
                shape: CheckboxShape.rectangle,
                borderRadius: 4,
                mouseCursor: SystemMouseCursors.click,
              ),
            ),
            // An icon between the box and the label; the count after it. One
            // slot could not have held both on the right sides.
            itemLeadingBuilder: (v) =>
                Icon(_osIcon[v] ?? Icons.help_outline, size: 18),
            itemTrailingBuilder: (v) => Text(
              '${counts[v]}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            onChanged: (next) => setState(() => _chosen = next),
          ),
          const SizedBox(height: 12),
          if (_chosen.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final value in _chosen)
                  InputChip(
                    label: Text(value, overflow: TextOverflow.ellipsis),
                    // A value with no rows left still has an exit.
                    avatar: counts.containsKey(value)
                        ? null
                        : const Icon(Icons.warning_amber, size: 16),
                    onDeleted: () =>
                        setState(() => _chosen = {..._chosen}..remove(value)),
                  ),
              ],
            ),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              children: [
                for (final node in _filtered)
                  ListTile(
                    dense: true,
                    leading: Icon(_osIcon[node.os] ?? Icons.help_outline),
                    title: Text(node.name),
                    subtitle: Text(node.os, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
