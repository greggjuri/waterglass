# Init Template - Feature Specification

## NN-init-{name}: {Feature Name}

**Created**: {YYYY-MM-DD}
**Priority**: {High/Medium/Low}
**Phase**: {1 / 2 / 3 / 4}
**Depends On**: {NN-init-{name}, or "None"}

---

## Problem Statement

{What problem does this feature solve? What's missing or broken? 1-3 sentences.}

## Goal

{What will be true when this feature is complete? What can you see/feel on device?}

## Requirements

### Must Have (P0)
1. {Requirement 1}
2. {Requirement 2}
3. {Requirement 3}

### Should Have (P1)
1. {Requirement 4}

### Nice to Have (P2)
1. {Requirement 5}

## Technical Considerations

### Swift / SpriteKit Changes
- {New nodes, physics bodies, or scene changes needed}
- {Changes to existing GameScene or extensions}

### CoreMotion Changes
- {Any changes to motion handling, if applicable}

### New Files / Extensions
- {e.g., GameScene+Motion.swift — new extension needed}
- {e.g., No new files — changes to GameScene.swift only}

### Physics Constants to Tune
- {List any new physics constants that will need device testing}

## Constraints

- {e.g., Must not drop below 60fps on device}
- {e.g., Must not break existing glass boundary}

## Success Criteria

- [ ] {Testable criterion 1 — observable on device}
- [ ] {Testable criterion 2}
- [ ] {Testable criterion 3}

## Out of Scope

{Explicitly list what this feature does NOT include}

- {Not included 1}
- {Not included 2}

## Open Questions

- [ ] {Question 1 — answer before generating PRP}
- [ ] {Question 2}

## Notes

{Any additional context, references, physics intuition, or relevant Apple docs}

---

## Usage

1. Copy to `initials/NN-init-{name}.md` — use the next available running number
2. Fill in all sections
3. Answer all Open Questions before generating PRP
4. Then in Claude Code: `/generate-prp initials/NN-init-{name}.md`
   → Produces: `prps/NN-prp-{name}.md` (same number prefix)
