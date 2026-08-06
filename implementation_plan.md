# Implementation Plan — Feature #47: Location Inventory Base and Postal Address

**Epic**: #51 (ietf-ni-location)  
**Spec**: `docs/features/feat-13-location-inventory-base-and-postal-address.md`  
**Schema container**: `ietf-ni-location:locations`  
**Layout binding**: PropertyGrid → properties_view  
**interface_type**: ui

## 3-Layer Architecture

| Layer | Component | File |
|---|---|---|
| Domain | `Location`, `PhysicalAddress`, `ContainedChassis` classes + validators + field keys | `app_flutter/lib/domain/models/location_inventory_types.dart` |
| Domain | Domain errors (CountryCodeValidationError, CyclicParentReferenceError, DuplicateChassisIdError) | `app_flutter/lib/domain/domain_errors.dart` (append) |
| Domain | Repository interface | `app_flutter/lib/domain/repositories/location_inventory_repository.dart` |
| Data | SQLite repository | `app_flutter/lib/data/repositories/sqlite_location_inventory_repository.dart` |
| ViewModel | `LocationInventoryViewModel` | `app_flutter/lib/presentation/viewmodels/location_inventory_viewmodel.dart` |
| Widget | `LocationInventoryPropertyWidget` | `app_flutter/lib/presentation/widgets/location_inventory_property_widget.dart` |
| Tests | Domain types test | `app_flutter/test/domain/location_inventory_types_test.dart` |
| Tests | SQLite repository test | `app_flutter/test/data/sqlite_location_inventory_repository_test.dart` |
| Tests | ViewModel test | `app_flutter/test/presentation/location_inventory_viewmodel_test.dart` |
| Tests | BDD widget test | `app_flutter/test/presentation/location_inventory_property_widget_test.dart` |

## Micro-Task 1: Domain Model + Errors
### Location class
- `containerId`, `id` (String), `uuid`, `name`, `alias`, `description`, `type`, `parent`, `timestamp`, `validUntil` (all nullable except id)
- `@immutable`, `const` constructor, value equality

### PhysicalAddress class
- `address`, `postalCode`, `state`, `city`, `countryCode` (all nullable String)
- `@immutable`, `const` constructor, value equality

### ContainedChassis class
- `chassisId` (int, required), `neRef`, `componentRef` (nullable String)
- `@immutable`, `const` constructor, value equality

### Field key constants (~20 keys)

### Validators (all return `Result<T>`)
- `validateCountryCode(String code)` — `[A-Z]{2}` regex, returns `CountryCodeValidationError`
- `validateCyclicParent(String locationId, String parentId, Map<String, String?> parents)` — cycle detection
- `validateLocation(Location model)` — aggregate validation
- `validatePhysicalAddress(PhysicalAddress addr)` — country code check
- `validateDuplicateChassisId(List<ContainedChassis> chassis)` — uniqueness check

### Domain errors (append to domain_errors.dart)
- `CountryCodeValidationError` — `input` (String)
- `CyclicParentReferenceError` — `locationId`, `parentId` (String)
- `DuplicateChassisIdError` — `chassisId` (int)

### Tests (~12 tests)
- Location creation/equality, PhysicalAddress creation, ContainedChassis creation
- Country code validation (valid: "US", invalid: "USA", "us", "123")
- Cyclic parent detection (A→B, B→A)
- Duplicate chassis-id detection

## Micro-Task 2: Repository + ViewModel
Follow `geodetic_system_repository.dart` / `velocity_repository.dart` pattern exactly.

### Repository interface
- `initDatabase()`, `save()`, `fetch()`, `update()`, `delete()`, `fetchAll()`, `fetchByParent()`
- Two tables: `locations` (id, uuid, name, alias, desc, type, parent, timestamp, valid_until, address, postal_code, state, city, country_code) and `contained_chassis` (location_id, chassis_id, ne_ref, component_ref)

### SQLite repository
- Foreign key relationship between tables
- Cascade delete on location removal

### ViewModel
- `load(String recordId)`, `save(Location)`, `update(Location)`, `addChassis(ContainedChassis)`, `removeChassis(int chassisId)`
- `_formatErrorMessage` handles new error types
- `_disposed` guard

## Micro-Task 3: Widget + BDD Tests
### Widget fields (PropertyGrid, TypeDescriptor-driven)
**Editable**: id, uuid, name, alias, description, type, parent, timestamp, valid-until, address, postal-code, state, city, country-code
**Read-only**: none (all editable per spec)
**Sub-list**: ContainedChassis table (chassis-id, ne-ref, component-ref)

### BDD tests (~5 tests matching spec scenarios)
1. Render location with physical address fields
2. Country code validation failure
3. Hierarchical parent reference display
4. Contained chassis list rendering
5. Cyclic parent prevention

## Final Verification
```bash
cd app_flutter && flutter analyze && flutter test && flutter build macos --release
```
All must pass with zero errors, zero warnings, zero test failures.
