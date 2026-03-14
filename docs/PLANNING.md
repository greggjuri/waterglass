# WaterGlass - Project Planning

## Project Vision

A physics-based iOS app that simulates water in a glass. Tilt your iPhone and watch the liquid
slosh realistically. Built as a first Swift project by a Python/infrastructure veteran who learns
by building tactile, satisfying things.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         iOS APP                                      │
│                    Swift + SpriteKit                                 │
│                    Runs on iPhone                                    │
└─────────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│      CoreMotion         │     │       SpriteKit          │
│  Device accelerometer   │────▶│   Physics world +        │
│  + gyroscope fusion     │     │   2D rendering           │
│  (gravity vector)       │     │   (particles/fluid)      │
└─────────────────────────┘     └─────────────────────────┘
```

**Data flow:**
```
Device tilts
  → CMMotionManager reads gravity vector (x, y, z)
  → Map to SKPhysicsWorld.gravity (CGVector)
  → SpriteKit physics engine updates particle positions
  → Renderer draws frame
  → 60fps loop
```

## No Backend. No Database. No Cloud.

This is a fully local iOS app. There are no API calls, no user accounts, no server costs.

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | Swift 5.x | iOS development |
| Physics + Rendering | SpriteKit | 2D physics world, particle nodes, shaders |
| Sensors | CoreMotion | Accelerometer + gyroscope (fused device motion) |
| IDE | Xcode | Build, run, debug, deploy to device |
| CLI | Claude Code | AI-assisted implementation |
| Version Control | Git + GitHub | Commit after every feature/fix |

## Project Structure

```
WaterGlass/
├── CLAUDE.md                        # Claude Code instructions
├── docs/
│   ├── PLANNING.md                  # This file
│   ├── TASK.md                      # Sprint tasks
│   ├── DECISIONS.md                 # Architecture Decision Records
│   └── TESTING.md                   # Testing standards
├── initials/                        # Feature specs (init-*.md)
├── prps/                            # Implementation plans (prp-*.md)
│   └── templates/
│       └── prp-template.md
├── .claude/
│   └── commands/
│       ├── generate-prp.md
│       └── execute-prp.md
└── WaterGlass/                      # Xcode project
    ├── WaterGlassApp.swift          # App entry point
    ├── GameViewController.swift     # Hosts SKView
    ├── GameScene.swift              # Main scene (split into extensions as it grows)
    ├── GameScene+Physics.swift      # (Phase 1+) Physics setup
    ├── GameScene+Motion.swift       # (Phase 1+) CoreMotion
    ├── GameScene+Water.swift        # (Phase 2+) Water/particle logic
    ├── GameScene+Rendering.swift    # (Phase 2+) Shaders/visuals
    └── Assets.xcassets/
```

## Key SpriteKit Concepts Used

| Concept | Role in WaterGlass |
|---------|-------------------|
| `SKScene` | Container for all game content |
| `SKShapeNode` | Draw water particles (circles → Phase 1) |
| `SKPhysicsBody` | Makes nodes respond to physics |
| `SKPhysicsWorld` | Global gravity — updated from CoreMotion |
| `edgeLoopFrom` | Glass boundary (static physics body) |
| `SKShader` | Metaball/liquid effect (Phase 2) |
| `SKEffectNode` | Blur + threshold for liquid look (Phase 2) |

## Key CoreMotion Concepts Used

| Concept | Role in WaterGlass |
|---------|-------------------|
| `CMMotionManager` | Access device sensors |
| `deviceMotion` | Fused sensor data (best quality) |
| `gravity` | Which way is down — drives physicsWorld.gravity |
| `deviceMotionUpdateInterval` | Set to 1/60 to match frame rate |

## Development Phases

### Phase 1: Proof of Concept
- [ ] Xcode project created (SpriteKit game template)
- [ ] Basic physics world with gravity
- [ ] Glass as edge-loop physics boundary
- [ ] 50 circular particles as "water"
- [ ] CoreMotion → physicsWorld.gravity connection
- [ ] Test on physical device

**Milestone:** Balls slosh around when you tilt the phone.

### Phase 2: Make It Look Like Water
- [ ] Smaller, more numerous particles
- [ ] SKEffectNode + blur + threshold for metaball effect
- [ ] Blue color with transparency
- [ ] Tune damping, restitution, friction for realistic feel
- [ ] Glass outline/shape

**Milestone:** Actually looks like water, not balls.

### Phase 3: Polish
- [ ] Sound effects (subtle slosh)
- [ ] Multiple glass shapes
- [ ] Fill level control (add/remove water)
- [ ] Different liquids (water, honey, mercury) with different physics presets
- [ ] Settings/UI

### Phase 4: Dracula Theme (Optional)
- Red liquid
- Gothic chalice shape
- Spooky ambient audio
- Game mode: don't spill or health drains

## Physics Constants (Starting Points — Tune on Device)

```swift
enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRadius: CGFloat = 12.0
    static let particleCount: Int = 50
    static let restitution: CGFloat = 0.3      // bounciness
    static let friction: CGFloat = 0.05        // surface drag
    static let linearDamping: CGFloat = 0.4    // velocity bleed
    static let angularDamping: CGFloat = 0.4   // spin bleed
}
```

## Success Criteria

1. [ ] Tilt phone → water moves naturally
2. [ ] Physics feels satisfying, not floaty or twitchy
3. [ ] Looks decent (Phase 2 visual effect working)
4. [ ] Runs at 60fps on device
5. [ ] Developer learned Swift fundamentals along the way

## Key Constraints

1. **Physical device required for testing** — simulator has no accelerometer
2. **500-line file limit** — split GameScene into extensions early
3. **Commit + push after each feature** — atomic, working commits
4. **Learning project** — favour clarity over cleverness in code
5. **No force unwraps** — use guard/if let for safe unwrapping

## Non-Functional Requirements

### Performance
- 60fps on device (SpriteKit default target)
- Physics updates at 1/60s interval matching CoreMotion

### Memory
- Particle count tuned to avoid memory pressure
- No retain cycles (use `[weak self]` in closures)

### Reliability
- App should not crash on motion unavailability (simulator)
- Graceful handling of CoreMotion errors
