import 'dropdown_scroll_theme.dart';
import 'dropdown_theme.dart';

/// Main theme container for all dropdown styling configurations.
///
/// This class serves as the central configuration point for all dropdown
/// theming options, including general styling, scrollbar appearance,
/// and any future theme extensions.
///
/// Example:
/// ```dart
/// DropdownStyleTheme(
///   dropdown: DropdownTheme(
///     borderRadius: 12.0,
///     elevation: 4.0,
///     backgroundColor: Colors.white,
///   ),
///   scroll: DropdownScrollTheme(
///     thickness: 8.0,
///     thumbColor: Colors.grey,
///     alwaysVisible: true,
///   ),
/// )
/// ```
class DropdownStyleTheme {
  /// Creates a dropdown style theme configuration.
  const DropdownStyleTheme({
    this.dropdown = const DropdownTheme(),
    this.scroll = const DropdownScrollTheme(),
  });

  /// General dropdown styling configuration.
  ///
  /// Controls the appearance and behavior of dropdown components
  /// including colors, borders, padding, animations, and decorations.
  final DropdownTheme dropdown;

  /// Scrollbar styling configuration.
  ///
  /// Controls the appearance and behavior of scrollbars within
  /// dropdown overlays when content exceeds the visible area.
  final DropdownScrollTheme scroll;

  /// Creates a copy of this theme with the given fields replaced.
  DropdownStyleTheme copyWith({
    DropdownTheme? dropdown,
    DropdownScrollTheme? scroll,
  }) {
    return DropdownStyleTheme(
      dropdown: dropdown ?? this.dropdown,
      scroll: scroll ?? this.scroll,
    );
  }

  /// Default theme that works well with Material Design.
  ///
  /// Uses default configurations for both dropdown and scroll themes.
  static const DropdownStyleTheme defaultTheme = DropdownStyleTheme();
}
