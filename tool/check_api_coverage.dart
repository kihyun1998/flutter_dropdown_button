// Reads which named arguments example/lib actually passes, and which named
// parameters the constructors actually declare — both from source, unresolved.
//
//   dart run tool/check_api_coverage.dart
//
// Unresolved parsing only: no package resolution, no analysis context, no
// `flutter pub get` in example/. It is the parser, not the resolver.

import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

const _package = 'package:flutter_dropdown_button/';

/// Which class each declaration file is expected to hold.
const _declSources = {
  'FlutterDropdownButton': 'lib/src/flutter_dropdown_button.dart',
  'FlutterMultiSelectDropdown': 'lib/src/flutter_multi_select_dropdown.dart',
};

CompilationUnit _parse(String path) => parseFile(
  path: p.normalize(p.absolute(path)),
  featureSet: FeatureSet.latestLanguageVersion(),
  throwIfDiagnostics: false,
).unit;

// ── declarations ────────────────────────────────────────────────────────────

/// `{'FlutterDropdownButton': {'': {...}, 'text': {...}}}`
Map<String, Map<String, Set<String>>> readDeclarations(String root) {
  final out = <String, Map<String, Set<String>>>{};

  for (final entry in _declSources.entries) {
    final unit = _parse('$root/${entry.value}');
    for (final decl in unit.declarations.whereType<ClassDeclaration>()) {
      if (decl.name.lexeme != entry.key) continue;
      final ctors = <String, Set<String>>{};
      for (final m in decl.members.whereType<ConstructorDeclaration>()) {
        ctors[m.name?.lexeme ?? ''] = {
          for (final p in m.parameters.parameters)
            if (p.isNamed) p.name!.lexeme,
        };
      }
      out[entry.key] = ctors;
    }
  }

  return out;
}

// ── call sites ──────────────────────────────────────────────────────────────

class CallSite {
  CallSite(this.type, this.constructor, this.args, this.file, this.line);

  final String type;
  final String constructor; // '' for the unnamed one
  final Set<String> args;
  final String file;
  final int line;

  @override
  String toString() =>
      '$file:$line  $type${constructor.isEmpty ? '' : '.$constructor'}'
      '(${(args.toList()..sort()).join(', ')})';
}

List<CallSite> readCallSites(Directory dir, Set<String> types) {
  final sites = <CallSite>[];

  for (final f in dir.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    final unit = _parse(f.path);

    // Discriminating power, part 1: a file that never imports this package
    // cannot be constructing its widgets, whatever its identifiers say.
    final imports = unit.directives.whereType<ImportDirective>().map(
      (d) => d.uri.stringValue ?? '',
    );
    if (!imports.any((u) => u.startsWith(_package))) continue;

    final lines = unit.lineInfo;
    unit.accept(_CallSiteVisitor(types, f.path, lines, sites));
  }

  return sites;
}

class _CallSiteVisitor extends RecursiveAstVisitor<void> {
  _CallSiteVisitor(this.types, this.file, this.lines, this.out);

  final Set<String> types;
  final String file;
  final LineInfo lines;
  final List<CallSite> out;

  void _add(String type, String ctor, ArgumentList args, int offset) {
    out.add(
      CallSite(
        type,
        ctor,
        {
          for (final a in args.arguments.whereType<NamedExpression>())
            a.name.label.name,
        },
        file,
        lines.getLocation(offset).lineNumber,
      ),
    );
  }

  // Shape A/B: `const Foo(...)`, `Foo<T>.text(...)`, `const Foo.text(...)`.
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final cn = node.constructorName;
    final prefix = cn.type.importPrefix?.name.lexeme;
    if (prefix != null && types.contains(prefix)) {
      // `const Foo.text(...)` with no type arguments: the parser reads `Foo`
      // as an import prefix and `text` as the type.
      _add(prefix, cn.type.name.lexeme, node.argumentList, node.offset);
    } else if (types.contains(cn.type.name.lexeme)) {
      _add(
        cn.type.name.lexeme,
        cn.name?.name ?? '',
        node.argumentList,
        node.offset,
      );
    }
    super.visitInstanceCreationExpression(node);
  }

  // Shape C/D: `Foo<T>(...)` and `Foo.text(...)` both parse as invocations
  // when there is no `const`/`new` keyword — the rewrite to an instance
  // creation is the resolver's job, and we never run it.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (node.target == null && types.contains(node.methodName.name)) {
      _add(node.methodName.name, '', node.argumentList, node.offset);
    } else if (target is SimpleIdentifier && types.contains(target.name)) {
      _add(target.name, node.methodName.name, node.argumentList, node.offset);
    }
    super.visitMethodInvocation(node);
  }
}

// ── report ──────────────────────────────────────────────────────────────────

/// Named parameters that are declared but are deliberately not ours to show.
///
/// **One entry, and it needs a reason to earn a second.** `key` is
/// `super.key` — Flutter's, on every widget in existence. A recipe passing it
/// would be passing it to satisfy this check and nothing else, which is the
/// definition of a demo that teaches nothing.
///
/// Do not add a parameter here to make a red build green. That is the same act
/// as lowering `--min`, one line further down.
const _exempt = {'key'};

void main(List<String> args) {
  final report = args.contains('--report');
  final minIndex = args.indexOf('--min');
  final min = minIndex == -1 ? null : double.parse(args[minIndex + 1]);
  final positional = args
      .where((a) => !a.startsWith('--'))
      .where((a) => minIndex == -1 || a != args[minIndex + 1])
      .toList();
  final root = positional.isEmpty ? Directory.current.path : positional.first;

  final decls = readDeclarations(root);
  final sites = readCallSites(
    Directory('$root/example/lib'),
    decls.keys.toSet(),
  );

  if (report) {
    stdout.writeln('DECLARED');
    for (final type in decls.keys) {
      for (final e in decls[type]!.entries) {
        final label = e.key.isEmpty ? '$type()' : '$type.${e.key}()';
        final ps = e.value.difference(_exempt).toList()..sort();
        stdout.writeln('  ${label.padRight(36)} ${ps.length} named');
        stdout.writeln('      ${ps.join(', ')}');
      }
    }

    stdout.writeln('');
    stdout.writeln('CALL SITES IN example/lib');
    for (final s in sites) {
      // Shape D is ambiguous unresolved: `Foo.bar(...)` is a named constructor
      // only if `bar` is declared as one. The same parse answers that.
      final known = decls[s.type]!.containsKey(s.constructor);
      stdout.writeln('  ${known ? ' ' : '!'} $s');
    }
    stdout.writeln('');
  }

  var declared = 0;
  var exercised = 0;
  final detail = <String>[];

  for (final type in decls.keys) {
    for (final e in decls[type]!.entries) {
      final wanted = e.value.difference(_exempt);
      final used = <String>{
        for (final s in sites)
          if (s.type == type && s.constructor == e.key) ...s.args,
      }.intersection(wanted);
      final missing = wanted.difference(used).toList()..sort();
      final label = e.key.isEmpty ? '$type()' : '$type.${e.key}()';

      declared += wanted.length;
      exercised += used.length;

      detail.add('  $label  ${used.length}/${wanted.length} exercised');
      if (missing.isNotEmpty) {
        detail.add('      missing: ${missing.join(', ')}');
      }
    }
  }

  stdout.writeln('UNEXERCISED NAMED PARAMETERS');
  detail.forEach(stdout.writeln);

  // Rounded to the same one decimal the report prints, and compared at that
  // precision on purpose: a human reads "65.9%" off this report and writes
  // `--min 65.9`. Comparing the unrounded 65.88235... against that would fail
  // the build on the number the tool itself just told them to use.
  final pct = declared == 0
      ? 100.0
      : double.parse((exercised * 100 / declared).toStringAsFixed(1));
  stdout.writeln('');
  stdout.writeln(
    'API coverage: $exercised/$declared named parameters '
    '(${pct.toStringAsFixed(1)}%)',
  );

  if (min == null) return;

  if (pct < min) {
    stderr.writeln('');
    stderr.writeln(
      'FAIL: API coverage ${pct.toStringAsFixed(1)}% is below the floor of '
      '${min.toStringAsFixed(1)}%.',
    );
    stderr.writeln(
      '  ${declared - exercised} named parameters are declared and never '
      'passed anywhere in example/lib.',
    );
    stderr.writeln(
      '  Pass them from a recipe or the playground. If one genuinely should '
      'not be demonstrated,',
    );
    stderr.writeln(
      '  add it to _exempt in this file *with the reason*. Never lower --min '
      'to make this green:',
    );
    stderr.writeln(
      '  a lowered floor permits exactly that much regression, and real '
      'regressions come to rest just under it.',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln('Floor of ${min.toStringAsFixed(1)}% held.');
}
