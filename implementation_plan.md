# Implementation Plan - Phase 1: Structural Extraction for RFC 9179 & `ietf-geo-location@2022-02-11.yang`

**Specification Target:** RFC 9179 & `ietf-geo-location@2022-02-11.yang`
**Normative Reference:** https://datatracker.ietf.org/doc/rfc9179/
**Structural Schema:** https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-geo-location%402022-02-11.yang
**Output Directory:** `docs/epics/`, `docs/features/`, `.pipeline/domain_specs/`

## 1. Specification Artifacts to Extract

### Features (4 Items)
1. **Feature 09 (`docs/features/feat-09-geodetic-reference-frame.md`)**: `[ietf-geo-location]: Geodetic Reference Frame`
   - **Schema Container:** `ietf-geo-location:geo-location/reference-frame`
   - **Nodes Covered:** `reference-frame`, `alternate-system`, `alternate-systems` (if-feature guard), `astronomical-body`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

2. **Feature 10 (`docs/features/feat-10-geodetic-system-and-accuracy.md`)**: `[ietf-geo-location]: Geodetic System and Accuracy Bounds`
   - **Schema Container:** `ietf-geo-location:geo-location/reference-frame/geodetic-system`
   - **Nodes Covered:** `geodetic-system`, `geodetic-datum`, `coord-accuracy`, `height-accuracy`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

3. **Feature 11 (`docs/features/feat-11-coordinates-and-altitude.md`)**: `[ietf-geo-location]: Geographic Coordinates and Altitude`
   - **Schema Container:** `ietf-geo-location:geo-location`
   - **Nodes Covered:** `geo-location`, `location` (choice), `ellipsoid` (`latitude`, `longitude`, `height`), `cartesian` (`x`, `y`, `z`), `timestamp`, `valid-until`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

4. **Feature 12 (`docs/features/feat-12-motion-and-velocity-vectors.md`)**: `[ietf-geo-location]: Motion and Velocity Vectors`
   - **Schema Container:** `ietf-geo-location:geo-location/velocity`
   - **Nodes Covered:** `velocity`, `v-north`, `v-east`, `v-up`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

### Epic (1 Item)
1. **Epic 03 (`docs/epics/epic-03-ietf-geo-location.md`)**: `[ietf-geo-location]: Geographic Location Management`
   - **Child Features:** Features 09, 10, 11, 12.
   - **Generation Mode:** `subagent`

---

## 2. Item-Level Subagent Dispatch Strategy

Per the **Role Boundary Lock** and **Item-Level Subagent Isolation Mandate**:
- The coordinator will NOT directly write target specification files (`docs/epics/`, `docs/features/`).
- Each Feature (Features 09-12) and Epic 03 will be extracted by an isolated, fresh subagent dispatched with at most 1 item per prompt.
- Every subagent prompt will instruct the subagent to execute `view_file` on `skills/schema-specification-engineering/SKILL.md` as Step 1.
- Each subagent will write standard UML Class Diagrams, Given-When-Then BDD acceptance criteria, verbatim specification text from `schema/rfc9179.txt`, exact schema paths, and YAML frontmatter (`generation_mode: "subagent"`).
- Keywords `PROCEED` appended to authorise subagent file modifications.

---

## 3. Verification & Registration Workflow

1. **Local Model Coverage Verification:** Run `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs` to ensure 100% schema node coverage and strict template compliance.
2. **Feature GitHub Registration FIRST:** Register Features 09-12 as GitHub issues via `create_issue.sh`, verify body content using `gh issue view <ID> --json body`.
3. **Epic Issue Linkage:** Inject live Feature Issue IDs into Epic 03 checklist tasklist.
4. **Epic GitHub Registration LAST:** Register Epic 03 as a GitHub issue via `create_issue.sh`, verify body content using `gh issue view <ID> --json body`.
5. **Backfill Parent Epic ID:** Update `## Parent Epic` in Features 09-12 with Epic 03 Issue ID and sync issue body.
6. **Backlog Reconciliation:** Execute `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py`.
7. **Git Commit & Push:** Commit generated specs with conventional commit message `docs: extract Phase 1 specifications for RFC 9179 and ietf-geo-location@2022-02-11.yang`, push to `origin/main`, and confirm clean remote diff.

---

## User Approval Request
Please review this implementation plan. Once approved, reply with **PROCEED** (or **Approved**) to authorize subagent dispatches and execution.
