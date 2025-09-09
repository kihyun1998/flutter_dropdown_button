# Changelog

## [Unreleased]

* **FEAT**: Added itemMargin property to DropdownTheme for controlling spacing between dropdown items
* **FEAT**: Added itemBorderRadius property to DropdownTheme for individual item border radius styling
* **FEAT**: Added hover effect support to TextOnlyDropdownButton with InkWell integration
* **FIX**: Fixed hover effect positioning to respect itemMargin boundaries for consistent visual feedback

## 1.0.0

* **FEAT**: Initial release with BasicDropdownButton and TextOnlyDropdownButton widgets
* **FEAT**: Smart dropdown positioning - automatically opens upward when insufficient space below
* **FEAT**: Dynamic height adjustment to prevent screen overflow
* **FEAT**: OverlayEntry-based dropdown with smooth animations and outside-tap dismissal
* **FEAT**: Dynamic width support (width, maxWidth, minWidth parameters)
* **FEAT**: Shared DropdownTheme system for consistent styling across variants
* **FEAT**: TextDropdownConfig for precise text overflow control (ellipsis, fade, clip, visible)
* **FEAT**: Multi-line text support and custom text styling
* **FEAT**: Generic DropdownItem model supporting any widget content
* **FEAT**: DropdownMixin for shared functionality across dropdown variants
* **FEAT**: Comprehensive example app with multiple dropdown demonstrations