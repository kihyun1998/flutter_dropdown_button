/// Scroll-wheel motion — the default glide next to the old jump, in one file.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

const _stations = [
  'Seoul',
  'Yongsan',
  'Gwangmyeong',
  'Cheonan-Asan',
  'Osong',
  'Daejeon',
  'Gimcheon-Gumi',
  'Dongdaegu',
  'Singyeongju',
  'Ulsan',
  'Busan',
  'Suseo',
  'Dongtan',
  'Pyeongtaek-Jije',
  'Gongju',
  'Iksan',
  'Jeongeup',
  'Gwangju-Songjeong',
  'Naju',
  'Mokpo',
  'Jeonju',
  'Namwon',
  'Gokseong',
  'Suncheon',
  'Yeosu-Expo',
  'Gangneung',
  'Jinbu',
  'Pyeongchang',
  'Dunnae',
  'Hoengseong',
  'Manjong',
  'Seowonju',
  'Yangpyeong',
  'Cheongnyangni',
];

/// A menu long enough that one wheel notch is only a small part of it.
///
/// **A notch glides; it no longer jumps.** Since 4.3.0 every dropdown whose menu
/// scrolls animates a scroll-wheel notch to the place it would have jumped to.
/// The place is unchanged — only the path to it. [DropdownScrollTheme.wheelMotion]
/// chooses the path, and leaving it unset is a 250 ms spring that does not pass
/// its target.
///
/// The left menu is pinned to the old behaviour with a zero duration, which is
/// the exact jump rather than a very fast glide. The right one uses
/// [wheelMotion], and null there is the package default.
///
/// **Only the wheel is affected.** Drag the scrollbar thumb or use the keyboard
/// and both menus behave identically. On the web a trackpad counts as a wheel,
/// because the browser delivers its scrolling the same way.
class WheelScrollRecipe extends StatefulWidget {
  const WheelScrollRecipe({super.key, this.wheelMotion});

  /// The motion the right-hand menu uses. Null is the package default.
  final WheelMotion? wheelMotion;

  @override
  State<WheelScrollRecipe> createState() => _WheelScrollRecipeState();
}

class _WheelScrollRecipeState extends State<WheelScrollRecipe> {
  String? _jumping;
  String? _gliding;

  /// The behaviour before 4.3.0: a notch moves the whole distance at once.
  static const _jump = DropdownStyleTheme(
    scroll: DropdownScrollTheme(
      wheelMotion: WheelMotion.spring(duration: Duration.zero),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Open either menu and turn the mouse wheel one notch at a time',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        const Text(
          'Both land on the same row. Only one menu is open at a time, so '
          'switch between them to compare.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 32,
          runSpacing: 24,
          children: [
            _column(
              context,
              'Jumps — Duration.zero',
              FlutterDropdownButton<String>.text(
                width: 240,
                height: 240,
                items: _stations,
                value: _jumping,
                hint: 'Pick a station',
                theme: _jump,
                onChanged: (value) => setState(() => _jumping = value),
              ),
            ),
            _column(
              context,
              widget.wheelMotion == null
                  ? 'Glides — the default'
                  : 'Glides — the motion on the right',
              FlutterDropdownButton<String>.text(
                width: 240,
                height: 240,
                items: _stations,
                value: _gliding,
                hint: 'Pick a station',
                // Null leaves the whole theme to the package, whose scroll
                // theme names no motion — which is the 250 ms spring.
                theme: widget.wheelMotion == null
                    ? null
                    : DropdownStyleTheme(
                        scroll: DropdownScrollTheme(
                          wheelMotion: widget.wheelMotion,
                        ),
                      ),
                onChanged: (value) => setState(() => _gliding = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _column(BuildContext context, String title, Widget dropdown) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      dropdown,
    ],
  );
}
