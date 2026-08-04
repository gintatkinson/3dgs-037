# Implementation Plan - Phase 1: Structural Extraction for RFC 6021 & `ietf-inet-types@2013-07-15.yang`

**Specification Target:** RFC 6021 & `ietf-inet-types@2013-07-15.yang`
**Normative Reference:** https://datatracker.ietf.org/doc/rfc6021/
**Structural Schema:** https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-inet-types%402013-07-15.yang
**Output Directory:** `docs/epics/`, `docs/features/`, `.pipeline/domain_specs/`

## 1. Specification Artifacts to Extract

### Features (4 Items)
1. **Feature 05 (`docs/features/feat-05-ip-address-types.md`)**: `[ietf-inet-types]: IP Address Data Types`
   - **Data Types Covered:** `ip-version`, `ip-address`, `ipv4-address`, `ipv6-address`, `ip-prefix`, `ipv4-prefix`, `ipv6-prefix`, `ip-address-no-zone`, `ipv4-address-no-zone`, `ipv6-address-no-zone`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

2. **Feature 06 (`docs/features/feat-06-domain-name-and-host-types.md`)**: `[ietf-inet-types]: Domain Name and Host Data Types`
   - **Data Types Covered:** `domain-name`, `host`, `uri`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

3. **Feature 07 (`docs/features/feat-07-autonomous-system-and-port-types.md`)**: `[ietf-inet-types]: Autonomous System and Port Number Data Types`
   - **Data Types Covered:** `as-number`, `port-number`.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

4. **Feature 08 (`docs/features/feat-08-ip-unicast-multicast-and-scope-types.md`)**: `[ietf-inet-types]: IP Unicast, Multicast, and Scope Data Types`
   - **Data Types Covered:** `ipv6-flow-label`, `dscp`, and related IP address scope/unicast/multicast representations.
   - **Interface Type:** `api`
   - **Generation Mode:** `subagent`

### Epic (1 Item)
1. **Epic 02 (`docs/epics/epic-02-ietf-inet-types.md`)**: `[ietf-inet-types]: Common Internet Data Types`
   - **Child Features:** Features 05, 06, 07, 08.
   - **Generation Mode:** `subagent`

---

## 2. Item-Level Subagent Dispatch Strategy

Per the **Role Boundary Lock** and **Item-Level Subagent Isolation Mandate**:
- The coordinator will NOT directly write target specification files.
- Each Feature and Epic will be extracted by an isolated, fresh subagent.
- Max 1 specification item per subagent dispatch.
- Every subagent prompt will instruct the subagent to execute `view_file` on `skills/schema-specification-engineering/SKILL.md` as Step 1.
- Each subagent will include standard UML Class Diagrams, Given-When-Then BDD acceptance criteria, verbatim specification text from `schema/rfc6021.txt`, exact schema paths, and YAML frontmatter (`generation_mode: "subagent"`).

---

## 3. Verification & Registration Workflow

1. **Local Model Coverage Verification:** Run `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs` to ensure 100% schema type coverage and strict template compliance.
2. **Feature GitHub Registration FIRST:** Register Features 05-08 as GitHub issues via `gh issue create`, verify body content using `gh issue view <ID> --json body`.
3. **Epic Issue Linkage:** Inject live Feature Issue IDs into Epic checklist tasklist.
4. **Epic GitHub Registration LAST:** Register Epic 02 as a GitHub issue via `gh issue create`, verify body content using `gh issue view <ID> --json body`.
5. **Backfill Parent Epic ID:** Update `## Parent Epic` in Features 05-08 with Epic Issue ID and sync issue body.
6. **Backlog Reconciliation:** Execute `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py`.
7. **Git Commit & Push:** Commit generated specs with conventional commit message `docs: extract Phase 1 specifications for RFC 6021 and ietf-inet-types@2013-07-15.yang`, push to `origin/main`, and confirm clean remote diff.

---

## User Approval Request
Please review this implementation plan. Once approved, reply with **PROCEED** (or **Approved**) to authorize subagent dispatches and execution.
