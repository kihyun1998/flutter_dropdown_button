/// The state a knobbed recipe's stage and its knob pane both read.
library;

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

import '../recipes/multi_select_recipe.dart';
import '../recipes/search_recipe.dart';
import '../recipes/wheel_scroll_recipe.dart';

/// What the multi-select recipe's knobs hold.
///
/// **Only the knobs.** The recipe's own selection — the `Set` the reader ticks
/// — lives in the recipe's `State`, because a recipe that took its selection
/// from an injected object would not be pasteable, and because a caller holding
/// the set is precisely what this package's API is.
///
/// This half lives outside for a different reason: the stage and the knob pane
/// are two views of one thing, drawn on the same frame, and something has to
/// own the value they both read.
class MultiSelectKnobs extends ChangeNotifier {
  bool _searchable = true;
  bool get searchable => _searchable;
  set searchable(bool value) {
    if (_searchable == value) return;
    _searchable = value;
    notifyListeners();
  }

  bool _solarisDropped = false;
  bool get solarisDropped => _solarisDropped;
  set solarisDropped(bool value) {
    if (_solarisDropped == value) return;
    _solarisDropped = value;
    notifyListeners();
  }
}

/// The stage half — the recipe, and nothing around it.
class MultiSelectStage extends StatelessWidget {
  const MultiSelectStage({super.key, required this.knobs});

  final MultiSelectKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => MultiSelectRecipe(
      searchable: knobs.searchable,
      solarisDropped: knobs.solarisDropped,
    ),
  );
}

/// The knob half.
class MultiSelectKnobPane extends StatelessWidget {
  const MultiSelectKnobPane({super.key, required this.knobs});

  final MultiSelectKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('searchable'),
          value: knobs.searchable,
          onChanged: (v) => knobs.searchable = v,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Drop Solaris from the data'),
          subtitle: const Text(
            'Tick Solaris first, then flip this: the row goes, the choice '
            'stays, the count still includes it.',
          ),
          value: knobs.solarisDropped,
          onChanged: (v) => knobs.solarisDropped = v,
        ),
      ],
    ),
  );
}

/// What the search recipe's knobs hold.
class SearchKnobs extends ChangeNotifier {
  bool _matchCountry = true;
  bool get matchCountry => _matchCountry;
  set matchCountry(bool value) {
    if (_matchCountry == value) return;
    _matchCountry = value;
    notifyListeners();
  }
}

/// The stage half.
class SearchStage extends StatelessWidget {
  const SearchStage({super.key, required this.knobs});

  final SearchKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => SearchRecipe(matchCountry: knobs.matchCountry),
  );
}

/// The knob half.
class SearchKnobPane extends StatelessWidget {
  const SearchKnobPane({super.key, required this.knobs});

  final SearchKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('searchFilter matches the country'),
          subtitle: const Text(
            'Off, the default filter reads only the label. Type "korea" with '
            'it off to reach the empty state.',
          ),
          value: knobs.matchCountry,
          onChanged: (v) => knobs.matchCountry = v,
        ),
      ],
    ),
  );
}

/// Which motion the wheel recipe's right-hand menu uses.
enum WheelKind {
  /// `wheelMotion` left unset.
  unset,
  spring,
  curve,
  lerp,

  /// `Duration.zero`: the jump from before 4.3.0.
  off,
}

/// What the wheel recipe's knobs hold.
class WheelKnobs extends ChangeNotifier {
  /// The curves offered, by the name the code pane prints.
  static const curves = <String, Curve>{
    'easeOutCubic': Curves.easeOutCubic,
    'easeOut': Curves.easeOut,
    'easeInOut': Curves.easeInOut,
    'linear': Curves.linear,
  };

  WheelKind _kind = WheelKind.unset;
  WheelKind get kind => _kind;
  set kind(WheelKind value) {
    if (_kind == value) return;
    _kind = value;
    notifyListeners();
  }

  /// Spring and curve duration, in milliseconds.
  int _durationMs = 250;
  int get durationMs => _durationMs;
  set durationMs(int value) {
    if (_durationMs == value) return;
    _durationMs = value;
    notifyListeners();
  }

  /// Spring bounce, in tenths so the slider lands on round values.
  int _bounceTenths = 0;
  int get bounceTenths => _bounceTenths;
  set bounceTenths(int value) {
    if (_bounceTenths == value) return;
    _bounceTenths = value;
    notifyListeners();
  }

  String _curve = 'easeOutCubic';
  String get curve => _curve;
  set curve(String value) {
    if (_curve == value) return;
    _curve = value;
    notifyListeners();
  }

  /// Lerp time constant, in milliseconds.
  int _timeConstantMs = 60;
  int get timeConstantMs => _timeConstantMs;
  set timeConstantMs(int value) {
    if (_timeConstantMs == value) return;
    _timeConstantMs = value;
    notifyListeners();
  }

  /// The motion the knobs describe; null when it is left unset.
  WheelMotion? get motion => switch (_kind) {
    WheelKind.unset => null,
    WheelKind.spring => WheelMotion.spring(
      duration: Duration(milliseconds: _durationMs),
      bounce: _bounceTenths / 10,
    ),
    WheelKind.curve => WheelMotion.curve(
      duration: Duration(milliseconds: _durationMs),
      curve: curves[_curve]!,
    ),
    WheelKind.lerp => WheelMotion.lerp(
      timeConstant: Duration(milliseconds: _timeConstantMs),
    ),
    WheelKind.off => const WheelMotion.spring(duration: Duration.zero),
  };

  /// [motion], as the line that would produce it.
  String get code => switch (_kind) {
    WheelKind.unset =>
      '// wheelMotion unset: the package default,\n'
          '// WheelMotion.spring(duration: Duration(milliseconds: 250))',
    WheelKind.spring =>
      'wheelMotion: WheelMotion.spring(\n'
          '  duration: Duration(milliseconds: $_durationMs),\n'
          '${_bounceTenths == 0 ? '' : '  bounce: ${_bounceTenths / 10},\n'}'
          '),',
    WheelKind.curve =>
      'wheelMotion: WheelMotion.curve(\n'
          '  duration: Duration(milliseconds: $_durationMs),\n'
          '  curve: Curves.$_curve,\n'
          '),',
    WheelKind.lerp =>
      'wheelMotion: WheelMotion.lerp(\n'
          '  timeConstant: Duration(milliseconds: $_timeConstantMs),\n'
          '),',
    WheelKind.off =>
      'wheelMotion: WheelMotion.spring(duration: Duration.zero),',
  };
}

/// The stage half.
class WheelScrollStage extends StatelessWidget {
  const WheelScrollStage({super.key, required this.knobs});

  final WheelKnobs knobs;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => WheelScrollRecipe(wheelMotion: knobs.motion),
  );
}

/// The knob half.
class WheelScrollKnobPane extends StatelessWidget {
  const WheelScrollKnobPane({super.key, required this.knobs});

  final WheelKnobs knobs;

  static const _labels = {
    WheelKind.unset: 'Unset — the default',
    WheelKind.spring: 'WheelMotion.spring',
    WheelKind.curve: 'WheelMotion.curve',
    WheelKind.lerp: 'WheelMotion.lerp',
    WheelKind.off: 'Off — Duration.zero',
  };

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: knobs,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final kind in WheelKind.values)
          _choice(
            _labels[kind]!,
            selected: knobs.kind == kind,
            onTap: () => knobs.kind = kind,
          ),
        if (knobs.kind == WheelKind.spring || knobs.kind == WheelKind.curve)
          _slider(
            'duration: ${knobs.durationMs} ms',
            'How long a notch takes to arrive.',
            knobs.durationMs.toDouble(),
            50,
            1000,
            19,
            (v) => knobs.durationMs = v.round(),
          ),
        if (knobs.kind == WheelKind.spring)
          _slider(
            'bounce: ${knobs.bounceTenths / 10}',
            'Above 0 passes the row and comes back. The menu never passes '
                'its own ends.',
            knobs.bounceTenths.toDouble(),
            -5,
            9,
            14,
            (v) => knobs.bounceTenths = v.round(),
          ),
        if (knobs.kind == WheelKind.curve)
          for (final name in WheelKnobs.curves.keys)
            _choice(
              'Curves.$name',
              selected: knobs.curve == name,
              onTap: () => knobs.curve = name,
              indent: 16,
            ),
        if (knobs.kind == WheelKind.lerp)
          _slider(
            'timeConstant: ${knobs.timeConstantMs} ms',
            'About 63% of the remaining distance per time constant.',
            knobs.timeConstantMs.toDouble(),
            10,
            300,
            29,
            (v) => knobs.timeConstantMs = v.round(),
          ),
        const SizedBox(height: 16),
        Text('Code', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        SelectableText(
          knobs.code,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ],
    ),
  );

  /// One option of a pick-one group, drawn as a [ListTile].
  Widget _choice(
    String title, {
    required bool selected,
    required VoidCallback onTap,
    double indent = 0,
  }) => ListTile(
    contentPadding: EdgeInsets.only(left: indent),
    dense: true,
    selected: selected,
    leading: Icon(
      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
    ),
    title: Text(title),
    onTap: onTap,
  );

  Widget _slider(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
