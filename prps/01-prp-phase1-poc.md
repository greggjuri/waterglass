# 01-prp-phase1-poc: Phase 1 — Proof of Concept

**Created**: 2026-03-14
**Initial**: `initials/01-init-phase1-poc.md`
**Status**: Complete

---

## Overview

### Problem Statement

The WaterGlass Xcode project contains the default SpriteKit template — spinning shape nodes, a "Hello" label, and `.sks` scene files. There is no physics world, no glass boundary, no water particles, and no CoreMotion integration. Nothing moves when you tilt the phone.

### Proposed Solution

Replace the template code with a programmatic SpriteKit scene containing:
1. A rectangular glass boundary (edge-loop physics body) inset from screen edges
2. 50 circular `SKShapeNode` particles with dynamic `SKPhysicsBody`
3. `CMMotionManager` using fused `deviceMotion` to drive `physicsWorld.gravity` at 60fps
4. Graceful fallback on Simulator where CoreMotion is unavailable

The scene is split into extensions from the start per ADR-004.

### Success Criteria
- [ ] App launches on Simulator: scene renders, particles visible, no console errors
- [ ] On Simulator: particles fall to bottom under default gravity
- [ ] On device: tilt left → particles move left
- [ ] On device: tilt right → particles move right
- [ ] On device: lay flat → particles settle at bottom
- [ ] On device: flip upside-down → particles fall to new "bottom"
- [ ] No particles ever escape the glass boundary
- [ ] No crashes during normal tilt — including rapid movement
- [ ] FPS stays at 60 on device (`showsFPS` overlay)

---

## Context

### Related Documentation
- `docs/PLANNING.md` — Architecture overview, phase breakdown
- `docs/DECISIONS.md` — ADR-001 (SpriteKit), ADR-002 (fused deviceMotion), ADR-003 (particle-based Phase 1), ADR-004 (extension split)
- `docs/TESTING.md` — Device testing checklist, physics tuning log

### Dependencies
- **Required**: None — this is the first feature
- **Optional**: None

### Files to Modify/Create
```
WaterGlass/WaterGlass/GameViewController.swift   # Switch from .sks to programmatic scene
WaterGlass/WaterGlass/GameScene.swift             # Rewrite: properties, didMove(to:), update(), Physics enum
WaterGlass/WaterGlass/GameScene+Physics.swift     # NEW: setupPhysicsWorld(), createGlass()
WaterGlass/WaterGlass/GameScene+Motion.swift      # NEW: startMotionUpdates(), stopMotionUpdates()
WaterGlass/WaterGlass/GameScene+Water.swift       # NEW: createWaterParticles()
```

### Files to Delete
```
WaterGlass/WaterGlass/GameScene.sks               # Replaced by programmatic scene
WaterGlass/WaterGlass/Actions.sks                  # Template artifact — no longer needed
```

---

## Technical Specification

### New Swift Types / Constants
```swift
import CoreMotion

// In GameScene.swift — top of file or inside the class
enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 12.0
    static let particleCount: Int = 50
    static let restitution: CGFloat = 0.3
    static let friction: CGFloat = 0.05
    static let linearDamping: CGFloat = 0.4
    static let angularDamping: CGFloat = 0.4
    static let glassInset: CGFloat = 60.0
}
```

### Scene/Node Structure
```
SKScene (GameScene)
├── self.physicsBody = SKPhysicsBody(edgeLoopFrom: glassRect)   # Glass boundary
├── glassOutline: SKShapeNode(rect: glassRect)                   # Visible glass outline (P2)
└── SKShapeNode (x 50)                                           # Water particles
    └── each has SKPhysicsBody(circleOfRadius: particleRadius)
```

### Properties on GameScene
```swift
class GameScene: SKScene {
    let motionManager = CMMotionManager()
    // No other stored properties needed — particles are child nodes
}
```

### CoreMotion Integration
```swift
// In GameScene+Motion.swift
func startMotionUpdates() {
    guard motionManager.isDeviceMotionAvailable else {
        print("Device motion not available (Simulator?) — using default gravity")
        return
    }
    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
        if let error = error {
            print("Motion error: \(error.localizedDescription)")
            return
        }
        guard let motion = motion, let self = self else { return }
        self.physicsWorld.gravity = CGVector(
            dx: motion.gravity.x * Physics.gravityMultiplier,
            dy: motion.gravity.y * Physics.gravityMultiplier
        )
    }
}
```

### Y-Axis Note
CoreMotion `gravity.y` is negative when phone is upright. SpriteKit Y=0 is at bottom. The mapping `dy: motion.gravity.y * multiplier` should be correct without sign flip — gravity.y negative = SpriteKit gravity pulling down = particles fall. **Must verify on device** and flip sign if particles move the wrong direction.

---

## Implementation Steps

### Step 1: Clean Up Template — GameViewController
**Files**: `WaterGlass/WaterGlass/GameViewController.swift`

Replace the `.sks`-based scene loading with programmatic scene creation. Remove `GameplayKit` import.

```swift
import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        #endif
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
```

Key changes:
- `guard let` instead of force-unwrap `as!`
- Programmatic `GameScene(size:)` instead of `SKScene(fileNamed:)`
- `.resizeFill` scale mode — scene matches view size
- Portrait-only orientation (water sim makes most sense in portrait)
- Debug overlays behind `#if DEBUG` (per P1 requirement)
- Removed `GameplayKit` import — not used

**Validation**:
- [ ] Builds without errors (scene will be blank — no content yet)

---

### Step 2: Rewrite GameScene Core
**Files**: `WaterGlass/WaterGlass/GameScene.swift`

Replace the entire template file. This becomes the hub that imports CoreMotion, declares properties, and calls setup methods defined in extensions.

```swift
//
//  GameScene.swift
//  WaterGlass
//

import SpriteKit
import CoreMotion

// MARK: - Physics Constants

enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 12.0
    static let particleCount: Int = 50
    static let restitution: CGFloat = 0.3
    static let friction: CGFloat = 0.05
    static let linearDamping: CGFloat = 0.4
    static let angularDamping: CGFloat = 0.4
    static let glassInset: CGFloat = 60.0
}

// MARK: - GameScene

class GameScene: SKScene {

    let motionManager = CMMotionManager()

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupPhysicsWorld()
        createGlass()
        createWaterParticles()
        startMotionUpdates()
    }

    override func update(_ currentTime: TimeInterval) {
        // Per-frame updates — empty for Phase 1
        // CoreMotion updates gravity in its own closure
    }

    override func willMove(from view: SKView) {
        stopMotionUpdates()
    }
}
```

Key design:
- `enum Physics` at file level — accessible from all extensions
- `motionManager` is a stored property (one instance per scene)
- `didMove(to:)` calls setup methods defined in extensions
- `willMove(from:)` stops motion updates on scene teardown (memory cleanup)
- `backgroundColor = .black` — particles (blue) will be visible

**Validation**:
- [ ] Does NOT build yet — extension methods not created. That's expected.

---

### Step 3: Create Physics Extension — Glass Boundary
**Files**: `WaterGlass/WaterGlass/GameScene+Physics.swift` (NEW)

```swift
//
//  GameScene+Physics.swift
//  WaterGlass
//

import SpriteKit

// MARK: - Physics Setup

extension GameScene {

    func setupPhysicsWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }

    func createGlass() {
        let glassRect = CGRect(
            x: Physics.glassInset,
            y: Physics.glassInset,
            width: size.width - Physics.glassInset * 2,
            height: size.height - Physics.glassInset * 2
        )

        // Invisible physics boundary — particles cannot escape
        physicsBody = SKPhysicsBody(edgeLoopFrom: glassRect)
        physicsBody?.friction = 0.1

        // Visible outline so you can see the glass (P2 nice-to-have, included here)
        let outline = SKShapeNode(rect: glassRect)
        outline.strokeColor = SKColor(white: 0.4, alpha: 0.6)
        outline.lineWidth = 2.0
        outline.fillColor = .clear
        addChild(outline)
    }
}
```

Key design:
- `edgeLoopFrom` creates a static boundary — no mass, other bodies collide against it
- Glass is inset 60pt from all edges — gives a "container" feel
- Visible outline included (init spec P2 nice-to-have) — subtle grey, not distracting
- Default gravity `(0, -9.8)` — overridden by CoreMotion on device, stays as fallback on Simulator

**Validation**:
- [ ] Does NOT build yet — still missing Water and Motion extensions

---

### Step 4: Create Water Extension — Particle Spawning
**Files**: `WaterGlass/WaterGlass/GameScene+Water.swift` (NEW)

```swift
//
//  GameScene+Water.swift
//  WaterGlass
//

import SpriteKit

// MARK: - Water Particles

extension GameScene {

    func createWaterParticles() {
        let glassMinX = Physics.glassInset + Physics.particleRadius * 2
        let glassMaxX = size.width - Physics.glassInset - Physics.particleRadius * 2
        let glassMinY = size.height * 0.4
        let glassMaxY = size.height - Physics.glassInset - Physics.particleRadius * 2

        for _ in 0..<Physics.particleCount {
            let particle = SKShapeNode(circleOfRadius: Physics.particleRadius)
            particle.fillColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8)
            particle.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.6)
            particle.lineWidth = 1.0

            // Random position in upper half of glass — loose scatter avoids overlap explosion
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

            addChild(particle)
        }
    }
}
```

Key design:
- Particles spawn in the upper half of the glass — they'll fall on launch, which looks natural
- Random scatter prevents physics engine overlap explosion at frame 1
- `allowsRotation = false` — circles don't need to spin, saves computation
- Blue fill with slight stroke — visible against black background
- All physics constants from `enum Physics` — easy to tune later

**Validation**:
- [ ] Does NOT build yet — still missing Motion extension

---

### Step 5: Create Motion Extension — CoreMotion Integration
**Files**: `WaterGlass/WaterGlass/GameScene+Motion.swift` (NEW)

```swift
//
//  GameScene+Motion.swift
//  WaterGlass
//

import SpriteKit
import CoreMotion

// MARK: - CoreMotion

extension GameScene {

    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available (Simulator?) — using default gravity")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            if let error = error {
                print("Motion error: \(error.localizedDescription)")
                return
            }
            guard let motion = motion, let self = self else { return }
            self.physicsWorld.gravity = CGVector(
                dx: motion.gravity.x * Physics.gravityMultiplier,
                dy: motion.gravity.y * Physics.gravityMultiplier
            )
        }
    }

    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
```

Key design:
- `guard isDeviceMotionAvailable` — Simulator returns false, motion setup skips gracefully
- `[weak self]` — prevents retain cycle between closure and scene
- Updates on `.main` queue — SpriteKit requires main-thread physics changes
- `stopMotionUpdates()` called from `willMove(from:)` — clean teardown
- Error logged but not fatal — app continues with last known gravity

**Validation**:
- [ ] Builds without errors
- [ ] Launches on Simulator: particles fall to bottom, no crash
- [ ] No console errors

---

### Step 6: Delete Template Files
**Files to delete**:
- `WaterGlass/WaterGlass/GameScene.sks`
- `WaterGlass/WaterGlass/Actions.sks`

```bash
rm WaterGlass/WaterGlass/GameScene.sks
rm WaterGlass/WaterGlass/Actions.sks
```

The project uses `PBXFileSystemSynchronizedRootGroup` — Xcode auto-syncs with the filesystem. A plain `git rm` is all that's needed; no `.pbxproj` editing required.

**Validation**:
- [ ] Builds without errors (no references to deleted files remain)
- [ ] App still launches — scene is fully programmatic

---

### Step 7: Build Verification and Simulator Test
**Commands**:
```bash
xcodebuild -scheme WaterGlass -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**Validation**:
- [ ] Build succeeds with zero errors
- [ ] Launch in Simulator: black background, grey glass outline, 50 blue particles
- [ ] Particles fall to bottom under default gravity and settle
- [ ] FPS counter visible in bottom-left (Debug build)
- [ ] Physics body outlines visible (Debug build)
- [ ] No console warnings or errors

---

### Step 8: Update Documentation
**Files**: `docs/TASK.md`, `docs/TESTING.md`

Update `docs/TASK.md`:
- Move `01-init-phase1-poc.md` from "Up Next" to "In Progress"
- Update any references using the old `init-phase1-poc.md` name to use the `01-init-` prefix

Update `docs/TESTING.md`:
- Add note about Simulator behaviour (particles fall, no motion — expected)

---

### Step 9: Commit and Push
```bash
git add WaterGlass/WaterGlass/GameScene.swift \
       WaterGlass/WaterGlass/GameScene+Physics.swift \
       WaterGlass/WaterGlass/GameScene+Water.swift \
       WaterGlass/WaterGlass/GameScene+Motion.swift \
       WaterGlass/WaterGlass/GameViewController.swift \
       docs/TASK.md docs/TESTING.md
git rm WaterGlass/WaterGlass/GameScene.sks WaterGlass/WaterGlass/Actions.sks
git commit -m "feat: Phase 1 POC — physics world, glass boundary, 50 particles, CoreMotion gravity"
git push
```

**Validation**:
- [ ] Commit pushed to GitHub
- [ ] `docs/TASK.md` updated

---

## Testing Requirements

### Unit Tests (deferred)
No pure logic worth unit-testing in this step. The gravity mapping is a single multiplication — testing it adds no value. Unit tests become relevant in Phase 2+ when calculation logic grows.

### Simulator Tests
- [ ] App launches without crash
- [ ] Scene renders: black background, grey glass outline
- [ ] 50 blue particles visible
- [ ] Particles fall under default gravity and settle at bottom of glass
- [ ] No console errors
- [ ] FPS and physics debug overlays visible

### Device Tests

| # | Action | Expected Result | Pass? |
|---|--------|-----------------|-------|
| 1 | Launch app | Scene renders, particles fall and settle | ☐ |
| 2 | Tilt left | Particles slide left | ☐ |
| 3 | Tilt right | Particles slide right | ☐ |
| 4 | Tilt forward (top away) | Particles move toward bottom edge | ☐ |
| 5 | Tilt backward (top toward) | Particles move toward top edge | ☐ |
| 6 | Lay flat on table | Particles settle at bottom | ☐ |
| 7 | Flip upside-down | Particles fall to new "bottom" (top of screen) | ☐ |
| 8 | Rapid tilt back and forth | Smooth sloshing, no crash | ☐ |
| 9 | Hold for 2 minutes | Stable FPS ~60, no memory growth | ☐ |
| 10 | Check glass edges | No particles escape boundary | ☐ |

### Error Scenarios

| Scenario | How to Trigger | Expected Behavior | Pass? |
|----------|----------------|-------------------|-------|
| Run on Simulator | Launch in Xcode Simulator | Renders, no crash, particles fall under default gravity | ☐ |
| CoreMotion error | Rare on device — error path logged | Console prints error, app continues | ☐ |

---

## Error Handling

| Error | Cause | Handling |
|-------|-------|----------|
| CoreMotion unavailable | Running on Simulator | `guard isDeviceMotionAvailable` — skip motion setup, default gravity stays |
| Motion update error | Sensor failure (rare) | Log error, return from closure — last gravity value persists |
| Scene teardown during updates | Navigating away / backgrounding | `willMove(from:)` calls `stopMotionUpdates()` |

---

## Open Questions

None — all questions answered in the init spec.

---

## Rollback Plan

If issues are discovered:
1. `git revert HEAD` to undo the Phase 1 commit
2. `git push` to update remote
3. Verify: app returns to default SpriteKit template, builds and launches

---

## Confidence Scores

| Dimension | Score (1-10) | Notes |
|-----------|--------------|-------|
| Clarity | 9 | Init spec is thorough — requirements are unambiguous |
| Feasibility | 10 | Standard SpriteKit + CoreMotion — well-documented Apple APIs |
| Completeness | 10 | All aspects covered. `.pbxproj` uses `PBXFileSystemSynchronizedRootGroup` — auto-syncs with filesystem, no manual editing needed |
| Alignment | 10 | Follows all four ADRs, respects file limits, uses conventions from CLAUDE.md |
| **Average** | **9.75** | |

---

## Notes

### Physics Tuning
The constants in `enum Physics` are starting points from the init spec. After the first device build, expect to iterate on:
- `gravityMultiplier` — 20.0 may feel too strong or too weak
- `linearDamping` — affects how quickly particles settle
- `restitution` — 0.3 gives mild bounce; lower for more "watery" feel

### Orientation Lock
`GameViewController` is locked to `.portrait`. Water simulation is most intuitive in portrait — the phone IS the glass. If landscape support is desired later, the gravity mapping works regardless since CoreMotion reports in device coordinates.

### Performance Budget
50 particles with `SKPhysicsBody` is well within SpriteKit's budget. SpriteKit handles hundreds of physics bodies at 60fps on modern iPhones. Phase 2 may increase count for denser fluid look.
