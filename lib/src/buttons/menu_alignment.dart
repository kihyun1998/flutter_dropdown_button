/// Defines how the dropdown menu should be aligned relative to the button
/// when the menu is wider than the button.
///
/// This alignment is only applied when the menu width (calculated from
/// [minMenuWidth] and [maxMenuWidth]) is greater than the button width.
enum MenuAlignment {
  /// Menu's left edge aligns with button's left edge.
  /// Menu extends to the right.
  ///
  /// This is the default alignment.
  ///
  /// Example (menu is wider than button):
  /// ```
  /// [Button    ]
  /// [Menu          ]
  /// ```
  left,

  /// Menu is centered over the button.
  /// Menu extends equally on both sides.
  ///
  /// Example (menu is wider than button):
  /// ```
  ///   [Button    ]
  /// [Menu          ]
  /// ```
  center,

  /// Menu's right edge aligns with button's right edge.
  /// Menu extends to the left.
  ///
  /// Example (menu is wider than button):
  /// ```
  ///       [Button    ]
  /// [Menu          ]
  /// ```
  right,
}
