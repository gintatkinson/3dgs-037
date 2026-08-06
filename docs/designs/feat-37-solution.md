---
issue_id: 37
title: "[ietf-geo-location]: Motion and Velocity Vectors — Solution Walkthrough"
epic: "[ietf-geo-location]: Geographic Location Management"
status: fixed-resolved
created: "2026-08-06"
---

# Feature #37: Motion and Velocity Vectors — Solution Walkthrough

## Summary

Implemented the `velocity` container from RFC 9179 SS geo-location/velocity with full 3-layer domain-driven architecture: immutable `Velocity` domain type with validators and derived computation functions (Layer 1), abstract repository + SQLite adapter + ChangeNotifier ViewModel (Layer 2), and a TypeDescriptor/FieldDescriptor-driven PropertyGrid widget with 5 field descriptors including derived speed and heading (Layer 3).

## Verification Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | **0 errors, 0 warnings** (72 pre-existing `info`-level `public_member_api_docs` on field key constants) |
| `flutter test` | **1054 passed, 0 failures** (1 pre-existing skip) |
| `flutter build macos --release` | **SUCCESS** (100.5MB) |

## Code Realization Table

### Layer 1: Domain Types

| Spec Element | Source File | Class/Function |
|---|---|---|
| Velocity container | `domain/models/velocity_types.dart:35` | `Velocity` (@immutable, const) |
| Field key constants | `domain/models/velocity_types.dart:11-19` | `kFieldVNorth`, `kFieldVEast`, `kFieldVUp`, `kFieldSpeed`, `kFieldHeading` |
| validateVelocityComponent | `domain/models/velocity_types.dart:101` | `Result<double> validateVelocityComponent(double, String)` |
| validateVelocity | `domain/models/velocity_types.dart:119` | `Result<Velocity> validateVelocity(Velocity)` |
| calculateSpeed | `domain/models/velocity_types.dart:155` | `double calculateSpeed(double, double)` |
| calculateHeading | `domain/models/velocity_types.dart:168` | `double calculateHeading(double, double)` |
| VelocityPrecisionExceededError | `domain/domain_errors.dart:517` | `VelocityPrecisionExceededError` (ERR-VEL-001) |
| UndefinedHeadingAngleError | `domain/domain_errors.dart:537` | `UndefinedHeadingAngleError` (ERR-VEL-003) |

### Layer 2: Repository + ViewModel

| Spec Element | Source File | Class |
|---|---|---|
| Abstract repository | `domain/repositories/velocity_repository.dart:11` | `VelocityRepository` |
| SQLite implementation | `data/repositories/sqlite_velocity_repository.dart:14` | `SqliteVelocityRepository` |
| ViewModel | `presentation/viewmodels/velocity_viewmodel.dart:14` | `VelocityViewModel` (ChangeNotifier + `_disposed` guard) |

### Layer 3: UI Widget

| Spec Element | Source File | Class |
|---|---|---|
| PropertyGrid widget | `presentation/widgets/velocity_property_widget.dart:17` | `VelocityPropertyWidget` (StatelessWidget + ListenableBuilder) |
| Header | `presentation/widgets/velocity_property_widget.dart:24` | `PropertyGrid (/ietf-geo-location:velocity)` |
| 5 FieldDescriptors | `presentation/widgets/velocity_property_widget.dart:31-114` | vNorth, vEast, vUp (editable), speed, heading (read-only derived) |
| valueResolver/valueWriter | `presentation/widgets/velocity_property_widget.dart:31-114` | All 5 fields use resolver/writer pattern |

## UML Realization Mapping

```
UML Velocity (Feat-037)
|-- vNorth: Real                    -> Velocity.vNorth (double?, nullable)
|-- vEast: Real                     -> Velocity.vEast (double?, nullable)
|-- vUp: Real                       -> Velocity.vUp (double?, nullable)
|-- updateVelocity(vNorth, vEast, vUp) -> VelocityViewModel.save() + update()
|-- calculateSpeed()                -> calculateSpeed(double, double) -> double
|-- calculateHeading()              -> calculateHeading(double, double) -> double
```

## Layers Implemented

### Layer 1 (Domain Model)
- `Velocity` @immutable class with const constructor, ==/hashCode
- 5 field key constants for FieldDescriptor schemas and serialisation
- 3 validators returning `Result<T>` (no exceptions): `validateVelocityComponent`, `validateVelocity`
- 2 pure computation functions: `calculateSpeed` ($speed = \sqrt{v_{north}^2 + v_{east}^2}$), `calculateHeading` ($heading = \arctan2(v_{east}, v_{north})$)
- Zero-vector handling: `calculateHeading(0, 0)` returns `0.0` (no exception, per ERR-VEL-003)
- 2 new domain errors extending sealed `DomainError`:
  - `VelocityPrecisionExceededError` (ERR-VEL-001): 12 fraction-digit limit
  - `UndefinedHeadingAngleError` (ERR-VEL-003): both v-north and v-east are zero

### Layer 2 (Repository + ViewModel)
- `VelocityRepository` abstract interface (interface segregation, 4 methods: `initDatabase`, `save`, `fetch`, `update`)
- `SqliteVelocityRepository` with `sqflite_common_ffi` live persistence, 5-column `velocity_records` table
- `VelocityViewModel` ChangeNotifier with `_disposed` guard, error formatting for all 4 error types (`InstanceNotFoundError`, `DatabaseStorageError`, `VelocityPrecisionExceededError`, `UndefinedHeadingAngleError`)

### Layer 3 (LUI Widget + BDD Tests)
- `VelocityPropertyWidget` StatelessWidget with ListenableBuilder
- Zero-Codegen: all 5 fields driven by TypeDescriptor/FieldDescriptor with valueResolver/valueWriter
- Header: `PropertyGrid (/ietf-geo-location:velocity)`
- 3 editable fields (v-north, v-east, v-up) + 2 read-only derived fields (speed, heading)
- 7 BDD testWidgets (User Event -> VM Action -> State Change -> LUI Render)

## Test Coverage

| Test Suite | Source File | Tests | Coverage |
|---|---|---|---|
| Domain types | `test/domain/velocity_types_test.dart` | 13 | Model equality, field constants, component validation, precision rejection, speed/heading computation, zero-vector handling, full model validation |
| Domain errors | `test/domain/domain_errors_test.dart` | 2 (added) | Exhaustive switch cases for `VelocityPrecisionExceededError`, `UndefinedHeadingAngleError` |
| SQLite repository | `test/data/sqlite_velocity_repository_test.dart` | 5 | Schema init, save+fetch round-trip, not-found, update, update-nonexistent |
| ViewModel | `test/presentation/velocity_viewmodel_test.dart` | 5 | Load success, save success, storage failure error, not-found error, initial state |
| Widget | `test/presentation/velocity_property_widget_test.dart` | 7 | BDD loading indicator, error display, header, speed/heading computation, editable fields, read-only derived fields |
| **Total** | | **30** | |

## BDD Acceptance Criteria Coverage

| Scenario | Status |
|---|---|
| SCENARIO 1: Valid Ingestion of 3D Motion and Velocity Vector (v-north=15.123456789012, v-east=8.654321098765, v-up=0.500000000000) | Covered by Widget SCENARIO_1 (speed/heading display + all 3 editable fields render correctly) |
| SCENARIO 2: Derivation of 2D Heading and Speed (v-north=3.0, v-east=4.0 -> speed=5.0, heading~0.927 rad) | Covered by domain tests `should calculate 2D speed as sqrt(v_north^2 + v_east^2)` and `should calculate 2D heading as atan2(vEast, vNorth)` |
| SCENARIO 3: Precision Validation Failure (v-north with 15 fraction digits rejected with ERR-VEL-001) | Covered by `should reject velocity component exceeding 12 fraction digits` domain test |
| SCENARIO 4: Zero Vector Heading Handling (v-north=0.0, v-east=0.0 -> speed=0.0, heading handles gracefully) | Covered by `should handle zero vector heading gracefully` domain test |

## Architecture Compliance

- **Constitution SS1.9 Zero-Mocking**: SQLite repository uses live `sqflite_common_ffi` with in-memory database in tests; widget test uses injected real `SqliteVelocityRepository`
- **Constitution SS4.5 Downstream Conformance Gates**: `flutter analyze` (0 errors, 0 warnings), `flutter test` (1054 passed, 0 failed), `flutter build macos --release` (success)
- **Constitution SS5 Closure**: Issue labeled `status:fixed-resolved`, resolution comment links to this document
- **No SDK leakage**: Widget depends only on abstract `VelocityRepository`, never on `sqflite_common_ffi` directly
- **@immutable + const constructors**: `Velocity` domain class
- **Value equality (==/hashCode)**: `Velocity` domain class
- **Result<T> signatures**: All validators (`validateVelocityComponent`, `validateVelocity`) return `Result<T>`
- **UML traceability tags**: All public classes carry `/// Realises: [Feat-037/ClassName]`
- **Zero-Codegen Parameter Isolation**: Widget uses `TypeDescriptor`/`FieldDescriptor` runtime schemas with `valueResolver`/`valueWriter` callbacks -- no compile-time schema hardcoding

## Spec Traceability

| Acceptance Criterion | Implementation |
|---|---|
| `decimal64` with 12 fraction digits (v-north, v-east, v-up) | `_exceedsVelocityPrecisionLimit()` checks fractional digits; `validateVelocityComponent()` returns `VelocityPrecisionExceededError` |
| `calculateSpeed()` = sqrt(v_north^2 + v_east^2) | `calculateSpeed()` in `velocity_types.dart:155` |
| `calculateHeading()` = atan2(v_east, v_north) | `calculateHeading()` in `velocity_types.dart:168` |
| ERR-VEL-001: Precision exceeded | `VelocityPrecisionExceededError` in `domain_errors.dart:517` |
| ERR-VEL-003: Undefined heading (zero vector) | `calculateHeading(0, 0)` returns `0.0`; `UndefinedHeadingAngleError` class available for callers |
| GET /nil:velocity | `VelocityRepository.fetch()` returns `Result<Velocity>` |
| PUT/PATCH /nil:velocity | `VelocityRepository.save()` and `VelocityRepository.update()` |
| Reactive LUI binding | `VelocityPropertyWidget` + ListenableBuilder + `VelocityViewModel` ChangeNotifier |

## New Files Created

1. `app_flutter/lib/domain/models/velocity_types.dart`
2. `app_flutter/lib/domain/repositories/velocity_repository.dart`
3. `app_flutter/lib/data/repositories/sqlite_velocity_repository.dart`
4. `app_flutter/lib/presentation/viewmodels/velocity_viewmodel.dart`
5. `app_flutter/lib/presentation/widgets/velocity_property_widget.dart`
6. `app_flutter/test/domain/velocity_types_test.dart`
7. `app_flutter/test/data/sqlite_velocity_repository_test.dart`
8. `app_flutter/test/presentation/velocity_viewmodel_test.dart`
9. `app_flutter/test/presentation/velocity_property_widget_test.dart`

## Files Modified

1. `app_flutter/lib/domain/domain_errors.dart` -- appended 2 error classes: `VelocityPrecisionExceededError`, `UndefinedHeadingAngleError`
2. `app_flutter/test/domain/domain_errors_test.dart` -- added exhaustive switch cases for both new velocity error types
