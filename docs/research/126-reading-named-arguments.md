# Reading named arguments out of `example/lib` (research for #126)

Child of the wayfinder map #122. **Facts only** — what the mechanism can and
cannot do, and what it costs. Designing *what to count* is a later ticket.

Everything below was run. Every version number came from a raw pub.dev API
response, a raw `raw.githubusercontent.com` fetch, or a `pubspec.lock` this
session produced. Every timing is a number that was actually printed. Where
something was not reached, it says so.

---

## Summary

| Question | Answer |
|---|---|
| Can an **unresolved** parse read named-argument names and constructor parameter lists? | **Yes**, both — but only if it handles four syntactic shapes, not one. |
| Does it need a resolved unit? | **No** — and the resolved route has a silent-failure mode that makes it *worse* as a gate. |
| Where does it run? | `dart run tool/...`, matching `tool/check_coverage.dart`. It also runs under `flutter test`; the script is the better fit. |
| Which `analyzer` at the floor? | **8.1.1** at Flutter 3.32.0 / Dart 3.8.0. Constraint `analyzer: ">=8.0.0 <9.0.0"` resolves on **both** CI legs. |
| Does a direct dev-dependency resolve alongside `flutter_test`? | **Yes**, verified by running `flutter pub get` on a real Flutter 3.32.0 SDK. |
| Lighter alternative that keeps the power? | **No.** Each one either degrades to grep or costs more than the script. |

---

## 1. `package:analyzer` — unresolved is enough, but the AST is not the shape you expect

### 1.1 The finding that decides the design

An **unresolved** parse does *not* produce an `InstanceCreationExpression` for a
constructor call. The rewrite from `MethodInvocation` to
`InstanceCreationExpression` is the **resolver's** job. Probe, run against this
repo's real `example/lib/pages/multi_select_page.dart`:

```
MI    FlutterMultiSelectDropdown targs=<String> @3593
ICE   DropdownStyleTheme @4435
MI    DropdownCheckboxTheme targs=null @4494
```

`FlutterMultiSelectDropdown<String>(...)` — the widget the whole page is about —
arrives as a **`MethodInvocation`**. `const DropdownStyleTheme(...)` arrives as an
`InstanceCreationExpression` only because the `const` keyword is written out; the
`DropdownCheckboxTheme(...)` nested inside that same const context is a
`MethodInvocation` again.

A check that visits only `visitInstanceCreationExpression` would have found
**zero** dropdown call sites in `example/lib` and passed forever. That is exactly
the "check that cannot fail" the ticket rules out, and only an actual run catches
it.

### 1.2 The four shapes, all confirmed against real files in this repo

Probe across every file in `example/lib`:

```
ICE   name2=FlutterDropdownButton prefix=null ctor=text targs=<String> keyword=null  [bare_anchor_page.dart]
MI    FlutterMultiSelectDropdown  target=null  targs=<String>                        [bare_anchor_page.dart]
MI    closeAll  target=FlutterDropdownButton  targs=null                             [bug_test_page.dart]
ICE   name2=FlutterDropdownButton prefix=null ctor=text targs=<Country>              [domain_type_page.dart]
MI    FlutterMultiSelectDropdown  target=null  targs=<String>                        [multi_select_page.dart]
ICE   name2=FlutterDropdownButton prefix=null ctor=text targs=<String>               [playground_page.dart]
MI    FlutterDropdownButton  target=null  targs=<String>                             [playground_page.dart]
```

| Source | Unresolved node | Where the class name is | Where the constructor name is |
|---|---|---|---|
| `Foo<T>(...)` | `MethodInvocation` | `methodName` | unnamed |
| `Foo<T>.text(...)` | `InstanceCreationExpression` | `constructorName.type.name` | `constructorName.name` |
| `const Foo(...)` / `const Foo.text(...)` | `InstanceCreationExpression` | `type.name`, or `type.importPrefix` when a named ctor has no type args | `constructorName.name`, or `type.name` in the prefix case |
| `Foo.text(...)` (no `const`, no type args) | `MethodInvocation` | `target` | `methodName` |

Two traps inside that table:

- **`A.b(...)` with no type arguments and no `const` is ambiguous unresolved.**
  `FlutterDropdownButton.closeAll()` in `bug_test_page.dart` is a **static
  method**, and it parses identically to a named-constructor call. The same parse
  resolves it: `closeAll` is not in the class's `ConstructorDeclaration` list, so
  it is not a construction. The snippet below marks those with `!`.
- **`const Foo.text(...)` with no type arguments** puts `Foo` in
  `NamedType.importPrefix` and `text` in `NamedType.name` — the parser cannot tell
  a class-with-named-constructor from a library-prefix-plus-class.

### 1.3 Reading the declarations

`ConstructorDeclaration.parameters` (a `FormalParameterList`) is fully available
unresolved. `p.isNamed` and `p.name!.lexeme` work uniformly across
`SimpleFormalParameter`, `FieldFormalParameter` (`this.items`) and
`SuperFormalParameter` (`super.key`), wrapped or not in `DefaultFormalParameter`.
Verified: the real numbers this repo produces are 29 / 32 / 27 named parameters
for the three constructors.

### 1.4 What an unresolved parse **cannot** tell you

Named as gaps, not as absences:

- **It cannot prove the `FlutterDropdownButton` at a call site is ours.** No
  element model, no import graph. The snippet narrows this by requiring the file
  to carry an `import 'package:flutter_dropdown_button/...'` directive — cheap,
  unresolved, and it kills the realistic decoys (see §5). It does **not** close
  the case where a file imports our package *and* a same-named class from
  somewhere else, nor `import ... as fdb;` with `fdb.FlutterDropdownButton(...)`
  (the prefix is readable — `NamedType.importPrefix` — but which package it binds
  to is not).
- **It cannot follow indirection.** Arguments assembled in a helper, spread from a
  variable, or passed through a wrapper widget are invisible. Only literal
  call-site syntax is read.
- **It cannot see conditional exports, typedefs, or `export ... show`.**
- **It cannot tell a re-exported `flutter_checkbox` type from ours** — relevant
  because `CheckboxShape` / `CheckboxStyle` are part of this package's API.

### 1.5 The resolved route, and why it is the *worse* gate

`AnalysisContextCollection` + `getResolvedUnit` does give the true owning library.
Verified against the real `example/lib`:

```
bare_anchor_page.dart: [FlutterDropdownButton<String>.text <- package:flutter_dropdown_button/src/flutter_dropdown_button.dart,
                        FlutterMultiSelectDropdown<String> <- package:flutter_dropdown_button/src/flutter_multi_select_dropdown.dart]
resolved 7 files, 24 typed hits, 13363 ms
```

Note that the resolved run *does* show `FlutterMultiSelectDropdown<String>` as an
`InstanceCreationExpression` — that is the rewrite from §1.1, observed happening.

Three costs, all measured:

1. **Speed.** 13,363 ms for 7 files resolved, against **221–274 ms for 28 files**
   (`example/lib` + `lib`, 327,299 bytes) parsed unresolved. Roughly 50x per file.
2. **It needs `example/.dart_tool/package_config.json`.** The CI `test` job does
   run `flutter pub get` in `example/`, so it would be present — but only in that
   job, and only after that step.
3. **It fails *silently* without it.** Run against a copy of `example/lib` with no
   `.dart_tool`:

   ```
   resolved 7 files, 0 typed hits, 3457 ms
   ```

   `getResolvedUnit` still returns a `ResolvedUnitResult`. It does not throw, does
   not warn — every element is simply null, and a gate keyed on
   "element.library contains flutter_dropdown_button" reports **zero call sites and
   passes**. That is a gate that cannot fail, arrived at by a different road.

**Conclusion: unresolved wins.** It is 50x faster, has no setup precondition, and
its failure mode is loud (a shape it does not handle shows up as a missing call
site in a report a human reads) rather than silent.

---

## 2. Where it runs

**`dart run tool/check_api_coverage.dart`**, alongside `tool/check_coverage.dart`.

Both routes were tried on the real floor SDK:

- **`dart run tool/...`** — ran on Dart 3.8.0, produced the output in §4. This
  matches the established shape in `ci.yml` (`dart run tool/check_coverage.dart
  --min 100 --report`), and `tool/.pubignore` is already `*`, so nothing new
  reaches the published archive.
- **`flutter test`** — also works. A test importing `package:analyzer` compiled and
  passed under Flutter 3.32.0:

  ```
  00:00 +0: package:analyzer parses source from inside flutter test
  cwd=...\floortest classes=[Node, MultiSelectPage, _MultiSelectPageState]
  00:00 +1: All tests passed!
  ```

  `Directory.current` is the package root, so relative source paths work. But this
  route puts the check inside `flutter test --coverage`, whose exit status the
  coverage floor then depends on, and it buys nothing the script does not have.

**Runtime fact worth writing down: `parseFile` requires the path to be absolute
*and* normalized.** Both were hit, in that order:

```
Invalid argument(s): Path must be absolute : example/lib/pages/multi_select_page.dart
Invalid argument(s): Path must be normalized : C:\...\floortest\example/lib/pages/multi_select_page.dart
```

On Windows the second one bites whenever a `\`-rooted `Directory.current` is
joined to a `/`-separated relative path. `p.normalize(p.absolute(path))` fixes
both; the snippet does this.

**Timing, all printed this session:**

| | ms |
|---|---|
| parse work alone, 28 files / 327,299 bytes | 221, 274 |
| `dart run tool/check_api_coverage.dart` (compiles `analyzer` from source) | 15,566 / 16,816 / 15,713 |
| same, from a pre-built kernel snapshot | 1,543 / 2,102 |

The ~16 s is JIT-compiling `package:analyzer`, not the parse. It is a one-off per
CI job and comparable to a single `flutter analyze`.

---

## 3. Version constraints at the floor — the highest-risk unknown, resolved

**Verified by running a real Flutter 3.32.0 SDK, not by inference.** Downloaded
`flutter_windows_3.32.0-stable.zip`, extracted, ran it:

```
Flutter 3.32.0 • channel stable
Tools • Dart 3.8.0 • DevTools 2.45.1
```

Confirmed independently from
`https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json`:
the `3.32.0` entry carries `"dart_sdk_version": "3.8.0"` exactly.

### 3.1 Which `analyzer` versions admit Dart 3.8.0

From the raw pub.dev API (`https://pub.dev/api/packages/analyzer`), each version's
own `pubspec.environment.sdk`:

| analyzer | sdk constraint | admits 3.8.0 |
|---|---|---|
| 6.0.0 – 6.4.1 | `>=3.0.0 <4.0.0` | yes (lowest) |
| 7.0.0 – 7.3.0 | `>=3.3.0 <4.0.0` | yes |
| 7.4.0 – 7.7.1 | `^3.5.0` | yes |
| 8.0.0 – 8.1.1 | `^3.7.0` | **yes — 8.1.1 is the ceiling** |
| 8.2.0 – 13.0.0 | `^3.9.0` | no |
| 13.1.0 – 14.3.0 | `^3.11.0` | no |

`analyzer 8.2.0` (published 2025-09-19) raised the floor to `^3.9.0`. **8.1.1
(2025-08-11) is the newest analyzer usable at Dart 3.8.0.**

### 3.2 Does it resolve alongside `flutter_test`?

**Yes.** `flutter_test` does not depend on `analyzer` at all — the raw
`packages/flutter_test/pubspec.yaml` at tag `3.32.0` lists `test_api 0.7.4`,
`matcher 0.12.17`, `path 1.9.1`, `fake_async 1.3.3`, `clock 1.1.2`,
`stack_trace 1.12.1`, `vector_math 2.1.4`, `leak_tracker_flutter_testing 3.0.9`,
`async 2.13.0`, `boolean_selector 2.1.2`, `characters 1.4.0`, `collection 1.19.1`,
`leak_tracker 10.0.9`, `leak_tracker_testing 3.0.1`,
`material_color_utilities 0.11.1`, `meta 1.16.0`, `source_span 1.10.1`,
`stream_channel 2.1.4`, `string_scanner 1.4.1`, `term_glyph 1.2.2`,
`vm_service 15.0.0` — and no `analyzer` line. (`flutter_tools` pins
`analyzer: 7.3.0`, but that is the CLI's own resolution inside the SDK, not the
consuming package's.)

The exact pins that *could* have collided all fit: analyzer 8.1.1 asks for
`collection ^1.19.0` (pinned 1.19.1), `meta ^1.15.0` (pinned 1.16.0),
`path ^1.9.0` (pinned 1.9.1), `source_span ^1.8.0` (pinned 1.10.1).

Actually run, on the real 3.32.0 SDK, against a copy of this repo with
`analyzer: any` added to `dev_dependencies`:

```
$ flutter pub get      # Flutter 3.32.0 / Dart 3.8.0
Changed 38 dependencies!
$ grep -A8 '^  analyzer:' pubspec.lock | grep version
    version: "8.1.1"
```

### 3.3 The constraint to write, and why it must be capped

**`analyzer: ">=8.0.0 <9.0.0"`** — plus `path: ^1.9.0`, which
`depend_on_referenced_packages` requires once the script imports it.

The cap is not caution, it is necessary. The same script **does not compile**
against `analyzer 14.3.0` (what the latest Dart would pick):

```
bin/api_coverage.dart:40:16: Error: The getter 'name' isn't defined for the type 'ClassDeclaration'.
bin/api_coverage.dart:43:28: Error: The getter 'members' isn't defined for the type 'ClassDeclaration'.
bin/api_coverage.dart:107:50: Error: 'NamedExpression' isn't a type.
```

The analyzer AST API is not stable across majors. An uncapped constraint would
break the `stable` CI leg on some future Dart with no code change here.

Verified on **both** legs with the cap in place:

| leg | Flutter / Dart | analyzer resolved | `dart analyze lib tool` | `dart format --set-exit-if-changed` | script runs |
|---|---|---|---|---|---|
| `minimum` | 3.32.0 / 3.8.0 | **8.1.1** | `No issues found!` | clean | yes |
| `stable` | 3.41.9 / 3.11.5 | **8.4.1** | `No issues found!` | clean | yes |

Both formatters agree on the same file — relevant given #120, where a local
reformat was rejected by CI.

`flutter pub publish --dry-run` with the two dev-dependencies added:
**`Package has 0 warnings.`**

### 3.4 A deprecation the floor's analyzer already flags

`NamedType.name2` is **deprecated in analyzer 8.1.1**:

```
info - tool\check_api_coverage.dart:122:28 - 'name2' is deprecated and shouldn't be used.
       Use name instead. - deprecated_member_use
```

This matters because `flutter analyze` is a CI gate. Use `NamedType.name`, which
exists in 8.1.1 and is what the snippet uses.

### 3.5 Named gaps

- The `flutter analyze` gate could **not** be run against the extracted 3.32.0
  SDK: the flutter tool crashed gathering project paths inside its own
  `dev/integration_tests/...` tree, an artifact of unzipping the SDK on Windows,
  unrelated to this change. `dart analyze lib tool` was run instead on both SDKs
  and is clean. Ubuntu CI would not hit that crash.
- Everything above holds **as long as `analyzer` stays inside `>=8.0.0 <9.0.0`**.
  Raising that cap is an API migration, not a version bump — §3.3 shows what it
  costs.
- Everything in §3.2 holds **as long as `flutter_test` continues not to depend on
  `analyzer`**. It does not at 3.32.0 or at 3.41.9; a future Flutter that added
  one could pin a conflicting version.

---

## 4. The verified snippet, and its real output

Reproduced verbatim from the file that was run. It ran under **Dart 3.8.0 /
analyzer 8.1.1** and **Dart 3.11.5 / analyzer 8.4.1** with byte-identical output,
and is clean under `dart analyze` and `dart format` on both.

`pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  analyzer: ">=8.0.0 <9.0.0"
  path: ^1.9.0
```

`tool/check_api_coverage.dart`:

```dart
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

void main(List<String> args) {
  final root = args.isEmpty ? Directory.current.path : args.first;

  final decls = readDeclarations(root);
  final sites = readCallSites(
    Directory('$root/example/lib'),
    decls.keys.toSet(),
  );

  stdout.writeln('DECLARED');
  for (final type in decls.keys) {
    for (final e in decls[type]!.entries) {
      final label = e.key.isEmpty ? '$type()' : '$type.${e.key}()';
      final ps = e.value.toList()..sort();
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
  stdout.writeln('UNEXERCISED NAMED PARAMETERS');
  for (final type in decls.keys) {
    for (final e in decls[type]!.entries) {
      final used = <String>{
        for (final s in sites)
          if (s.type == type && s.constructor == e.key) ...s.args,
      };
      final missing = e.value.difference(used).toList()..sort();
      final label = e.key.isEmpty ? '$type()' : '$type.${e.key}()';
      stdout.writeln('  $label  ${used.length}/${e.value.length} exercised');
      if (missing.isNotEmpty)
        stdout.writeln('      missing: ${missing.join(', ')}');
    }
  }
}
```

Real output, `dart run tool/check_api_coverage.dart` against this repo
(paths shortened, nothing else edited):

```
DECLARED
  FlutterDropdownButton()              29 named
      anchorBuilder, animationDuration, disableWhenSingleItem, emptyBuilder, enabled, expand, height, hideIconWhenSingleItem, hintWidget, itemBuilder, itemHeight, items, key, maxMenuWidth, maxWidth, menuAlignment, minMenuWidth, minWidth, onChanged, positioningKey, scrollToSelectedDuration, scrollToSelectedItem, searchFilter, searchable, selectedBuilder, theme, trailing, value, width
  FlutterDropdownButton.text()         32 named
      anchorBuilder, animationDuration, config, disableWhenSingleItem, emptyBuilder, enabled, expand, height, hideIconWhenSingleItem, hint, itemHeight, items, key, label, leading, leadingPadding, maxMenuWidth, maxWidth, menuAlignment, minMenuWidth, minWidth, onChanged, positioningKey, scrollToSelectedDuration, scrollToSelectedItem, searchFilter, searchable, selectedLeading, theme, trailing, value, width
  FlutterMultiSelectDropdown()         27 named
      anchorBuilder, animationDuration, config, emptyBuilder, enabled, expand, height, itemHeight, itemLeadingBuilder, itemTrailingBuilder, items, key, label, labelBuilder, maxMenuWidth, maxWidth, menuAlignment, minMenuWidth, minWidth, onChanged, positioningKey, searchFilter, searchable, selected, theme, trailing, width

CALL SITES IN example/lib
    example/lib/pages/bare_anchor_page.dart:63  FlutterDropdownButton.text(anchorBuilder, items, onChanged, positioningKey, value)
    example/lib/pages/bare_anchor_page.dart:82  FlutterMultiSelectDropdown(anchorBuilder, items, labelBuilder, onChanged, positioningKey, selected)
  ! example/lib/pages/bug_test_page.dart:52  FlutterDropdownButton.closeAll()
  ! example/lib/pages/bug_test_page.dart:70  FlutterDropdownButton.closeAll()
    example/lib/pages/bug_test_page.dart:186  FlutterDropdownButton.text(hint, items, onChanged, theme, value, width)
    example/lib/pages/domain_type_page.dart:60  FlutterDropdownButton.text(hint, items, label, onChanged, searchable, value, width)
    example/lib/pages/multi_select_page.dart:106  FlutterMultiSelectDropdown(height, itemLeadingBuilder, itemTrailingBuilder, items, labelBuilder, onChanged, searchable, selected, theme, width)
    example/lib/pages/playground_page.dart:1749  FlutterDropdownButton.text(animationDuration, config, disableWhenSingleItem, enabled, expand, height, hideIconWhenSingleItem, hint, itemHeight, items, leading, maxMenuWidth, maxWidth, menuAlignment, minMenuWidth, minWidth, onChanged, scrollToSelectedItem, searchable, selectedLeading, theme, trailing, value, width)
    example/lib/pages/playground_page.dart:1781  FlutterDropdownButton(animationDuration, enabled, height, hintWidget, itemBuilder, itemHeight, items, maxMenuWidth, menuAlignment, minMenuWidth, onChanged, scrollToSelectedItem, searchFilter, searchable, theme, trailing, value)

UNEXERCISED NAMED PARAMETERS
  FlutterDropdownButton()  17/29 exercised
      missing: anchorBuilder, disableWhenSingleItem, emptyBuilder, expand, hideIconWhenSingleItem, key, maxWidth, minWidth, positioningKey, scrollToSelectedDuration, selectedBuilder, width
  FlutterDropdownButton.text()  27/32 exercised
      missing: emptyBuilder, key, leadingPadding, scrollToSelectedDuration, searchFilter
  FlutterMultiSelectDropdown()  12/27 exercised
      missing: animationDuration, config, emptyBuilder, enabled, expand, itemHeight, key, label, maxMenuWidth, maxWidth, menuAlignment, minMenuWidth, minWidth, searchFilter, trailing
```

The `!` marks the shape-D ambiguity from §1.2 resolving correctly:
`FlutterDropdownButton.closeAll()` is a static method, not a constructor, and the
declaration list says so.

---

## 5. It discriminates — proved by making it fail, and making it pass

A gate is only a gate if it can do both.

**Decoys.** A file that imports the package and mentions both type names in a doc
comment, a line comment, a string literal containing a full call, and a `Text`
widget; plus a second file declaring its own same-named `FlutterDropdownButton`
and constructing it, with no import of our package:

```
=== our tool ===
CALL SITES IN example/lib
                       (empty)

=== plain grep would have said ===
fake/example/lib/decoy.dart:4
fake/example/lib/no_import.dart:3
```

**7 grep hits, 0 call sites.**

**Redden.** Adding four real call sites to the same tree, one per syntactic shape:

```
CALL SITES IN example/lib
    real.dart:2  FlutterDropdownButton(itemBuilder, items, onChanged)
    real.dart:3  FlutterDropdownButton.text(items, leadingPadding, onChanged)
    real.dart:4  FlutterMultiSelectDropdown(items, onChanged, selected)
    real.dart:5  FlutterMultiSelectDropdown(items, onChanged, selected, trailing)
```

All four found, including the `const` one on line 5 and the `.text()` one on
line 3.

---

## 6. Lighter alternatives — honestly, none of them

### `dart analyze --format=json`

Degrades to nothing. It is a **diagnostics** channel, not an AST. With no custom
rule there is no diagnostic to key on:

```
$ dart analyze --format=json lib
{"version":1,"diagnostics":[]}
```

To get a diagnostic about an unpassed parameter, something must first *compute*
it — which is the whole problem, unmoved.

### `package:custom_lint`

**Resolves at the floor, but costs more and is deprecated upstream.**

- `custom_lint` / `custom_lint_builder` **0.8.1** (2025-09-09) carry
  `sdk: >=3.0.0 <4.0.0`, so Dart 3.8.0 is admitted. `custom_lint_builder 0.8.1`
  requires `analyzer: ^8.0.0` and `analyzer_plugin: ^0.13.0`; at Dart 3.8.0 that
  lands on `analyzer_plugin 0.13.7` (`sdk: ^3.5.0`, which pins `analyzer: 8.1.1`
  exactly). The stack resolves.
- But it does not remove the separate command. Its own README:
  *"Unfortunately, running `dart analyze` does not pick up our newly defined
  lints. We need a separate command for this… `dart run custom_lint`."* That is
  the same shape as `dart run tool/...`, with three extra dependencies and a
  plugin protocol.
- The upstream README opens with: *"This package is no longer under active
  development… The official `analysis_server_plugin` is now the recommended
  approach for building custom lints."*
- **Gap:** the README never uses the words "resolved" or "unresolved". Whether
  `CustomLintResolver` hands a rule a resolved or unresolved unit was **not
  confirmed** — a documentation gap, not evidence either way. It was not probed,
  because the two points above already rule the route out on cost.

### A hand-rolled tokenizer

Degrades to grep the moment it meets this repo's real source. From
`multi_select_page.dart` itself, inside an argument to the call being measured:

```dart
labelBuilder: (s) => switch (s.length) {
  0 => 'All operating systems',
  1 => s.first,
  _ => '${s.length} selected',
},
```

A scanner tracking parenthesis depth must already handle string interpolation
containing balanced braces, switch expressions, nested closures, raw strings,
comments, and collection-`if`/`for`. That is a Dart scanner. `package:analyzer`
already ships one, and gets it right.

### `analysis_server_plugin`

**Not reached.** Named by custom_lint's README as the successor. Its version
history, SDK constraints at Dart 3.8.0, and whether it can run headless in CI
were not checked. An open question, not an absence.

---

## 7. What this leaves for the next ticket

The mechanism is settled and cheap. What is *not* settled — deliberately out of
scope here:

- Which parameters should count. `key` shows up in every "missing" list and is
  Flutter's, not ours. `emptyBuilder` and `scrollToSelectedDuration` are missing
  from every constructor.
- Whether the numbers above (17/29, 27/32, 12/27) are a floor to hold, a report to
  read, or both.
- Whether `example/lib` is the right corpus at all, or whether `test/` should
  count too.
- The wrapper-widget blind spot from §1.4: if a page ever wraps the dropdown in a
  local helper, its arguments vanish from this count with no warning.
