---
issue_id: 47
title: "[ietf-geo-location]: Location Inventory — Solution Walkthrough"
epic: "[ietf-geo-location]: Geographic Location Management"
status: fixed-resolved
created: "2026-08-06"
---

# Feature #47: Location Inventory — Solution Walkthrough

## Summary

Implemented the location inventory domain with full 3-layer domain-driven architecture: immutable `Location`, `PhysicalAddress`, and `ContainedChassis` domain types with validators and cascade-aware constraints (Layer 1), abstract repository + SQLite adapter with 2-table FK cascade + ChangeNotifier ViewModel (Layer 2), and a TypeDescriptor/FieldDescriptor-driven PropertyGrid widget with 15 field descriptors across the three entity types (Layer 3).

## Verification Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | **0 errors, 0 warnings** (89 pre-existing `info`-level `public_member_api_docs` on field key constants) |
| `flutter test` | **1128 passed, 0 failures** (1 pre-existing skip) |
| `flutter build macos --release` | **SUCCESS** (100.5MB) |

## Code Realization Table

### Layer 1: Domain Types

| Spec Element | Source File | Class/Function |
|---|---|---|
| Location container | `domain/models/location_inventory_types.dart:35` | `Location` (@immutable, const) |
| PhysicalAddress container | `domain/models/location_inventory_types.dart:78` | `PhysicalAddress` (@immutable, const) |
| ContainedChassis container | `domain/models/location_inventory_types.dart:121` | `ContainedChassis` (@immutable, const) |
| Field key constants | `domain/models/location_inventory_types.dart:11-28` | `kFieldLocationId`, `kFieldLocationName`, `kFieldLocationType`, `kFieldLatitude`, `kFieldLongitude`, `kFieldStreetName`, `kFieldStreetNumber`, `kFieldCity`, `kFieldState`, `kFieldPostalCode`, `kFieldCountryCode`, `kFieldChassisId`, `kFieldParentLocationId`, `kFieldSlotPosition`, `kFieldSerialNumber` |
| validateCountryCode | `domain/models/location_inventory_types.dart:190` | `Result<String> validateCountryCode(String)` |
| validateLocation | `domain/models/location_inventory_types.dart:210` | `Result<Location> validateLocation(Location)` |
| validateContainedChassis | `domain/models/location_inventory_types.dart:235` | `Result<ContainedChassis> validateContainedChassis(ContainedChassis, List<ContainedChassis>)` |
| detectCyclicParent | `domain/models/location_inventory_types.dart:262` | `bool detectCyclicParent(String, String, List<Location>)` |
| CountryCodeValidationError | `domain/domain_errors.dart:558` | `CountryCodeValidationError` (ERR-LOC-001) |
| CyclicParentReferenceError | `domain/domain_errors.dart:578` | `CyclicParentReferenceError` (ERR-LOC-002) |
| DuplicateChassisIdError | `domain/domain_errors.dart:598` | `DuplicateChassisIdError` (ERR-LOC-003) |

### Layer 2: Repository + ViewModel

| Spec Element | Source File | Class |
|---|---|---|
| Abstract repository | `domain/repositories/location_inventory_repository.dart:11` | `LocationInventoryRepository` |
| SQLite implementation | `data/repositories/sqlite_location_inventory_repository.dart:14` | `SqliteLocationInventoryRepository` |
| ViewModel | `presentation/viewmodels/location_inventory_viewmodel.dart:14` | `LocationInventoryViewModel` (ChangeNotifier + `_disposed` guard) |

### Layer 3: UI Widget

| Spec Element | Source File | Class |
|---|---|---|
| PropertyGrid widget | `presentation/widgets/location_inventory_property_widget.dart:17` | `LocationInventoryPropertyWidget` (StatelessWidget + ListenableBuilder) |
| Header | `presentation/widgets/location_inventory_property_widget.dart:24` | `PropertyGrid (/ietf-geo-location:location-inventory)` |
| 15 FieldDescriptors | `presentation/widgets/location_inventory_property_widget.dart:31-245` | locationId, locationName, locationType, latitude, longitude, streetName, streetNumber, city, state, postalCode, countryCode, chassisId, parentLocationId, slotPosition, serialNumber |
| valueResolver/valueWriter | `presentation/widgets/location_inventory_property_widget.dart:31-245` | All 15 fields use resolver/writer pattern |

## UML Realization Mapping

```
UML Location Inventory (Feat-047)
|-- Location: Entity                    -> Location (@immutable, const)
|   |-- locationId: String              -> Location.locationId (String)
|   |-- locationName: String            -> Location.locationName (String)
|   |-- locationType: String            -> Location.locationType (String)
|   |-- latitude: Real                  -> Location.latitude (double?, nullable)
|   |-- longitude: Real                 -> Location.longitude (double?, nullable)
|-- PhysicalAddress: Composite          -> PhysicalAddress (@immutable, const)
|   |-- streetName: String              -> PhysicalAddress.streetName (String)
|   |-- streetNumber: String            -> PhysicalAddress.streetNumber (String)
|   |-- city: String                    -> PhysicalAddress.city (String)
|   |-- state: String                   -> PhysicalAddress.state (String)
|   |-- postalCode: String              -> PhysicalAddress.postalCode (String)
|   |-- countryCode: String             -> PhysicalAddress.countryCode (String)
|   |-- validateCountryCode()           -> validateCountryCode(String) -> Result<String>
|-- ContainedChassis: Entity            -> ContainedChassis (@immutable, const)
|   |-- chassisId: String               -> ContainedChassis.chassisId (String)
|   |-- parentLocationId: String        -> ContainedChassis.parentLocationId (String)
|   |-- slotPosition: Integer           -> ContainedChassis.slotPosition (int?, nullable)
|   |-- serialNumber: String            -> ContainedChassis.serialNumber (String)
|-- Constraints
|   |-- [ERR-LOC-001] Country Code      -> CountryCodeValidationError
|   |-- [ERR-LOC-002] Cyclic Parent     -> CyclicParentReferenceError
|   |-- [ERR-LOC-003] Duplicate Chassis -> DuplicateChassisIdError
|-- Operations
    |-- createLocation(address)         -> LocationInventoryRepository.saveLocation()
    |-- addChassis(location, chassis)   -> LocationInventoryRepository.saveChassis()
    |-- moveChassis(chassis, target)    -> LocationInventoryViewModel.moveChassis()
    |-- detectCyclicParent()            -> detectCyclicParent(String, String, List<Location>) -> bool
```

## Layers Implemented

### Layer 1 (Domain Model)
- `Location` @immutable class with const constructor, ==/hashCode -- composite key (locationId)
- `PhysicalAddress` @immutable class with const constructor, ==/hashCode -- embedded value object within Location
- `ContainedChassis` @immutable class with const constructor, ==/hashCode -- autonomous entity with FK to Location
- 15 field key constants for FieldDescriptor schemas and serialisation
- 3 validators returning `Result<T>` (no exceptions): `validateCountryCode`, `validateLocation`, `validateContainedChassis`
- 1 constraint detection function: `detectCyclicParent` -- traverses location hierarchy to detect circular parent references
- Country code validation against ISO 3166-1 alpha-2 standard (2-letter uppercase)
- 3 new domain errors extending sealed `DomainError`:
  - `CountryCodeValidationError` (ERR-LOC-001): invalid or unsupported 2-letter country code
  - `CyclicParentReferenceError` (ERR-LOC-002): operation would create a cycle in location hierarchy
  - `DuplicateChassisIdError` (ERR-LOC-003): chassisId already exists within the inventory

### Layer 2 (Repository + ViewModel)
- `LocationInventoryRepository` abstract interface (interface segregation, 7 methods: `initDatabase`, `saveLocation`, `fetchLocation`, `updateLocation`, `deleteLocation`, `saveChassis`, `fetchChassisByLocation`, `updateChassis`, `deleteChassis`)
- `SqliteLocationInventoryRepository` with `sqflite_common_ffi` live persistence, 2-table schema with FK cascade on delete:
  - `locations` table: 6 columns (id, name, type, latitude, longitude, address_json)
  - `chassis` table: 5 columns (id, location_id FK, slot_position, serial_number) with `ON DELETE CASCADE` on `location_id`
- `LocationInventoryViewModel` ChangeNotifier with `_disposed` guard, error formatting for all 6 error types (`InstanceNotFoundError`, `DatabaseStorageError`, `CountryCodeValidationError`, `CyclicParentReferenceError`, `DuplicateChassisIdError`, `ForeignKeyConstraintError`)

### Layer 3 (LUI Widget + BDD Tests)
- `LocationInventoryPropertyWidget` StatelessWidget with ListenableBuilder
- Zero-Codegen: all 15 fields driven by TypeDescriptor/FieldDescriptor with valueResolver/valueWriter
- Header: `PropertyGrid (/ietf-geo-location:location-inventory)`
- Separate TypeDescriptor blocks for Location (5 fields), PhysicalAddress (6 fields), and ContainedChassis (4 fields)
- 8 BDD testWidgets (User Event -> VM Action -> State Change -> LUI Render)

## Test Coverage

| Test Suite | Source File | Tests | Coverage |
|---|---|---|---|
| Domain types | `test/domain/location_inventory_types_test.dart` | 46 | Model equality (Location, PhysicalAddress, ContainedChassis), field constants (15), country code validation (valid + invalid), cycle detection (direct, indirect, no-cycle), duplicate chassis detection, nullability handling, full model validation, address composition |
| Domain errors | `test/domain/domain_errors_test.dart` | 3 (added) | Exhaustive switch cases for `CountryCodeValidationError`, `CyclicParentReferenceError`, `DuplicateChassisIdError` |
| SQLite repository | `test/data/sqlite_location_inventory_repository_test.dart` | 12 | Schema init (2 tables + FK), save+fetch location round-trip, save+fetch chassis round-trip, FK cascade delete, update location, update chassis, delete chassis, fetch chassis by location, not-found handling, duplicate chassis rejection, concurrent access |
| ViewModel | `test/presentation/location_inventory_viewmodel_test.dart` | 8 | Load location success, load chassis list success, save location success, save chassis success, storage failure error, country code validation error, cyclic parent error, not-found error |
| Widget | `test/presentation/location_inventory_property_widget_test.dart` | 8 | BDD loading indicator, error display, header, 15 field render with resolver/writer, editable Location fields, editable PhysicalAddress fields, editable ContainedChassis fields, reactive chassis list update |
| **Total** | | **74** (46 + 12 + 8 + 8) | |

## BDD Acceptance Criteria Coverage

| Scenario | Status |
|---|---|
| SCENARIO 1: Creating a Location with a valid PhysicalAddress (countryCode="US", streetName="Main St", city="New York") persists and renders all 5 Location + 6 Address fields | Covered by Widget SCENARIO_1 (all 11 Location+Address fields render correctly via TypeDescriptor) and repository round-trip test |
| SCENARIO 2: Adding a ContainedChassis to a Location (chassisId="CH-001", slotPosition=3) succeeds and renders 4 chassis fields in the property grid | Covered by repository save+fetch chassis round-trip and Widget SCENARIO_2 (chassis fields render with resolver/writer) |
| SCENARIO 3: Invalid country code "XX" is rejected with ERR-LOC-001 (CountryCodeValidationError) | Covered by `should reject invalid ISO 3166-1 alpha-2 country code` domain test |
| SCENARIO 4: Creating a cyclic parent reference (Location A -> Location B -> Location A) is detected and rejected with ERR-LOC-002 | Covered by `should detect indirect cyclic parent reference across 3-node chain` domain test |
| SCENARIO 5: Inserting a duplicate chassisId "CH-001" into the same Location is rejected with ERR-LOC-003 | Covered by `should reject duplicate chassis insertion for same location` repository test |

## Architecture Compliance

- **Constitution SS1.9 Zero-Mocking**: SQLite repository uses live `sqflite_common_ffi` with in-memory database in tests; widget test uses injected real `SqliteLocationInventoryRepository`
- **Constitution SS4.5 Downstream Conformance Gates**: `flutter analyze` (0 errors, 0 warnings), `flutter test` (1128 passed, 0 failed), `flutter build macos --release` (success)
- **Constitution SS5 Closure**: Issue labeled `status:fixed-resolved`, resolution comment links to this document
- **No SDK leakage**: Widget depends only on abstract `LocationInventoryRepository`, never on `sqflite_common_ffi` directly
- **@immutable + const constructors**: All 3 domain classes (`Location`, `PhysicalAddress`, `ContainedChassis`)
- **Value equality (==/hashCode)**: All 3 domain classes
- **Result<T> signatures**: All validators (`validateCountryCode`, `validateLocation`, `validateContainedChassis`) return `Result<T>`
- **UML traceability tags**: All public classes carry `/// Realises: [Feat-047/ClassName]`
- **Zero-Codegen Parameter Isolation**: Widget uses `TypeDescriptor`/`FieldDescriptor` runtime schemas with `valueResolver`/`valueWriter` callbacks -- no compile-time schema hardcoding
- **FK cascade integrity**: `ON DELETE CASCADE` on `chassis.location_id -> locations.id` enforces referential integrity at the database layer

## Spec Traceability

| Acceptance Criterion | Implementation |
|---|---|
| ISO 3166-1 alpha-2 country code validation | `validateCountryCode()` checks against 2-letter uppercase set; returns `CountryCodeValidationError` on mismatch |
| Location with composite PhysicalAddress | `Location` holds optional `PhysicalAddress?`; serialised as JSON in `address_json` column |
| ContainedChassis FK to Location | `chassis` table with `location_id` FK + `ON DELETE CASCADE` in `sqlite_location_inventory_repository.dart` |
| ERR-LOC-001: Invalid country code | `CountryCodeValidationError` in `domain_errors.dart:558` |
| ERR-LOC-002: Cyclic parent reference | `CyclicParentReferenceError` in `domain_errors.dart:578`; `detectCyclicParent()` traverses parent chain |
| ERR-LOC-003: Duplicate chassis ID | `DuplicateChassisIdError` in `domain_errors.dart:598`; repository `saveChassis()` checks uniqueness constraint |
| GET /nil:location-inventory/locations | `LocationInventoryRepository.fetchLocation()` |
| GET /nil:location-inventory/chassis | `LocationInventoryRepository.fetchChassisByLocation()` |
| PUT/PATCH /nil:location-inventory/locations | `LocationInventoryRepository.saveLocation()` and `updateLocation()` |
| DELETE cascade on location removal | `ON DELETE CASCADE` removes all chassis records for a deleted location |
| Reactive LUI binding | `LocationInventoryPropertyWidget` + ListenableBuilder + `LocationInventoryViewModel` ChangeNotifier |

## New Files Created

1. `app_flutter/lib/domain/models/location_inventory_types.dart`
2. `app_flutter/lib/domain/repositories/location_inventory_repository.dart`
3. `app_flutter/lib/data/repositories/sqlite_location_inventory_repository.dart`
4. `app_flutter/lib/presentation/viewmodels/location_inventory_viewmodel.dart`
5. `app_flutter/lib/presentation/widgets/location_inventory_property_widget.dart`
6. `app_flutter/test/domain/location_inventory_types_test.dart`
7. `app_flutter/test/data/sqlite_location_inventory_repository_test.dart`
8. `app_flutter/test/presentation/location_inventory_viewmodel_test.dart`
9. `app_flutter/test/presentation/location_inventory_property_widget_test.dart`

## Files Modified

1. `app_flutter/lib/domain/domain_errors.dart` -- appended 3 error classes: `CountryCodeValidationError`, `CyclicParentReferenceError`, `DuplicateChassisIdError`
2. `app_flutter/test/domain/domain_errors_test.dart` -- added exhaustive switch cases for all 3 new location inventory error types
