# thegraph — flutter_dropdown_button

## What this project is

A published Flutter package (pub.dev; consumers pin with `^`) that renders a
dropdown through an `OverlayEntry` rather than Flutter's built-in menu machinery.

## References

| Source | Informs | Reached by | Binding |
|---|---|---|---|
| Flutter's own dropdown/menu widgets — `material/dropdown.dart`, `dropdown_menu.dart`, `menu_anchor.dart`, `popup_menu.dart` | how it works | local checkout at `/d/flutter`, read at the version CI pins — raw | **example** — not followed on purpose. `MenuAnchor` already does placement, and not using it is this package's reason to exist. A lens reporting the duplication has found a settled divergence, not a bug. |
| `flutter_checkbox` | how it works — the re-exported `CheckboxShape`/`CheckboxStyle`, its `environment` floor, its emitted semantics | the real source in the pub cache at the version `pubspec.lock` pins — raw | **binding** — its public types are this package's API, so an upstream break at `0.x` is a break here. |
| `flutter_smooth_wheel_scroll` | how it works — the re-exported `WheelMotion` types, `SmoothScrollController`'s wheel handling, its `environment` floor | the real source in the pub cache at the version `pubspec.lock` pins — raw | **binding** — its public types are this package's API, so an upstream break at `0.x` is a break here. |
| `flutter_example_template` — the shell `example/` is built on | the shell's ports and their contracts: `ShellDestinations`, `StageDestination`/`RouteDestination`, `PreviewStage`, the Code pane | the real source in the pub cache at the version `example/pubspec.lock` pins — raw, never pub.dev's rendered docs | **binding** — a published package this repo depends on. Its undocumented contracts bind whether or not they are written down. |
| Open-source Flutter dropdown packages — `AhmedLSayed9/dropdown_button2`, `AbdullahChauhan/custom-dropdown`, `CHB61/multi_select_flutter` | how it works | GitHub source, raw (`gh api …/contents/<path>`). Not in the pub cache, and pub.dev's rendered docs are summarized | **example** — how peers solved overlay placement, search and multi-select. A difference is a choice to record, never a defect. |
