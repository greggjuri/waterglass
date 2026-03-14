# CLAUDE.md - Claude Code Instructions

This file provides project-specific instructions and conventions for Claude Code.

## Project Overview

**WaterGlass**: Physics-based iOS app simulating water in a glass. Tilt the iPhone, watch the water slosh.

**Tech Stack**: Swift | SpriteKit | CoreMotion | Xcode | iOS

## Quick Commands

```bash
# Build for simulator (CI/layout checks)
xcodebuild -scheme WaterGlass -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -scheme WaterGlass -destination 'platform=iOS Simulator,name=iPhone 16'

# Build for device (requires connected iPhone)
xcodebuild -scheme WaterGlass -destination 'platform=iOS,name=My iPhone' build

# Commit and push (after every feature/fix)
git add .
git commit -m "{type}: {description}"
git push
```

## File Structure

```
WaterGlass/
├── CLAUDE.md                        # This file
├── docs/
│   ├── PLANNING.md                  # Architecture overview
│   ├── TASK.md                      # Current tasks
│   ├── DECISIONS.md                 # ADRs
│   └── TESTING.md                   # Testing standards
├── initials/                        # Feature specifications
├── prps/                            # Implementation plans
│   └── templates/
│       └── prp-template.md
├── .claude/
│   └── commands/
│       ├── generate-prp.md
│       └── execute-prp.md
└── WaterGlass/                      # Xcode app source
    ├── WaterGlassApp.swift
    ├── GameViewController.swift
    ├── GameScene.swift
    ├── GameScene.sks
    └── Assets.xcassets/
```

## Critical Rules

### 1. File Size Limit
- **Maximum 500 lines per file**
- When approaching limit: split into Swift extensions or separate files
- Prefer `GameScene+Physics.swift`, `GameScene+Motion.swift` over one giant file

### 2. Commit Strategy
- **Commit AND push after every feature and fix** — no exceptions
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Each commit should build successfully

### 3. Testing Requirements
- Run `xcodebuild test` before committing when tests exist
- Motion/physics features: note in commit that device testing is required
- Add XCTest unit tests for any pure logic (calculations, data transforms)

### 4. Documentation
- Update `docs/TASK.md` when starting/completing tasks
- Create ADR in `docs/DECISIONS.md` for architectural choices
- Add learnings to `docs/TESTING.md` when debugging issues

## Coding Conventions

### Swift Style

```swift
// MARK: - Use MARK comments to organize large files

// Explicit types where it aids clarity
let gravity: CGFloat = -9.8

// Weak self in closures (memory management — important in SpriteKit)
motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
    guard let motion = motion, let self = self else { return }
    // ...
}

// Guard for early exits
guard motionManager.isDeviceMotionAvailable else {
    print("Device motion not available")
    return
}

// Constants at top of class or in enum namespace
enum Physics {
    static let gravityMultiplier: Double = 20.0
    static let particleRestitution: CGFloat = 0.3
    static let particleFriction: CGFloat = 0.05
}
```

### SpriteKit Patterns

```swift
// Override didMove(to:) for scene setup — not init
override func didMove(to view: SKView) {
    setupPhysics()
    createGlass()
    createWater()
    startMotionUpdates()
}

// Separate setup into focused private methods
private func setupPhysics() { ... }
private func createGlass() { ... }
private func createWater() { ... }
private func startMotionUpdates() { ... }

// Use update(_ currentTime:) for per-frame logic
override func update(_ currentTime: TimeInterval) {
    // Per-frame updates here
}
```

### CoreMotion Patterns

```swift
// Always check availability
guard motionManager.isDeviceMotionAvailable else { return }

// Always use [weak self] to avoid retain cycles
// Always guard against nil motion data
// Update interval: 1/60 for 60fps sync
motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
```

### File Organisation
- Split `GameScene.swift` into extensions when it approaches 300 lines:
  - `GameScene+Physics.swift` — physics world setup, glass creation
  - `GameScene+Water.swift` — particle/water creation and management
  - `GameScene+Motion.swift` — CoreMotion setup and updates
  - `GameScene+Rendering.swift` — visual/shader effects (Phase 2+)

## Error Handling Patterns

```swift
// CoreMotion errors — log, don't crash
motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
    if let error = error {
        print("Motion error: \(error.localizedDescription)")
        return
    }
    guard let motion = motion else { return }
    // proceed
}
```

## PRP Workflow

### Generating PRPs
```bash
/generate-prp initials/init-{feature}.md
```

### Executing PRPs
```bash
/execute-prp prps/prp-{feature}.md
```

## Common Patterns

### Adding a New Visual Element
1. Create in `didMove(to:)` or a dedicated `create*()` method
2. Set up `SKPhysicsBody` with appropriate properties
3. `addChild()` to scene
4. Test physics constants feel right on device

### Tuning Physics Feel
- `restitution` — bounciness (0 = dead, 1 = perfectly elastic)
- `friction` — surface drag
- `linearDamping` — velocity bleed-off (water feels ~0.3–0.5)
- `angularDamping` — rotation bleed-off
- `density` — affects how particles interact

### Gravity Mapping (CoreMotion → SpriteKit)
```swift
// gravity.x and gravity.y are in range [-1, 1]
// Multiply by a tuning constant (~20) to get useful SpriteKit forces
physicsWorld.gravity = CGVector(
    dx: motion.gravity.x * Physics.gravityMultiplier,
    dy: motion.gravity.y * Physics.gravityMultiplier
)
```

## DO NOT

- Commit secrets or provisioning profiles
- Skip the push step after committing
- Create files over 500 lines
- Contradict existing ADRs without discussion
- Use force unwrap (`!`) unless you have a specific reason and comment why
- Import frameworks not already in the project without noting it

## Reference Documents

- `docs/PLANNING.md` - Architecture and phases
- `docs/DECISIONS.md` - Past decisions to respect
- `docs/TASK.md` - Current work status
- `docs/TESTING.md` - Testing standards and device testing notes
