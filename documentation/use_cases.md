# Use Cases

Practical examples showing how to use `FlutterDropdownButton` for common real-world scenarios.

## Font Picker Dropdown

A dropdown where each item displays its font name rendered in its own font style. This is useful for font selection UIs in text editors, design tools, or any app that lets users choose a font.

### Basic Font Picker

Use the default constructor with `itemBuilder` to render each font in its own `TextStyle`:

```dart
final fonts = ['Roboto', 'Noto Sans KR', 'Courier New', 'Georgia', 'Comic Sans MS'];
String? selectedFont;

FlutterDropdownButton<String>(
  items: fonts,
  value: selectedFont,
  itemBuilder: (font, isSelected) => Text(
    font,
    style: TextStyle(
      fontFamily: font,
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  ),
  onChanged: (value) => setState(() => selectedFont = value),
)
```

### Font Picker with Preview Text

Show a sample sentence below each font name so users can compare readability:

```dart
FlutterDropdownButton<String>(
  items: fonts,
  value: selectedFont,
  itemHeight: 64,
  itemBuilder: (font, isSelected) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(font, style: TextStyle(fontSize: 12, color: Colors.grey)),
      Text(
        'The quick brown fox jumps over the lazy dog',
        style: TextStyle(fontFamily: font, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  ),
  onChanged: (value) => setState(() => selectedFont = value),
)
```

### Font Picker from a Font Model List

When working with a font model class (e.g., from Google Fonts or a custom font registry):

```dart
class FontModel {
  final String name;
  final String family;
  final String? category; // serif, sans-serif, monospace, etc.

  const FontModel({
    required this.name,
    required this.family,
    this.category,
  });
}

final fontList = [
  FontModel(name: 'Roboto', family: 'Roboto', category: 'sans-serif'),
  FontModel(name: 'Noto Sans KR', family: 'NotoSansKR', category: 'sans-serif'),
  FontModel(name: 'Playfair Display', family: 'PlayfairDisplay', category: 'serif'),
  FontModel(name: 'Fira Code', family: 'FiraCode', category: 'monospace'),
];

FontModel? selectedFont;

FlutterDropdownButton<FontModel>(
  items: fontList,
  value: selectedFont,
  itemHeight: 56,
  itemBuilder: (font, isSelected) => Row(
    children: [
      Expanded(
        child: Text(
          font.name,
          style: TextStyle(
            fontFamily: font.family,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
      if (font.category != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            font.category!,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
    ],
  ),
  selectedBuilder: (font) => Text(
    font.name,
    style: TextStyle(fontFamily: font.family, fontSize: 16),
  ),
  onChanged: (value) => setState(() => selectedFont = value),
)
```

### Searchable Font Picker

For large font lists, enable search to let users filter by name:

```dart
FlutterDropdownButton<FontModel>(
  items: fontList,
  value: selectedFont,
  searchable: true,
  searchFilter: (query, font) =>
      font.name.toLowerCase().contains(query.toLowerCase()),
  height: 300,
  itemBuilder: (font, isSelected) => Text(
    font.name,
    style: TextStyle(
      fontFamily: font.family,
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  ),
  onChanged: (value) => setState(() => selectedFont = value),
)
```

### Using with Google Fonts Package

If using the `google_fonts` package, you can dynamically apply font styles:

```dart
import 'package:google_fonts/google_fonts.dart';

final googleFonts = ['Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Poppins'];

FlutterDropdownButton<String>(
  items: googleFonts,
  value: selectedFont,
  itemBuilder: (font, isSelected) => Text(
    font,
    style: GoogleFonts.getFont(
      font,
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  ),
  selectedBuilder: (font) => Text(
    font,
    style: GoogleFonts.getFont(font, fontSize: 16),
  ),
  onChanged: (value) => setState(() => selectedFont = value),
)
```

## Color Picker Dropdown

A dropdown showing color swatches alongside color names:

```dart
final colors = {
  'Red': Colors.red,
  'Blue': Colors.blue,
  'Green': Colors.green,
  'Purple': Colors.purple,
  'Orange': Colors.orange,
};

String? selectedColor;

FlutterDropdownButton<String>(
  items: colors.keys.toList(),
  value: selectedColor,
  itemBuilder: (colorName, isSelected) => Row(
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colors[colorName],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        colorName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ],
  ),
  onChanged: (value) => setState(() => selectedColor = value),
)
```

## Country / Language Picker

A dropdown with flag emojis and country names:

```dart
class Country {
  final String code;
  final String name;
  final String flag;

  const Country(this.code, this.name, this.flag);
}

final countries = [
  Country('KR', 'South Korea', '\ud83c\uddf0\ud83c\uddf7'),
  Country('US', 'United States', '\ud83c\uddfa\ud83c\uddf8'),
  Country('JP', 'Japan', '\ud83c\uddef\ud83c\uddf5'),
  Country('GB', 'United Kingdom', '\ud83c\uddec\ud83c\udde7'),
];

Country? selectedCountry;

FlutterDropdownButton<Country>(
  items: countries,
  value: selectedCountry,
  searchable: true,
  searchFilter: (query, country) =>
      country.name.toLowerCase().contains(query.toLowerCase()) ||
      country.code.toLowerCase().contains(query.toLowerCase()),
  itemBuilder: (country, isSelected) => Row(
    children: [
      Text(country.flag, style: const TextStyle(fontSize: 24)),
      const SizedBox(width: 12),
      Text('${country.name} (${country.code})'),
    ],
  ),
  selectedBuilder: (country) => Row(
    children: [
      Text(country.flag, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 8),
      Text(country.name),
    ],
  ),
  onChanged: (value) => setState(() => selectedCountry = value),
)
```

## Dynamic Width Dropdown

By omitting `width` and using only `maxWidth` (or `minWidth`), the button width automatically adjusts based on the selected item's content. This is useful for toolbars, headers, or any layout where the dropdown should fit its content naturally without wasting space.

### How It Works

When `width` is **not set**:
- The button's inner `Row` uses `MainAxisSize.min`, so it shrinks to fit the selected item
- `maxWidth` applies a `ConstrainedBox` to prevent the button from growing beyond a limit
- `minWidth` ensures the button doesn't get too narrow for short content

When the user selects a different item, the button width changes automatically.

```
Short item selected:   [ Apple  v ]
Long item selected:    [ Pineapple Juice  v ]
Very long item:        [ Strawberry Lem...  v ]  ← clamped at maxWidth
```

### Basic Dynamic Width

```dart
FlutterDropdownButton<String>.text(
  items: ['Apple', 'Banana', 'Pineapple Juice', 'Strawberry Lemonade'],
  value: selected,
  maxWidth: 250,
  onChanged: (value) => setState(() => selected = value),
)
```

The button expands for "Pineapple Juice" and shrinks for "Apple". Content exceeding 250px gets truncated with ellipsis.

### With minWidth for Consistent Minimum Size

```dart
FlutterDropdownButton<String>.text(
  items: ['S', 'M', 'L', 'XL', 'XXL'],
  value: selectedSize,
  minWidth: 80,
  maxWidth: 150,
  onChanged: (value) => setState(() => selectedSize = value),
)
```

Even single-character items like "S" maintain an 80px minimum width for a clean look.

### Responsive maxWidth with MediaQuery

Use `MediaQuery` to make `maxWidth` responsive to screen size:

```dart
@override
Widget build(BuildContext context) {
  final double maxWidth = MediaQuery.of(context).size.width * 0.45;

  return FlutterDropdownButton<String>.text(
    maxWidth: maxWidth,
    items: profileNames,
    value: currentProfile,
    onChanged: (value) => switchProfile(value),
  );
}
```

This is particularly useful for toolbar buttons that should scale with the window but never overflow.

### Dynamic Width with Custom Builder

Works the same way with the default constructor and `itemBuilder`:

```dart
FlutterDropdownButton<User>(
  items: users,
  value: selectedUser,
  maxWidth: 300,
  minWidth: 120,
  itemBuilder: (user, isSelected) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(radius: 12, backgroundImage: NetworkImage(user.avatar)),
      const SizedBox(width: 8),
      Text(user.name),
    ],
  ),
  selectedBuilder: (user) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(radius: 12, backgroundImage: NetworkImage(user.avatar)),
      const SizedBox(width: 8),
      Text(user.name),
    ],
  ),
  onChanged: (value) => setState(() => selectedUser = value),
)
```

### Independent Menu Width

The dropdown menu width can be different from the button width using `minMenuWidth` / `maxMenuWidth`. This is useful when the button should be compact but the menu needs more space to display full content:

```dart
FlutterDropdownButton<String>.text(
  items: longItemNames,
  value: selected,
  maxWidth: 150,       // button stays compact
  minMenuWidth: 250,   // menu opens wider to show full text
  onChanged: (value) => setState(() => selected = value),
)
```

### Width Behavior Summary

| Configuration | Button Width Behavior |
|---|---|
| `width: 200` | Fixed at 200px, ignores content |
| `maxWidth: 200` | Shrinks to content, max 200px |
| `minWidth: 100` | Shrinks to content, min 100px |
| `minWidth: 100, maxWidth: 300` | Content-driven, clamped to 100~300px |
| `expand: true` | Fills available flex space |
| None | Shrinks to content, no limit |

---

## Filter Panel — Multi-Select

The case this widget was built for. A side panel, 350px wide, filters a list of
server nodes by fields whose values are finite and discovered at runtime: OS
family, protocol, status. The user wants several values ORed together, applied
the moment they are ticked, beside chip filters that already behave that way.

A `showDialog` + `CheckboxListTile` gets you there, but it dims the page, it
forces an *Apply* button, and it breaks gesture parity with the chips.

```dart
class OsFilter extends StatefulWidget {
  const OsFilter({super.key, required this.nodes, required this.onFilter});

  final List<Node> nodes;
  final ValueChanged<Set<String>> onFilter;

  @override
  State<OsFilter> createState() => _OsFilterState();
}

class _OsFilterState extends State<OsFilter> {
  Set<String> chosen = {};

  @override
  Widget build(BuildContext context) {
    // The values, and how many nodes carry each, come from the data.
    final counts = <String, int>{};
    for (final node in widget.nodes) {
      counts[node.os] = (counts[node.os] ?? 0) + 1;
    }
    final values = counts.keys.toList()..sort();

    return FlutterMultiSelectDropdown<String>(
      width: 320,
      items: values,
      selected: chosen,
      labelBuilder: (s) => switch (s.length) {
        0 => 'All operating systems',
        1 => s.first,
        _ => '${s.length} selected',
      },
      // Ten values is where scanning stops working.
      searchable: values.length > 10,
      // A row is [checkbox] [leading] [label] [trailing]. Both slots are
      // builders because each value wants a different icon and a different
      // count. Only the label gives way when the row runs out of room.
      itemLeadingBuilder: (v) => Icon(osIcon[v], size: 18),
      itemTrailingBuilder: (v) => Text('${counts[v]}'),
      onChanged: (next) {
        setState(() => chosen = next);
        widget.onFilter(next);   // OR semantics are yours; the widget has none
      },
    );
  }
}
```

### Why a list rather than chips

`Windows Active Directory` is a real value. As a chip in a `Wrap` it eats a whole
row of a 350px panel. A list row uses the full width and ellipsises what does not
fit, with the full string in a tooltip — so the layout is immune to how long the
values turn out to be.

### The value that disappears

Refresh the node list and every machine running `Solaris` may be gone. `chosen`
still holds `'Solaris'`; `items` no longer offers it.

Nothing breaks. The widget draws what it was handed: no row is invented for the
missing value, no exception is thrown, and the choice is not silently discarded.
What it *does* do is count it — `labelBuilder` sees a set of three beside two
ticked boxes.

That is deliberate: `chosen` is your state, and a widget that edited it behind
your back would be the harder bug. Show the chosen values as removable chips
beside the button, and the stale one has an exit.

### What the widget does not do

Filter semantics. OR versus AND, `contains` versus `∈`, how an empty set reads —
all yours. The widget takes a `Set<T>` and gives back a `Set<T>`.

## Field selector inside a search box — Bare anchor

A control toolbar that collapses to one row: a search box with a field-scope
selector at its head, `[All ▾] │ search…`. The scope must stay field-scoped, so
it wants this package's anchored, searchable menu — but a full dropdown *button*
in front of the field nests a box inside a box.

`anchorBuilder` drops the button chrome and hands the anchor to you, so the same
overlay hangs off a compact inline widget:

```dart
Row(
  children: [
    // The field-scope selector — no border, no background, no fixed width.
    FlutterDropdownButton<String>.text(
      items: const ['All', 'Title', 'Body', 'Author'],
      value: field,
      onChanged: (f) => setState(() => field = f!),
      anchorBuilder: (context, isOpen) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(field),
            AnimatedRotation(
              turns: isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more, size: 16),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(
      height: 20,
      child: VerticalDivider(width: 1),
    ),
    // The search field fills the rest.
    const Expanded(
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Search…',
        ),
      ),
    ),
  ],
)
```

The outer field owns the border and background; the selector contributes only
its label and chevron. Everything the menu does — theming, keyboard navigation,
`searchable`, `itemBuilder` — is untouched. `FlutterMultiSelectDropdown` takes
the same `anchorBuilder` for a multi-scope selector.

The chevron turns off `isOpen`, the one thing the builder cannot read for
itself. Build the label from the `value` you already hold; the builder is not
handed one. And drop `width`, `expand` and `trailing` — the button box they
describe is gone, and combining them asserts.
