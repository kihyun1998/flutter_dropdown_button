import 'package:flutter/material.dart';

import '../config/text_dropdown_config.dart';
import '../theme/tooltip_theme.dart';
import '../widgets/smart_tooltip_text.dart';

/// Decides whether [item] survives a search for [query].
typedef DropdownSearchFilter<T> = bool Function(T item, String query);

/// How a dropdown draws its items and the face of its button.
///
/// One implementation per rendering mode. The widget asks a presentation what
/// to draw rather than asking itself what mode it is in, so a new mode is a new
/// implementation rather than another branch at every render site.
///
/// A presentation is built fresh on each build and holds only plain values —
/// no `State`, no `BuildContext`. Whatever it needs from the element tree, the
/// widget reads first and hands over.
abstract interface class DropdownItemPresentation<T> {
  /// Where the button's face and each item row sit horizontally.
  Alignment get contentAlignment;

  /// The filter to use when the caller supplies no `searchFilter`.
  ///
  /// Null means this mode has no sensible default: it cannot know how to match
  /// an arbitrary widget against a query.
  DropdownSearchFilter<T>? get defaultSearchFilter;

  /// One row of the open menu.
  Widget buildItem(T item, bool isSelected);

  /// The button's face: the selected item, or the hint when nothing is chosen.
  Widget buildSelected();
}

/// Renders items as text, through a [label] extractor.
///
/// Text gains overflow handling, an automatic tooltip on overflow, and a
/// default search filter — the three things [CustomItemPresentation] cannot
/// offer, because it does not know what an item *says*.
class TextItemPresentation<T> implements DropdownItemPresentation<T> {
  /// Creates the text presentation.
  ///
  /// Asserts that [label] is present unless `T` is [String]; a string is its
  /// own label. This is the invariant `.text()` promises and the default
  /// constructor knows nothing about.
  TextItemPresentation({
    required this.label,
    required this.value,
    required this.hintText,
    required this.config,
    required this.tooltipTheme,
    required this.enabled,
    required this.leadingHeight,
    this.leading,
    this.selectedLeading,
    this.leadingPadding,
  }) : assert(
         label != null || T == String,
         'FlutterDropdownButton<$T>.text() needs a `label` callback.\n'
         'Text mode renders items as text, so it must know how to turn a $T '
         'into a String. Supply `label: (item) => item.someTextProperty`, or '
         'use the default constructor with `itemBuilder` instead.',
       );

  /// Turns an item into the string that represents it.
  final String Function(T item)? label;

  /// The chosen item, if any.
  final T? value;

  /// Shown on the button when [value] is null.
  final String? hintText;

  /// Text rendering rules: overflow, alignment, styles.
  final TextDropdownConfig config;

  /// Styling and behaviour of the overflow tooltip.
  final DropdownTooltipTheme tooltipTheme;

  /// Whether the button is interactive, which selects the disabled text style.
  final bool enabled;

  /// The height a [leading] widget is centred within.
  final double leadingHeight;

  /// Drawn before the text of every item.
  final Widget? leading;

  /// Drawn before the text on the button face. Falls back to [leading].
  final Widget? selectedLeading;

  /// Space between a leading widget and the text.
  final EdgeInsets? leadingPadding;

  /// The text [item] displays.
  ///
  /// Uses [label] when given. Without it, `T` must be [String].
  ///
  /// The throw below is a **release-mode guard**, and is unreachable in debug.
  /// It fires when `label == null && item is! String`, which is exactly the
  /// condition this class's constructor asserts against — and asserts are
  /// compiled out of release builds. Coverage for it is therefore always zero,
  /// and that is not a reason to delete it: without it a release build would
  /// carry on with no label and fail somewhere less legible.
  String labelOf(T item) {
    final extract = label;
    if (extract != null) return extract(item);
    if (item is String) return item;

    // coverage:ignore-start
    throw FlutterError(
      'FlutterDropdownButton<$T>.text() needs a `label` callback.\n'
      'Text mode renders items as text, so it must know how to turn a $T '
      'into a String. Supply one:\n\n'
      '  FlutterDropdownButton<$T>.text(\n'
      '    items: items,\n'
      '    label: (item) => item.someTextProperty,\n'
      '  )\n\n'
      '`label` may only be omitted when T is String.',
    );
    // coverage:ignore-end
  }

  @override
  Alignment get contentAlignment => _alignmentOf(config.textAlign);

  /// Case-insensitive `contains` over the item's label, whatever `T` is.
  @override
  DropdownSearchFilter<T>? get defaultSearchFilter =>
      (item, query) =>
          labelOf(item).toLowerCase().contains(query.toLowerCase());

  /// One run of text under this theme's rules.
  ///
  /// Every caller shares the same eight `config` pass-throughs; only the string
  /// and its style differ. Writing them out twice is how `semanticsLabel` came
  /// to reach the items and not the button. [style] is passed through verbatim:
  /// a null style is a decision, not a gap.
  SmartTooltipText _text(String text, TextStyle? style) {
    return SmartTooltipText(
      text: text,
      tooltipTheme: tooltipTheme,
      style: style,
      textAlign: config.textAlign,
      maxLines: config.maxLines,
      overflow: config.overflow,
      softWrap: config.softWrap,
      textDirection: config.textDirection,
      locale: config.locale,
      textScaler: config.textScaler,
    );
  }

  @override
  Widget buildItem(T item, bool isSelected) {
    final text = _text(
      labelOf(item),
      isSelected
          ? config.selectedTextStyle ?? config.textStyle
          : config.textStyle,
    );

    // `config.semanticsLabel` deliberately does not reach here. `Text`'s
    // semantics label *replaces* the announced string, so applying one label to
    // every row made a screen reader read the same phrase for all of them.
    // It describes the dropdown, and it is applied in [buildSelected].
    return _withLeading(text, leading);
  }

  @override
  Widget buildSelected() {
    final selected = value;
    final selectedText = selected == null ? null : labelOf(selected);
    final displayText = selectedText ?? hintText ?? '';
    final isHint = selectedText == null;

    final baseStyle = isHint ? config.hintStyle : config.textStyle;
    final resolvedStyle = !enabled && config.disabledTextStyle != null
        ? (baseStyle?.merge(config.disabledTextStyle) ??
              config.disabledTextStyle)
        : baseStyle;

    final text = _text(displayText, resolvedStyle);

    // The hint never takes a leading widget; only a chosen item does.
    final face = _withLeading(
      text,
      selectedText != null ? (selectedLeading ?? leading) : null,
    );

    // The label describes the control, so it goes on the control. Wrapping
    // rather than passing it to `Text` keeps the selected value announced too.
    final describe = config.semanticsLabel;
    if (describe == null) return face;
    return Semantics(label: describe, child: face);
  }

  Widget _withLeading(Widget text, Widget? leadingWidget) {
    if (leadingWidget == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: leadingPadding ?? const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: leadingHeight,
            child: Center(child: leadingWidget),
          ),
        ),
        Flexible(child: text),
      ],
    );
  }
}

/// Renders each item as whatever widget [itemBuilder] returns.
class CustomItemPresentation<T> implements DropdownItemPresentation<T> {
  /// Creates the custom-widget presentation.
  const CustomItemPresentation({
    required this.itemBuilder,
    required this.items,
    required this.value,
    this.selectedBuilder,
    this.hintWidget,
  });

  /// Builds one item row.
  final Widget Function(T item, bool isSelected) itemBuilder;

  /// The items on offer, consulted to decide whether [value] is still one.
  final List<T> items;

  /// The chosen item, if any.
  final T? value;

  /// Builds the button's face. Falls back to [itemBuilder].
  final Widget Function(T item)? selectedBuilder;

  /// Shown on the button when nothing is chosen.
  final Widget? hintWidget;

  @override
  Alignment get contentAlignment => Alignment.centerLeft;

  /// None. This mode cannot match an arbitrary widget against a query, so a
  /// caller who wants search must supply `searchFilter` themselves.
  @override
  DropdownSearchFilter<T>? get defaultSearchFilter => null;

  @override
  Widget buildItem(T item, bool isSelected) => itemBuilder(item, isSelected);

  @override
  Widget buildSelected() {
    final selected = value;
    if (selected != null && items.contains(selected)) {
      final build = selectedBuilder;
      if (build != null) return build(selected);
      return itemBuilder(selected, true);
    }
    return hintWidget ?? const SizedBox.shrink();
  }
}

Alignment _alignmentOf(TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.center:
      return Alignment.center;
    case TextAlign.right:
    case TextAlign.end:
      return Alignment.centerRight;
    case TextAlign.left:
    case TextAlign.start:
    case TextAlign.justify:
      return Alignment.centerLeft;
  }
}
