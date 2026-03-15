# 02-prp-phase2-visuals: Phase 2 — Metaball Liquid Effect

**Created**: 2026-03-14
**Initial**: `initials/02-init-phase2-visuals.md`
**Status**: Ready

---

## Overview

### Problem Statement

The Phase 1 app works correctly but looks like a bag of blue marbles. Individual circular
particles are clearly visible as separate objects. The water doesn't look like water.

### Proposed Solution

Apply the metaball visual technique using SpriteKit's `SKEffectNode`:
1. Wrap all water particles in an `SKEffectNode` with a custom `CIFilter`
2. The filter chains `CIGaussianBlur` → `CIColorMatrix` to create a threshold effect
3. Where blurred particles overlap, they visually merge into a single liquid mass
4. Where they separate, the liquid stretches and snaps apart
5. Increase particle count (50 → 100) and decrease radius (12 → 8) for denser fluid
6. Physics remain unchanged — the effect is purely visual

### Success Criteria
- [ ] Particles visually merge when close together — no visible seam
- [ ] Particles visually separate with a stretched "neck" when pulling apart
- [ ] No individual circle outlines visible in normal use
- [ ] Glass outline is sharp (not blurred by the effect)
- [ ] Physics feel is identical to Phase 1 — sloshing behaviour unchanged
- [ ] 60fps on device with effect active
- [ ] Looks like liquid, not marbles

---

## Context

### Related Documentation
- `docs/PLANNING.md` — Phase 2: "Make It Look Like Water"
- `docs/DECISIONS.md` — ADR-001 (SpriteKit only), ADR-003 (metaball visual in Phase 2), ADR-004 (GameScene+Rendering.swift for shaders)
- `docs/TESTING.md` — Device testing checklist, performance monitoring

### Dependencies
- **Required**: `01-init-phase1-poc.md` — Phase 1 complete (done)
- **Optional**: None

### Files to Modify/Create
```
WaterGlass/WaterGlass/GameScene.swift             # Add effectNode property, update didMove(to:), update Physics enum
WaterGlass/WaterGlass/GameScene+Rendering.swift   # NEW: MetaballFilter CIFilter subclass, setupEffectNode()
WaterGlass/WaterGlass/GameScene+Water.swift       # Particles → effectNode children, white fill, updated count/radius
WaterGlass/WaterGlass/GameScene+Physics.swift     # Glass outline zPosition above effectNode
```

---

## Technical Specification

### Updated Physics Constants
```swift
enum Physics {
    // Unchanged
    static let gravityMultiplier: Double = 20.0
    static let restitution: CGFloat = 0.3
    static let friction: CGFloat = 0.05
    static let linearDamping: CGFloat = 0.4
    static let angularDamping: CGFloat = 0.4
    static let glassInset: CGFloat = 60.0

    // Changed for Phase 2
    static let particleRadius: CGFloat = 8.0      // was 12.0 — smaller for fluid look
    static let particleCount: Int = 100            // was 50 — denser liquid mass

    // New for Phase 2
    static let blurRadius: Double = 12.0           // Gaussian blur spread
    static let alphaMultiplier: Double = 20.0      // threshold sharpness (higher = sharper edge)
}
```

### New Node Hierarchy
```
GameScene
├── self.physicsBody                    # Glass boundary (edgeLoop) — unchanged
├── effectNode: SKEffectNode            # NEW — wraps particles, applies metaball filter
│   ├── SKShapeNode (particle 1)        # Now children of effectNode, not scene
│   ├── SKShapeNode (particle 2)
│   └── ... (x 100)
└── glassOutline: SKShapeNode           # Stays as scene child — sharp, not blurred
    └── zPosition = 10                  # Renders above effectNode
```

### MetaballFilter — Custom CIFilter Subclass
```swift
class MetaballFilter: CIFilter {
    var inputImage: CIImage?
    var blurRadius: Double = Physics.blurRadius
    var alphaMultiplier: Double = Physics.alphaMultiplier

    override var outputImage: CIImage? {
        guard let input = inputImage else { return nil }

        // Step 1: Gaussian blur — spreads particles into soft glows
        guard let blur = CIFilter(name: "CIGaussianBlur") else { return nil }
        blur.setValue(input, forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        guard let blurred = blur.outputImage?.cropped(to: input.extent) else { return nil }

        // Step 2: Threshold via CIColorMatrix
        // - Zero out RGB, replace with water colour via bias
        // - Boost alpha by alphaMultiplier to create hard edges
        guard let colorMatrix = CIFilter(name: "CIColorMatrix") else { return nil }
        colorMatrix.setValue(blurred, forKey: kCIInputImageKey)
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(alphaMultiplier)), forKey: "inputAVector")
        colorMatrix.setValue(CIVector(x: 0.3, y: 0.6, z: 1.0, w: 0), forKey: "inputBiasVector")

        return colorMatrix.outputImage
    }
}
```

**How this works:**
1. `CIGaussianBlur` spreads each white particle into a soft glow — overlapping glows add alpha
2. `CIColorMatrix` does two things:
   - Zeros out original RGB and replaces with water colour (0.3, 0.6, 1.0) via bias vector
   - Multiplies alpha by 20 — where blurred particles overlap (combined alpha > 0.05), result clamps to fully opaque; isolated edges stay transparent
3. Result: overlapping particles merge into one solid liquid shape; isolated particles have soft rounded edges; the "neck" between near-touching particles stretches naturally

### Particle Changes for Filter Pipeline
- **fillColor**: `.white` (alpha 1.0) — maximises alpha signal for threshold
- **strokeColor**: `.clear` — no outline needed; filter handles all visual rendering
- **lineWidth**: 0
- The water colour is set in the `CIColorMatrix` bias vector, not on particles

### CoreMotion Integration
No changes — CoreMotion integration is unchanged from Phase 1.

---

## Implementation Steps

### Step 1: Update Physics Constants
**Files**: `WaterGlass/WaterGlass/GameScene.swift`

Add Phase 2 constants and update particle parameters in `enum Physics`:

```swift
enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 8.0       // reduced from 12.0
    static let particleCount: Int = 100             // increased from 50
    static let restitution: CGFloat = 0.3
    static let friction: CGFloat = 0.05
    static let linearDamping: CGFloat = 0.4
    static let angularDamping: CGFloat = 0.4
    static let glassInset: CGFloat = 60.0
    static let blurRadius: Double = 12.0            // NEW — metaball blur
    static let alphaMultiplier: Double = 20.0       // NEW — threshold sharpness
}
```

**Validation**:
- [ ] Builds without errors
- [ ] Runs on Simulator — 100 smaller particles, still looks like marbles (no filter yet)

---

### Step 2: Create GameScene+Rendering.swift — MetaballFilter
**Files**: `WaterGlass/WaterGlass/GameScene+Rendering.swift` (NEW)

Create the new rendering extension with:
1. `MetaballFilter` — custom `CIFilter` subclass that chains blur → threshold
2. `setupEffectNode()` — creates `SKEffectNode`, applies filter, adds to scene

```swift
//
//  GameScene+Rendering.swift
//  WaterGlass
//

import SpriteKit
import CoreImage

// MARK: - Metaball Filter

class MetaballFilter: CIFilter {
    var inputImage: CIImage?

    override var outputImage: CIImage? {
        guard let input = inputImage else { return nil }

        guard let blur = CIFilter(name: "CIGaussianBlur") else { return nil }
        blur.setValue(input, forKey: kCIInputImageKey)
        blur.setValue(Physics.blurRadius, forKey: kCIInputRadiusKey)
        guard let blurred = blur.outputImage?.cropped(to: input.extent) else { return nil }

        guard let colorMatrix = CIFilter(name: "CIColorMatrix") else { return nil }
        colorMatrix.setValue(blurred, forKey: kCIInputImageKey)
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputRVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputBVector")
        colorMatrix.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(Physics.alphaMultiplier)),
                             forKey: "inputAVector")
        colorMatrix.setValue(CIVector(x: 0.3, y: 0.6, z: 1.0, w: 0),
                             forKey: "inputBiasVector")

        return colorMatrix.outputImage
    }
}

// MARK: - Effect Node Setup

extension GameScene {

    func setupEffectNode() {
        effectNode.shouldEnableEffects = true
        effectNode.shouldRasterize = false  // particles move every frame — can't cache
        effectNode.filter = MetaballFilter()
        addChild(effectNode)
    }
}
```

**Validation**:
- [ ] Builds without errors (file exists but `setupEffectNode()` not called yet)

---

### Step 3: Integrate effectNode into GameScene
**Files**: `WaterGlass/WaterGlass/GameScene.swift`

Add `effectNode` as a stored property. Update `didMove(to:)` to call `setupEffectNode()`
before `createWaterParticles()` and `createGlass()`:

```swift
class GameScene: SKScene {
    let motionManager = CMMotionManager()
    let effectNode = SKEffectNode()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysicsWorld()
        setupEffectNode()       // NEW — must come before createWaterParticles
        createGlass()
        createWaterParticles()
        startMotionUpdates()
    }
    // ... rest unchanged
}
```

**Validation**:
- [ ] Builds without errors
- [ ] Runs on Simulator — effectNode is in scene but particles still added to scene directly (next step)

---

### Step 4: Update createWaterParticles — Particles to effectNode
**Files**: `WaterGlass/WaterGlass/GameScene+Water.swift`

Change particles to be children of `effectNode` instead of the scene. Update particle
colours for the filter pipeline (white fill, no stroke):

```swift
func createWaterParticles() {
    let glassMinX = Physics.glassInset + Physics.particleRadius * 2
    let glassMaxX = size.width - Physics.glassInset - Physics.particleRadius * 2
    let glassMinY = size.height * 0.4
    let glassMaxY = size.height - Physics.glassInset - Physics.particleRadius * 2

    for _ in 0..<Physics.particleCount {
        let particle = SKShapeNode(circleOfRadius: Physics.particleRadius)
        particle.fillColor = .white       // white for max alpha signal — filter sets colour
        particle.strokeColor = .clear     // no outline — filter handles visual
        particle.lineWidth = 0

        let x = CGFloat.random(in: glassMinX...glassMaxX)
        let y = CGFloat.random(in: glassMinY...glassMaxY)
        particle.position = CGPoint(x: x, y: y)

        let body = SKPhysicsBody(circleOfRadius: Physics.particleRadius)
        body.isDynamic = true
        body.restitution = Physics.restitution
        body.friction = Physics.friction
        body.linearDamping = Physics.linearDamping
        body.angularDamping = Physics.angularDamping
        body.allowsRotation = false
        particle.physicsBody = body

        effectNode.addChild(particle)     // was: addChild(particle)
    }
}
```

Key changes:
- `effectNode.addChild(particle)` — particles go through effect pipeline
- White fill, clear stroke — colour is applied by `CIColorMatrix` bias vector
- Physics unchanged — `SKPhysicsBody` still works when parent is `SKEffectNode`

**Validation**:
- [ ] Builds without errors
- [ ] Runs on Simulator — metaball effect visible! Particles merge into liquid mass

---

### Step 5: Fix Glass Outline z-Ordering
**Files**: `WaterGlass/WaterGlass/GameScene+Physics.swift`

Glass outline is already a direct scene child (not inside effectNode), so it won't be
blurred. But ensure it renders above the effectNode by setting `zPosition`:

```swift
func createGlass() {
    let glassRect = CGRect(
        x: Physics.glassInset,
        y: Physics.glassInset,
        width: size.width - Physics.glassInset * 2,
        height: size.height - Physics.glassInset * 2
    )

    physicsBody = SKPhysicsBody(edgeLoopFrom: glassRect)
    physicsBody?.friction = 0.1

    let outline = SKShapeNode(rect: glassRect)
    outline.strokeColor = SKColor(white: 0.4, alpha: 0.6)
    outline.lineWidth = 2.0
    outline.fillColor = .clear
    outline.zPosition = 10  // render above effectNode
    addChild(outline)
}
```

**Validation**:
- [ ] Builds without errors
- [ ] Glass outline renders sharp and above the liquid

---

### Step 6: Build Verification and Simulator Test
**Commands**:
```bash
xcodebuild -scheme WaterGlass -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

**Validation**:
- [ ] Build succeeds with zero errors and zero warnings
- [ ] Launch in Simulator: black background, glass outline, liquid mass (not individual circles)
- [ ] Particles fall under default gravity and visually merge at bottom
- [ ] Glass outline is sharp (not blurred)
- [ ] No console errors

---

### Step 7: Update Documentation
**Files**: `docs/TASK.md`, `docs/TESTING.md`

Update `docs/TASK.md`:
- Move `02-init-phase2-visuals.md` to "In Progress"
- Update backlog references to use `02-init-` prefix

Update `docs/TESTING.md`:
- Add Phase 2 visual entries to Physics Tuning Log (blurRadius, alphaMultiplier)

---

### Step 8: Commit and Push
```bash
git add WaterGlass/WaterGlass/GameScene.swift \
       WaterGlass/WaterGlass/GameScene+Rendering.swift \
       WaterGlass/WaterGlass/GameScene+Water.swift \
       WaterGlass/WaterGlass/GameScene+Physics.swift \
       docs/TASK.md docs/TESTING.md
git commit -m "feat: Phase 2 metaball liquid effect — blur + threshold filter pipeline"
git push
```

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Unit Tests (deferred)
No pure logic worth unit-testing. The filter is a visual effect — only device testing is
meaningful.

### Simulator Tests
- [ ] App launches without crash
- [ ] Liquid mass visible (not individual circles)
- [ ] Glass outline is sharp
- [ ] Particles fall under default gravity
- [ ] No console errors

### Device Tests

| # | Action | Expected Result | Pass? |
|---|--------|-----------------|-------|
| 1 | Launch app | Liquid mass renders, falls and settles | ☐ |
| 2 | Look closely at liquid | No individual circle outlines visible | ☐ |
| 3 | Tilt slowly | Liquid moves as a cohesive body | ☐ |
| 4 | Tilt to split liquid | Stretched "neck" between separating blobs | ☐ |
| 5 | Bring separated blobs back | Blobs merge seamlessly — no seam | ☐ |
| 6 | Tilt left/right | Sloshing feels identical to Phase 1 | ☐ |
| 7 | Rapid tilt | Smooth, no crash, no visual glitches | ☐ |
| 8 | Check FPS overlay | Stable ~60fps with effect active | ☐ |
| 9 | Hold for 2 minutes | No FPS degradation, no memory growth | ☐ |
| 10 | Glass outline | Sharp, not blurred, visible above liquid | ☐ |

### Error Scenarios

| Scenario | How to Trigger | Expected Behavior | Pass? |
|----------|----------------|-------------------|-------|
| Run on Simulator | Launch in Xcode Simulator | Renders with metaball effect, no crash | ☐ |
| FPS below 60 | 100 particles + filter too expensive | Reduce particleCount or blurRadius | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| CIFilter returns nil | Filter name typo or unavailable | Guard in MetaballFilter — returns nil, effectNode shows raw particles |
| FPS drops below 60 | SKEffectNode + CIFilter per-frame cost too high | Reduce particleCount toward 80 or reduce blurRadius |
| CoreMotion unavailable | Simulator | Unchanged from Phase 1 — guard + default gravity |

---

## Open Questions

None blocking execution. The three questions from the init spec are addressed:

1. **Performance**: Start with 100 particles. If FPS drops below 60 on device, reduce
   toward 80 or reduce blurRadius. Test early in Step 6.
2. **Threshold approach**: Using `CIColorMatrix` with alpha multiplier of 20. Tune on device.
3. **Particle colour**: Set via `CIColorMatrix` bias vector `(0.3, 0.6, 1.0)`. Particles
   are white to maximise alpha signal for the threshold.

---

## Rollback Plan

If issues are discovered:
1. `git revert HEAD` to undo the Phase 2 commit
2. `git push` to update remote
3. Verify: app returns to Phase 1 marble-style particles, builds and runs

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | 9 | Init spec is thorough. Metaball technique well-described. |
| Feasibility | 8 | SKEffectNode + CIFilter is proven approach. Performance is the main risk — 100 particles with per-frame filter is demanding but within SpriteKit's budget on modern iPhones. |
| Completeness | 9 | All aspects covered. Only unknown is exact tuning values for blurRadius and alphaMultiplier — expected to need device iteration. |
| Alignment | 10 | Follows ADR-001 (SpriteKit only), ADR-003 (metaball Phase 2), ADR-004 (GameScene+Rendering.swift). |
| **Average** | **9.0** | |

---

## Notes

### Performance Budget
`SKEffectNode` renders children to an offscreen texture and applies the CIFilter every
frame. This is the expected cost — `shouldRasterize = false` because particles move
constantly. On modern iPhones (A15+), 100 particles with Gaussian blur + color matrix
should comfortably hit 60fps. If not, the knobs are:
- Reduce `particleCount` (80 → 60 → 50)
- Reduce `blurRadius` (12 → 8) — less blur = faster, but less smooth merge
- Both are in `enum Physics` — easy to change

### Tuning the Metaball Look
Two main knobs:
- **blurRadius** (12.0): Controls how far the glow spreads. Higher = particles merge from
  further apart. Too high = blobby mess. Too low = still see individual circles.
- **alphaMultiplier** (20.0): Controls edge sharpness. Higher = harder edge (more solid
  look). Lower = softer, more transparent edges. 20 is a good starting point.

### Why White Particles
The `CIColorMatrix` zeros out original RGB and replaces via bias. The particle's visual
colour is irrelevant — only its alpha matters for the threshold. White at alpha 1.0 gives
the strongest, cleanest alpha signal. The water colour (blue) is entirely controlled by the
bias vector `(0.3, 0.6, 1.0)`.

### Crop After Blur
`CIGaussianBlur` extends the image extent beyond the input bounds. The `.cropped(to:
input.extent)` call clips back to the original size, preventing the filter from processing
an ever-expanding region and improving performance.
