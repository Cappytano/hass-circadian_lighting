# Public Readiness Audit

Date: 2026-05-24  
Scope: upstream-conscious review of Smart Wake documentation and examples

This audit classifies repository content by publication safety and privacy risk.

Note: this file is fork-local process documentation and may be omitted from an upstream PR unless a maintainer requests it.

## Category Definitions

1. `UPSTREAM_SAFE_CANDIDATE`
2. `REUSABLE_EXAMPLE_AFTER_SANITIZATION`
3. `PRIVATE_LOCAL_ONLY`
4. `DO_NOT_PUBLISH`

## File Classification

| File or Content Group | Category | Why this category | Privacy risk | Required change before upstream contribution | Intended home |
|---|---|---|---|---|---|
| `.gitignore` | `UPSTREAM_SAFE_CANDIDATE` | Contains generic local-development ignore patterns only. | Low | None. | Repo hygiene |
| `examples/smart_wake/README.md` | `UPSTREAM_SAFE_CANDIDATE` | Generic setup guidance with placeholders and explicit privacy boundary. | Low | None. | Example docs |
| `examples/smart_wake/site_config.example.yaml` | `UPSTREAM_SAFE_CANDIDATE` | Placeholder-only helper configuration with no site-specific values. | Low | None. | Reusable example |
| `examples/smart_wake/package.example.yaml` | `UPSTREAM_SAFE_CANDIDATE` | Generic helper-driven wake behavior; no private infrastructure references. | Low | Optional: add version compatibility notes. | Reusable example |
| `custom_components/circadian_lighting/*` | `UPSTREAM_SAFE_CANDIDATE` | Integration runtime files are unchanged in this pass and remain generic. | Low | None in this pass. | Integration code |
| Legacy local package examples (imported context tree) | `REUSABLE_EXAMPLE_AFTER_SANITIZATION` | Useful logic patterns exist, but structure and comments still reflect migration-era local context. | Medium | Split into neutral modules, remove migration-specific narration. | Example package |
| Legacy local template helpers (inventory tooling) | `REUSABLE_EXAMPLE_AFTER_SANITIZATION` | Template concepts are reusable but need neutral framing and caveat notes. | Low | Add generic comments and expected-output guidance. | Example tooling |
| Legacy local dashboard snippets | `PRIVATE_LOCAL_ONLY` | Dashboard snippet naming and workflow assumptions are site-specific. | Medium | Rename and re-document as generic optional snippets before publication. | Local deployment snippets |
| Legacy local state/path documents | `PRIVATE_LOCAL_ONLY` | Operational notes and environment references are specific to a private deployment. | High | Replace with placeholders or keep local-only. | Local migration docs |
| Legacy operational handoff documents | `DO_NOT_PUBLISH` | Handoff files include operational history and private deployment details. | High | Exclude from upstream PR scope. | Private handoff |

## Integration Change Candidates (Not Implemented In This Pass)

No runtime integration changes were made in this pass.

If integration changes are proposed later, keep them minimal and generic:
1. `README.md` (root): add a short "Optional Smart Wake examples" section linking to `examples/smart_wake/`.
2. Integration runtime files: change only when broad user value is proven, with tests and backward compatibility checks.

## Suggested Upstream PR Slice Strategy

1. PR 1: hygiene and contribution boundary docs
   - `.gitignore`
   - `PUBLIC_READINESS_AUDIT.md`
2. PR 2: reusable Smart Wake examples
   - `examples/smart_wake/*`
3. PR 3+: optional integration enhancements (only if justified with generic use cases)

## Notes

- Wake behavior remains separate from `input_boolean.circadian_rhythm`.
- No `effect: "Circadian rhythm"` logic is introduced.
- Private deployment artifacts stay outside upstream PR scope.
