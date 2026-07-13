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

/// The case `FlutterMultiSelectDropdown` was built for: a narrow side panel
/// filtering a list by a field whose values are finite and discovered at
/// runtime, several values ORed together, applied the instant they are ticked.
///
/// Two things this page exists to show, because neither is visible in a
/// screenshot:
///
///  * **Long values do not break the layout.** `Windows Active Directory` would
///    eat a whole row as a chip. As a list row it ellipsises, with the full
///    string in a tooltip.
///  * **A chosen value may disappear from `items`.** Press *Drop Solaris* while
///    it is ticked. Nothing throws, no row is invented, the choice is not
///    silently discarded — and the face still counts it.
class MultiSelectPage extends StatefulWidget {
  const MultiSelectPage({super.key});

  @override
  State<MultiSelectPage> createState() => _MultiSelectPageState();
}

class _MultiSelectPageState extends State<MultiSelectPage> {
  Set<String> _chosen = {};
  bool _solarisGone = false;
  bool _searchable = true;

  List<Node> get _nodes => _solarisGone
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

  /// OR semantics. The widget has none of its own.
  List<Node> get _filtered => _chosen.isEmpty
      ? _nodes
      : _nodes.where((n) => _chosen.contains(n.os)).toList();

  @override
  Widget build(BuildContext context) {
    final counts = _counts;
    final values = counts.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Select Filter')),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 350,
            child: Padding(
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
                    width: 318,
                    height: 260,
                    items: values,
                    selected: _chosen,
                    searchable: _searchable,
                    labelBuilder: (s) => switch (s.length) {
                      0 => 'All operating systems',
                      1 => s.first,
                      _ => '${s.length} selected',
                    },
                    // The row checkbox, scoped to this dropdown — an app-wide
                    // CheckboxThemeData would be the only ambient way to reach a
                    // box drawn in the root overlay, and it would restyle every
                    // checkbox in the app. `click` matches the box's cursor to
                    // the row's.
                    theme: const DropdownStyleTheme(
                      checkbox: DropdownCheckboxTheme(
                        activeColor: Colors.indigo,
                        checkColor: Colors.white,
                        shape: CheckboxShape.rectangle,
                        borderRadius: 4,
                        mouseCursor: SystemMouseCursors.click,
                      ),
                    ),
                    // An icon between the box and the label; the count after
                    // it. One slot could not have held both on the right sides.
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
                            onDeleted: () => setState(
                              () => _chosen = {..._chosen}..remove(value),
                            ),
                          ),
                      ],
                    ),
                  const Divider(height: 32),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('searchable'),
                    value: _searchable,
                    onChanged: (v) => setState(() => _searchable = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Drop Solaris from the data'),
                    subtitle: const Text(
                      'Tick Solaris first, then flip this: the row goes, the '
                      'choice stays, the count still includes it.',
                    ),
                    value: _solarisGone,
                    onChanged: (v) => setState(() => _solarisGone = v),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_filtered.length} of ${_nodes.length} nodes',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final node in _filtered)
                  ListTile(
                    dense: true,
                    title: Text(node.name),
                    subtitle: Text(node.os),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
