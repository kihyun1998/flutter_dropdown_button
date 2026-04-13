# Flutter Dropdown Button

A highly customizable dropdown package for Flutter with overlay-based rendering, smooth animations, and full control over appearance and behavior — all in a single widget.

[![pub package](https://img.shields.io/pub/v/flutter_dropdown_button.svg)](https://pub.dev/packages/flutter_dropdown_button)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Single Unified Widget**: One `FlutterDropdownButton<T>` for all use cases
- **Two Modes**: Custom widget rendering (default) or text-only (`.text()`)
- **Overlay-based Rendering**: Better positioning and visual effects than Flutter's built-in DropdownButton
- **Smart Positioning**: Automatically opens up/down based on available space
- **Smooth Animations**: Scale and fade effects with configurable timing
- **Outside-tap Dismissal**: Automatic closure when tapping outside
- **Flexible Width**: Fixed, min/max constraints, content-based, or flex expansion
- **Independent Menu Width**: Set menu width separately from button with alignment control
- **Text Overflow Control**: Ellipsis, fade, clip, or visible overflow options
- **Smart Tooltip**: Automatic tooltip on overflow with full customization
- **Custom Scrollbar**: Scrollbar theming with colors, thickness, and visibility
- **Single-Item Mode**: Auto-disable when only one option exists
- **Leading Widgets**: Optional icons/widgets before text content
- **Searchable Dropdown**: Real-time filtering with customizable search field

## Screenshots

<table>
  <tr>
    <td><img src="screenshot/basic_screenshot.png" alt="Basic Text Dropdown" width="300"/></td>
    <td><img src="screenshot/custom_hover.png" alt="Icon + Text Dropdown with Hover" width="300"/></td>
  </tr>
  <tr>
    <td align="center"><b>Basic Text Dropdown</b><br/>Simple text options with customizable styles</td>
    <td align="center"><b>Icon + Text Dropdown</b><br/>Rich content with icons and hover effects</td>
  </tr>
</table>

## Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dropdown_button: ^2.3.0
```

Import the package:

```dart
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
```

## Basic Usage

### Text Dropdown (Fixed Width)

```dart
FlutterDropdownButton<String>.text(
  items: ['Apple', 'Banana', 'Cherry'],
  value: selectedValue,
  hint: 'Select a fruit',
  width: 200,
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

### Text Dropdown (Dynamic Width)

```dart
FlutterDropdownButton<String>.text(
  items: ['Apple', 'Banana', 'Cherry'],
  value: selectedValue,
  hint: 'Select a fruit',
  minWidth: 120,
  maxWidth: 300,
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

### Custom Widget Dropdown

```dart
FlutterDropdownButton<String>(
  items: ['home', 'settings', 'profile'],
  value: selectedValue,
  hintWidget: Text('Choose option'),
  itemBuilder: (item, isSelected) => Row(
    children: [
      Icon(_getIcon(item), size: 20),
      SizedBox(width: 8),
      Text(item),
    ],
  ),
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

### Custom Selected Display

```dart
FlutterDropdownButton<String>(
  items: ['apple', 'banana'],
  value: selectedValue,
  itemBuilder: (item, isSelected) => Text(item),
  selectedBuilder: (item) => Text(item.toUpperCase(),
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  onChanged: (value) {
    setState(() => selectedValue = value);
  },
)
```

---

## API Reference

### FlutterDropdownButton\<T\>

The unified dropdown widget. Use the default constructor for custom widget rendering, or `.text()` for text-only content.

#### Custom Mode (Default Constructor)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **`items`** | `List<T>` | **required** | List of item values |
| **`onChanged`** | `ValueChanged<T?>` | **required** | Called when an item is selected |
| **`itemBuilder`** | `Widget Function(T, bool)` | **required** | Builds widget for each item (`item`, `isSelected`) |
| `selectedBuilder` | `Widget Function(T)?` | `null` | Builds widget for selected item on button face (falls back to `itemBuilder`) |
| `hintWidget` | `Widget?` | `null` | Widget shown when no item is selected |

#### Text Mode (.text Constructor)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| **`items`** | `List<T>` | **required** | List of string items |
| **`onChanged`** | `ValueChanged<T?>` | **required** | Called when an item is selected |
| `hint` | `String?` | `null` | Text shown when no item is selected |
| `config` | `TextDropdownConfig?` | `null` | Text rendering configuration |
| `leading` | `Widget?` | `null` | Widget before text in all items |
| `selectedLeading` | `Widget?` | `null` | Widget before text in selected item (falls back to `leading`) |
| `leadingPadding` | `EdgeInsets?` | `right: 8.0` | Padding around the leading widget |

#### Common Parameters (Both Modes)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `T?` | `null` | Currently selected value |
| `width` | `double?` | `null` | Fixed width (`null` = content-based) |
| `minWidth` | `double?` | `null` | Minimum width constraint |
| `maxWidth` | `double?` | `null` | Maximum width constraint |
| `height` | `double` | `200.0` | Maximum height of dropdown overlay |
| `itemHeight` | `double` | `48.0` | Height of each dropdown item |
| `animationDuration` | `Duration` | `200ms` | Duration of show/hide animation |
| `enabled` | `bool` | `true` | Whether the dropdown is interactive |
| `expand` | `bool` | `false` | Expand to fill available space in flex container |
| `trailing` | `Widget?` | `null` | Custom widget replacing default arrow icon |
| `scrollToSelectedItem` | `bool` | `true` | Auto-scroll to selected item on open |
| `scrollToSelectedDuration` | `Duration?` | `null` | Scroll animation duration (`null` = instant jump) |
| `disableWhenSingleItem` | `bool` | `false` | Disable dropdown when only one item exists |
| `hideIconWhenSingleItem` | `bool` | `true` | Hide arrow icon in single-item mode |
| `minMenuWidth` | `double?` | `null` | Minimum width of dropdown menu |
| `maxMenuWidth` | `double?` | `null` | Maximum width of dropdown menu |
| `menuAlignment` | `MenuAlignment` | `.left` | Menu alignment when wider than button |
| `theme` | `DropdownStyleTheme?` | `null` | Theme configuration |
| `searchable` | `bool` | `false` | Enable search/filter field in dropdown |
| `searchFilter` | `bool Function(T, String)?` | `null` | Custom filter function (required for custom mode) |
| `emptyBuilder` | `Widget Function(String)?` | `null` | Widget builder for empty search results |

### MenuAlignment

Alignment of the dropdown menu relative to the button when the menu is wider.

| Value | Description |
|-------|-------------|
| `MenuAlignment.left` | Left edges align, menu extends right **(default)** |
| `MenuAlignment.center` | Menu centered over button |
| `MenuAlignment.right` | Right edges align, menu extends left |

---

## Theme System

Theme is applied via the `theme` parameter using `DropdownStyleTheme`, which groups four theme objects:

```dart
DropdownStyleTheme(
  dropdown: DropdownTheme(...),        // General dropdown styling
  scroll: DropdownScrollTheme(...),    // Scrollbar styling
  tooltip: DropdownTooltipTheme(...),  // Tooltip styling
  search: SearchFieldTheme(...),       // Search field styling
)
```

### DropdownTheme

Controls general styling for button, overlay, and items.

#### Button Styling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `buttonDecoration` | `BoxDecoration?` | `null` | Custom button decoration (overrides all below) |
| `buttonPadding` | `EdgeInsets` | `horizontal: 16, vertical: 12` | Internal padding of button |
| `buttonHeight` | `double?` | `null` | Height of button content area (falls back to `iconSize` or `24.0`) |
| `buttonHoverColor` | `Color?` | `null` | Button hover background color |
| `buttonSplashColor` | `Color?` | `null` | Button tap ripple color |
| `buttonHighlightColor` | `Color?` | `null` | Button focus highlight color |

#### Overlay Styling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `overlayDecoration` | `BoxDecoration?` | `null` | Custom overlay decoration (overrides `backgroundColor`, `border`, `borderRadius`) |
| `overlayPadding` | `EdgeInsets?` | `null` | Padding inside the overlay container |
| `borderRadius` | `double` | `8.0` | Border radius for button and overlay |
| `elevation` | `double` | `8.0` | Shadow depth of overlay |
| `backgroundColor` | `Color?` | `null` | Overlay background color (falls back to `Theme.cardColor`) |
| `border` | `Border?` | `null` | Border for button and overlay (falls back to `Theme.dividerColor`) |
| `shadowColor` | `Color?` | `null` | Overlay shadow color |

#### Item Styling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `itemPadding` | `EdgeInsets` | `horizontal: 16, vertical: 12` | Internal padding of each item |
| `itemMargin` | `EdgeInsets?` | `null` | External margin around each item |
| `itemBorderRadius` | `double?` | `null` | Border radius for individual items |
| `itemBorder` | `Border?` | `null` | Border for each item (e.g., bottom divider) |
| `excludeLastItemBorder` | `bool` | `true` | Skip `itemBorder` on the last item |
| `selectedItemColor` | `Color?` | `null` | Background color for selected item (falls back to `primaryColor` 10%) |
| `itemHoverColor` | `Color?` | `null` | Item hover background color |
| `itemSplashColor` | `Color?` | `null` | Item tap ripple color |
| `itemHighlightColor` | `Color?` | `null` | Item focus highlight color |

#### Icon Styling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `IconData?` | `Icons.keyboard_arrow_down` | Dropdown arrow icon |
| `iconSize` | `double?` | `24.0` | Size of the dropdown icon |
| `iconColor` | `Color?` | `null` | Icon color when enabled |
| `iconDisabledColor` | `Color?` | `null` | Icon color when disabled |
| `iconPadding` | `EdgeInsets?` | `EdgeInsets.only(left: 8.0)` | Padding around the icon |

#### Disabled State

Applied when `enabled: false` (or when the single-item auto-disable kicks in). If none of these are set, the disabled button falls back to the regular `buttonDecoration` / `border`.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `disabledButtonDecoration` | `BoxDecoration?` | `null` | Full custom decoration for the disabled button (takes precedence over the two below) |
| `disabledBackgroundColor` | `Color?` | `null` | Background color of the button when disabled |
| `disabledBorder` | `Border?` | `null` | Border of the button when disabled (falls back to `border`) |

### DropdownScrollTheme

Controls scrollbar appearance inside the dropdown overlay.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `thumbWidth` | `double?` | `null` | Width of the scrollbar thumb |
| `trackWidth` | `double?` | `null` | Width of the scrollbar track |
| `radius` | `Radius?` | `null` | Corner radius of scrollbar thumb |
| `thumbColor` | `Color?` | `null` | Color of the scrollbar thumb |
| `trackColor` | `Color?` | `null` | Color of the scrollbar track |
| `trackBorderColor` | `Color?` | `null` | Border color of the scrollbar track |
| `thumbVisibility` | `bool?` | `null` | Show/hide scrollbar thumb |
| `trackVisibility` | `bool?` | `null` | Show/hide scrollbar track |
| `interactive` | `bool?` | `null` | Allow dragging the scrollbar thumb |
| `crossAxisMargin` | `double?` | `null` | Margin from edge of scroll view |
| `mainAxisMargin` | `double?` | `null` | Margin at top/bottom of scrollbar |
| `minThumbLength` | `double?` | `null` | Minimum length of scrollbar thumb |
| `showScrollGradient` | `bool?` | `false` | Show fade gradient when scrollable |
| `gradientHeight` | `double?` | `24.0` | Height of gradient effect |
| `gradientColors` | `List<Color>?` | `null` | Custom gradient colors (auto-detects from background if `null`) |

### DropdownTooltipTheme

Controls tooltip styling and behavior for text-based dropdowns.

#### Visual Styling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `decoration` | `Decoration?` | `null` | Custom tooltip decoration |
| `backgroundColor` | `Color?` | `null` | Tooltip background color |
| `textColor` | `Color?` | `null` | Tooltip text color |
| `textStyle` | `TextStyle?` | `null` | Tooltip text style (overrides `textColor`) |
| `borderRadius` | `BorderRadius?` | `null` | Tooltip corner radius |
| `borderColor` | `Color?` | `null` | Tooltip border color |
| `borderWidth` | `double?` | `1.0` | Tooltip border width |
| `shadow` | `List<BoxShadow>?` | `null` | Tooltip shadow |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding inside tooltip |
| `margin` | `EdgeInsetsGeometry?` | `null` | Margin around tooltip |

#### Behavior

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Enable/disable tooltip |
| `mode` | `TooltipMode` | `.onlyWhenOverflow` | When to show tooltip |
| `waitDuration` | `Duration` | `500ms` | Delay before showing on hover |
| `showDuration` | `Duration` | `3s` | How long tooltip stays visible |
| `verticalOffset` | `double?` | `null` | Gap between widget and tooltip |
| `triggerMode` | `TooltipTriggerMode?` | `null` | How tooltip is triggered |

### SearchFieldTheme

Controls the appearance and behavior of the search text field when `searchable` is enabled.

#### Layout

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `height` | `double?` | `36.0` | Height of the search field |
| `borderRadius` | `BorderRadius?` | `circular(8)` | Corner radius of the search field |
| `margin` | `EdgeInsets?` | `fromLTRB(8, 8, 8, 4)` | Outer margin around the search field |
| `padding` | `EdgeInsets?` | `null` | Inner padding of the search field container |
| `contentPadding` | `EdgeInsets?` | `horizontal: 12, vertical: 8` | Content padding inside the text field |

#### Styling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `decoration` | `InputDecoration?` | `null` | Full InputDecoration override (ignores individual properties when set) |
| `textStyle` | `TextStyle?` | `null` | Text style for search input |
| `backgroundColor` | `Color?` | `null` | Background color of the search field |
| `border` | `BoxBorder?` | `null` | Border when not focused |
| `focusedBorder` | `BoxBorder?` | `null` | Border when focused |
| `divider` | `Widget?` | `null` | Widget between search field and item list |

#### Cursor

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cursorColor` | `Color?` | `null` | Cursor color |
| `cursorWidth` | `double?` | `2.0` | Cursor width |
| `cursorHeight` | `double?` | `null` | Cursor height |
| `cursorRadius` | `Radius?` | `null` | Cursor corner radius |

#### Behavior

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `autofocus` | `bool` | `true` | Auto-focus search field on dropdown open |
| `textAlign` | `TextAlign` | `.start` | Text alignment |
| `keyboardType` | `TextInputType?` | `.text` | Keyboard type |
| `textInputAction` | `TextInputAction?` | `.search` | Keyboard action button |

### TextDropdownConfig

Configuration for text rendering in `.text()` mode.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `overflow` | `TextOverflow` | `.ellipsis` | How to handle text overflow |
| `maxLines` | `int?` | `1` | Maximum number of lines |
| `textStyle` | `TextStyle?` | `null` | Style for item text |
| `hintStyle` | `TextStyle?` | `null` | Style for hint text |
| `selectedTextStyle` | `TextStyle?` | `null` | Style for selected item text |
| `disabledTextStyle` | `TextStyle?` | `null` | Style for button text (value and hint) when disabled — merged over `textStyle` / `hintStyle` |
| `textAlign` | `TextAlign` | `.start` | Horizontal text alignment (also controls item alignment in menu) |
| `softWrap` | `bool` | `true` | Allow line breaks at word boundaries |

---

## Advanced Features

### Searchable Dropdown (Text Mode)

```dart
FlutterDropdownButton<String>.text(
  items: ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'],
  value: selected,
  hint: 'Select a fruit',
  width: 250,
  searchable: true,
  onChanged: (value) => setState(() => selected = value),
)
```

### Searchable Dropdown (Custom Mode)

```dart
FlutterDropdownButton<User>(
  items: users,
  value: selectedUser,
  searchable: true,
  searchFilter: (user, query) =>
    user.name.toLowerCase().contains(query.toLowerCase()),
  emptyBuilder: (query) => Center(
    child: Text('No users matching "$query"'),
  ),
  itemBuilder: (user, isSelected) => Row(
    children: [
      CircleAvatar(radius: 14, child: Text(user.name[0])),
      SizedBox(width: 8),
      Text(user.name),
    ],
  ),
  onChanged: (value) => setState(() => selectedUser = value),
)
```

### Searchable Dropdown with Custom Theme

```dart
FlutterDropdownButton<String>.text(
  items: countries,
  value: selected,
  searchable: true,
  theme: DropdownStyleTheme(
    search: SearchFieldTheme(
      backgroundColor: Colors.grey.shade100,
      height: 40,
      borderRadius: BorderRadius.circular(12),
      cursorColor: Colors.blue,
      divider: Divider(height: 1),
    ),
  ),
  onChanged: (value) => setState(() => selected = value),
)
```

### Custom Theme

```dart
FlutterDropdownButton<String>.text(
  items: items,
  value: selected,
  width: 200,
  theme: DropdownStyleTheme(
    dropdown: DropdownTheme(
      borderRadius: 12.0,
      elevation: 4.0,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue.withOpacity(0.1),
      itemHoverColor: Colors.grey.withOpacity(0.1),
      itemBorder: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      excludeLastItemBorder: true,
    ),
    scroll: DropdownScrollTheme(
      thumbWidth: 6.0,
      thumbColor: Colors.blue,
      showScrollGradient: true,
    ),
    tooltip: DropdownTooltipTheme(
      backgroundColor: Colors.black87,
      textStyle: TextStyle(color: Colors.white),
      borderRadius: BorderRadius.circular(8),
      mode: TooltipMode.onlyWhenOverflow,
    ),
  ),
  onChanged: (value) => setState(() => selected = value),
)
```

### Menu Width & Alignment

```dart
FlutterDropdownButton<String>.text(
  items: items,
  width: 120,
  minMenuWidth: 250,
  maxMenuWidth: 400,
  menuAlignment: MenuAlignment.center,
  onChanged: (value) {},
)
```

### Single-Item Mode

```dart
FlutterDropdownButton<String>.text(
  items: ['Only Option'],
  disableWhenSingleItem: true,
  hideIconWhenSingleItem: true,
  onChanged: (value) {},
)
```

### Leading Widget

```dart
FlutterDropdownButton<String>.text(
  items: ['USD', 'EUR', 'JPY'],
  leading: Icon(Icons.attach_money, size: 20),
  selectedLeading: Icon(Icons.attach_money, size: 20, color: Colors.blue),
  leadingPadding: EdgeInsets.only(right: 12),
  onChanged: (value) {},
)
```

### Expand in Flex Container

```dart
Row(
  children: [
    Text('Label:'),
    FlutterDropdownButton<String>.text(
      items: items,
      expand: true,
      maxWidth: 200,
      onChanged: (value) {},
    ),
  ],
)
```

### Manual Dropdown Cleanup

```dart
// Close with animation (trailing icon rotates back)
FlutterDropdownButton.closeAll();

// Close immediately without animation (useful before navigation)
FlutterDropdownButton.closeAll(animate: false);
Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
```

**Note**: Dropdowns are automatically cleaned up during widget disposal. Use `closeAll()` only when you need explicit control.

---

## Migration from 1.x

### BasicDropdownButton → FlutterDropdownButton

```dart
// Before (1.x)
BasicDropdownButton<String>(
  items: [
    DropdownItem(value: 'apple', child: Text('Apple'), onTap: () {}),
    DropdownItem(value: 'banana', child: Text('Banana')),
  ],
  value: selected,
  hint: Text('Select'),
  onChanged: (v) {},
)

// After (2.0)
FlutterDropdownButton<String>(
  items: ['apple', 'banana'],
  value: selected,
  hintWidget: Text('Select'),
  itemBuilder: (item, isSelected) => Text(item),
  onChanged: (v) {},
)
```

### TextOnlyDropdownButton → FlutterDropdownButton.text

```dart
// Before (1.x)
TextOnlyDropdownButton(
  items: ['A', 'B', 'C'],
  value: selected,
  hint: 'Select',
  width: 200,
  onChanged: (v) {},
)

// After (2.0)
FlutterDropdownButton<String>.text(
  items: ['A', 'B', 'C'],
  value: selected,
  hint: 'Select',
  width: 200,
  onChanged: (v) {},
)
```

### DynamicTextBaseDropdownButton → FlutterDropdownButton.text

```dart
// Before (1.x)
DynamicTextBaseDropdownButton(
  items: items,
  value: selected,
  disableWhenSingleItem: true,
  leading: Icon(Icons.star),
  onChanged: (v) {},
)

// After (2.0)
FlutterDropdownButton<String>.text(
  items: items,
  value: selected,
  disableWhenSingleItem: true,
  leading: Icon(Icons.star),
  onChanged: (v) {},
)
```

### Removed APIs

| Removed | Replacement |
|---------|-------------|
| `DropdownItem<T>` | `itemBuilder` callback |
| `showSeparator` / `separator` | `DropdownTheme.itemBorder` |
| `BasicDropdownButton.borderRadius` | `DropdownTheme.borderRadius` |
| `BasicDropdownButton.decoration` | `DropdownTheme.overlayDecoration` |
| `DropdownItem.onTap` | Handle in `onChanged` callback |

---

## Example

Check out the [example app](example/) for a comprehensive demonstration of all features and customization options.

## Documentation

- [Use Cases](documentation/use_cases.md) - Font picker, dynamic width, color picker, country picker examples
- [API Reference](documentation/api_reference.md) - Complete API documentation
- [Theming](documentation/theming.md) - Theming and styling guide
- [Text Configuration](documentation/text_configuration.md) - Text-specific configuration guide
- [Migration](documentation/migration.md) - Migration guide from previous versions

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and version history.
