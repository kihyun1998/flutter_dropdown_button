# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

This is a **single-context** repo.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root — the domain glossary.
- **`docs/adr/`** — read ADRs that touch the area you're about to work in.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved.

Neither `CONTEXT.md` nor `docs/adr/` exists yet in this repo. That is expected.

## File structure

```
/
├── CONTEXT.md
├── docs/
│   ├── adr/
│   │   ├── 0001-overlay-based-rendering.md
│   │   └── 0002-shared-dropdown-mixin.md
│   └── agents/
└── lib/
```

If this repo ever splits into multiple bounded contexts, add a `CONTEXT-MAP.md` at the root pointing at one `CONTEXT.md` per context, and let each context keep its own `docs/adr/` alongside system-wide decisions at the root.

Note: long-form user-facing docs already live in `documentation/` (API reference, theming, migration). That directory is **not** the domain-doc surface — it's product documentation. Don't conflate the two.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
