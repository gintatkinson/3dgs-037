# Implementation Plan — Feature #37: Motion and Velocity Vectors

**Epic**: #38 (ietf-geo-location)  
**Spec**: `docs/features/feat-12-motion-and-velocity-vectors.md`  
**Schema container**: `ietf-geo-location:geo-location/velocity`  
**Layout binding**: PropertyGrid → properties_view  
**Data source**: `/nwi:network-inventory/nil:locations/nil:location/nil:geo-location/nil:velocity`  
**Reference widget**: `coordinates_and_altitude_property_widget.dart`, `geodetic_system_property_widget.dart`

## Architecture

The 3-layer DoD maps as follows:

| Layer | Component | File |
|---|---|---|
| Domain Model | `Velocity` class, validators, field key constants | `app_flutter/lib/domain/models/velocity_types.dart` |
| Domain Model | Domain errors (ERR-VEL-001, ERR-VEL-002, ERR-VEL-003) | `app_flutter/lib/domain/domain_errors.dart` (append) |
| Domain Model | Repository interface | `app_flutter/lib/domain/repositories/velocity_repository.dart` |
| Data Layer | SQLite repository | `app_flutter/lib/data/repositories/sqlite_velocity_repository.dart` |
| ViewModel | `VelocityViewModel` | `app_flutter/lib/presentation/viewmodels/velocity_viewmodel.dart` |
| Widget | `VelocityPropertyWidget` | `app_flutter/lib/presentation/widgets/velocity_property_widget.dart` |
| Tests | Domain types test | `app_flutter/test/domain/velocity_types_test.dart` |
| Tests | SQLite repository test | `app_flutter/test/data/sqlite_velocity_repository_test.dart` |
| Tests | ViewModel test | `app_flutter/test/presentation/velocity_viewmodel_test.dart` |
| Tests | Widget + BDD test | `app_flutter/test/presentation/velocity_property_widget_test.dart` |

## Domain Model Specification

### Velocity class (`@immutable`)
```dart
class Velocity {
  const Velocity({
    this.containerId = 'default',
    this.vNorth,
    this.vEast,
    this.vUp,
  });
  final String containerId;
  final double? vNorth;  // m/s, decimal64 12 fraction digits
  final double? vEast;   // m/s, decimal64 12 fraction digits
  final double? vUp;     // m/s, decimal64 12 fraction digits
}
```

### Field key constants
```dart
const String kFieldVNorth = 'vNorth';
const String kFieldVEast = 'vEast';
const String kFieldVUp = 'vUp';
const String kFieldSpeed = 'speed';
const String kFieldHeading = 'heading';
```

### Validators (all return `Result<T>`)
- `validateVelocityComponent(double value, String fieldName)` — checks non-negative and ≤12 fraction digits
- `validateVelocity(Velocity model)` — aggregates all component validations
- `calculateSpeed(double vNorth, double vEast)` — sqrt(v_north² + v_east²)
- `calculateHeading(double vNorth, double vEast)` — atan2(v_east, v_north), returns 0.0 for zero vector

### New domain errors (appended to `domain_errors.dart`)
- `VelocityPrecisionExceededError` (ERR-VEL-001) — exceeds 12 fraction digits
- `NonNumericVelocityValueError` (ERR-VEL-002) — already covered by type system, but error class exists
- `UndefinedHeadingAngleError` (ERR-VEL-003) — caught when both vNorth and vEast are zero

## Micro-Task Decomposition (3 tasks)

### Micro-Task 1: Domain Model + Errors
**Target files**:
- CREATE `app_flutter/lib/domain/models/velocity_types.dart`
- MODIFY `app_flutter/lib/domain/domain_errors.dart` (append 3 new error classes)
- CREATE `app_flutter/test/domain/velocity_types_test.dart`

**Driving tests (RED)**:
- `should parse valid velocity vector with all components`
- `should reject velocity component exceeding 12 fraction digits` (ERR-VEL-001)
- `should calculate 2D speed as sqrt(v_north^2 + v_east^2)`
- `should calculate 2D heading as atan2(v_east, v_north)`
- `should handle zero vector heading gracefully` (ERR-VEL-003)
- `should validate all three components via aggregate validator`

**Verification**: `flutter test test/domain/velocity_types_test.dart` — all pass

### Micro-Task 2: Repository + ViewModel
**Target files**:
- CREATE `app_flutter/lib/domain/repositories/velocity_repository.dart`
- CREATE `app_flutter/lib/data/repositories/sqlite_velocity_repository.dart`
- CREATE `app_flutter/lib/presentation/viewmodels/velocity_viewmodel.dart`
- CREATE `app_flutter/test/data/sqlite_velocity_repository_test.dart`
- CREATE `app_flutter/test/presentation/velocity_viewmodel_test.dart`

**Driving tests (RED)**:
- Repository: `should save and fetch velocity record`, `should return InstanceNotFoundError for missing record`, `should update existing record`
- ViewModel: `should load velocity from repository`, `should save velocity to repository`, `should expose error message on failure`

**Verification**: `flutter test test/data/sqlite_velocity_repository_test.dart test/presentation/velocity_viewmodel_test.dart` — all pass

### Micro-Task 3: Widget + BDD Acceptance Test
**Target files**:
- CREATE `app_flutter/lib/presentation/widgets/velocity_property_widget.dart`
- CREATE `app_flutter/test/presentation/velocity_property_widget_test.dart`

**Pattern**: Follow `coordinates_and_altitude_property_widget.dart` — `TypeDescriptor` with `FieldDescriptor`s using `valueResolver`/`valueWriter` callbacks. Fields: vNorth, vEast, vUp (all editable), Speed and Heading (read-only derived values). `ListenableBuilder` bound to `VelocityViewModel`.

**BDD Widget Test (RED)**:
```
Given a VelocityPropertyWidget bound to a VelocityViewModel
When the widget renders with vNorth=3.0, vEast=4.0, vUp=0.5
Then the speed field displays 5.0
And the heading field displays ~0.927 radians
And all three velocity component fields are editable
And the speed and heading fields are read-only
```

**Verification**: `flutter test test/presentation/velocity_property_widget_test.dart` — all pass

## Final Verification
```bash
cd app_flutter && flutter analyze && flutter test && flutter build macos --release
```
All must pass with zero issues.

## File Summary

| Action | File |
|---|---|
| CREATE | `app_flutter/lib/domain/models/velocity_types.dart` |
| MODIFY | `app_flutter/lib/domain/domain_errors.dart` (append errors) |
| CREATE | `app_flutter/lib/domain/repositories/velocity_repository.dart` |
| CREATE | `app_flutter/lib/data/repositories/sqlite_velocity_repository.dart` |
| CREATE | `app_flutter/lib/presentation/viewmodels/velocity_viewmodel.dart` |
| CREATE | `app_flutter/lib/presentation/widgets/velocity_property_widget.dart` |
| CREATE | `app_flutter/test/domain/velocity_types_test.dart` |
| CREATE | `app_flutter/test/data/sqlite_velocity_repository_test.dart` |
| CREATE | `app_flutter/test/presentation/velocity_viewmodel_test.dart` |
| CREATE | `app_flutter/test/presentation/velocity_property_widget_test.dart` |
