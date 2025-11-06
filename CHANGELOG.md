# Changelog

## [Unreleased]

* **FEAT**: Added thumbWidth and trackWidth properties to DropdownScrollTheme for independent scrollbar thumb and track width control
* **FEAT**: Added iconColor property to DropdownTheme for customizing dropdown arrow icon color
* **FIX**: Fixed dropdown overlay content clipping issue with border radius by adding clipBehavior to Material widget
* **FIX**: Changed theme parameter type from Object? to DropdownStyleTheme? for better type safety
* **FIX**: Fixed dropdown menu height calculation to properly account for itemMargin and border thickness, preventing unnecessary scrollbars

## 1.1.0

* **FEAT**: Added DropdownScrollTheme for customizing scrollbar appearance
* **FEAT**: Added DropdownStyleTheme as main theme container for dropdown and scroll themes
* **FEAT**: Support for custom scrollbar colors, thickness, radius, and visibility options
* **REFACTOR**: Updated example app with feature-based showcase and style selector

## 1.0.1

* **FEAT**: Added itemMargin property to DropdownTheme for controlling spacing between dropdown items
* **FEAT**: Added itemBorderRadius property to DropdownTheme for individual item border radius styling
* **FEAT**: Added hover effect support to TextOnlyDropdownButton with InkWell integration
* **FIX**: Fixed hover effect positioning to respect itemMargin boundaries for consistent visual feedback
* **REFACTOR**: Added BaseDropdownButton abstract class to reduce code duplication between dropdown variants
* **FEAT**: Exported BaseDropdownButton for creating custom dropdown implementations

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