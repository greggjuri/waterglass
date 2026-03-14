# Generate PRP

Generate a comprehensive Project Requirement Plan (PRP) for a WaterGlass feature.

## Arguments
- `$ARGUMENTS` - Path to initial file (e.g., `initials/init-phase1-poc.md`)

## Instructions

You are generating a PRP for the **WaterGlass** iOS project — a physics-based water simulation
app built in Swift using SpriteKit and CoreMotion.

### Step 1: Gather Context

Read and internalize the following project documentation:
1. `CLAUDE.md` — Coding conventions, Swift patterns, commit rules
2. `docs/PLANNING.md` — Architecture, phases, tech stack
3. `docs/DECISIONS.md` — Past ADRs (don't contradict these)
4. `docs/TASK.md` — Current task status
5. `docs/TESTING.md` — Testing standards and device testing requirements

### Step 2: Read the Initial File

Read the initial specification at `$ARGUMENTS`:
1. Understand the feature requirements
2. Note phase (1/2/3/4) and dependencies
3. Identify SpriteKit/CoreMotion integration points
4. Confirm all open questions are answered

### Step 3: Research Codebase

Based on the feature, research existing code:
1. Read current `WaterGlass/GameScene.swift` and any extensions
2. Identify files that need modification vs new files to create
3. Check if any extension split is warranted (approaching 300 lines?)
4. Note existing physics constants and patterns to follow

### Step 4: Generate PRP

Create a new PRP file at `prps/prp-{feature-slug}.md` where:
- feature-slug matches the init file name (e.g., `init-phase1-poc.md` → `prp-phase1-poc.md`)

Use the template at `prps/templates/prp-template.md` as the structure.

Fill in all sections:
1. **Overview**: Clear problem statement and proposed solution
2. **Success Criteria**: Observable on device, measurable outcomes
3. **Context**: Relevant ADRs, files to modify/create
4. **Technical Specification**: Swift types, node structure, CoreMotion integration
5. **Implementation Steps**: Ordered, atomic tasks with exact file paths
6. **Testing Requirements**: Simulator check + full device testing checklist
7. **Error Handling**: Especially CoreMotion unavailable (simulator case)
8. **Open Questions**: Anything unclear
9. **Rollback Plan**: git revert steps

### Step 5: Score Confidence

Score confidence (1-10) on each dimension:
- **Clarity**: Are requirements unambiguous?
- **Feasibility**: Achievable with SpriteKit + CoreMotion?
- **Completeness**: No missing pieces?
- **Alignment**: Follows ADRs and constraints?

If average < 7:
- List specific concerns
- Do NOT proceed until concerns are addressed

### Step 6: Output

1. Create the PRP file in `prps/`
2. Report the file path created
3. Display confidence scores
4. List any open questions or concerns

## Example Usage

```
/generate-prp initials/init-phase1-poc.md
```

## Quality Checklist

Before completing, verify:
- [ ] Every implementation step has specific Swift file paths
- [ ] Steps are atomic and individually buildable
- [ ] Device testing checklist is specific and actionable
- [ ] Simulator edge case (no CoreMotion) is handled
- [ ] No ADRs are contradicted
- [ ] Commit + push step is the final implementation step
- [ ] Rollback plan uses git revert
