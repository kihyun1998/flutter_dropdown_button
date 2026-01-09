import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

// Style presets
class StylePreset {
  final String name;
  final DropdownStyleTheme theme;

  const StylePreset(this.name, this.theme);
}

final List<StylePreset> stylePresets = [
  StylePreset(
    'Material Design',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 8.0,
        elevation: 8.0,
        animationDuration: Duration(milliseconds: 200),
        selectedItemColor: Color(0x1A6750A4),
        itemHoverColor: Color(0x0A6750A4),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  ),
  StylePreset(
    'iOS/Cupertino',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 12.0,
        elevation: 2.0,
        animationDuration: const Duration(milliseconds: 150),
        backgroundColor: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
        selectedItemColor: const Color(0x1A007AFF),
        itemHoverColor: const Color(0x0A007AFF),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  ),
  StylePreset(
    'Minimal Hover',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 12.0,
        elevation: 4.0,
        itemMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBorderRadius: 8.0,
        itemHoverColor: const Color(0xFFE0E0E0),
        selectedItemColor: const Color(0xFFD0D0D0),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        overlayPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),
    ),
  ),
  StylePreset(
    'Custom Scrollbar',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 10.0,
        elevation: 6.0,
        selectedItemColor: Color(0x1A1976D2),
        itemHoverColor: Color(0x0A1976D2),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      scroll: DropdownScrollTheme(
        thickness: 8.0,
        radius: const Radius.circular(4.0),
        thumbColor: Colors.blue.shade400,
        trackColor: Colors.blue.shade50,
        trackBorderColor: Colors.blue.shade200,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
      ),
    ),
  ),
  StylePreset(
    'Vibrant',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 16.0,
        elevation: 12.0,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.deepPurple.shade50,
        selectedItemColor: const Color(0x40673AB7),
        itemHoverColor: const Color(0x20673AB7),
        itemSplashColor: const Color(0x60FF9800),
        itemPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 2),
        iconColor: Colors.deepPurple, // Custom icon color
      ),
    ),
  ),
  StylePreset(
    'Glassmorphism',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 16.0,
        elevation: 8.0,
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        selectedItemColor: Colors.white.withValues(alpha: 0.3),
        itemHoverColor: Colors.white.withValues(alpha: 0.2),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    ),
  ),
  StylePreset(
    'Thick Border',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 12.0,
        elevation: 4.0,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0x1AFF5722),
        itemHoverColor: const Color(0x0AFF5722),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(
          color: Colors.deepOrange,
          width: 3.0, // Thick border for testing
        ),
      ),
    ),
  ),
  StylePreset(
    'Extra Thick Border',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 8.0,
        elevation: 2.0,
        backgroundColor: Colors.blue.shade50,
        selectedItemColor: const Color(0x402196F3),
        itemHoverColor: const Color(0x202196F3),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(
          color: Colors.blue.shade700,
          width: 5.0, // Extra thick border for testing
        ),
      ),
    ),
  ),
  StylePreset(
    'Black with White Border',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 8.0,
        elevation: 6.0,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white.withValues(alpha: 0.2),
        itemHoverColor: Colors.white.withValues(alpha: 0.1),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
    ),
  ),
  StylePreset(
    'Custom Icon & Size',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 12.0,
        elevation: 4.0,
        selectedItemColor: Color(0x1A4CAF50),
        itemHoverColor: Color(0x0A4CAF50),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Icons.expand_more, // Custom icon
        iconSize: 32.0, // Larger icon size
        iconColor: Colors.green,
        iconDisabledColor: Colors.grey,
      ),
    ),
  ),
  StylePreset(
    'Tiny Arrow',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 8.0,
        elevation: 2.0,
        selectedItemColor: Color(0x1AFF9800),
        itemHoverColor: Color(0x0AFF9800),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        icon: Icons.arrow_drop_down, // Different icon
        iconSize: 16.0, // Smaller icon size
        iconColor: Colors.orange,
      ),
    ),
  ),
  StylePreset(
    'Wide Icon Spacing',
    DropdownStyleTheme(
      dropdown: const DropdownTheme(
        borderRadius: 10.0,
        elevation: 4.0,
        selectedItemColor: Color(0x1A9C27B0),
        itemHoverColor: Color(0x0A9C27B0),
        itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        iconPadding: EdgeInsets.only(left: 24.0), // Wide spacing
        iconColor: Colors.purple,
        iconSize: 28.0,
      ),
    ),
  ),
  StylePreset(
    'Item Borders',
    DropdownStyleTheme(
      dropdown: DropdownTheme(
        borderRadius: 8.0,
        elevation: 4.0,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0x1A2196F3),
        itemHoverColor: const Color(0x0A2196F3),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        // Item borders without using separators
        itemBorder: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        excludeLastItemBorder: true, // Last item won't have bottom border
      ),
    ),
  ),
];
