import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// The case `anchorBuilder` was built for (#75): a search box with a
/// field-scope selector at its head, `[All ▾] │ search…`. The selector wants
/// this package's anchored, searchable menu, but a full dropdown *button* in
/// front of the field would nest a box inside a box.
///
/// Bare mode drops the button chrome and hands the anchor to the caller, so the
/// outer field owns the border and background and the selector contributes only
/// its label and chevron. The chevron turns off `isOpen`, the one thing the
/// builder cannot read for itself.
///
/// `positioningKey` completes the pattern (#86): a `GlobalKey` on the outer
/// field, so the menu drops below the *whole* field and matches its width,
/// instead of hanging off the tiny anchor. That is what makes `minMenuWidth`
/// unnecessary here — the menu already inherits the field's width.
class BareAnchorPage extends StatefulWidget {
  const BareAnchorPage({super.key});

  @override
  State<BareAnchorPage> createState() => _BareAnchorPageState();
}

class _BareAnchorPageState extends State<BareAnchorPage> {
  static const _fields = ['All', 'Title', 'Body', 'Author'];

  String _field = 'All';
  Set<String> _tags = {};
  final _searchController = TextEditingController();

  // One key per field, attached to the outer box and handed to its selector as
  // `positioningKey` so the menu positions against the whole field.
  final _singleFieldKey = GlobalKey();
  final _multiFieldKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bare anchor — inline in a field')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Single-select scope', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                _SearchField(
                  fieldKey: _singleFieldKey,
                  // The scope selector — no border, no background, no width.
                  scope: FlutterDropdownButton<String>.text(
                    items: _fields,
                    value: _field,
                    onChanged: (f) => setState(() => _field = f!),
                    // The menu positions against the whole field, not the tiny
                    // anchor: it drops below the field and matches its width. No
                    // `minMenuWidth` needed — that lever is only for a bare
                    // anchor left to size the menu itself.
                    positioningKey: _singleFieldKey,
                    anchorBuilder: (context, isOpen) =>
                        _AnchorFace(label: _field, isOpen: isOpen),
                  ),
                  controller: _searchController,
                ),
                const SizedBox(height: 32),
                Text('Multi-select scope', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                _SearchField(
                  fieldKey: _multiFieldKey,
                  scope: FlutterMultiSelectDropdown<String>(
                    items: const ['Title', 'Body', 'Author', 'Tags'],
                    selected: _tags,
                    onChanged: (next) => setState(() => _tags = next),
                    // The checklist menu positions against the whole field too,
                    // so its rows get the field's width. See the single-select
                    // note above.
                    positioningKey: _multiFieldKey,
                    labelBuilder: (s) => switch (s.length) {
                      0 => 'All',
                      1 => s.first,
                      _ => '${s.length} fields',
                    },
                    anchorBuilder: (context, isOpen) => _AnchorFace(
                      label: switch (_tags.length) {
                        0 => 'All',
                        1 => _tags.first,
                        _ => '${_tags.length} fields',
                      },
                      isOpen: isOpen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The caller-drawn anchor: a label and a chevron that turns while open. No box
/// of its own — the surrounding field supplies the chrome.
class _AnchorFace extends StatelessWidget {
  const _AnchorFace({required this.label, required this.isOpen});

  final String label;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          AnimatedRotation(
            turns: isOpen ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.expand_more, size: 18),
          ),
        ],
      ),
    );
  }
}

/// The outer field that owns the border and background. The [scope] anchor sits
/// at its head, then a divider, then the text field.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.scope,
    required this.fieldKey,
    this.controller,
  });

  final Widget scope;

  /// Attached to the outer box and handed to [scope] as its `positioningKey`,
  /// so the selector's menu drops below the whole field.
  final GlobalKey fieldKey;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: fieldKey,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          scope,
          const SizedBox(height: 24, child: VerticalDivider(width: 1)),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                hintText: 'Search…',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
