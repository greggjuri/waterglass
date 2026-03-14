# WaterGlass - Architecture Decisions

## ADR-001: SpriteKit for Physics and Rendering

**Date**: 2026-03-14
**Status**: Accepted

### Context
Need a 2D physics engine and renderer for iOS that can handle many interacting particles
driven by device motion. Options: SpriteKit (Apple built-in), Unity, custom Metal/SceneKit.

### Decision
Use SpriteKit with SKPhysicsWorld for physics simulation and rendering.

### Rationale
- Built into iOS — no dependencies to manage
- Excellent documentation and community resources
- Physics engine handles particle collisions natively
- SKShader and SKEffectNode available for Phase 2 visual effects (metaballs)
- Appropriate for a first Swift project — lower cognitive overhead than Metal

### Alternatives Considered
| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| SpriteKit | Built-in, well-documented, has shaders | 2D only, less control than Metal | **Selected** |
| Unity | Powerful physics, cross-platform | Massive overhead for a learning project | Rejected |
| Custom Metal | Maximum control, best performance | Far too complex for first Swift project | Rejected |
| SceneKit | 3D capable | Overkill, 3D not needed | Rejected |

### Consequences

**Positive:**
- Fast to get started
- Physics "just works" for particle simulation
- SKEffectNode + blur provides metaball path for Phase 2

**Negative:**
- SpriteKit has some quirks with coordinate systems (Y-axis inverted vs UIKit)
- Performance ceiling lower than Metal for very large particle counts

---

## ADR-002: CoreMotion deviceMotion (Fused Sensor Data)

**Date**: 2026-03-14
**Status**: Accepted

### Context
Need to read device orientation/gravity to drive physics world gravity vector.
Options: raw accelerometer, raw gyroscope, or fused deviceMotion.

### Decision
Use `CMMotionManager.deviceMotion` (fused sensor data) rather than raw accelerometer.

### Rationale
- Fused data combines accelerometer + gyroscope for smoother, more accurate gravity vector
- Automatically compensates for device movement vs gravity
- Apple recommended approach for orientation-based apps
- `motion.gravity` gives clean [-1, 1] range on x/y/z axes

### Consequences

**Positive:**
- Smooth, stable gravity vector — no jitter from raw accelerometer
- Simple to map to `physicsWorld.gravity` CGVector

**Negative:**
- Slightly higher battery usage than raw accelerometer (negligible)
- Not available in Simulator (expected — acceptable constraint)

---

## ADR-003: Particle-Based Water (Phase 1), Metaball Visual (Phase 2)

**Date**: 2026-03-14
**Status**: Accepted

### Context
True fluid simulation (SPH, Navier-Stokes) is complex and expensive. Need an approach
that looks good enough while being feasible in SpriteKit.

### Decision
- **Phase 1**: Discrete circular `SKShapeNode` particles with `SKPhysicsBody` — proves the concept
- **Phase 2**: Wrap particles in `SKEffectNode` with blur + threshold shader to create metaball liquid effect

### Rationale
- Phase 1 gets something working fast — validates CoreMotion → physics pipeline
- Metaball technique (blur + threshold) is a well-known 2D liquid approximation
- Avoids implementing actual fluid dynamics
- Achievable in SpriteKit without Metal/custom shaders

### Consequences

**Positive:**
- Working prototype quickly
- Visual upgrade path is clear
- Each phase is independently valuable

**Negative:**
- Not physically accurate fluid simulation
- Particle count bounded by physics engine performance
- Metaball effect requires shader knowledge (Phase 2 learning curve)

---

## ADR-004: Split GameScene.swift into Extensions

**Date**: 2026-03-14
**Status**: Accepted

### Context
GameScene.swift will grow quickly. Physics setup, CoreMotion, water management,
and rendering are distinct concerns. 500-line file limit is a constraint.

### Decision
Split GameScene into Swift extensions by concern as the file approaches 300 lines:
- `GameScene+Physics.swift` — physics world, glass boundary
- `GameScene+Motion.swift` — CoreMotion setup and updates
- `GameScene+Water.swift` — particle creation and management
- `GameScene+Rendering.swift` — shaders and visual effects (Phase 2+)

### Rationale
- Swift extensions are idiomatic for this pattern
- Keeps each file focused and under 500 lines
- Easy to navigate — know exactly which file to look in

### Consequences

**Positive:**
- Clear separation of concerns
- Files stay small and readable
- Matches Swift community conventions

**Negative:**
- Slightly more files to manage (minor)

---

## Template for New Decisions

```markdown
## ADR-XXX: Title

**Date**: YYYY-MM-DD
**Status**: Proposed/Accepted/Deprecated/Superseded

### Context
What is the issue motivating this decision?

### Decision
What are we doing?

### Rationale
Why is this the best choice?

### Alternatives Considered (optional)
| Option | Pros | Cons | Verdict |
|--------|------|------|---------|

### Consequences
**Positive:**
- Benefit 1

**Negative:**
- Tradeoff 1
```

## Key Principles

1. **SpriteKit over custom**: Use Apple frameworks where they fit — avoid reinventing
2. **Fused sensor data**: Always use `deviceMotion` not raw accelerometer
3. **Phase discipline**: Get Phase 1 working before touching Phase 2 visuals
4. **Extensions for organisation**: Split by concern, not by size alone
