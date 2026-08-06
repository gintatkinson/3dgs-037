---
issue_id: 36
title: "[ietf-geo-location]: Geographic Coordinates and Altitude — Solution Walkthrough"
epic: "[ietf-geo-location]: Geographic Location Management"
status: fixed-resolved
created: "2026-08-06"
---

# Feature #36: Geographic Coordinates and Altitude — Solution Walkthrough

## Summary

Implemented the `geo-location` container from RFC 9179 § geo-location with full 3-layer domain-driven architecture: immutable domain types with validators (Layer 1), abstract repository + SQLite adapter + ChangeNotifier ViewModel (Layer 2), and a TypeDescriptor/FieldDescriptor-driven PropertyGrid widget (Layer 3).

## Verification Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | **0 errors, 0 warnings** (72 pre-existing `info`-level `public_member_api_docs` on field key constants) |
| `flutter test` | **All 1024+ tests pass** (1 pre-existing skip) |
| `flutter build macos --release` | **SUCCESS** (100.5MB) |

## Code Realization Table

### Layer 1: Domain Types

| Spec Element | Source File | Class/Function |
|---|---|---|
| GeoLocation container | `domain/models/coordinates_and_altitude_types.dart:112` | `GeoLocation` (@immutable, const) |
| EllipsoidalCoordinates | `domain/models/coordinates_and_altitude_types.dart:34` | `EllipsoidalCoordinates` (@immutable, const) |
| CartesianCoordinates | `domain/models/coordinates_and_altitude_types.dart:72` | `CartesianCoordinates` (@immutable, const) |
| validateLatitude | `domain/models/coordinates_and_altitude_types.dart:163` | `Result<double> validateLatitude(double)` |
| validateLongitude | `domain/models/coordinates_and_altitude_types.dart:177` | `Result<double> validateLongitude(double)` |
| validateLocationChoice | `domain/models/coordinates_and_altitude_types.dart:194` | `Result<void> validateLocationChoice(...)` |
| validateDateTimeFormat | `domain/models/coordinates_and_altitude_types.dart:215` | `Result<void> validateDateTimeFormat(String?)` |
| validateTemporalWindow | `domain/models/coordinates_and_altitude_types.dart:234` | `Result<void> validateTemporalWindow(...)` |
| validateGeoLocation | `domain/models/coordinates_and_altitude_types.dart:249` | `Result<GeoLocation> validateGeoLocation(GeoLocation)` |
| InvalidLatitudeOutOfBoundsError | `domain/domain_errors.dart:418` | `InvalidLatitudeOutOfBoundsError` |
| InvalidLongitudeOutOfBoundsError | `domain/domain_errors.dart:431` | `InvalidLongitudeOutOfBoundsError` |
| MutualExclusivityViolationError | `domain/domain_errors.dart:444` | `MutualExclusivityViolationError` |
| MissingMandatoryCoordinatesError | `domain/domain_errors.dart:456` | `MissingMandatoryCoordinatesError` |
| InvalidDateTimeFormatError | `domain/domain_errors.dart:469` | `InvalidDateTimeFormatError` |
| InvalidTemporalWindowError | `domain/domain_errors.dart:481` | `InvalidTemporalWindowError` |
| Field key constants | `domain/models/coordinates_and_altitude_types.dart:10-17` | `kFieldTimestamp`, `kFieldValidUntil`, `kFieldLatitude`, `kFieldLongitude`, `kFieldHeight`, `kFieldCartesianX`, `kFieldCartesianY`, `kFieldCartesianZ` |

### Layer 2: Repository + ViewModel

| Spec Element | Source File | Class |
|---|---|---|
| Abstract repository | `domain/repositories/coordinates_and_altitude_repository.dart:16` | `CoordinatesAndAltitudeRepository` |
| SQLite implementation | `data/repositories/sqlite_coordinates_and_altitude_repository.dart:16` | `SqliteCoordinatesAndAltitudeRepository` |
| ViewModel | `presentation/viewmodels/coordinates_and_altitude_viewmodel.dart:16` | `CoordinatesAndAltitudeViewModel` (ChangeNotifier + `_disposed` guard) |

### Layer 3: UI Widget

| Spec Element | Source File | Class |
|---|---|---|
| PropertyGrid widget | `presentation/widgets/coordinates_and_altitude_property_widget.dart:18` | `CoordinatesAndAltitudePropertyWidget` (StatelessWidget + ListenableBuilder) |
| Header | `presentation/widgets/coordinates_and_altitude_property_widget.dart:33` | `PropertyGrid (/ietf-geo-location:coordinates)` |
| 8 FieldDescriptors | `presentation/widgets/coordinates_and_altitude_property_widget.dart:37-197` | timestamp, validUntil, latitude, longitude, height, X, Y, Z |
| valueResolver/valueWriter | `presentation/widgets/coordinates_and_altitude_property_widget.dart:37-197` | All 8 fields use resolver/writer pattern |

### Tests

| Test Suite | Source File | Tests | BDD Scenarios |
|---|---|---|---|
| Domain types | `test/domain/coordinates_and_altitude_types_test.dart` | 34 | All validators, model equality, boundaries |
| SQLite repository | `test/data/sqlite_coordinates_and_altitude_repository_test.dart` | 5 | CRUD operations with live SQLite (sqflite_common_ffi) |
| ViewModel | `test/presentation/coordinates_and_altitude_viewmodel_test.dart` | 5 | Load, save, update, error formatting |
| Widget | `test/presentation/coordinates_and_altitude_property_widget_test.dart` | 5 | Loading indicator, error message, header, ellipsoidal fields, cartesian fields |

## BDD Acceptance Criteria Coverage

| Scenario | Status |
|---|---|
| SCENARIO 1: Valid Ellipsoidal Coordinate Creation with Altitude | Covered by SCENARIO_4 widget test + domain ellipsoid validation tests |
| SCENARIO 2: Valid Cartesian Coordinate Creation | Covered by SCENARIO_5 widget test + repository cartesian round-trip test |
| SCENARIO 3: Rejection of Out-of-Bounds Latitude | Covered by `validateLatitude(95.1234)` domain test |
| SCENARIO 4: Rejection of Conflicting Location Choice Branches | Covered by `validateLocationChoice` mutual exclusivity test |
| SCENARIO 5: Temporal Window Validation | Covered by `validateTemporalWindow` + `check-temporal-validity` domain tests |

## Architecture Compliance

- **Constitution §1.9 Zero-Mocking**: SQLite repository uses live `sqflite_common_ffi` with in-memory database in tests; widget uses injected abstract repository
- **Constitution §4.5 Approval Gate**: Implementation plan approved with PROCEED
- **Constitution §5 Closure**: Issue labeled `status:fixed-resolved`, resolution comment links to this document
- **No SDK leakage**: Widget depends only on abstract `CoordinatesAndAltitudeRepository`, never on `sqflite_common_ffi` directly
- **@immutable + const constructors**: All 3 domain classes
- **Value equality (==/hashCode)**: All 3 domain classes
- **Result<T> signatures**: All 6 validators return `Result<T>`
- **UML traceability tags**: All public classes carry `/// Realises: [Feat-036/ClassName]`
- **Zero-Codegen Parameter Isolation**: Widget uses `TypeDescriptor`/`FieldDescriptor` runtime schemas with `valueResolver`/`valueWriter` callbacks — no compile-time schema hardcoding
