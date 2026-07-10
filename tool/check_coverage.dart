// Reads `coverage/lcov.info` and fails when line coverage sits below a floor.
//
// Run `flutter test --coverage` first.
//
//   dart run tool/check_coverage.dart --min 80 --report
//
// A floor with slack permits exactly that much regression, and real regressions
// come to rest just under the threshold. Raise it when the number rises; never
// lower it to make a red build green.
//
// Lines that cannot be covered are wrapped in `// coverage:ignore-start` /
// `// coverage:ignore-end`, which removes them from the denominator rather than
// counting them as misses. That keeps the exception in the diff instead of in
// a slowly-sagging threshold.

import 'dart:io';

void main(List<String> args) {
  final min = _doubleArg(args, '--min') ?? 100.0;
  final report = args.contains('--report');

  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    _fail('coverage/lcov.info not found. Run `flutter test --coverage` first.');
  }

  final files = _parse(lcov.readAsLinesSync());
  if (files.isEmpty) _fail('coverage/lcov.info records no files.');

  final found = files.fold<int>(0, (n, f) => n + f.found);
  final hit = files.fold<int>(0, (n, f) => n + f.hit);
  final percent = found == 0 ? 100.0 : hit * 100 / found;

  if (report) _report(files, found, hit, percent);

  if (percent < min) {
    _fail(
      'Coverage ${percent.toStringAsFixed(2)}% is below the floor of '
      '${min.toStringAsFixed(2)}%.',
    );
  }

  stdout.writeln(
    'Coverage ${percent.toStringAsFixed(2)}% '
    '($hit/$found lines) meets the floor of ${min.toStringAsFixed(2)}%.',
  );
}

void _report(List<_FileCoverage> files, int found, int hit, double percent) {
  final sorted = [...files]..sort((a, b) => a.percent.compareTo(b.percent));

  stdout.writeln('');
  for (final file in sorted) {
    stdout.writeln(
      '${file.percent.toStringAsFixed(1).padLeft(6)}%  '
      '${'${file.hit}/${file.found}'.padRight(10)}  ${file.path}',
    );
    if (file.uncovered.isNotEmpty) {
      stdout.writeln('          uncovered: ${_ranges(file.uncovered)}');
    }
  }
  stdout.writeln('');
  stdout.writeln('${percent.toStringAsFixed(2)}%  $hit/$found lines');
  stdout.writeln('');
}

/// `1,2,3,7,9,10` reads better as `1-3, 7, 9-10`.
String _ranges(List<int> lines) {
  final out = <String>[];
  var start = lines.first;
  var previous = start;

  for (final line in lines.skip(1)) {
    if (line == previous + 1) {
      previous = line;
      continue;
    }
    out.add(start == previous ? '$start' : '$start-$previous');
    start = previous = line;
  }
  out.add(start == previous ? '$start' : '$start-$previous');

  return out.join(', ');
}

List<_FileCoverage> _parse(List<String> lines) {
  final files = <_FileCoverage>[];
  String? path;
  var covered = <int>[];
  var uncovered = <int>[];

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      path = line.substring(3).replaceAll(r'\', '/');
      covered = [];
      uncovered = [];
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      final number = int.parse(parts[0]);
      (parts[1] == '0' ? uncovered : covered).add(number);
    } else if (line == 'end_of_record' && path != null) {
      files.add(_FileCoverage(path, covered.length, uncovered..sort()));
      path = null;
    }
  }

  return files;
}

class _FileCoverage {
  _FileCoverage(this.path, this.hit, this.uncovered);

  final String path;
  final int hit;
  final List<int> uncovered;

  int get found => hit + uncovered.length;
  double get percent => found == 0 ? 100 : hit * 100 / found;
}

double? _doubleArg(List<String> args, String name) {
  final at = args.indexOf(name);
  if (at == -1 || at + 1 >= args.length) return null;

  final value = double.tryParse(args[at + 1]);
  if (value == null) _fail('$name expects a number, got "${args[at + 1]}".');

  return value;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
