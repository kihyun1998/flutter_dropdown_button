# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

This is a Flutter package (`flutter_dropdown_button`) that provides highly customizable dropdown widgets with overlay-based rendering. The package consists of two main dropdown variants and a shared architecture for common functionality.

## Core Architecture

### Main Components

- **BasicDropdownButton**: Generic dropdown supporting any widget as items
- **TextOnlyDropdownButton**: Specialized dropdown for text content with precise text rendering control
- **DropdownMixin**: Shared functionality mixin that eliminates code duplication between dropdown variants
- **DropdownTheme**: Shared theme system for consistent styling across variants
- **TextDropdownConfig**: Text-specific configuration for overflow, styling, and alignment
- **DropdownItem**: Generic model for BasicDropdownButton items

### Shared Architecture Pattern

Both dropdown variants use the `DropdownMixin` which provides:
- Smart positioning logic (automatically opens upward when insufficient space below)
- Animation management (scale and opacity animations)
- Overlay lifecycle management
- Outside-tap dismissal functionality
- Dynamic height adjustment to prevent screen overflow

The mixin eliminates ~150 lines of duplicate code between the two dropdown variants.

## Development Commands

### Package Development
```bash
# Install dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run linter
flutter pub run flutter_lints

# Format code
dart format .

# Run tests (minimal test suite currently exists)
flutter test

# Run tests for specific file
flutter test test/flutter_dropdown_button_test.dart
```

### Example App Development
```bash
# Run example app
cd example && flutter run

# Build example app
cd example && flutter build web
```

### Documentation
The package includes comprehensive documentation in the `documentation/` directory:
- `api_reference.md`: Complete API documentation
- `theming.md`: Theming and styling guide
- `text_configuration.md`: Text-specific configuration guide
- `migration.md`: Migration guide from Flutter's built-in DropdownButton

## Key Implementation Details

### Overlay-Based Rendering
Unlike Flutter's built-in DropdownButton, these widgets use `OverlayEntry` for better positioning control and visual effects. The overlay system allows for smart positioning that adapts to available screen space.

### Positioning Algorithm
The `DropdownMixin.calculateDropdownPosition()` method implements smart positioning:
1. Calculates available space above and below the button
2. Prefers to open downward if sufficient space exists
3. Falls back to opening upward if more space is available above
4. Dynamically adjusts height when space is constrained
5. Ensures minimum visibility of items

### Breaking Changes
Version 1.1.0 introduced breaking changes:
- `CustomDropdown` → `BasicDropdownButton`  
- `TextOnlyDropdown` → `TextOnlyDropdownButton`

When making changes to class names or public APIs, ensure all documentation files are updated accordingly.

## Package Structure
```
lib/
├── flutter_dropdown_button.dart          # Main export file
└── src/
    ├── basic_dropdown_button.dart        # Generic dropdown widget
    ├── text_only_dropdown_button.dart    # Text-specific dropdown widget
    ├── dropdown_mixin.dart               # Shared functionality mixin
    ├── dropdown_theme.dart               # Shared theme system
    ├── text_dropdown_config.dart         # Text-specific configuration
    └── dropdown_item.dart                # Item model for BasicDropdownButton
```

## Version Management

- Current version: 1.1.0
- Uses semantic versioning
- Breaking changes require major version bump
- Update version in both `pubspec.yaml` and documentation when releasing
- CHANGELOG.md follows the format: `* **TYPE**: Description` (e.g., `* **FEAT**: New feature`)