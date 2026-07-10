import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';
import 'package:flutter_test/flutter_test.dart';

/// No widget tree.
///
/// Two properties per class, and the second is the one that earns its keep:
///
/// * `copyWith()` with no arguments preserves every field. This is the only
///   thing that evaluates the **right** operand of each `x ?? this.x`. Testing
///   fields one at a time only ever evaluates the left one.
/// * `copyWith(<every field of another instance>)` reproduces that other
///   instance. This is what catches `borderRadius: borderRadius ?? this.border`
///   — a mis-wired field that a preservation test cannot see, because the
///   wrong field is preserved just as faithfully as the right one.
///
/// These classes define no `==`, so each is compared through a named snapshot.
/// A failure names the field rather than an index.

/// Distinct per field, on purpose.
///
/// If two fields in the same instance carry the same value, `copyWith` can
/// preserve or replace the *wrong* one and the snapshot still matches. Proven:
/// rewiring `iconDisabledColor: iconDisabledColor ?? this.iconColor` left all
/// twelve tests green until these colours were made unique.
Color _a(int i) => Color(0xFFA00000 + i);
Color _b(int i) => Color(0xFFB00000 + i);

void expectSame(Map<String, Object?> actual, Map<String, Object?> expected) {
  expect(actual, expected);
}

void main() {
  group('DropdownTheme', () {
    Map<String, Object?> snap(DropdownTheme t) => {
      'borderRadius': t.borderRadius,
      'elevation': t.elevation,
      'backgroundColor': t.backgroundColor,
      'border': t.border,
      'selectedItemColor': t.selectedItemColor,
      'itemHoverColor': t.itemHoverColor,
      'itemSplashColor': t.itemSplashColor,
      'itemHighlightColor': t.itemHighlightColor,
      'buttonHoverColor': t.buttonHoverColor,
      'buttonSplashColor': t.buttonSplashColor,
      'buttonHighlightColor': t.buttonHighlightColor,
      'shadowColor': t.shadowColor,
      'overlayDecoration': t.overlayDecoration,
      'buttonDecoration': t.buttonDecoration,
      'itemPadding': t.itemPadding,
      'buttonPadding': t.buttonPadding,
      'itemMargin': t.itemMargin,
      'itemBorderRadius': t.itemBorderRadius,
      'iconColor': t.iconColor,
      'iconDisabledColor': t.iconDisabledColor,
      'icon': t.icon,
      'iconSize': t.iconSize,
      'buttonHeight': t.buttonHeight,
      'iconPadding': t.iconPadding,
      'overlayPadding': t.overlayPadding,
      'itemBorder': t.itemBorder,
      'excludeLastItemBorder': t.excludeLastItemBorder,
      'disabledBackgroundColor': t.disabledBackgroundColor,
      'disabledBorder': t.disabledBorder,
      'disabledButtonDecoration': t.disabledButtonDecoration,
    };

    final a = DropdownTheme(
      borderRadius: 1,
      elevation: 2,
      backgroundColor: _a(1),
      border: Border.all(color: _a(2)),
      selectedItemColor: _a(3),
      itemHoverColor: _a(4),
      itemSplashColor: _a(5),
      itemHighlightColor: _a(6),
      buttonHoverColor: _a(7),
      buttonSplashColor: _a(8),
      buttonHighlightColor: _a(9),
      shadowColor: _a(10),
      overlayDecoration: BoxDecoration(color: _a(11)),
      buttonDecoration: BoxDecoration(color: _a(12)),
      itemPadding: const EdgeInsets.all(1),
      buttonPadding: const EdgeInsets.all(2),
      itemMargin: const EdgeInsets.all(3),
      itemBorderRadius: 3,
      iconColor: _a(13),
      iconDisabledColor: _a(14),
      icon: Icons.abc,
      iconSize: 4,
      buttonHeight: 5,
      iconPadding: const EdgeInsets.all(4),
      overlayPadding: const EdgeInsets.all(5),
      itemBorder: Border.all(color: _a(15), width: 2),
      excludeLastItemBorder: false,
      disabledBackgroundColor: _a(16),
      disabledBorder: Border.all(color: _a(17), width: 3),
      disabledButtonDecoration: BoxDecoration(color: _a(18)),
    );

    final b = DropdownTheme(
      borderRadius: 10,
      elevation: 20,
      backgroundColor: _b(1),
      border: Border.all(color: _b(2)),
      selectedItemColor: _b(3),
      itemHoverColor: _b(4),
      itemSplashColor: _b(5),
      itemHighlightColor: _b(6),
      buttonHoverColor: _b(7),
      buttonSplashColor: _b(8),
      buttonHighlightColor: _b(9),
      shadowColor: _b(10),
      overlayDecoration: BoxDecoration(color: _b(11)),
      buttonDecoration: BoxDecoration(color: _b(12)),
      itemPadding: const EdgeInsets.all(10),
      buttonPadding: const EdgeInsets.all(20),
      itemMargin: const EdgeInsets.all(30),
      itemBorderRadius: 30,
      iconColor: _b(13),
      iconDisabledColor: _b(14),
      icon: Icons.zoom_in,
      iconSize: 40,
      buttonHeight: 50,
      iconPadding: const EdgeInsets.all(40),
      overlayPadding: const EdgeInsets.all(50),
      itemBorder: Border.all(color: _b(15), width: 20),
      excludeLastItemBorder: true,
      disabledBackgroundColor: _b(16),
      disabledBorder: Border.all(color: _b(17), width: 30),
      disabledButtonDecoration: BoxDecoration(color: _b(18)),
    );

    test('copyWith() preserves every field', () {
      expectSame(snap(a.copyWith()), snap(a));
    });

    test('copyWith(everything) reproduces the other instance', () {
      final copy = a.copyWith(
        borderRadius: b.borderRadius,
        elevation: b.elevation,
        backgroundColor: b.backgroundColor,
        border: b.border,
        selectedItemColor: b.selectedItemColor,
        itemHoverColor: b.itemHoverColor,
        itemSplashColor: b.itemSplashColor,
        itemHighlightColor: b.itemHighlightColor,
        buttonHoverColor: b.buttonHoverColor,
        buttonSplashColor: b.buttonSplashColor,
        buttonHighlightColor: b.buttonHighlightColor,
        shadowColor: b.shadowColor,
        overlayDecoration: b.overlayDecoration,
        buttonDecoration: b.buttonDecoration,
        itemPadding: b.itemPadding,
        buttonPadding: b.buttonPadding,
        itemMargin: b.itemMargin,
        itemBorderRadius: b.itemBorderRadius,
        iconColor: b.iconColor,
        iconDisabledColor: b.iconDisabledColor,
        icon: b.icon,
        iconSize: b.iconSize,
        buttonHeight: b.buttonHeight,
        iconPadding: b.iconPadding,
        overlayPadding: b.overlayPadding,
        itemBorder: b.itemBorder,
        excludeLastItemBorder: b.excludeLastItemBorder,
        disabledBackgroundColor: b.disabledBackgroundColor,
        disabledBorder: b.disabledBorder,
        disabledButtonDecoration: b.disabledButtonDecoration,
      );

      expectSame(snap(copy), snap(b));
    });
  });

  group('DropdownScrollTheme', () {
    Map<String, Object?> snap(DropdownScrollTheme t) => {
      'thickness': t.thickness,
      'thumbWidth': t.thumbWidth,
      'radius': t.radius,
      'thumbColor': t.thumbColor,
      'trackColor': t.trackColor,
      'trackBorderColor': t.trackBorderColor,
      'thumbVisibility': t.thumbVisibility,
      'trackVisibility': t.trackVisibility,
      'interactive': t.interactive,
      'crossAxisMargin': t.crossAxisMargin,
      'mainAxisMargin': t.mainAxisMargin,
      'minThumbLength': t.minThumbLength,
      'showScrollGradient': t.showScrollGradient,
      'gradientHeight': t.gradientHeight,
      'gradientColors': t.gradientColors,
    };

    final a = DropdownScrollTheme(
      thickness: 1,
      thumbWidth: 2,
      radius: const Radius.circular(3),
      thumbColor: _a(1),
      trackColor: _a(2),
      trackBorderColor: _a(3),
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      crossAxisMargin: 4,
      mainAxisMargin: 5,
      minThumbLength: 6,
      showScrollGradient: true,
      gradientHeight: 7,
      gradientColors: [_a(4)],
    );

    final b = DropdownScrollTheme(
      thickness: 10,
      thumbWidth: 20,
      radius: const Radius.circular(30),
      thumbColor: _b(1),
      trackColor: _b(2),
      trackBorderColor: _b(3),
      thumbVisibility: false,
      trackVisibility: false,
      interactive: false,
      crossAxisMargin: 40,
      mainAxisMargin: 50,
      minThumbLength: 60,
      showScrollGradient: false,
      gradientHeight: 70,
      gradientColors: [_b(4)],
    );

    test('copyWith() preserves every field', () {
      expectSame(snap(a.copyWith()), snap(a));
    });

    test('copyWith(everything) reproduces the other instance', () {
      final copy = a.copyWith(
        thickness: b.thickness,
        thumbWidth: b.thumbWidth,
        radius: b.radius,
        thumbColor: b.thumbColor,
        trackColor: b.trackColor,
        trackBorderColor: b.trackBorderColor,
        thumbVisibility: b.thumbVisibility,
        trackVisibility: b.trackVisibility,
        interactive: b.interactive,
        crossAxisMargin: b.crossAxisMargin,
        mainAxisMargin: b.mainAxisMargin,
        minThumbLength: b.minThumbLength,
        showScrollGradient: b.showScrollGradient,
        gradientHeight: b.gradientHeight,
        gradientColors: b.gradientColors,
      );

      expectSame(snap(copy), snap(b));
    });
  });

  group('DropdownTooltipTheme', () {
    Map<String, Object?> snap(DropdownTooltipTheme t) => {
      'backgroundColor': t.backgroundColor,
      'textColor': t.textColor,
      'textStyle': t.textStyle,
      'decoration': t.decoration,
      'borderRadius': t.borderRadius,
      'border': t.border,
      'shadow': t.shadow,
      'padding': t.padding,
      'margin': t.margin,
      'constraints': t.constraints,
      'textAlign': t.textAlign,
      'enabled': t.enabled,
      'mode': t.mode,
      'waitDuration': t.waitDuration,
      'showDuration': t.showDuration,
      'exitDuration': t.exitDuration,
      'verticalOffset': t.verticalOffset,
      'preferBelow': t.preferBelow,
      'enableTapToDismiss': t.enableTapToDismiss,
      'triggerMode': t.triggerMode,
    };

    final a = DropdownTooltipTheme(
      backgroundColor: _a(1),
      textColor: _a(2),
      textStyle: const TextStyle(fontSize: 1),
      decoration: BoxDecoration(color: _a(3)),
      borderRadius: BorderRadius.circular(1),
      border: Border.all(color: _a(4)),
      shadow: [BoxShadow(color: _a(5))],
      padding: const EdgeInsets.all(1),
      margin: const EdgeInsets.all(2),
      constraints: const BoxConstraints(maxWidth: 1),
      textAlign: TextAlign.left,
      enabled: true,
      mode: TooltipMode.always,
      waitDuration: const Duration(seconds: 1),
      showDuration: const Duration(seconds: 2),
      exitDuration: const Duration(seconds: 3),
      verticalOffset: 1,
      preferBelow: true,
      enableTapToDismiss: true,
      triggerMode: TooltipTriggerMode.tap,
    );

    final b = DropdownTooltipTheme(
      backgroundColor: _b(1),
      textColor: _b(2),
      textStyle: const TextStyle(fontSize: 10),
      decoration: BoxDecoration(color: _b(3)),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _b(4)),
      shadow: [BoxShadow(color: _b(5))],
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 10),
      textAlign: TextAlign.right,
      enabled: false,
      mode: TooltipMode.disabled,
      waitDuration: const Duration(seconds: 10),
      showDuration: const Duration(seconds: 20),
      exitDuration: const Duration(seconds: 30),
      verticalOffset: 10,
      preferBelow: false,
      enableTapToDismiss: false,
      triggerMode: TooltipTriggerMode.longPress,
    );

    test('copyWith() preserves every field', () {
      expectSame(snap(a.copyWith()), snap(a));
    });

    test('copyWith(everything) reproduces the other instance', () {
      final copy = a.copyWith(
        backgroundColor: b.backgroundColor,
        textColor: b.textColor,
        textStyle: b.textStyle,
        decoration: b.decoration,
        borderRadius: b.borderRadius,
        border: b.border,
        shadow: b.shadow,
        padding: b.padding,
        margin: b.margin,
        constraints: b.constraints,
        textAlign: b.textAlign,
        enabled: b.enabled,
        mode: b.mode,
        waitDuration: b.waitDuration,
        showDuration: b.showDuration,
        exitDuration: b.exitDuration,
        verticalOffset: b.verticalOffset,
        preferBelow: b.preferBelow,
        enableTapToDismiss: b.enableTapToDismiss,
        triggerMode: b.triggerMode,
      );

      expectSame(snap(copy), snap(b));
    });
  });

  group('SearchFieldTheme', () {
    Map<String, Object?> snap(SearchFieldTheme t) => {
      'decoration': t.decoration,
      'textStyle': t.textStyle,
      'cursorColor': t.cursorColor,
      'cursorWidth': t.cursorWidth,
      'cursorHeight': t.cursorHeight,
      'cursorRadius': t.cursorRadius,
      'backgroundColor': t.backgroundColor,
      'height': t.height,
      'margin': t.margin,
      'padding': t.padding,
      'borderRadius': t.borderRadius,
      'border': t.border,
      'focusedBorder': t.focusedBorder,
      'contentPadding': t.contentPadding,
      'divider': t.divider,
      'dividerHeight': t.dividerHeight,
      'autofocus': t.autofocus,
      'keyboardType': t.keyboardType,
      'textInputAction': t.textInputAction,
      'textAlign': t.textAlign,
    };

    final a = SearchFieldTheme(
      decoration: const InputDecoration(hintText: 'a'),
      textStyle: const TextStyle(fontSize: 1),
      cursorColor: _a(1),
      cursorWidth: 1,
      cursorHeight: 2,
      cursorRadius: const Radius.circular(3),
      backgroundColor: _a(2),
      height: 4,
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(2),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: _a(3)),
      focusedBorder: Border.all(color: _a(4), width: 2),
      contentPadding: const EdgeInsets.all(3),
      divider: const Divider(height: 1),
      dividerHeight: 1,
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.left,
    );

    final b = SearchFieldTheme(
      decoration: const InputDecoration(hintText: 'b'),
      textStyle: const TextStyle(fontSize: 10),
      cursorColor: _b(1),
      cursorWidth: 10,
      cursorHeight: 20,
      cursorRadius: const Radius.circular(30),
      backgroundColor: _b(2),
      height: 40,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: _b(3)),
      focusedBorder: Border.all(color: _b(4), width: 20),
      contentPadding: const EdgeInsets.all(30),
      divider: const Divider(height: 10),
      dividerHeight: 10,
      autofocus: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.search,
      textAlign: TextAlign.right,
    );

    test('copyWith() preserves every field', () {
      expectSame(snap(a.copyWith()), snap(a));
    });

    test('copyWith(everything) reproduces the other instance', () {
      final copy = a.copyWith(
        decoration: b.decoration,
        textStyle: b.textStyle,
        cursorColor: b.cursorColor,
        cursorWidth: b.cursorWidth,
        cursorHeight: b.cursorHeight,
        cursorRadius: b.cursorRadius,
        backgroundColor: b.backgroundColor,
        height: b.height,
        margin: b.margin,
        padding: b.padding,
        borderRadius: b.borderRadius,
        border: b.border,
        focusedBorder: b.focusedBorder,
        contentPadding: b.contentPadding,
        divider: b.divider,
        dividerHeight: b.dividerHeight,
        autofocus: b.autofocus,
        keyboardType: b.keyboardType,
        textInputAction: b.textInputAction,
        textAlign: b.textAlign,
      );

      expectSame(snap(copy), snap(b));
    });
  });

  group('DropdownStyleTheme', () {
    Map<String, Object?> snap(DropdownStyleTheme t) => {
      'dropdown': t.dropdown,
      'scroll': t.scroll,
      'tooltip': t.tooltip,
      'search': t.search,
    };

    final a = DropdownStyleTheme(
      dropdown: DropdownTheme(backgroundColor: _a(1)),
      scroll: DropdownScrollTheme(thumbColor: _a(2)),
      tooltip: DropdownTooltipTheme(backgroundColor: _a(3)),
      search: SearchFieldTheme(backgroundColor: _a(4)),
    );

    final b = DropdownStyleTheme(
      dropdown: DropdownTheme(backgroundColor: _b(1)),
      scroll: DropdownScrollTheme(thumbColor: _b(2)),
      tooltip: DropdownTooltipTheme(backgroundColor: _b(3)),
      search: SearchFieldTheme(backgroundColor: _b(4)),
    );

    test('copyWith() preserves every field', () {
      expectSame(snap(a.copyWith()), snap(a));
    });

    test('copyWith(everything) reproduces the other instance', () {
      final copy = a.copyWith(
        dropdown: b.dropdown,
        scroll: b.scroll,
        tooltip: b.tooltip,
        search: b.search,
      );

      expectSame(snap(copy), snap(b));
    });
  });

  group('TextDropdownConfig', () {
    Map<String, Object?> snap(TextDropdownConfig c) => {
      'overflow': c.overflow,
      'maxLines': c.maxLines,
      'textStyle': c.textStyle,
      'hintStyle': c.hintStyle,
      'selectedTextStyle': c.selectedTextStyle,
      'disabledTextStyle': c.disabledTextStyle,
      'textAlign': c.textAlign,
      'softWrap': c.softWrap,
      'textDirection': c.textDirection,
      'locale': c.locale,
      'textScaler': c.textScaler,
      'semanticsLabel': c.semanticsLabel,
    };

    const a = TextDropdownConfig(
      overflow: TextOverflow.clip,
      maxLines: 1,
      textStyle: TextStyle(fontSize: 1),
      hintStyle: TextStyle(fontSize: 2),
      selectedTextStyle: TextStyle(fontSize: 3),
      disabledTextStyle: TextStyle(fontSize: 4),
      textAlign: TextAlign.left,
      softWrap: true,
      textDirection: TextDirection.ltr,
      locale: Locale('en'),
      textScaler: TextScaler.linear(1),
      semanticsLabel: 'a',
    );

    const b = TextDropdownConfig(
      overflow: TextOverflow.fade,
      maxLines: 10,
      textStyle: TextStyle(fontSize: 10),
      hintStyle: TextStyle(fontSize: 20),
      selectedTextStyle: TextStyle(fontSize: 30),
      disabledTextStyle: TextStyle(fontSize: 40),
      textAlign: TextAlign.right,
      softWrap: false,
      textDirection: TextDirection.rtl,
      locale: Locale('ko'),
      textScaler: TextScaler.linear(2),
      semanticsLabel: 'b',
    );

    test('copyWith() preserves every field', () {
      expectSame(snap(a.copyWith()), snap(a));
    });

    test('copyWith(everything) reproduces the other instance', () {
      final copy = a.copyWith(
        overflow: b.overflow,
        maxLines: b.maxLines,
        textStyle: b.textStyle,
        hintStyle: b.hintStyle,
        selectedTextStyle: b.selectedTextStyle,
        disabledTextStyle: b.disabledTextStyle,
        textAlign: b.textAlign,
        softWrap: b.softWrap,
        textDirection: b.textDirection,
        locale: b.locale,
        textScaler: b.textScaler,
        semanticsLabel: b.semanticsLabel,
      );

      expectSame(snap(copy), snap(b));
    });
  });
}
