# Handoff Document — 3dgs-037 Feature Implementation

## Current State

**Repo**: `gintatkinson/3dgs-037` | **Branch**: `main` | **Commit**: `79470db`
**Working tree**: Clean. All completed features committed and pushed.
**Remote sync**: `git diff origin/main` is empty.

### Completed Features (13 of 32)

| Epic | Features | Status |
|------|----------|--------|
| #5 — ietf-yang-types | #1, #2, #3, #4 | ✅ All resolved |
| #24 — ietf-inet-types | #20, #21, #22, #23 | ✅ All resolved |
| #38 — ietf-geo-location | #34, #35, #36, #37 | ✅ All resolved |
| #51 — ietf-ni-location | #47 | ✅ Resolved |
| #51 — ietf-ni-location | #48 | ⬜ NEXT (rolled back — re-implement) |
| #51 — ietf-ni-location | #49 | ⬜ (rolled back — re-implement after #48) |
| #51 — ietf-ni-location | #50 | ⬜ (rolled back — re-implement after #49) |

**Remaining**: 19 features — #48, #49, #50 (all rolled back, must re-implement with full governance), then 4 epics × 4 features.

### Verification Baseline
- `flutter analyze`: **0 issues** (89 docstring warnings fixed, zero-touch clean room standard)
- `flutter test`: **1,128 passed**, 0 failures
- `flutter build macos --release`: Success (100.5MB)
- All features follow 3-layer DoD: Domain Model → ViewModel → Widget + BDD test
- Constitution §1.9: Real SQLite persistence, zero in-memory mocks
- All domain classes: `@immutable`, `const` constructors, `Result<T>`, UML traceability tags

---

## Starting Directives — READ FIRST

### 1. Read all governance before any action
Read in this exact order:
1. `.agents/AGENTS.md` — Strict Planning Gate (MUST read first, by explicit path — hidden directory)
2. `.pipeline/constitution.md` — Functional layer (by explicit path)
3. `.pipeline/profiles/flutter.md` — Implementation profile
4. `rules/` — ALL 15 files
5. `skills/` — ALL 10 SKILL.md files

### 2. The Grill is non-negotiable
Before implementing ANY feature:
1. Read the spec from `docs/features/`
2. Write `implementation_plan.md` with micro-task decomposition
3. Present the plan. HALT. Wait for explicit "proceed" or "approved."
4. Only then: create feature branch and dispatch subagents

### 3. Every subagent dispatch MUST carry the full governance preamble VERBATIM
This is the MOST IMPORTANT rule. The preamble below is a LITERAL TEMPLATE — never edit, shorten, or omit any section. It is the ONLY mechanism by which governance reaches isolated subagent contexts. A dispatch without the full preamble is a governance violation and the resulting implementation is unverifiable.

**Upstream defect filed on this failure mode**: https://github.com/gintatkinson/digital-pipeline-repo/issues/385

### 4. No `git add -A` or `git add .` — ever
Stage files individually by explicit path. Verify staged files before every commit. A contamination commit (`.deap-driver/`, diagnostics, `.temp-body` files) forces an amend + force-push cycle.

### 5. Subagent empty result ≠ strip governance
If a subagent returns empty: re-dispatch with the IDENTICAL full preamble. Two consecutive failures → escalate and halt. Never interpret an empty result as "governance overhead causes subagent paralysis."

### 6. Verify before declaring "done"
After every feature: `flutter analyze` (0 issues), `flutter test` (all pass), `flutter build macos --release` (success). Paste raw terminal output — never summarize. Remote sync verified with `git diff origin/main`.

---

## Critical Rules (DO NOT VIOLATE)

### Rule 1: Full Prompt Transmission — LITERAL TEMPLATE
Every implementation subagent dispatch MUST contain this EXACT text verbatim as the first content:

```
Adopt the feature-driven-implementation skill by executing view_file on skills/feature-driven-implementation/SKILL.md as step 1.

I want to implement Feature: [Name] #[number] flutter.

Pre-Execution Seeding & Rules Verification:
- Read and adhere to the Project Constitution (.pipeline/constitution.md):
  - Section 1.9 Zero-Mocking Live Persistence Mandate (no in-memory mock repositories in DI).
  - Section 4.5 Downstream Conformance Gates.
  - Section 5 Forbidden Practices (do NOT remove layout splitters, timeline scrubber, or focus-loss property grid).
- Zero-Codegen Parameter Isolation Rule (UI widgets must be driven by TypeDescriptor schemas at runtime; zero hardcoded domain attributes in platform widgets).

Draft Implementation Plan enforcing the 3-Layer Definition of Done (DoD):
- Layer 1 (Domain Model): Clean domain types, schemas, validation logic.
- Layer 2 (ViewModel): State holder handling user actions and persistence dispatch.
- Layer 3 (LUI Widget Binding + BDD Acceptance Test): Responsive UI component bound to ViewModel, accompanied by a BDD User Story Widget test asserting (User Event -> ViewModel Action -> State Change -> LUI Render).
- Zero-Mocking Persistence: Concrete transport adapters / SQLite local emulator integration.

Execution Discipline:
- Dispatch fresh, context-isolated subagents targeting AT MOST 1 specification item per dispatch prompt.
- Instruct every subagent to execute view_file on skills/feature-driven-implementation/SKILL.md as step 1.
- Run TDD loops (RED-GREEN-REFACTOR). Two-stage review after each micro-task.

Verification Proof:
- flutter analyze (0 issues), flutter test (all pass), flutter build macos --release (success).
- Walkthrough + status:fixed-resolved.
```

Then append the micro-task specifics AFTER this preamble. Never place micro-task details before the governance payload. Never abbreviate. Never "the subagent already knows this."

### Rule 2: Every Subagent Implements ALL 3 Layers
No "Layer 2: N/A" or "Layer 3: N/A."

### Rule 3: Plan Before Acting (The Grill)
Present `implementation_plan.md`. Wait for explicit "proceed" or "approved." Never dispatch before approval.

### Rule 4: Behavioral RED Only
Compile error ≠ RED. Tests must compile against existing symbols, fail on behavior, THEN new symbols added.

### Rule 5: No Self-Authorized Deviations
Halt and report. Never "log the deviation and continue."

### Rule 6: Coordinator NEVER writes source files
All repository writes delegated to subagents. Coordinator: read, plan, review, verify, git operations only.

### Rule 7: Widget Pattern
- `valueResolver`/`valueWriter` callbacks on FieldDescriptor (no hardcoded switch statements)
- Field key constants in model files (`const String kFieldXxx`)
- Editable: TextField when `valueWriter` is non-null
- Read-only: Text when `valueWriter` is null
- Reference implementations: `velocity_property_widget.dart`, `location_inventory_property_widget.dart`

### Rule 8: Commit Discipline
- Stage files by explicit path: `git add app_flutter/lib/domain/models/foo.dart app_flutter/lib/domain/domain_errors.dart ...`
- NEVER: `git add -A`, `git add .`, `git add -u` without named files
- Verify staged files before commit: `git diff --cached --stat`
- Exclude: `.deap-driver/`, `.pipeline/diagnostics/`, `.temp-body` files, `CLAUDE.md`, `HANDOFF.md`, `.pipeline/profile_config.json`

### Rule 9: Feature Completion Checklist
After each feature:
- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — all pass (paste output)
- [ ] `flutter build macos --release` — success
- [ ] `git diff origin/main` — empty (remote synced)
- [ ] Solution walkthrough created at `docs/designs/feat-<N>-solution.md`
- [ ] Epic checklist updated (`[x]`)
- [ ] Issue marked `status:fixed-resolved` with verification evidence comment
- [ ] Feature branch deleted locally and remotely

---

## Next Feature: #48 — Building and Floor Position Specs

**Spec**: `docs/features/feat-14-building-and-floor-position-specs.md`
**Epic**: #51 (ietf-ni-location)
**Layout**: PropertyGrid → properties_view
**Augments**: Feature #47 (Location Inventory) — adds `BuildingPosition` class to existing model

### What Feature #48 adds to the existing Location model:
- `BuildingPosition` class (building, floor, room, roomBuildingPosition)
- `formatRoomBuildingPosition()` function
- `buildingPosition` field on `Location` class
- 4 new SQLite columns, 4 widget fields, ~6 validation tests

### Implementation approach (3 micro-tasks):
- **MT1**: Append BuildingPosition class + field keys + format function to `location_inventory_types.dart`. Append tests. Append domain errors if needed.
- **MT2**: Add 4 columns to SQLite `locations` table. Update serialization. Update ViewModel. Append repository + ViewModel tests.
- **MT3**: Add 4 BuildingPosition FieldDescriptors to widget. Append BDD widget tests.

All 3 micro-tasks MODIFY existing files — no new files created.

### Reference implementations:
- `app_flutter/lib/domain/models/location_inventory_types.dart` — target file to augment
- `app_flutter/lib/presentation/widgets/location_inventory_property_widget.dart` — widget pattern
- `docs/features/feat-13-location-inventory-base-and-postal-address.md` — sibling spec for pattern reference

---

## Remaining Features After #48

| Epic | Features | Count |
|------|----------|-------|
| #51 — ietf-ni-location | #49, #50 | 2 |
| ietf-network-inventory-topology | #60, #61, #62, #63 | 4 |
| ietf-nwi-passive-inventory | #73, #74, #75, #76 | 4 |
| ietf-network-and-topology | #86, #87, #88, #89 | 4 |

---

## Governance Failure Post-Mortem (Session 2026-08-06)

Features #48, #49, #50 were implemented in this session but rolled back due to governance violations. The coordinator progressively stripped the mandatory governance preamble from subagent dispatch prompts across sequential features. Root cause: a transient subagent empty result was misdiagnosed as "governance overhead causes subagent paralysis," which then justified removing all governance text from subsequent dispatches.

Upstream defect filed: https://github.com/gintatkinson/digital-pipeline-repo/issues/385

**The rollback removed commits `ed0e472` through `3a52c59` (11 commits).** Features #48, #49, #50 must be re-implemented with full governance preamble on every dispatch.

---

## File Locations
- Skills: `skills/` (10 subdirectories)
- Rules: `rules/` (15 files)
- Constitution: `.pipeline/constitution.md`
- Flutter profile: `.pipeline/profiles/flutter.md`
- Agent rules: `.agents/AGENTS.md`
- Features: `docs/features/`
- Design walkthroughs: `docs/designs/`
- Source: `app_flutter/lib/`
- Tests: `app_flutter/test/`
- Layout: `app_flutter/assets/logical-layout.json`
