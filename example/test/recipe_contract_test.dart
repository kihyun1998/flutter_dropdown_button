// The two rules that make a recipe a recipe, neither of which the compiler can
// enforce. Both are legal Dart when violated, and both fail silently — the app
// runs, the pane renders, and only the reader who pasted the file finds out.

import 'dart:io';

import 'package:example/app/destinations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

/// Everything under `lib/recipes/`, resolved from the test's own working
/// directory rather than from a list somebody has to remember to extend.
List<File> _recipeFiles() {
  final dir = Directory('lib/recipes');
  expect(
    dir.existsSync(),
    isTrue,
    reason: 'lib/recipes/ is gone, and this suite would pass vacuously',
  );

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // The window has to exist before anything is asserted inside it. An empty
  // directory would walk zero files and report success.
  expect(files, isNotEmpty, reason: 'no recipes to check');
  return files;
}

void main() {
  test('a recipe imports no shell', () {
    // The whole of the pasteable claim. A recipe reaching for
    // `flutter_example_template` compiles, runs and looks right — and cannot be
    // pasted into an app that does not have the gallery.
    for (final file in _recipeFiles()) {
      final source = file.readAsStringSync();
      expect(
        source.contains('flutter_example_template'),
        isFalse,
        reason:
            '${file.path} imports the shell it is meant to be pasted out of',
      );
    }
  });

  testWidgets('every source a destination claims opens from the bundle', (
    tester,
  ) async {
    // The asset key is the path exactly as `pubspec.yaml` writes it, and the
    // directory form means a typo here is caught by nothing else: no build step
    // reads these strings.
    //
    // One trap, whose symptom is indistinguishable from a real defect: a stale
    // `build/unit_test_assets` serves a manifest from before the pubspec
    // change, so a correctly declared asset reports "Unable to load asset".
    // `rm -rf build/unit_test_assets .dart_tool/flutter_build` tells the two
    // apart.
    final destinations = DropdownDestinations();
    addTearDown(destinations.dispose);

    final sources = destinations.all
        .whereType<StageDestination>()
        .map((d) => d.source)
        .whereType<String>()
        .toList();

    expect(sources, isNotEmpty, reason: 'nothing claims a source to check');

    for (final source in sources) {
      final contents = await rootBundle.loadString(source);
      expect(contents, isNotEmpty, reason: '$source loaded empty');
      // What the pane shows is the file's real bytes, so the bytes have to be
      // the file's: a manifest can resolve a key to the wrong asset without
      // failing.
      expect(
        contents,
        equals(File(source).readAsStringSync()),
        reason: '$source in the bundle differs from $source on disk',
      );
    }
  });
}
