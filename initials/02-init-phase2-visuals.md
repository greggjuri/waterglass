# Init Spec - Feature Specification

## 02-init-phase2-visuals: Phase 2 — Metaball Liquid Effect

**Created**: 2026-03-14
**Priority**: High
**Phase**: 2
**Depends On**: `01-init-phase1-poc.md`

---

## Problem Statement

The Phase 1 app works correctly but looks like a bag of blue marbles, not water. Individual
circular particles are clearly visible as separate objects. The goal of Phase 2 is to make
the particles visually merge into a cohesive liquid mass that stretches and splits as it
moves — the metaball effect.

## Goal

When this feature is complete: the particles are no longer visible as individual circles.
Instead you see a single body of liquid that deforms, stretches when it pulls apart, and
snaps back together when particles get close. It should look like water (or at least
convincingly like a liquid) when you tilt the phone.

---

## Requirements

### Must Have (P0)
1. `SKEffectNode` wrapping all water particles — provides the blur + threshold pipeline
2. Gaussian blur applied to the effect node (`CIFilter` blur, radius ~12–15)
3. Threshold/colour matrix filter applied after blur to create sharp liquid edge from the
   blurred particles — this is the metaball technique
4. Particles remain physically identical to Phase 1 — only the rendering changes
5. Physics must continue working correctly — the effect is purely visual
6. 60fps maintained on device with the effect active

### Should Have (P1)
7. Particle count increased from 50 to ~80–120 for denser, more liquid-looking mass
8. Particle radius reduced from 12pt to ~8pt — smaller particles look more fluid
9. Blue colour tuned for water — slightly more saturated/transparent than Phase 1
10. Visible glass outline — `SKShapeNode` stroke with no fill, drawn over the effect node
    so it's not blurred

### Nice to Have (P2)
11. Subtle colour variation in particles (slightly lighter near "surface") — deferred if complex

---

## Technical Considerations

### How the Metaball Technique Works

This is the key concept for the whole phase — worth understanding before Claude Code touches it:

1. Particles are rendered as blurry blobs (Gaussian blur spreads each circle into a soft glow)
2. Where blobs overlap, their brightness adds together — the overlap region becomes brighter
3. A threshold filter then says: anything above brightness X → fully opaque liquid colour;
   anything below → fully transparent
4. Result: overlapping particles merge into one solid shape; isolated particles stay as
   rounded blobs; the "neck" between nearly-touching particles stretches and snaps

The SpriteKit implementation:
- `SKEffectNode` with `shouldEnableEffects = true`
- Apply `CIFilter(name: "CIGaussianBlur")` with blur radius ~12
- Then `CIColorMatrix` or `CIColorClamp` to create the threshold effect
- All water particles are children of this effect node (not directly of the scene)

### SpriteKit Changes

**New node hierarchy:**
```
GameScene
├── effectNode: SKEffectNode        ← NEW — wraps all particles
│   ├── SKShapeNode (particle 1)
│   ├── SKShapeNode (particle 2)
│   └── ... (x 80–120)
└── glassOutline: SKShapeNode       ← moved OUTSIDE effectNode so it stays sharp
```

**Effect node setup:**
```swift
let effectNode = SKEffectNode()
effectNode.shouldEnableEffects = true
effectNode.filter = makeMetaballFilter()
addChild(effectNode)
```

**Filter chain:**
The metaball filter is a two-stage CIFilter composition: blur → threshold. This is a
known SpriteKit pattern but requires some experimentation with the threshold values.
The blur radius and threshold level are the two main tuning knobs.

**Key constraint**: `SKEffectNode` renders its children into an offscreen texture, applies
the filter, then composites back. This means particles must be children of the effect node,
not the scene directly. Physics bodies still work — physics is on the nodes, rendering is
handled by the effect node.

### Changes to Existing Code

- `GameScene+Water.swift` — add particles to `effectNode` instead of scene directly;
  reduce radius; adjust count; adjust colour
- `GameScene+Physics.swift` — glass outline `SKShapeNode` moves outside effect node
- `GameScene.swift` — store `effectNode` as property; create in `didMove(to:)`
- `GameScene+Rendering.swift` (NEW) — `makeMetaballFilter()` function lives here;
  this is the Phase 2+ rendering extension from ADR-004

### New Files / Extensions

- `GameScene+Rendering.swift` — new extension for shader/filter construction (ADR-004)

### Physics Constants to Tune

New or changed constants in `enum Physics`:

```swift
static let particleRadius: CGFloat = 8.0     // reduced from 12.0
static let particleCount: Int = 100           // increased from 50 (tune on device)
static let blurRadius: Double = 12.0          // metaball blur — tune on device
static let threshold: Double = 0.4            // metaball threshold — tune on device
```

---

## Constraints

- Physics behaviour must be unchanged — effect node is rendering only
- Must maintain 60fps on device with filter active — `SKEffectNode` has a performance cost,
  test early
- Glass outline must remain sharp — must be a sibling of effectNode, not a child
- Must not contradict ADR-001 (SpriteKit only — no Metal shaders in Phase 2)
- 500-line file limit still applies

---

## Success Criteria

- [ ] Particles visually merge when close together — no visible seam
- [ ] Particles visually separate with a stretched "neck" when pulling apart
- [ ] No individual circle outlines visible in normal use
- [ ] Glass outline is sharp (not blurred)
- [ ] Physics feel is identical to Phase 1 — sloshing behaviour unchanged
- [ ] 60fps on device with effect active
- [ ] Looks like liquid, not marbles

---

## Out of Scope

- Custom Metal/GLSL shaders (Phase 3+ if needed)
- Multiple liquid colours / liquid presets (Phase 3)
- Glass shape changes — still rectangular (Phase 3)
- Sound effects (Phase 3)
- Surface tension simulation — this is visual approximation only

---

## Open Questions

- [ ] **Performance**: `SKEffectNode` with CIFilter can be expensive. If 60fps can't be
  maintained with 100 particles, the fallback is to reduce `particleCount` back toward 50
  or reduce `blurRadius`. Need to test on device before committing to a particle count.
  
- [ ] **Threshold filter approach**: `CIColorMatrix` is the standard approach for the
  threshold step, but values need tuning. Alternative is `CIColorClamp`. Claude Code should
  try `CIColorMatrix` first and note the rVector/gVector/bVector/aVector values that
  produce a good result.

- [ ] **Particle colour with filter**: The blur + threshold pipeline changes how colours
  appear. The final rendered colour is determined by the threshold filter, not the original
  particle fill colour. The actual water colour will likely need to be set on the
  `SKEffectNode` or via the colour matrix, not on individual particles.

All three are answered well enough to proceed — Claude Code should use the CIColorMatrix
approach, test performance early, and adjust particle count to maintain 60fps.

---

## Notes

**The metaball technique is well established for SpriteKit** — there are multiple community
resources and Apple forum posts covering it. The core CIFilter chain is:
`CIGaussianBlur` → `CIColorMatrix` (for threshold).

The `CIColorMatrix` threshold trick works by boosting the alpha channel aggressively
(multiplying it by a large number like 20–30) and then clamping. Where the blurred
particles overlap, alpha exceeds 1.0 before clamping, so it stays fully opaque. Where a
single particle sits alone, the blurred edge has low alpha which gets boosted then clamped
to either 0 or 1 depending on the threshold. Tuning the multiplier value controls how
"liquid" vs "blobby" the merge looks.

**Performance note**: `shouldRasterize = true` on `SKEffectNode` caches the rendered
texture and only re-renders when children change. Since particles move every frame, this
does NOT help here — leave it false. The filter runs every frame, which is the expected
cost.

**Filter chaining in SpriteKit**: `SKEffectNode` only accepts a single `CIFilter`. To chain
blur + threshold, the two filters must be composed using `CIFilter` chaining
(`setValue(blurOutput, forKey: kCIInputImageKey)` on the threshold filter) and passed as
a single filter to the effect node.

---

## Usage

1. ✅ This file is complete
2. In Claude Code: `/generate-prp initials/02-init-phase2-visuals.md`
