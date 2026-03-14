# WaterGlass

A physics-based iOS app simulating water in a glass. Tilt your iPhone — watch the water slosh.

Built with Swift + SpriteKit + CoreMotion as a first Swift project by a Python/infrastructure veteran.

---

## What It Does

- Device accelerometer drives a SpriteKit physics world in real time
- Water particles respond to gravity as you tilt the phone
- Phase 2: metaball shader makes it actually look like liquid

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift |
| Physics + Rendering | SpriteKit |
| Sensors | CoreMotion |
| IDE | Xcode |

## Requirements

- Xcode 15+
- iOS 16+ device (iPhone)
- Physical device required for motion testing — Simulator has no accelerometer

## Getting Started

```bash
git clone https://github.com/greggjuri/waterglass.git
cd waterglass
open WaterGlass.xcodeproj
```

Build and run on a connected iPhone via Xcode.

## Project Structure

```
WaterGlass/
├── CLAUDE.md                    # Claude Code instructions
├── docs/
│   ├── PLANNING.md              # Architecture and phases
│   ├── TASK.md                  # Sprint tasks
│   ├── DECISIONS.md             # Architecture Decision Records
│   └── TESTING.md               # Testing standards
├── initials/                    # Feature specs (init-*.md)
├── prps/                        # Implementation plans (prp-*.md)
└── WaterGlass/                  # Xcode app source
    ├── GameScene.swift          # Main scene — physics lives here
    └── ...
```

## Development Phases

- **Phase 1** ✅/🚧 — Proof of concept: balls slosh when you tilt the phone
- **Phase 2** — Looks like water: metaball shader, visual polish
- **Phase 3** — Polish: sound, multiple glass shapes, fill level, liquid presets
- **Phase 4** *(optional)* — Dracula's Goblet re-skin

## Workflow

This project uses a Claude.ai + Claude Code workflow:

1. Feature specs created in `initials/init-{feature}.md`
2. Claude Code generates implementation plans: `/generate-prp`
3. Claude Code executes plans: `/execute-prp`
4. Commit + push after every feature and fix

---

*First Swift project. Named after a conversation about Dracula and device motion.*
