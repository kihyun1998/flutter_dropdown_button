import 'package:flutter/widgets.dart';

import '../presentation/item_presentation.dart';

/// Owns a dropdown's search query: its text field, its focus, and its lifetime.
///
/// **A `State` holds one; it does not inherit from it.** The controller is
/// exported, so a third party building their own dropdown holds the same object
/// `FlutterDropdownButton` does.
///
/// It deliberately does **not** know about the menu or the scroll position.
/// Those belong to other modules, and a query change that also scrolled and
/// rebuilt an overlay would make this class a second copy of the widget.
///
/// The query is state; the filtered list is not. [visibleItems] derives the
/// list on every call rather than caching it. A cache here would need
/// invalidating from the search callback, from `didUpdateWidget`, and from
/// open/close/select — and every past defect in this area was a missed
/// invalidation.
class DropdownSearchController<T> {
  /// Creates a controller. Call [dispose] from the owner's `dispose`.
  ///
  /// Pass `enabled: false` for a dropdown without a search field; no
  /// `TextEditingController` or `FocusNode` is allocated until [enable] is
  /// called, which the owner does if `searchable` flips at runtime.
  DropdownSearchController({required bool enabled}) : _enabled = enabled {
    if (enabled) _allocate();
  }

  TextEditingController? _text;
  FocusNode? _focus;
  String _query = '';
  bool _enabled;

  /// Whether the dropdown offers a search field at all.
  ///
  /// Distinct from whether the field's controllers exist: turning search off
  /// stops filtering but keeps them, so turning it back on does not lose the
  /// caret. Set this from `didUpdateWidget` when `searchable` changes.
  bool get enabled => _enabled;
  set enabled(bool value) {
    _enabled = value;
    if (value) _allocate();
  }

  /// What the user has typed. Empty when they have not.
  String get query => _query;

  /// Attach to the search field. Null until search is first enabled.
  TextEditingController? get textController => _text;

  /// Attach to the search field. Null until search is first enabled.
  FocusNode? get focusNode => _focus;

  void _allocate() {
    _text ??= TextEditingController();
    _focus ??= FocusNode();
  }

  /// Records what the user typed. The owner decides what to redraw.
  void onQueryChanged(String query) => _query = query;

  /// Clears the query and the field. Called on select, dismiss and reopen.
  void reset() {
    _query = '';
    _text?.clear();
  }

  /// Puts the caret in the search field, if there is one.
  void requestFocus() => _focus?.requestFocus();

  /// The items [query] leaves visible.
  ///
  /// [filter] is the caller's `searchFilter`, or the default the presentation
  /// offers. A null filter means this mode cannot search, so nothing is hidden.
  ///
  /// Returns [items] itself when there is no search field, and a copy otherwise
  /// — the menu must not hand the caller's list to a `ListView` that will
  /// outlive this build.
  List<T> visibleItems(List<T> items, DropdownSearchFilter<T>? filter) {
    if (!_enabled) return items;
    if (_query.isEmpty || filter == null) return List<T>.from(items);

    return items.where((item) => filter(item, _query)).toList();
  }

  /// Releases the field's controllers.
  void dispose() {
    _text?.dispose();
    _focus?.dispose();
    _text = null;
    _focus = null;
  }
}
