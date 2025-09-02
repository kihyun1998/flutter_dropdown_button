# Flutter Dropdown Button

A highly customizable dropdown package for Flutter with overlay-based rendering, smooth animations, and specialized variants for different content types.

[![pub package](https://img.shields.io/pub/v/flutter_dropdown_button.svg)](https://pub.dev/packages/flutter_dropdown_button)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🎨 **Highly Customizable**: Complete control over appearance and behavior
- 📱 **Overlay-based Rendering**: Better positioning and visual effects
- ✨ **Smooth Animations**: Scale and fade effects with configurable timing
- 🎯 **Outside-tap Dismissal**: Automatic closure when tapping outside
- 📏 **Dynamic Width**: Fixed, min/max width constraints, or content-based sizing
- 📝 **Text Overflow Control**: Ellipsis, fade, clip, or visible overflow options
- 🎭 **Multiple Variants**: Generic CustomDropdown and specialized TextOnlyDropdown
- 🎨 **Shared Theme System**: Consistent styling across all dropdown variants
- ♿ **Accessibility Support**: Screen reader friendly with proper semantics

## Variants

### CustomDropdown
Generic dropdown supporting any widget as items with complete customization.

### TextOnlyDropdown
Specialized dropdown for text content with precise text rendering control.

## Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_dropdown_button: ^1.0.0
```

Import the package:

```dart
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
```

## Basic Usage

### CustomDropdown

```dart
CustomDropdown<String>(
  items: [
    DropdownItem(
      value: 'apple',
      child: Row(
        children: [
          Icon(Icons.apple),
          SizedBox(width: 8),
          Text('Apple'),
        ],
      ),
    ),
    DropdownItem(
      value: 'banana',
      child: Text('Banana'),
    ),
  ],
  value: selectedValue,
  hint: Text('Select a fruit'),
  onChanged: (value) {
    setState(() {
      selectedValue = value;
    });
  },
)
```

### TextOnlyDropdown

```dart
TextOnlyDropdown(
  items: [
    'Short',
    'Medium length text',
    'Very long text that demonstrates overflow behavior',
  ],
  value: selectedText,
  hint: 'Select an option',
  maxWidth: 200,
  config: TextDropdownConfig(
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
  onChanged: (value) {
    setState(() {
      selectedText = value;
    });
  },
)
```

## Advanced Features

### Custom Theme

```dart
TextOnlyDropdown(
  // ... other properties
  theme: DropdownTheme(
    borderRadius: 12.0,
    animationDuration: Duration(milliseconds: 300),
    elevation: 4.0,
    backgroundColor: Colors.white,
  ),
)
```

### Text Configuration

```dart
TextOnlyDropdown(
  // ... other properties
  config: TextDropdownConfig(
    overflow: TextOverflow.fade,
    maxLines: 2,
    textStyle: TextStyle(fontSize: 16),
    textAlign: TextAlign.center,
  ),
)
```

### Dynamic Width

```dart
CustomDropdown<String>(
  // ... other properties
  maxWidth: 300,        // Maximum width constraint
  minWidth: 150,        // Minimum width constraint
  // OR
  width: 250,           // Fixed width
)
```

## Documentation

For detailed documentation and advanced usage examples, see:

- [Complete API Reference](documentation/api_reference.md)
- [Theming Guide](documentation/theming.md)
- [Text Configuration Guide](documentation/text_configuration.md)
- [Migration from DropdownButton](documentation/migration.md)

## Example

Check out the [example app](example/) for a comprehensive demonstration of all features and customization options.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and version history.