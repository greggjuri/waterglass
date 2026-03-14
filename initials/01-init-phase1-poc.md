# Init Spec - Feature Specification

## init-01: Phase 1 — Proof of Concept (Physics World + Glass + Particles + CoreMotion)

**Created**: 2026-03-14
**Priority**: High
**Phase**: 1
**Depends On**: None

---

## Problem Statement

The WaterGlass Xcode project exists but contains the default SpriteKit template (spinning
shape nodes, hello label). There is no physics world, no glass boundary, no water particles,
and no CoreMotion integration. Nothing moves when you tilt the phone.

## Goal

When this feature is complete: you can hold a real iPhone, tilt it any direction, and watch
50 circular particles slosh around inside a glass-shaped boundary — responding naturally to
gravity as the device moves.

---

## Requirements

### Must Have (P0)
1. Glass boundary defined as an `edgeLoopFrom` physics body — particles cannot escape
2. 50 circular `SKShapeNode` particles with `SKPhysicsBody`, sitting inside the glass
3. `CMMotionManager` using fused `deviceMotion` (not raw accelerometer) — per ADR-002
4. CoreMotion gravity vector maps to `physicsWorld.gravity` in real time at 60fps
5. App launches without crash on Simulator (CoreMotion unavailable — graceful guard)
6. App works correctly on physical iPhone

### Should Have (P1)
7. Physics constants isolated in a typed `enum Physics { }` namespace (easy to tune on device)
8. `GameScene.swift` split into extensions before hitting 300 lines — per ADR-004
9. Debug overlays on in Debug build: `showsFPS = true`, `showsPhysics = true`

### Nice to Have (P2)
10. Glass boundary drawn with a visible `SKShapeNode` outline so you can see the container

---

## Technical Considerations

### SpriteKit Changes

**Glass boundary:**
- Use `physicsBody = SKPhysicsBody(edgeLoopFrom: rect)` on the scene itself
- Rect should be inset from screen edges — feels like a glass, not the whole screen
- A simple rectangle for Phase 1 is fine (proper glass shape is Phase 2)
- Optional: draw visible `SKShapeNode` outline to show the container

**Particle nodes (x50):**
- `SKShapeNode(circleOfRadius: Physics.particleRadius)`
- `SKPhysicsBody(circleOfRadius: Physics.particleRadius)` — dynamic, affected by gravity
- Set `restitution`, `friction`, `linearDamping`, `angularDamping` from `enum Physics`
- Blue fill colour: `SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8)`
- Spawn inside glass boundary — stacked loosely near centre/top

**Physics world:**
- Default gravity: `CGVector(dx: 0, dy: -9.8)` initially — overridden by CoreMotion on device
- On Simulator: gravity stays at default (acceptable — particles just fall and sit at bottom)

### CoreMotion Changes

- `CMMotionManager` instance on `GameScene`
- `deviceMotionUpdateInterval = 1.0 / 60.0`
- Start updates in `didMove(to:)`
- Map `motion.gravity.x / .y` → `physicsWorld.gravity` using `Physics.gravityMultiplier`
- `[weak self]` in closure — memory management
- `guard motionManager.isDeviceMotionAvailable` — Simulator safety

### New Files / Extensions

Per ADR-004, split as GameScene approaches 300 lines:

- `GameScene.swift` — `didMove(to:)`, `update()`, `enum Physics`, wiring
- `GameScene+Physics.swift` — `setupPhysicsWorld()`, `createGlass()`
- `GameScene+Motion.swift` — `startMotionUpdates()`, `stopMotionUpdates()`
- `GameScene+Water.swift` — `createWaterParticles()`

**Delete from template**: `GameScene.sks` file and all references — we build the scene
programmatically, not from a `.sks` file. Also remove `spinnyNode`, `label`, and
`childNode(withName: "//helloLabel")` — all template cruft.

**Modify**: `GameViewController.swift` — replace `SKScene(fileNamed: "GameScene")` with
direct programmatic scene creation: `GameScene(size: view.bounds.size)`.

### Physics Constants to Tune

All defined in `enum Physics` — tweak on device after first build:

```swift
enum Physics {
    static let gravityMultiplier: Double = 20.0  // scale CoreMotion [-1,1] to useful force
    static let particleRadius: CGFloat = 12.0
    static let particleCount: Int = 50
    static let restitution: CGFloat = 0.3        // bounciness — start low, water isn't bouncy
    static let friction: CGFloat = 0.05          // surface drag
    static let linearDamping: CGFloat = 0.4      // velocity bleed — prevents endless sloshing
    static let angularDamping: CGFloat = 0.4     // spin bleed
}
```

---

## Constraints

- Must not crash on Simulator (CoreMotion returns nil — guard and skip)
- Must maintain 60fps on device (50 particles is well within SpriteKit budget)
- Must follow ADR-001 (SpriteKit only — no Unity, no Metal)
- Must follow ADR-002 (fused `deviceMotion` — not raw `accelerometer`)
- No force unwraps (`!`) — use `guard` / `if let`

---

## Success Criteria

- [ ] App launches on Simulator: scene renders, particles visible, no console errors
- [ ] On Simulator: particles fall to bottom under default gravity (no motion, just gravity)
- [ ] On device: tilt left → particles move left
- [ ] On device: tilt right → particles move right
- [ ] On device: lay flat → particles settle at bottom
- [ ] On device: flip upside-down → particles fall to new "bottom"
- [ ] No particles ever escape the glass boundary
- [ ] No crashes during normal tilt — including rapid movement
- [ ] FPS stays at 60 on device (visible in `showsFPS` overlay)

---

## Out of Scope

- Visual metaball / liquid shader effect (Phase 2)
- Actual glass shape (tapered, curved) — rectangle is fine for Phase 1
- Sound effects (Phase 3)
- Multiple glass shapes (Phase 3)
- Any UI controls (Phase 3)
- Dracula theme (Phase 4)

---

## Open Questions

All answered — none blocking PRP generation.

1. ~~Rectangle or tapered glass for Phase 1?~~ → Rectangle. Shape polish is Phase 2.
2. ~~`GameScene.sks` or programmatic scene?~~ → Programmatic. Delete the `.sks` file.
3. ~~Split extensions immediately or only when file grows?~~ → Split from the start — it's
   easier to start organised than to refactor later.
4. ~~How to handle CoreMotion on Simulator?~~ → `guard isDeviceMotionAvailable else { return }`.
   Default gravity stays. Document in `TESTING.md`.

---

## Notes

**Y-axis inversion**: SpriteKit uses a flipped Y axis relative to UIKit. Bottom-left is (0,0).
CoreMotion `gravity.y` is negative when phone is upright (gravity pulls down = negative Y in
device coordinates, which is positive Y in screen coordinates). The mapping needs care — test
on device and flip sign if particles move the wrong direction. This is a known SpriteKit quirk
(documented in ADR-001 consequences).

**Glass inset values**: Start with something like 60pt inset from each screen edge. This gives
a visible "container" feel. The exact values will need device tuning.

**Particle spawn positions**: Scatter within the upper half of the glass boundary. If you pack
them too tightly the physics engine has to resolve a lot of overlaps at start — can look like
an explosion. A loose grid or jittered positions work better.

**Reference**: Apple's SpriteKit physics docs and WWDC sessions on SKPhysicsWorld are solid.
`edgeLoopFrom` is the right approach for a container — it creates a static boundary with no
mass that other bodies collide against.

---

## Usage

1. ✅ This file is complete
2. In Claude Code: `/generate-prp initials/init-phase1-poc.md`
