# Execute PRP

Execute a Project Requirement Plan step-by-step for WaterGlass.

## Arguments
- `$ARGUMENTS` - Path to PRP file (e.g., `prps/prp-phase1-poc.md`)

## Instructions

You are executing a PRP for the **WaterGlass** iOS project — a Swift/SpriteKit/CoreMotion app.

### Step 0: Pre-flight Checks

Before starting:
1. Read `CLAUDE.md` for Swift conventions and commit rules
2. Read the PRP at `$ARGUMENTS` completely
3. Verify all dependencies are met
4. Check that confidence score is ≥ 7 (if not, stop and report concerns)
5. Confirm you understand the success criteria

### Step 1: Execute Implementation Steps

For each implementation step in the PRP:

1. **Announce**: State which step you're starting
2. **Implement**: Write the Swift code changes
3. **Follow conventions**: `[weak self]` in closures, guard for optionals, MARK comments
4. **Validate**: Build after each step
5. **Commit and push**: After each step validates

```bash
# Build check after each step
xcodebuild -scheme WaterGlass \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Commit and push after validation
git add .
git commit -m "{type}: {description}"
git push
```

### Step 2: Handle Failures

If a build fails:
1. **Read the error**: Xcode errors are usually precise
2. **Fix**: Make minimal changes to resolve
3. **Document**: Note the issue in commit message if interesting
4. **Continue**: Only proceed when build succeeds

If unable to proceed:
1. Report the blocker clearly
2. Suggest potential solutions
3. Ask for guidance before continuing

### Step 3: Simulator Validation

After all implementation steps build cleanly:

1. Note that Simulator **cannot test motion** — that's expected
2. Verify: app launches, scene renders, no console errors
3. If UI/layout steps: verify in simulator
4. Record: "Simulator check passed — device testing required for motion"

### Step 4: Flag Device Testing Required

After simulator validation, clearly flag:

```
⚠️  DEVICE TESTING REQUIRED

The following must be verified on a physical iPhone:
- [list motion/physics criteria from PRP device test checklist]

Run the app on device and work through the checklist in docs/TESTING.md
```

### Step 5: Update Documentation

1. Update `docs/TASK.md`:
   - Move task from "In Progress" to "Recently Completed"
   - Add physics tuning notes to "Architecture Decisions" if relevant

2. If architectural decisions were made:
   - Add ADR to `docs/DECISIONS.md`

3. If new physics constants were tuned:
   - Update the Physics Tuning Log in `docs/TESTING.md`

### Step 6: Report Completion

Provide summary:
```
## PRP Execution Complete

**PRP**: prps/prp-{feature}.md
**Status**: Complete (pending device testing) / Partial / Blocked

### Commits Made
- {commit hash}: {message}
- {commit hash}: {message}

### Build Status
- Simulator: ✅ Builds and launches
- Device: ⚠️ Not yet tested — motion features require physical iPhone

### Success Criteria
- [x] Criterion 1 (verified simulator)
- [x] Criterion 2 (verified simulator)
- [ ] Criterion 3 — requires device (motion response)

### Issues Encountered
{List any issues and how they were resolved}

### Device Testing Checklist
{Paste the device test checklist from the PRP for the developer to run}

### Follow-up Items
{Any tasks that should be done next}
```

## Commit Message Format

```
feat: add CoreMotion gravity → physicsWorld integration
fix: guard against CoreMotion unavailable on simulator
refactor: extract physics setup to GameScene+Physics.swift
docs: update TASK.md with phase 1 completion
test: add gravity vector mapping unit test
```

## Quality Standards

- **No file over 500 lines**: Split into Swift extensions if approaching
- **No force unwraps**: Use guard/if let — comment any exception
- **Working commits**: Each commit must build
- **Always push**: Never commit without pushing
- **[weak self] in all closures**: Especially CoreMotion callbacks

## Emergency Stop

Stop and report before proceeding if you encounter:
- Contradicting an existing ADR
- A physics approach that seems fundamentally wrong
- Unclear requirements about device behaviour
- A build error you cannot resolve

## Notes

- Physics constants will need tuning on real device — commit reasonable starting values
- Simulator "not available" for CoreMotion is expected — guard and continue
- Leave the codebase better than you found it
- It's okay to deviate from PRP if you find a better Swift approach — document in commit why
