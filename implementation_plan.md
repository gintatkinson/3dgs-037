# Implementation Plan - Phase 2: Behavioral Extraction (BDD User Stories)

**Specification Target:** RFC 9911 & `ietf-yang-types@2025-12-22.yang`
**Parent Epic:** Issue #5 - `docs/epics/epic-01-ietf-yang-types.md`
**Features Covered:**
- Feature 01 (Issue #1): `docs/features/feat-01-counter-and-gauge-types.md`
- Feature 02 (Issue #2): `docs/features/feat-02-identifier-types.md`
- Feature 03 (Issue #3): `docs/features/feat-03-date-and-time-types.md`
- Feature 04 (Issue #4): `docs/features/feat-04-address-and-string-types.md`

## 1. User Story Extraction List (10 Atomic Packages)

### Scope 1: Counter & Gauge Behaviors (Feature 01 / Issue #1)
- **US-01**: `docs/user-stories/us-01-counter-monotonic-wrap.md` - Counter Monotonic Increment and Wraparound Behavior (`counter32` and `counter64`).
- **US-02**: `docs/user-stories/us-02-zero-based-counter-initialization.md` - Zero-Based Counter Default Initialization and Initial Delta (`zero-based-counter32` and `zero-based-counter64`).
- **US-03**: `docs/user-stories/us-03-gauge-min-max-latching.md` - Gauge Dynamic Range and Min/Max Bound Latching (`gauge32` and `gauge64`).

### Scope 2: Identifier Types Behaviors (Feature 02 / Issue #2)
- **US-04**: `docs/user-stories/us-04-object-identifier-asn1-validation.md` - Object Identifier ASN.1 Arc Hierarchy & 128-Subidentifier Limit Validation (`object-identifier` & `object-identifier-128`).
- **US-05**: `docs/user-stories/us-05-uuid-formatting-canonicalization.md` - RFC 9562 UUID Pattern Validation and Canonicalization (`uuid`).
- **US-06**: `docs/user-stories/us-06-yang-identifier-syntax-validation.md` - RFC 7950 YANG Identifier Syntax Rules and Length Validation (`yang-identifier`).

### Scope 3: Date & Time Types Behaviors (Feature 03 / Issue #3)
- **US-07**: `docs/user-stories/us-07-date-time-timestamp-parsing.md` - RFC 3339 Timestamp Parsing, Fractional Seconds, and RFC 9557 Timezone Offset Semantics (`date-and-time`, `date`, `time`).
- **US-08**: `docs/user-stories/us-08-timeticks-wrap-timestamp-reset.md` - Timeticks Modulo 2^32 Arithmetic and Associated Timestamp Reset (`timeticks` & `timestamp`).

### Scope 4: Address & String Types Behaviors (Feature 04 / Issue #4)
- **US-09**: `docs/user-stories/us-09-mac-and-phys-address-canonicalization.md` - IEEE 802 MAC Address and Physical Media Address Validation and Canonicalization (`mac-address` & `phys-address`).
- **US-10**: `docs/user-stories/us-10-dotted-quad-and-xpath-validation.md` - Dotted-Quad Decimal Parsing to Uint32 and XPath 1.0 Expression Syntax Validation (`dotted-quad` & `xpath1.0`).

## 2. Subagent Dispatch Strategy

For each of the 10 User Stories above:
1. Dispatch a fresh context-isolated subagent targeting exactly 1 User Story.
2. Direct the subagent to execute `view_file` on `/Users/perkunas/jail/3dgs-037/.agents/skills/spec-user-story-engineering/SKILL.md` as step 1.
3. Ensure exact compliance with UML sequence diagram notation (`actor userActor as "userActor : UserActor"`, open return arrows `-->`, return signatures `value : Type`, operation signatures matching feature classes).
4. Save markdown file under `docs/user-stories/` (and `.pipeline/domain_specs/` as required).

## 3. Verification & Registration Workflow

1. Execute model coverage linter: `python3 skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only --allow-missing-specs`.
2. Register each User Story as a GitHub issue using `skills/spec-orchestrator/scripts/create_issue.sh` (or `gh issue create`).
3. Post-register verification: `gh issue view <ID> --json body`.
4. Back-fill registered User Story issue IDs into Feature checklists (#1, #2, #3, #4) and Epic checklist (#5).
5. Run backlog reconciliation: `python3 skills/spec-orchestrator/scripts/reconcile_backlog.py`.
6. Commit all generated files and changes with standard commit message format (`docs: extract BDD User Stories for RFC 9911`).
7. Push commit to remote `origin/main` and verify clean diff.
