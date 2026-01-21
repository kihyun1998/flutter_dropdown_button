# Changelog

## 1.5.4

* **FIX**: Fixed scroll gradient direction - top gradient now properly fades from opaque to transparent downward, bottom gradient fades from transparent to opaque downward

## 1.5.3

* **FIX**: Fixed ScrollbarTheme colors not being applied by correcting widget hierarchy (ScrollbarTheme must wrap Scrollbar, not vice versa)

## 1.5.2

* **PERF**: Improved scroll performance with many items by using ListView.builder (lazy loading) and ClampingScrollPhysics (removes bouncing effect)
* **FIX**: Fixed dropdown height calculation to account for safe areas (status bar, navigation bar, home indicator)

## 1.5.1

* **FIX**: Fixed dropdown overlay remaining visible after screen transitions by immediately removing overlay on dispose without animation
* **FIX**: Added safe error handling for overlay removal to prevent crashes when overlay has already been removed
* **FEAT**: Added DropdownMixin.closeAll() static method for manual dropdown cleanup before navigation or other actions

## 1.5.0

* **BREAKING**: Extracted tooltip styling from TextDropdownConfig into new TooltipTheme class for better separation of concerns
* **BREAKING**: Removed tooltip styling properties from TextDropdownConfig (tooltipBackgroundColor, tooltipTextColor, tooltipTextStyle, tooltipDecoration, tooltipBorderRadius, tooltipBorderColor, tooltipBorderWidth, tooltipShadow, tooltipPadding, tooltipMargin, tooltipConstraints, tooltipTextAlign)
* **FEAT**: Added TooltipTheme class for centralized tooltip visual styling
* **FEAT**: Added tooltip field to DropdownStyleTheme to include TooltipTheme alongside DropdownTheme and DropdownScrollTheme
* **CHANGE**: TextDropdownConfig now only controls tooltip behavior (enableTooltip, tooltipMode, durations, positioning, trigger modes)
* **MIGRATION**: Move tooltip styling properties from TextDropdownConfig to TooltipTheme in DropdownStyleTheme

## 1.4.8

* **FEAT**: Added itemBorder property to DropdownTheme for applying borders to individual dropdown items (commonly used for bottom borders between items)
* **FEAT**: Added excludeLastItemBorder property to DropdownTheme to exclude border from the last item (defaults to true for clean design)
* **DEPRECATED**: showSeparator and separator parameters are now deprecated in favor of itemBorder (will be removed in 2.0.0)

## 1.4.7

* **FEAT**: Added minMenuWidth parameter to set minimum dropdown menu width independently from button width
* **FEAT**: Added maxMenuWidth parameter to set maximum dropdown menu width independently from button width
* **FEAT**: Added menuAlignment parameter (left/center/right) to control menu positioning when menu is wider than button

## 1.4.6

* **FEAT**: Added showSeparator and separator parameters to display customizable dividers between dropdown items (defaults to Divider widget)

## 1.4.4

* **FIX**: Fixed hover color not visible when selectedItemColor is set by changing Container to Ink widget for proper Material effect layering

## 1.4.3

* **FEAT**: Added trailing parameter support to DynamicTextBaseDropdownButton (static display for single-item mode, rotation animation for multi-item mode)

## 1.4.2

* **FEAT**: Added buttonHoverColor, buttonSplashColor, and buttonHighlightColor to DropdownTheme for controlling dropdown button InkWell interaction colors
* **FEAT**: Added buttonHeight property to DropdownTheme for independent button content height control from iconSize, with automatic overflow prevention
* **FEAT**: Added trailing parameter to BaseDropdownButton for customizing the dropdown arrow icon with automatic rotation animation

## 1.4.1

* **FEAT**: Added hover cursor support - dropdown button now shows click cursor on mouse hover using InkWell

## 1.4.0

* **BREAKING**: Changed `leadingBuilder` to `leading` and `selectedLeading` parameters in DynamicTextBaseDropdownButton for better performance and simpler API
* **BREAKING**: Renamed `leadingWidgetPadding` to `leadingPadding` in DynamicTextBaseDropdownButton for consistent naming
* **PERF**: Optimized AnimatedBuilder in DropdownMixin to prevent unnecessary rebuilds of overlay content during animations (60+ rebuilds eliminated per dropdown open/close)
* **PERF**: Changed leading widget API from builder function to direct widget parameters, eliminating redundant widget creation (126+ widget creations reduced to 2 per dropdown)

## 1.3.3

* **FEAT**: Added expand parameter to automatically wrap dropdown in Expanded widget for flex layouts, with spaceBetween alignment when expanded

## 1.3.2

* **FEAT**: Added smart tooltip support with overflow detection, auto-positioning, and extensive customization options (background color, border, shadow, text styling, trigger modes, and timing controls)
* **FIX**: Fixed text and icon vertical alignment issue by adding centerLeft alignment to text and center crossAxisAlignment to Row, and fixed mainAxisAlignment to use spaceBetween when width is fixed

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