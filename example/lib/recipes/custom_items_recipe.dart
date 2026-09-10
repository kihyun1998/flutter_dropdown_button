/// Rows you draw yourself — and a button face that need not match them.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

/// A person on the assignee list.
class Member {
  const Member(this.name, this.role, this.colour);

  final String name;
  final String role;
  final Color colour;
}

const _members = <Member>[
  Member('Ada Lovelace', 'Engineering', Color(0xFF6750A4)),
  Member('Grace Hopper', 'Engineering', Color(0xFF00696D)),
  Member('Katherine Johnson', 'Research', Color(0xFF8C4A60)),
  Member('Alan Turing', 'Research', Color(0xFF4F5B92)),
  Member('Radia Perlman', 'Networking', Color(0xFF7A5900)),
];

/// The default constructor, where a row is whatever `itemBuilder` returns.
///
/// Three slots, and the two after the first are the ones that get missed:
///
/// * `itemBuilder` draws a row, and is told whether that row is the chosen one.
/// * `selectedBuilder` draws the **button face**. Without it the face falls
///   back to `itemBuilder(item, true)` — a whole row, avatar and role and all,
///   squeezed into a button. Here the face is a single line, which is what a
///   face usually wants to be.
/// * `hintWidget` is the face before anything is chosen. `hint` is text mode's;
///   this is the custom-mode one, and it takes a widget because there may be no
///   text involved at all.
///
/// **`.text()` cannot do this and is not meant to.** It buys overflow handling,
/// an automatic tooltip and a default search filter by knowing what an item
/// *says*; this constructor knows nothing about an item, and gets arbitrary
/// widgets in exchange.
class CustomItemsRecipe extends StatefulWidget {
  const CustomItemsRecipe({super.key});

  @override
  State<CustomItemsRecipe> createState() => _CustomItemsRecipeState();
}

class _CustomItemsRecipeState extends State<CustomItemsRecipe> {
  Member? _assignee;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterDropdownButton<Member>(
            width: 300,
            itemHeight: 56,
            items: _members,
            value: _assignee,
            onChanged: (member) => setState(() => _assignee = member),
            // Before anything is chosen. A widget, not a string, because a
            // custom face may have no text in it.
            hintWidget: Row(
              children: [
                Icon(
                  Icons.person_add_alt,
                  size: 20,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assign to…',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ),
            // A row: avatar, name, role.
            itemBuilder: (member, isSelected) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: member.colour,
                    child: Text(
                      member.name.characters.first,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        Text(
                          member.role,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check, size: 18),
                ],
              ),
            ),
            // The face. One line, not the row — which is the whole reason this
            // slot exists.
            selectedBuilder: (member) => Row(
              children: [
                CircleAvatar(radius: 10, backgroundColor: member.colour),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(member.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _assignee == null
                ? 'Unassigned'
                : '${_assignee!.name} · ${_assignee!.role}',
          ),
        ],
      ),
    );
  }
}
