---
title: "Feature #34 Implementation — Geodetic Reference Frame"
issue_id: 34
feature: "[ietf-geo-location]: Geodetic Reference Frame"
status: "fixed-resolved"
date: "2026-08-06"
---

# Feature #34: Geodetic Reference Frame — Implementation Walkthrough

## Verification Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | 0 errors, 0 warnings |
| `flutter test` | 962 passed (all pass) |
| `flutter build macos --release` | Success (100.5MB) |
| Parity Auditor | Not run (unconfigured) |

## Files Created

| File | Layer | Purpose |
|------|-------|---------|
| `lib/domain/models/geodetic_reference_frame_types.dart` | L1 Domain | `GeodeticReferenceFrame` class, validation functions, field key constants |
| `lib/domain/repositories/geodetic_reference_frame_repository.dart` | L2 Repository | Abstract repository interface |
| `lib/data/repositories/sqlite_geodetic_reference_frame_repository.dart` | L2 Data | SQLite-backed repository implementation |
| `lib/presentation/viewmodels/geodetic_reference_frame_viewmodel.dart` | L2 ViewModel | ChangeNotifier state holder |
| `lib/presentation/widgets/geodetic_reference_frame_property_widget.dart` | L3 Widget | PropertyGrid widget with TypeDescriptor-driven fields |
| `test/domain/geodetic_reference_frame_types_test.dart` | TDD | Domain model + validation tests |
| `test/data/sqlite_geodetic_reference_frame_repository_test.dart` | TDD | SQLite repository integration tests |
| `test/presentation/geodetic_reference_frame_viewmodel_test.dart` | TDD | ViewModel unit tests |
| `test/presentation/geodetic_reference_frame_property_widget_test.dart` | TDD | Widget BDD tests |

## Files Modified

| File | Change |
|------|--------|
| `lib/domain/domain_errors.dart` | Added `InvalidAstronomicalBodyError`, `FeatureDisabledAlternateSystemError` |
| `test/domain/domain_errors_test.dart` | Added new errors to exhaustive switch test |

## Code Realization Table

| UML Class / Spec Item | Implementation | File |
|------------------------|---------------|------|
| `ReferenceFrame` | `GeodeticReferenceFrame` @immutable class | `geodetic_reference_frame_types.dart:44` |
| `astronomicalBody` attribute | `String astronomicalBody` (default "earth") | `geodetic_reference_frame_types.dart:60` |
| `alternateSystem` attribute | `String? alternateSystem` | `geodetic_reference_frame_types.dart:63` |
| `alternateSystems` attribute | `bool alternateSystems` (feature guard) | `geodetic_reference_frame_types.dart:66` |
| `validateAstronomicalBody()` | `validateAstronomicalBody(String)` → `Result<String>` | `geodetic_reference_frame_types.dart:89` |
| `validateAlternateSystem()` | `validateAlternateSystemWithFeature()` → `Result<String?>` | `geodetic_reference_frame_types.dart:113` |
| `ERR_INVALID_ASTRONOMICAL_BODY` | `InvalidAstronomicalBodyError` | `domain_errors.dart:366` |
| `ERR_FEATURE_DISABLED_ALTERNATE_SYSTEM` | `FeatureDisabledAlternateSystemError` | `domain_errors.dart:379` |
| `ERR_REFERENCE_FRAME_NOT_FOUND` | Re-uses `InstanceNotFoundError` | `domain_errors.dart:238` |
| Repository contract | `GeodeticReferenceFrameRepository` | `geodetic_reference_frame_repository.dart:13` |
| SQLite transport | `SqliteGeodeticReferenceFrameRepository` | `sqlite_geodetic_reference_frame_repository.dart:17` |
| ViewModel | `GeodeticReferenceFrameViewModel` (ChangeNotifier, _disposed guard) | `geodetic_reference_frame_viewmodel.dart:17` |
| PropertyGrid widget | `GeodeticReferenceFramePropertyWidget` (TypeDescriptor-driven) | `geodetic_reference_frame_property_widget.dart:20` |
| UI header | `PropertyGrid (/ietf-geo-location:reference-frame)` | `geodetic_reference_frame_property_widget.dart:27` |

## Acceptance Criteria Coverage

| Scenario | Test | Status |
|----------|------|--------|
| SCENARIO 1: Default "earth" | Domain test: default constructor | PASS |
| SCENARIO 2: Valid custom body | Domain test: "mars", "Enceladus", "1P/Halley" | PASS |
| SCENARIO 3: Invalid pattern | Domain test: control character rejection | PASS |
| SCENARIO 4: Feature enabled | Domain + ViewModel tests | PASS |
| SCENARIO 5: Feature disabled rejection | Domain test: `FeatureDisabledAlternateSystemError` | PASS |

## BDD Widget Scenarios

| # | Scenario | Test |
|---|----------|------|
| 1 | Loading indicator | `shouldDisplayLoadingIndicatorWhenViewModelIsLoading` |
| 2 | Error message | `shouldDisplayErrorMessageWhenViewModelHasError` |
| 3 | Header text | `shouldDisplayCorrectHeaderText` |
| 4 | Fields rendered | `shouldRenderAllThreeFieldsFromFieldDescriptorSchema` |
| 5 | Editable typing | `shouldRenderEditableTextFieldAndAcceptTyping` |

## 3-Layer DoD Summary

- **Layer 1 (Domain Model):** `GeodeticReferenceFrame` @immutable, `const` constructor, `==`/`hashCode`, validation returning `Result<T>`, typed errors. `/// Realises: [Feat-034]` on all public elements.
- **Layer 2 (ViewModel + Repository):** Abstract `GeodeticReferenceFrameRepository` interface. `SqliteGeodeticReferenceFrameRepository` using `sqflite_common_ffi` (live persistence per constitution §1.9). `GeodeticReferenceFrameViewModel` extends `ChangeNotifier` with `_disposed` guard.
- **Layer 3 (Widget + BDD Tests):** `GeodeticReferenceFramePropertyWidget` with `TypeDescriptor`/`FieldDescriptor`-driven fields (zero codegen), `valueResolver`/`valueWriter` callbacks, `ListenableBuilder` binding. 5 BDD widget tests asserting User Event → ViewModel Action → State Change → LUI Render.
