# Solution: Feature #35 — Geodetic System and Accuracy Bounds

## Issue: [ietf-geo-location]: Geodetic System and Accuracy Bounds #35

## Verification Status

| Gate | Result |
|------|--------|
| `flutter analyze` | 0 errors (65 info: pre-existing `public_member_api_docs`) |
| `flutter test` | 975 passed, 0 failed, 1 skipped |
| `flutter build macos --release` | Built successfully (100.5MB) |

## Code Realization Table

| Layer | Realises Tag | Source File | Class / Function |
|-------|-------------|-------------|-----------------|
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/models/geodetic_system_and_accuracy_types.dart` | `GeodeticSystem` (immutable domain model) |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/models/geodetic_system_and_accuracy_types.dart` | `kFieldGeodeticDatum`, `kFieldCoordAccuracy`, `kFieldHeightAccuracy` (field key constants) |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/models/geodetic_system_and_accuracy_types.dart` | `validateGeodeticDatum()` — YANG pattern `[ -@\[-\^_-~]*` |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/models/geodetic_system_and_accuracy_types.dart` | `validateCoordAccuracy()` — non-negative + 6 fraction digits |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/models/geodetic_system_and_accuracy_types.dart` | `validateHeightAccuracy()` — non-negative + 6 fraction digits |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/models/geodetic_system_and_accuracy_types.dart` | `validateGeodeticSystem()` — compound validator |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/domain_errors.dart` | `InvalidGeodeticDatumError` |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/domain_errors.dart` | `NegativeAccuracyValueError` |
| 1 | `[Feat-035/GeodeticSystem]` | `lib/domain/domain_errors.dart` | `AccuracyPrecisionExceededError` |
| 2 | `[Feat-035/GeodeticSystemRepository]` | `lib/domain/repositories/geodetic_system_repository.dart` | `GeodeticSystemRepository` (abstract interface) |
| 2 | `[Feat-035/SqliteGeodeticSystemRepository]` | `lib/data/repositories/sqlite_geodetic_system_repository.dart` | `SqliteGeodeticSystemRepository` (SQLite via sqflite_common_ffi) |
| 2 | `[Feat-035/GeodeticSystemViewModel]` | `lib/presentation/viewmodels/geodetic_system_viewmodel.dart` | `GeodeticSystemViewModel` (ChangeNotifier) |
| 3 | `[Feat-035/GeodeticSystemPropertyWidget]` | `lib/presentation/widgets/geodetic_system_property_widget.dart` | `GeodeticSystemPropertyWidget` (StatelessWidget, TypeDescriptor-driven) |
| 3 | `[Feat-035/GeodeticSystemPropertyWidget]` | `test/presentation/geodetic_system_property_widget_test.dart` | 5 BDD testWidgets (loading, error, header, fields, typing) |
| 2 | `[Feat-035/GeodeticSystemRepository]` | `test/data/sqlite_geodetic_system_repository_test.dart` | 4 SQLite integration tests (roundtrip, not found, nullable, update) |
| 2 | `[Feat-035/GeodeticSystemViewModel]` | `test/presentation/geodetic_system_viewmodel_test.dart` | 4 ViewModel unit tests (load success/fail, save, update) |

## UML Realization Mapping

```
UML GeodeticSystem (Feat-035)
├── geodeticDatum: String         → GeodeticSystem.geodeticDatum (default "wgs-84")
├── coordAccuracy: Real           → GeodeticSystem.coordAccuracy (double?)
├── heightAccuracy: Real          → GeodeticSystem.heightAccuracy (double?)
├── validateGeodeticDatum()       → validateGeodeticDatum(String) → Result<String>
├── validateCoordAccuracy()       → validateCoordAccuracy(double) → Result<double>
├── validateHeightAccuracy()      → validateHeightAccuracy(double) → Result<double>
└── checkTemporalValidity()       → [deferred to future sprint]
```

## Layers Implemented

### Layer 1 (Domain Model)
- `GeodeticSystem` @immutable class with const constructor, ==/hashCode
- 3 field key constants for FieldDescriptor schemas
- 4 validators all returning `Result<T>` (no exceptions)
- 3 new domain errors extending sealed `DomainError`

### Layer 2 (ViewModel)
- `GeodeticSystemRepository` abstract interface (interface segregation)
- `SqliteGeodeticSystemRepository` with `sqflite_common_ffi` live persistence
- `GeodeticSystemViewModel` ChangeNotifier with `_disposed` guard
- Error formatting for all 3 new error types

### Layer 3 (LUI Widget + BDD Tests)
- `GeodeticSystemPropertyWidget` StatelessWidget
- Zero-Codegen: all 3 fields driven by TypeDescriptor/FieldDescriptor with valueResolver/valueWriter
- Header: `PropertyGrid (/ietf-geo-location:geodetic-system)`
- ListenableBuilder for reactive rendering
- 5 BDD testWidgets (User Event → VM Action → State Change → LUI Render)

## Constitution Compliance
- **§1.9** Zero-Mocking Live Persistence: SQLite via `sqflite_common_ffi`, no in-memory DI mocks
- **§4.5** Downstream Conformance Gates: `flutter analyze` (0 errors), `flutter test` (all pass), `flutter build macos --release` (success)
- **§5** Forbidden Practices: No layout splitters, timeline scrubber, or focus-loss property grid removed
- **Zero-Codegen Parameter Isolation**: UI widgets driven by TypeDescriptor schemas at runtime; zero hardcoded domain attributes

## New Files Created
1. `app_flutter/lib/domain/models/geodetic_system_and_accuracy_types.dart`
2. `app_flutter/lib/domain/repositories/geodetic_system_repository.dart`
3. `app_flutter/lib/data/repositories/sqlite_geodetic_system_repository.dart`
4. `app_flutter/lib/presentation/viewmodels/geodetic_system_viewmodel.dart`
5. `app_flutter/lib/presentation/widgets/geodetic_system_property_widget.dart`
6. `app_flutter/test/data/sqlite_geodetic_system_repository_test.dart`
7. `app_flutter/test/presentation/geodetic_system_viewmodel_test.dart`
8. `app_flutter/test/presentation/geodetic_system_property_widget_test.dart`

## Files Modified
1. `app_flutter/lib/domain/domain_errors.dart` — appended 3 error classes
2. `app_flutter/test/domain/domain_errors_test.dart` — added exhaustive switch cases
