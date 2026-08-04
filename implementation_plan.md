# Implementation Plan - Phase 2: User Story Extraction for `us-21-building-floor-room-positioning.md`

**Target File Path:** `docs/user-stories/us-21-building-floor-room-positioning.md` (and copy to `.pipeline/domain_specs/us-21-building-floor-room-positioning.md`)
**Title:** `[ietf-ni-location]: Building, Floor, and Room Spatial Hierarchy Navigation, Room Name Assignment, and Physical Access Bounds`
**Type:** `user-story`
**Generation Mode:** `subagent`
**Spec Source:** `draft-ietf-ivy-network-inventory-location & ietf-ni-location.yang`
**Parent Epic:** Issue #51 - `[ietf-ni-location]: Network Inventory Location Management` (`https://github.com/gintatkinson/3dgs-037/blob/main/docs/epics/epic-04-ietf-ni-location.md`)

---

## 1. User Story Artifact Specification

### User Story Details
- **Identifier:** `us-21-building-floor-room-positioning.md`
- **Domain Objects:** `Location`, `PhysicalAddress`, `BuildingPosition`
- **Actor/Role:** `UserActor` (Facility manager / site operator)

### BDD Acceptance Scenarios (Given-When-Then)
1. **Indoor Building, Floor, and Room Attribute Specification:** Setting building name/ID (`building`), floor number/designation (`floor`), and room name/number (`room`).
2. **Compound `room-building-position` String Derivation/Formatting:** Dynamic string formatting ("Building B, Floor 3, Room 302") combining position components.
3. **Spatial Hierarchy Navigation:** Navigating parent-child relationships (Site -> Building -> Floor -> Room) via `parent` leafref resolution.
4. **Invalid Parent / Orphaned Hierarchy Rejection:** Rejecting non-existent parent location references and validating hierarchy integrity.

### UML Modeling Specifications
- **Sequence Diagram (`sequenceDiagram`):**
  - Lifelines: `actor userActor as "userActor : UserActor"`, `participant location as "location : Location"`, `participant buildingPosition as "buildingPosition : BuildingPosition"`, `participant physicalAddress as "physicalAddress : PhysicalAddress"`.
  - Operations: typed method signatures with open return arrows (`-->`) and typed return signatures (`isValid : Boolean`, `formattedPosition : String`).
  - Guards & Alt Blocks: Explicit validation logic for parent resolution and position string derivation.
- **State Machine Diagram (`stateDiagram-v2`):**
  - States: `Unconfigured`, `BuildingAssigned`, `FloorAssigned`, `RoomBound`, `PositioningActive`.
  - Transitions: Annotated with `event [guard] / action`.

### Feature Intersect Matrix
- `#48` - `[ietf-ni-location: Building and Floor Position Specs]` (`docs/features/feat-14-building-and-floor-position-specs.md`)
- `#47` - `[ietf-ni-location: Location Inventory Base and Postal Address]` (`docs/features/feat-13-location-inventory-base-and-postal-address.md`)

---

## 2. Execution Strategy & Subagent Dispatch

Per the **Role Boundary Lock**, **Coordinator Direct Writing Lock**, and **Strict Plan Enforcement**:
1. The coordinator will NOT directly write `docs/user-stories/us-21-building-floor-room-positioning.md` or `.pipeline/domain_specs/us-21-building-floor-room-positioning.md`.
2. A context-isolated subagent (`User Story Implementer`) will be launched using `invoke_subagent`.
3. The subagent prompt will instruct it to:
   - Read `skills/spec-user-story-engineering/SKILL.md` as its very first step.
   - Include a 4-point compliance table in output prior to file generation.
   - Write the markdown user story to `docs/user-stories/us-21-building-floor-room-positioning.md` and copy to `.pipeline/domain_specs/us-21-building-floor-room-positioning.md`.
   - Run linter verification `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only`.
   - Reconcile backlog using `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py` or `gh issue` commands if needed.
   - Commit and push to git.

---

## 3. Verification & Acceptance Criteria
1. `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only` passes with exit code 0.
2. File exists in both `docs/user-stories/us-21-building-floor-room-positioning.md` and `.pipeline/domain_specs/us-21-building-floor-room-positioning.md`.
3. Remote git sync verified with `git diff origin/main` clean.

---

## User Approval Request
Please review this implementation plan. Once approved, reply with **PROCEED** (or **Approved**) to authorize subagent dispatches and execution.
