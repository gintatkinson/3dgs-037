---
title: "Feature #1 Solution Walkthrough — Counter and Gauge Data Types"
feature: "[ietf-yang-types]: Counter and Gauge Data Types"
issue_id: 1
status: fixed-resolved
created: "2026-08-05"
---

# Feature #1: Counter and Gauge Data Types — Solution Walkthrough

## Overview

Implements the six core quantitative numeric counter and gauge data types from the ietf-yang-types YANG module (RFC 9911):
counter32, zeroBasedCounter32, counter64, zeroBasedCounter64, gauge32, gauge64.

## Architecture (3-Layer Vertical Slice)

| Layer | Component | File |
|-------|-----------|------|
| 1 (Domain) | CounterAndGaugeTypes model + validation + operations | `app_flutter/lib/domain/models/counter_and_gauge_types.dart` |
| 2 (ViewModel) | CounterAndGaugeViewModel | `app_flutter/lib/presentation/viewmodels/counter_and_gauge_viewmodel.dart` |
| 2 (Persistence) | CounterAndGaugeRepository (abstract) | `app_flutter/lib/domain/repositories/counter_and_gauge_repository.dart` |
| 2 (Persistence) | SqliteCounterAndGaugeRepository (concrete) | `app_flutter/lib/data/repositories/sqlite_counter_and_gauge_repository.dart` |
| 3 (UI) | CounterAndGaugePropertyWidget | `app_flutter/lib/presentation/widgets/counter_and_gauge_property_widget.dart` |

## Code Realization Table

| Spec Element | Implementation |
|---|---|
| counter32 typedef | `CounterAndGaugeTypes.counter32` field, `validateCounter32()`, `incrementCounter32()` |
| zeroBasedCounter32 typedef | `CounterAndGaugeTypes.zeroBasedCounter32` field, `validateZeroBasedCounter32()` |
| counter64 typedef | `CounterAndGaugeTypes.counter64` field, `validateCounter64()`, `incrementCounter64()`, `computeCounterDelta64()` |
| zeroBasedCounter64 typedef | `CounterAndGaugeTypes.zeroBasedCounter64` field, `validateZeroBasedCounter64()` |
| gauge32 typedef | `CounterAndGaugeTypes.gauge32` field, `validateGauge32()`, `updateGauge32()` |
| gauge64 typedef | `CounterAndGaugeTypes.gauge64` field, `validateGauge64()`, `updateGauge64()` |
| Counter delta processing | `computeCounterDelta32()`, `computeCounterDelta64()` |
| Payload schema (7-column DB) | `counter_and_gauge_records` table |
| Logical UI PropertyGrid | `CounterAndGaugePropertyWidget` |

## Layer 1: Domain Model

**File**: `app_flutter/lib/domain/models/counter_and_gauge_types.dart`

- `@immutable class CounterAndGaugeTypes` with 6 const fields
- Constants: `kMaxUint32`, `kModUint32`, `kMaxUint64` (BigInt), `kModUint64` (BigInt)
- 6 static validation functions returning `Result<T>` with `SchemaFieldRangeError`
- 4 operation functions: `incrementCounter32/64` (wraparound at max), `updateGauge32/64` (latch at 0/max)
- 2 delta functions: `computeCounterDelta32/64` (mod 2^32/2^64 arithmetic)
- `copyWith`, `==`/`hashCode` for value equality

**Test**: `app_flutter/test/domain/counter_and_gauge_types_test.dart` — 48 tests

## Layer 2: Persistence

**Abstract Repository**: `app_flutter/lib/domain/repositories/counter_and_gauge_repository.dart`
- `CounterAndGaugeRepository` with `save`, `fetch`, `update`, `initDatabase`

**SQLite Implementation**: `app_flutter/lib/data/repositories/sqlite_counter_and_gauge_repository.dart`
- Implements `CounterAndGaugeRepository` using `sqflite_common_ffi` (constitution §1.9 live persistence)
- 7-column table: id, container_id, counter32, zero_based_counter32, counter64 (TEXT), zero_based_counter64 (TEXT), gauge32, gauge64 (TEXT)
- 64-bit values stored as TEXT for full precision

**Test**: `app_flutter/test/data/sqlite_counter_and_gauge_repository_test.dart` — 6 tests (in-memory SQLite via FFI)

## Layer 2: ViewModel

**File**: `app_flutter/lib/presentation/viewmodels/counter_and_gauge_viewmodel.dart`
- `CounterAndGaugeViewModel extends ChangeNotifier`
- Constructor injection of `CounterAndGaugeRepository`
- State: `model`, `isLoading`, `errorMessage`, `_currentRecordId`
- Methods: `load()`, `save()`, `update()`, `incrementCounter32/64()`, `updateGauge32/64()`
- Full `notifyListeners()` on all state transitions

**Test**: `app_flutter/test/presentation/counter_and_gauge_viewmodel_test.dart` — 7 tests

## Layer 3: LUI Widget

**File**: `app_flutter/lib/presentation/widgets/counter_and_gauge_property_widget.dart`
- `CounterAndGaugePropertyWidget` using `ListenableBuilder`
- Zero-Codegen Parameter Isolation: all fields driven by `TypeDescriptor`/`FieldDescriptor` at runtime
- Loading: `CircularProgressIndicator`
- Error: red container with error text
- Model: header + property rows from FieldDescriptor schema with increment/decrement buttons

**BDD Acceptance Test**: `app_flutter/test/presentation/counter_and_gauge_property_widget_test.dart` — 5 testWidgets

## Modified Existing File

- `app_flutter/lib/domain/domain_errors.dart`: Widened `SchemaFieldRangeError.value/min/max` from `num` to `Object` to support BigInt values; added `==`/`hashCode`

## Verification Results

| Gate | Result |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` (full suite) | 416 passed, 1 skipped, 0 failed |
| `flutter build macos --release` | Success |
| `verify_downstream_baseline.py` | All gates passed |

## Manual Testing Instructions

1. Navigate to the app: `cd app_flutter`
2. Run domain tests in isolation: `flutter test test/domain/counter_and_gauge_types_test.dart`
3. Run persistence tests: `flutter test test/data/sqlite_counter_and_gauge_repository_test.dart`
4. Run ViewModel tests: `flutter test test/presentation/counter_and_gauge_viewmodel_test.dart`
5. Run BDD widget tests: `flutter test test/presentation/counter_and_gauge_property_widget_test.dart`
6. Run full suite: `flutter test`
7. Check no analysis issues: `flutter analyze`
8. Verify the `CounterAndGaugePropertyWidget` renders:
   - Loading spinner while fetching
   - Red error container on fetch failure
   - "Counter and Gauge Types" header with 6 property rows
   - Increment/decrement buttons update displayed values
