# LANE <ID>: <one-line objective>

Project: <path>. Operator: Winter. Hard stop: <time, America/Halifax>.

## Read first (only these)

- RULES.md, section 1 (hard limits) + section 3 (taste)
- craft/<GUIDE>.md (and craft/<GUIDE2>.md if needed)
- This brief. Notes added after you start are NOT seen; the operator queues them for the next lane.

## Objective

<What done looks like, in 2-3 lines. Name the TOOL and PIPELINE for any visible model (e.g. "Blender → FBX → 3D Importer").>

## Inputs (approved only)

- <art bible images / spec sheet / previous handoff / reference paths>

## Outputs

| File | What |
|---|---|
| <path> | <deliverable> |
| DOCS/HANDOFF-<ID>.md | the handoff (template below) |
| REVIEW/<id>/ | review shots: hero + side places + low back corners + 2x crops |

## Owner overrides (top priority)

- <e.g. "don't redesign the shop", "keep the hype ribbons">

## Acceptance (each with its evidence)

- [ ] <measurable check> → evidence: <test / log / screenshot path>
- [ ] The lane gate passed:
  - visual: the overlap / support / functional-surface audits;
  - UI: the GUI gate (0 unapproved findings);
  - code: the regression sweep + full tests.
- [ ] The prune list: what this lane made obsolete, removed WITH its code.
- [ ] The place is saved and its LastWriteTime verified; git committed.

## Constraints

- Never spend money or Robux; never change experience access; never print the API key.
- Kill processes by exact PID only. Batch fixes, then one Play session.
- Stop when done. Don't start extra work.

## Handoff template (DOCS/HANDOFF-<ID>.md)

- **Done:** what changed, with file paths.
- **Evidence:** test results, audit reports, shot paths.
- **Status words:** built / tests pass / verified in Studio / NOT verified live.
- **Pruned:** what was removed and why.
- **Open:** known issues, with severity.
- **Next:** the exact next action for the operator.
