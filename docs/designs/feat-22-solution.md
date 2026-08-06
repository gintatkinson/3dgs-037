---
issue_id: 22
title: "[ietf-inet-types]: Autonomous System and Port Number Data Types — Solution Walkthrough"
created: "2026-08-06"
status: "fixed-resolved"
---

# feat-22-solution: Autonomous System and Port Number Data Types

## Summary
Implements the two typedefs from ietf-inet-types (RFC 6021): `as-number` (uint32, 0..4294967295) and `port-number` (uint16, 0..65535). Port zero is valid in the base type but rejected by `validatePortNonZero` for subtyped contexts per IANA reservation.

## 3-Layer Architecture

| Layer | File | Role |
|-------|------|------|
| Domain Model | `lib/domain/models/autonomous_system_and_port_types.dart` | @immutable value object, 3 validation functions |
| ViewModel | `lib/presentation/viewmodels/autonomous_system_and_port_viewmodel.dart` | ChangeNotifier, _disposed guard, load/save/update |
| Repository (abstract) | `lib/domain/repositories/autonomous_system_and_port_repository.dart` | Interface: initDatabase, save, fetch, update |
| Repository (concrete) | `lib/data/repositories/sqlite_autonomous_system_and_port_repository.dart` | SQLite via sqflite_common_ffi, 4-column table |
| LUI Widget | `lib/presentation/widgets/autonomous_system_and_port_property_widget.dart` | TypeDescriptor-driven, ListenableBuilder, header "PropertyGrid (/ietf-inet-types:as-number)" |

## Code Realization Table

| Feature/Classifier | Implementation | File |
|-------------------|---------------|------|
| Feat-022/AutonomousSystemAndPortTypes | @immutable class AutonomousSystemAndPortTypes | `app_flutter/lib/domain/models/autonomous_system_and_port_types.dart:18` |
| Feat-022/AsNumber | `validateAsNumber(int) -> Result<int>` | `app_flutter/lib/domain/models/autonomous_system_and_port_types.dart:68` |
| Feat-022/PortNumber | `validatePortNumber(int) -> Result<int>` | `app_flutter/lib/domain/models/autonomous_system_and_port_types.dart:87` |
| Feat-022/PortNumber | `validatePortNonZero(int) -> Result<int>` | `app_flutter/lib/domain/models/autonomous_system_and_port_types.dart:107` |
| Feat-022/AutonomousSystemAndPortRepository | Abstract repository interface | `app_flutter/lib/domain/repositories/autonomous_system_and_port_repository.dart:18` |
| Feat-022/SqliteAutonomousSystemAndPortRepository | SQLite concrete repository | `app_flutter/lib/data/repositories/sqlite_autonomous_system_and_port_repository.dart:18` |
| Feat-022/AutonomousSystemAndPortViewModel | ChangeNotifier state holder | `app_flutter/lib/presentation/viewmodels/autonomous_system_and_port_viewmodel.dart:16` |
| Feat-022/AutonomousSystemAndPortPropertyWidget | LUI property panel widget | `app_flutter/lib/presentation/widgets/autonomous_system_and_port_property_widget.dart:18` |

## Test Coverage

| Test Suite | File | Tests | Status |
|-----------|------|-------|--------|
| Domain unit | `test/domain/autonomous_system_and_port_types_test.dart` | 19 | Pass |
| SQLite repository | `test/data/sqlite_autonomous_system_and_port_repository_test.dart` | 6 | Pass |
| ViewModel | `test/presentation/autonomous_system_and_port_viewmodel_test.dart` | 7 | Pass |
| BDD Widget | `test/presentation/autonomous_system_and_port_property_widget_test.dart` | 5 | Pass |

### BDD Acceptance Criteria Coverage

| BDD Scenario | Widget Test |
|-------------|-------------|
| Scenario 1: Valid 32-bit AS number validation | `domain test: validateAsNumber should accept minimum/maximum` |
| Scenario 2: Invalid out-of-bounds AS number | `domain test: validateAsNumber should reject -1/4294967296` |
| Scenario 3: Valid 16-bit port number boundary | `domain test: validatePortNumber should accept 0/80/443/65535` |
| Scenario 4: Invalid out-of-bounds port number | `domain test: validatePortNumber should reject -1/65536` |
| Scenario 5: Reserved port zero subtyping | `domain test: validatePortNonZero should reject port 0` |
| LUI: Loading indicator display | `SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading` |
| LUI: Error message display | `SCENARIO_2 shouldDisplayErrorMessageWhenViewModelHasError` |
| LUI: Header text display | `SCENARIO_3 shouldDisplayCorrectHeaderText` |
| LUI: All fields rendered from schema | `SCENARIO_4 shouldRenderAllThreeFieldsFromFieldDescriptorSchema` |
| LUI: User event -> VM action -> state change -> render | `SCENARIO_5 shouldUpdateDisplayOnUserSaveAction_...` |

## Verification

- `flutter analyze`: **No issues found**
- `flutter test`: **826 passed, 1 skipped, 0 failed**
- `flutter build macos --release`: **Built and packaged successfully** (100.5MB)

## Source References

- Normative: [RFC 6021](https://datatracker.ietf.org/doc/rfc6021/)
- Schema: [ietf-inet-types@2013-07-15.yang](https://github.com/YangModels/yang/blob/main/standard/ietf/RFC/ietf-inet-types%402013-07-15.yang)
- Feature Spec: `docs/features/feat-07-autonomous-system-and-port-types.md`
- Parent Epic: #24 — ietf-inet-types: Common Internet Data Types
