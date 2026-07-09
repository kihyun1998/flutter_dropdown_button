import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// No widget tree, no `pumpWidget`, no `BuildContext`.
///
/// **Characterization, not regression.** None of these were ever red: they pin
/// behaviour that already worked, extracted unchanged from private methods on
/// the widget's `State`. What is new is that they are reachable at all — the
/// alignment mapping and the default filter used to be observable only by
/// rendering a menu and looking at it.

class Fruit {
  const Fruit(this.name);
  final String name;
}

TextItemPresentation<T> text<T>({
  String Function(T)? label,
  T? value,
  String? hintText,
  TextDropdownConfig config = TextDropdownConfig.defaultConfig,
}) {
  return TextItemPresentation<T>(
    label: label,
    value: value,
    hintText: hintText,
    config: config,
    tooltipTheme: DropdownTooltipTheme.defaultTheme,
    enabled: true,
    leadingHeight: 24,
  );
}

CustomItemPresentation<T> custom<T>({
  required List<T> items,
  T? value,
  Widget Function(T)? selectedBuilder,
  Widget? hintWidget,
}) {
  return CustomItemPresentation<T>(
    itemBuilder: (item, isSelected) => Text('$item'),
    items: items,
    value: value,
    selectedBuilder: selectedBuilder,
    hintWidget: hintWidget,
  );
}

void main() {
  group('content alignment', () {
    Alignment alignmentFor(TextAlign textAlign) =>
        text<String>(config: TextDropdownConfig(textAlign: textAlign))
            .contentAlignment;

    test('text mode follows the configured textAlign', () {
      expect(alignmentFor(TextAlign.center), Alignment.center);
      expect(alignmentFor(TextAlign.right), Alignment.centerRight);
      expect(alignmentFor(TextAlign.end), Alignment.centerRight);
      expect(alignmentFor(TextAlign.left), Alignment.centerLeft);
      expect(alignmentFor(TextAlign.start), Alignment.centerLeft);
      expect(alignmentFor(TextAlign.justify), Alignment.centerLeft);
    });

    test('custom mode is always left, whatever the text config says', () {
      expect(custom<String>(items: const ['a']).contentAlignment,
          Alignment.centerLeft);
    });
  });

  group('default search filter', () {
    test('text mode matches the label, case-insensitively', () {
      final filter = text<Fruit>(label: (f) => f.name).defaultSearchFilter!;

      expect(filter(const Fruit('Banana'), 'ban'), isTrue);
      expect(filter(const Fruit('Banana'), 'NAN'), isTrue);
      expect(filter(const Fruit('Apple'), 'ban'), isFalse);
    });

    test('custom mode has none — it cannot read a widget', () {
      expect(custom<String>(items: const ['a']).defaultSearchFilter, isNull);
    });
  });

  group('label extraction', () {
    test('a String is its own label', () {
      expect(text<String>().labelOf('Apple'), 'Apple');
    });

    test('any other T goes through the callback', () {
      expect(text<Fruit>(label: (f) => f.name).labelOf(const Fruit('Kiwi')),
          'Kiwi');
    });

    test('a non-String T without a label fails at construction', () {
      expect(() => text<Fruit>(), throwsAssertionError,
          reason: 'the invariant .text() promises, checked where it lives');
    });
  });

  group('custom selected widget', () {
    test('a value absent from items falls back to the hint', () {
      final presentation = custom<String>(
        items: const ['a', 'b'],
        value: 'gone',
        hintWidget: const Text('pick one'),
      );

      expect((presentation.buildSelected() as Text).data, 'pick one');
    });

    test('no value and no hint widget draws nothing', () {
      expect(
          custom<String>(items: const ['a']).buildSelected(), isA<SizedBox>());
    });

    test('selectedBuilder wins over itemBuilder for the button face', () {
      final presentation = custom<String>(
        items: const ['a'],
        value: 'a',
        selectedBuilder: (item) => Text('face:$item'),
      );

      expect((presentation.buildSelected() as Text).data, 'face:a');
    });
  });
}
