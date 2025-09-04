# Changelog

## v1.1.0

* **FEAT**: Smart dropdown positioning - automatically opens upward when insufficient space below
* **FEAT**: Dynamic height adjustment to prevent screen overflow  
* **FEAT**: `DropdownMixin` for shared functionality across dropdown variants
* **BREAKING**: `CustomDropdown` → `BasicDropdownButton`
* **BREAKING**: `TextOnlyDropdown` → `TextOnlyDropdownButton`
* **REFACTOR**: Improved code architecture with ~150 lines of duplicate code removed

## 1.0.0

* **FEAT**: Initial release with CustomDropdown and TextOnlyDropdown widgets
* **FEAT**: OverlayEntry-based dropdown with smooth animations and outside-tap dismissal  
* **FEAT**: Dynamic width support (width, maxWidth, minWidth parameters)
* **FEAT**: Shared DropdownTheme system for consistent styling across variants
* **FEAT**: TextDropdownConfig for precise text overflow control (ellipsis, fade, clip, visible)
* **FEAT**: Multi-line text support and custom text styling
* **FEAT**: Generic DropdownItem model supporting any widget content
* **FEAT**: Comprehensive example app with multiple dropdown demonstrations