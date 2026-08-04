# Implementation Plan: Inject issue_id frontmatter fields into Epic 07 and Features 25-28

## Proposed Changes

### Target Specification Files

1. **`docs/epics/epic-07-ietf-network-and-topology.md`**
   - Add `issue_id: 90` to the YAML frontmatter.

2. **`docs/features/feat-25-base-networks-and-network-data-model.md`**
   - Add `issue_id: 86` to the YAML frontmatter.

3. **`docs/features/feat-26-node-data-model-and-supporting-nodes.md`**
   - Add `issue_id: 87` to the YAML frontmatter.

4. **`docs/features/feat-27-termination-point-data-model.md`**
   - Add `issue_id: 88` to the YAML frontmatter.

5. **`docs/features/feat-28-link-data-model-and-supporting-links.md`**
   - Add `issue_id: 89` to the YAML frontmatter.

## Execution Strategy

Per project governance rules:
- Subagent dispatch mandate: File updates to target specification files will be executed via context-isolated subagents.
- Each subagent will use `replace_file_content` to add `issue_id: <ID>` to the frontmatter of its assigned specification file.

## Verification Plan

- Verify frontmatter of each file using `view_file`.
- Run model coverage verification script: `./skills/spec-orchestrator/scripts/verify_model_coverage.py --spec-only` if applicable.
