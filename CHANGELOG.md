# Changelog

## 1.3.1

* **FEAT**: Added leadingBuilder property to DynamicTextBaseDropdownButton for displaying custom widgets (icons, images) before text
* **FEAT**: Added leadingWidgetPadding property to DynamicTextBaseDropdownButton for controlling leading widget spacing

## 1.3.0

* **FEAT**: Added DynamicTextBaseDropdownButton widget that adapts behavior based on item count (non-interactive when single item, normal dropdown when multiple items)
* **FEAT**: Added hideIconWhenSingleItem property to DynamicTextBaseDropdownButton for controlling icon visibility in single-item mode
* **FEAT**: Added interactive example demo with real-time item add/delete functionality
* **FIX**: Fixed dropdown button height consistency issue by wrapping Text and Icon in SizedBox with fixed height based on iconSize
* **FIX**: Fixed mainAxisAlignment from spaceBetween to start to allow button width to fit content size within maxWidth constraint

## 1.2.3

* **FEAT**: Added scrollToSelectedItem property to automatically scroll to the currently selected item when dropdown opens (defaults to true)
* **FEAT**: Added scrollToSelectedDuration property for controlling scroll animation duration (null for instant jump, duration value for smooth animation)
* **FEAT**: Improved scrollable dropdown UX by automatically positioning selected items in view when there are many items

## 1.2.2

* **FEAT**: Added icon property to DropdownTheme for customizing dropdown arrow icon (supports any IconData)
* **FEAT**: Added iconSize property to DropdownTheme for controlling dropdown icon size
* **FEAT**: Added iconDisabledColor property to DropdownTheme for customizing icon color in disabled state
* **FEAT**: Added iconPadding property to DropdownTheme for controlling spacing between selected value and icon
* **FEAT**: Added overlayPadding property to DropdownTheme for controlling internal spacing of the dropdown menu container

## 1.2.1

* **FIX**: Fixed dropdown overlay border rendering issue by removing Material borderRadius that conflicted with Container border decoration
* **FIX**: Fixed dropdown icon not updating on open/close state change and added rotation animation
* **REFACTOR**: Reorganized theme files into theme/ subdirectory for better code organization

## 1.2.0

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