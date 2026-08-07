---
issue_id: 48
title: "Building and Floor Position — Solution Walkthrough"
epic: "[ietf-geo-location]: Geographic Location Management"
status: fixed-resolved
created: "2026-08-07"
---

# Feature #48: Building and Floor Position — Solution Walkthrough

## Summary

Implemented indoor building position tracking defined in the `ietf-ni-location` YANG module (building, floor, room, room-building-position). Added the `BuildingPosition` domain model with immutability and value equality, `formatRoomBuildingPosition` formatting function, `validateBuildingPosition` validator, `BuildingPositionValidationError` error type, 4 field key constants, SQLite column persistence with schema migration, ViewModel propagation, and 4 PropertyGrid FieldDescriptors — plus 5 BDD widget test scenarios covering rendering, null handling, read-only computed fields, interactive editing, and persistence round-trip.

## Verification Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | **0 errors, 0 warnings** |
| `flutter test` | **1155 passed, 0 failures** |
| `flutter build macos --release` | **SUCCESS** (100.5MB) |

## Files Modified

| File | Description |
|------|-------------|
| `app_flutter/lib/domain/models/location_inventory_types.dart` | Added `BuildingPosition` class, `formatRoomBuildingPosition`, `validateBuildingPosition`, 4 field key constants (`kFieldBuilding`, `kFieldFloor`, `kFieldRoom`, `kFieldRoomBuildingPosition`), and `buildingPosition` field on `Location` with equality/hashCode updates |
| `app_flutter/lib/domain/domain_errors.dart` | Added `BuildingPositionValidationError` class with 4 error detail fields |
| `app_flutter/lib/data/repositories/sqlite_location_inventory_repository.dart` | Added 4 SQLite columns (`building`, `floor`, `room`, `room_building_position`) with ALTER TABLE migration, updated `_locationToRow` and `_locationFromRow` for serialization/deserialization |
| `app_flutter/lib/presentation/viewmodels/location_inventory_viewmodel.dart` | Added `buildingPosition` propagation in `addChassis` and `removeChassis` to preserve the field when updating chassis collections |
| `app_flutter/lib/presentation/widgets/location_inventory_property_widget.dart` | Added 4 `FieldDescriptor` entries for Building, Floor, Room, and Room Building Position (read-only computed) |
| `app_flutter/test/domain/location_inventory_types_test.dart` | Added 5 test groups: `BuildingPosition`, `formatRoomBuildingPosition`, `validateBuildingPosition`, `Location equality with buildingPosition`, and 4 field key constant tests |
| `app_flutter/test/domain/domain_errors_test.dart` | Added `BuildingPositionValidationError` to the error round-trip test and `toString` switch |
| `app_flutter/test/data/sqlite_location_inventory_repository_test.dart` | Added 4 persistence tests: full buildingPosition save/fetch, null buildingPosition, partial buildingPosition, and buildingPosition preservation on update |
| `app_flutter/test/presentation/location_inventory_property_widget_test.dart` | Added 5 BDD widget test scenarios (SCENARIO_9 through SCENARIO_13) and updated TextField count from 14 to 17 |

## Layer 1: Domain

### BuildingPosition class

Immutable domain model capturing indoor building position attributes per ietf-ni-location.yang § physical-address:
- `building`: Optional building identifier (1-64 chars)
- `floor`: Optional floor designation (1-64 chars)
- `room`: Optional room identifier (1-64 chars)
- `roomBuildingPosition`: Optional formatted compound position string (1-128 chars)

Const constructor with `@immutable` annotation, custom `==` and `hashCode` for value semantics.

### formatRoomBuildingPosition

Static function that joins non-empty building, floor, and room segments with `", "` separator. Gracefully omits null/empty segments. Example: `"Building B, Floor 3, Room 302"`.

### validateBuildingPosition

Returns `Success<BuildingPosition>` if at least one of the four fields is non-null and non-empty, or `Failure<BuildingPositionValidationError>` if all fields are null or empty — enforcing the YANG constraint that at least one indoor position field must be populated.

### BuildingPositionValidationError

Domain error class extending `DomainError` (immutable, `@immutable`), carrying the four field values that failed validation. Realises `[Feat-048/BuildingPositionValidationError]`.

### Field Key Constants (4)

| Constant | Value | Purpose |
|----------|-------|---------|
| `kFieldBuilding` | `'building'` | Building identifier field key |
| `kFieldFloor` | `'floor'` | Floor designation field key |
| `kFieldRoom` | `'room'` | Room identifier field key |
| `kFieldRoomBuildingPosition` | `'roomBuildingPosition'` | Computed compound position field key |

## Layer 2: ViewModel + Persistence

### SQLite Columns

Four new TEXT columns added to the `locations` table:
- `building`
- `floor`
- `room`
- `room_building_position`

Schema migration via `ALTER TABLE ADD COLUMN` with try/catch for idempotency (columns may already exist from prior migration).

Serialization (`_locationToRow`) writes `buildingPosition?.building`, `?.floor`, `?.room`, `?.roomBuildingPosition` into row map. Deserialization (`_locationFromRow`) constructs `BuildingPosition` only when at least one column is non-null.

### ViewModel Updates

`addChassis` and `removeChassis` methods now include `buildingPosition` in the `Location` copy constructor to preserve indoor position data when chassis collections are modified.

## Layer 3: Widget + BDD

### FieldDescriptors (4)

| Label | Key | Type | Value Resolver | Editable |
|-------|-----|------|----------------|----------|
| Building | `kFieldBuilding` | string | `buildingPosition?.building ?? '-'` | Yes (valueWriter creates new Location with updated BuildingPosition) |
| Floor | `kFieldFloor` | string | `buildingPosition?.floor ?? '-'` | Yes |
| Room | `kFieldRoom` | string | `buildingPosition?.room ?? '-'` | Yes |
| Room Building Position | `kFieldRoomBuildingPosition` | string | `formatRoomBuildingPosition(building, floor, room)` | Read-only (no valueWriter) |

The Room Building Position field is computed from the individual building/floor/room fields using `formatRoomBuildingPosition`, providing a live formatted preview without duplicating storage.

### BDD Widget Test Scenarios (5)

| Scenario | Name | Description |
|----------|------|-------------|
| SCENARIO_9 | `shouldRenderBuildingPositionFields` | Renders all 4 field labels and displays stored values (B, 3, 302) with computed format "B, 3, 302" |
| SCENARIO_10 | `shouldRenderDashForNullBuildingPosition` | Renders Building/Floor/Room labels with dash placeholder when buildingPosition is null (exists alongside physicalAddress) |
| SCENARIO_11 | `shouldRenderReadOnlyRoomBuildingPosition` | Computed field shows "West, 2, 201-A" from building/floor/room, NOT from the stored `roomBuildingPosition` field ("should-not-appear"), verifying read-only logic |
| SCENARIO_12 | `shouldEditBuildingFieldAndPropagateToComputedField` | Editing building from "Alpha" to "Bravo" updates the computed Room Building Position from "Alpha, 1, R01" to "Bravo, 1, R01" |
| SCENARIO_13 | `shouldPreserveBuildingPositionOnPersistenceRoundTrip` | Saves, loads, navigates away, and reloads — verifies all 4 fields plus computed format survive the full persistence round-trip |

## UML Traceability

```
Realises [Feat-048/BuildingPosition]
Realises [Feat-048/Location.buildingPosition]
Realises [Feat-048/BuildingPositionValidationError]
Realises [Feat-048/formatRoomBuildingPosition]
Realises [Feat-048/validateBuildingPosition]
```

- `BuildingPosition` class → `location_inventory_types.dart:239`
- `formatRoomBuildingPosition` function → `location_inventory_types.dart:298`
- `validateBuildingPosition` function → `location_inventory_types.dart:323`
- `BuildingPositionValidationError` class → `domain_errors.dart:565`
- Field key constants (4) → `location_inventory_types.dart:37-47`
- SQLite columns (4) + migration → `sqlite_location_inventory_repository.dart:46-56`
- ViewModel propagation → `location_inventory_viewmodel.dart:128,160`
- FieldDescriptors (4) → `location_inventory_property_widget.dart:431-549`
- BDD test scenarios (5) → `location_inventory_property_widget_test.dart:326-597`
