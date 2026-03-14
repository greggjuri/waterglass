# PRP Template

## PRP-XXX: {Feature Name}

**Created**: {YYYY-MM-DD}
**Initial**: `initials/init-{feature}.md`
**Status**: Draft/Ready/In Progress/Complete

---

## Overview

### Problem Statement
{What problem are we solving? Copy/adapt from init.}

### Proposed Solution
{High-level description of what we're building and how.}

### Success Criteria
- [ ] {Criterion 1 — observable on device}
- [ ] {Criterion 2 — testable}
- [ ] {Criterion 3}

---

## Context

### Related Documentation
- `docs/PLANNING.md` — Architecture overview
- `docs/DECISIONS.md` — Relevant ADRs: {list specific ones, e.g., ADR-001, ADR-003}
- `docs/TESTING.md` — Device testing checklist

### Dependencies
- **Required**: {PRPs/features that must be complete first, or "None"}
- **Optional**: {Features that enhance but aren't required}

### Files to Modify/Create
```
WaterGlass/GameScene.swift              # Description of changes
WaterGlass/GameScene+Motion.swift       # NEW: CoreMotion extension
WaterGlass/GameScene+Physics.swift      # NEW: Physics setup extension
```

---

## Technical Specification

### New Swift Types / Constants
```swift
// Example: physics constants enum
enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 12.0
    static let particleCount: Int = 50
    static let restitution: CGFloat = 0.3
    static let friction: CGFloat = 0.05
    static let linearDamping: CGFloat = 0.4
}
```

### Scene/Node Structure
```
SKScene (GameScene)
├── self.physicsBody          # Glass boundary (edgeLoop)
├── SKShapeNode (x N)         # Water particles
└── {other nodes as needed}
```

### CoreMotion Integration
{Describe how CoreMotion feeds into this feature, if applicable}

```swift
// Example pattern
motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
    guard let motion = motion, let self = self else { return }
    self.physicsWorld.gravity = CGVector(
        dx: motion.gravity.x * Physics.gravityMultiplier,
        dy: motion.gravity.y * Physics.gravityMultiplier
    )
}
```

---

## Implementation Steps

### Step 1: {First Step Title}
**Files**: `WaterGlass/GameScene.swift`

{Detailed description of what to implement}

```swift
// Code example or pseudocode if helpful
```

**Validation**:
- [ ] Builds without errors
- [ ] {Specific check}

---

### Step 2: {Second Step Title}
**Files**: `WaterGlass/GameScene+Physics.swift` (new)

{Detailed description}

**Validation**:
- [ ] Builds without errors
- [ ] Launches on simulator without crash

---

### Step 3: {Third Step Title}
**Files**: `WaterGlass/GameScene+Motion.swift` (new)

{Detailed description}

**Validation**:
- [ ] Builds without errors
- [ ] On device: motion drives gravity correctly

---

### Step N: Commit and Push
```bash
git add .
git commit -m "feat: {description}"
git push
```

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Unit Tests (if applicable)
- `test{Feature}GravityMapping`: Verify CoreMotion → CGVector math
- `test{Feature}ParticleCount`: Verify correct number of particles created

### Simulator Tests
- [ ] App launches without crash
- [ ] Scene renders (glass boundary + particles visible)
- [ ] No console errors

### Device Tests
{Reference checklist from docs/TESTING.md and add feature-specific checks}

| Step | Action | Expected Result | Pass? |
|------|--------|-----------------|-------|
| 1 | Launch app | Scene renders, particles at rest | ☐ |
| 2 | Tilt left | Particles move left | ☐ |
| 3 | Tilt right | Particles move right | ☐ |
| 4 | Rapid tilt | No crash, smooth recovery | ☐ |
| 5 | Leave flat | Particles settle naturally | ☐ |

### Error Scenarios
| Scenario | How to Trigger | Expected Behavior | Pass? |
|----------|----------------|-------------------|-------|
| Run on Simulator | Launch in Xcode Simulator | Renders, no crash (no motion) | ☐ |
| {Other error case} | {How to cause it} | {Graceful handling} | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| CoreMotion unavailable | Running on Simulator | Guard + skip motion setup gracefully |
| Motion update error | Sensor failure | Log error, continue with last known gravity |
| {Other} | {Cause} | {Handling} |

---

## Open Questions

- [ ] {Question 1 — must be answered before execution}
- [ ] {Question 2}

---

## Rollback Plan

If issues are discovered:
1. `git revert {commit-hash}` to undo
2. `git push` to update remote
3. Verify: build succeeds, device behaviour restored

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | X | Are requirements unambiguous? |
| Feasibility | X | Can this be done with current SpriteKit/Swift approach? |
| Completeness | X | Does PRP cover all aspects? |
| Alignment | X | Follows ADRs and project constraints? |
| **Average** | **X** | |

{If average < 7, list specific concerns before proceeding}

---

## Notes

{Additional context, relevant Apple docs, physics tuning intuition, etc.}
