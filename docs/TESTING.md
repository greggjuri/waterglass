# WaterGlass - Testing Standards

## Testing Reality for iOS/SpriteKit

This is not a backend with unit-testable business logic. Most of the "tests" are
physical — does it feel right when you tilt the phone? That said, pure logic is testable.

```
        /\
       /  \     Device testing (primary — physics feel, motion response)
      /----\
     /      \   Simulator (layout, UI, crash-free launch)
    /--------\
   /          \ XCTest unit tests (pure logic, calculations)
  --------------
```

## Test Types

| Test Type | When | How |
|-----------|------|-----|
| XCTest unit | Pure logic — physics constants, calculations | `xcodebuild test` |
| Simulator | Launch, UI layout, no-crash check | Xcode Simulator |
| Device | Motion response, physics feel, 60fps | Physical iPhone |

## Running Tests

```bash
# Run unit tests (simulator)
xcodebuild test \
  -scheme WaterGlass \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Build for device (requires connected iPhone + provisioning)
xcodebuild \
  -scheme WaterGlass \
  -destination 'platform=iOS,name=My iPhone' \
  build
```

## Before Every Commit

- [ ] Project builds without errors (`xcodebuild build`)
- [ ] No obvious Swift warnings treated as errors
- [ ] If unit tests exist: all pass
- [ ] Commit message is conventional format

## Device Testing Checklist

Run this after every Phase 1+ feature on physical iPhone:

### Motion Response
- [ ] Tilt left → particles move left
- [ ] Tilt right → particles move right
- [ ] Tilt forward/back → particles respond correctly
- [ ] Flat on table → particles settle at bottom
- [ ] Full flip (upside down) → particles fall to new bottom

### Physics Feel
- [ ] Motion feels smooth, not jittery
- [ ] Particles don't tunnel through glass walls
- [ ] Particles settle naturally when device is still
- [ ] No particles escape the glass boundary
- [ ] ~60fps (check Xcode FPS overlay or SKView `showsFPS = true`)

### Stability
- [ ] No crashes during normal use
- [ ] No crashes when tilting rapidly
- [ ] App runs for 5+ minutes without degrading

## Simulator Testing Checklist

(Before device — catches obvious issues fast)

- [ ] App launches without crash
- [ ] Scene renders — glass boundary visible
- [ ] Particles appear in initial position
- [ ] No red runtime errors in Xcode console
- [ ] Memory usage looks reasonable (Instruments if concerned)

## Physics Tuning Log

Document what you tried and how it felt — this is your institutional memory:

| Constant | Value Tried | Result | Verdict |
|----------|-------------|--------|---------|
| gravityMultiplier | 20.0 | (initial) | TBD on device |
| restitution | 0.3 | (initial) | TBD on device |
| linearDamping | 0.4 | (initial) | TBD on device |
| particleCount | 50 | (initial) | TBD on device |

*Add rows as you tune. Note what "too floaty", "too heavy", "twitchy" etc. feel like.*

## Common Bugs to Catch

| Bug | How to Detect | Fix Pattern |
|-----|---------------|-------------|
| Particles escape glass | Watch edges on device | Check edgeLoop inset values |
| Jittery motion | Looks twitchy | Increase linearDamping, check update interval |
| Floaty feel | Particles drift too long | Increase linearDamping |
| Wrong gravity direction | Tilting behaves backwards | Check x/y mapping, may need to negate |
| Memory leak | FPS drops over time | Check for [weak self] in closures |
| Retain cycle | App grows in memory | Use Instruments → Allocations |
| Crash on simulator | Immediate crash | Guard against CoreMotion unavailability |
| Particles overlap weirdly | Stack/pile unnaturally | Tune restitution and friction |

## Debugging Workflow

1. **Reproduce**: Confirm the issue
2. **Enable debug overlays**: `skView.showsFPS = true`, `skView.showsPhysics = true`
3. **Check Xcode console**: Look for runtime warnings
4. **Isolate**: Reduce particle count, simplify scene
5. **Fix**: Minimal change
6. **Verify**: Test on device again
7. **Document**: Add to Physics Tuning Log above

## XCTest Patterns (for pure logic)

```swift
// test file: WaterGlassTests/PhysicsTests.swift

import XCTest
@testable import WaterGlass

class PhysicsTests: XCTestCase {

    func testGravityVectorMapping() {
        // Verify CoreMotion gravity maps correctly to CGVector
        let gravityX = 0.5
        let gravityY = -0.866
        let multiplier = 20.0

        let result = CGVector(
            dx: gravityX * multiplier,
            dy: gravityY * multiplier
        )

        XCTAssertEqual(result.dx, 10.0, accuracy: 0.001)
        XCTAssertEqual(result.dy, -17.32, accuracy: 0.01)
    }
}
```

## Lessons Learned

*(Add here as you debug real issues — becomes invaluable reference)*

| Issue | Root Cause | Prevention |
|-------|------------|------------|
| *(add as encountered)* | | |

## Pre-Feature Completion Checklist

Before moving a task to "Recently Completed":

- [ ] Builds cleanly
- [ ] Unit tests pass (if any)
- [ ] Tested on simulator (no crash, renders)
- [ ] Tested on device (motion works, feels right)
- [ ] Committed with conventional message
- [ ] Pushed to GitHub
- [ ] TASK.md updated
