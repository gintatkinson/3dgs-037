---
issue_id: 23
title: "[ietf-inet-types]: IP Unicast, Multicast, and Scope Data Types — Solution Walkthrough"
type: "solution"
created: "2026-08-06"
labels: ["solution", "ietf-inet-types"]
---

# Feature #23: IP Unicast, Multicast, and Scope Data Types — Solution Walkthrough

## Overview

Implementation of the IP unicast, multicast, flow label, DSCP, and scope data types from `ietf-inet-types` (RFC 6021 / RFC 6991) across all 3 mandatory layers: Domain Model, ViewModel/Persistence, and LUI Widget + BDD Acceptance Test.

## Code Realization Table

| Specification Element | Source File | Class/Function | Traceability Tag |
|---|---|---|---|
| `IpScopeType` enum | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `enum IpScopeType` | `/// Realises: [Feat-023/IpScopeType]` |
| `ipScopeTypeCode(IpScopeType)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `int ipScopeTypeCode(IpScopeType)` | `/// Realises: [Feat-023/IpScopeType]` |
| `isGlobalScope(IpScopeType)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `bool isGlobalScope(IpScopeType)` | `/// Realises: [Feat-023/IpScopeType]` |
| `IpUnicastMulticastAndScopeTypes` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `@immutable class IpUnicastMulticastAndScopeTypes` | `/// Realises: [Feat-023/IpUnicastMulticastAndScopeTypes]` |
| `validateIpv6FlowLabel(int)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<int> validateIpv6FlowLabel(int)` | `/// Realises: [Feat-023/IpFlowLabel]` |
| `validateDscp(int)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<int> validateDscp(int)` | `/// Realises: [Feat-023/Dscp]` |
| `validateIpv4UnicastAddress(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<String> validateIpv4UnicastAddress(String)` | `/// Realises: [Feat-023/Ipv4UnicastAddress]` |
| `validateIpv6UnicastAddress(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<String> validateIpv6UnicastAddress(String)` | `/// Realises: [Feat-023/Ipv6UnicastAddress]` |
| `validateIpv4MulticastAddress(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<String> validateIpv4MulticastAddress(String)` | `/// Realises: [Feat-023/Ipv4MulticastAddress]` |
| `validateIpv6MulticastAddress(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<String> validateIpv6MulticastAddress(String)` | `/// Realises: [Feat-023/Ipv6MulticastAddress]` |
| `validateScopeType(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<IpScopeType> validateScopeType(String)` | `/// Realises: [Feat-023/IpScopeType]` |
| `classifyIpAddress(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `String classifyIpAddress(String)` | `/// Realises: [Feat-023/IpAddressClassification]` |
| `getMulticastScope(String)` | `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` | `Result<IpScopeType> getMulticastScope(String)` | `/// Realises: [Feat-023/IpScopeType]` |
| `ERR_IPV6_FLOW_LABEL_OUT_OF_BOUNDS` | `app_flutter/lib/domain/domain_errors.dart` | `final class IpFlowLabelOutOfBoundsError` | `/// Realises: [Feat-023/IpFlowLabel]` |
| `ERR_DSCP_OUT_OF_BOUNDS` | `app_flutter/lib/domain/domain_errors.dart` | `final class DscpOutOfBoundsError` | `/// Realises: [Feat-023/Dscp]` |
| `ERR_INVALID_UNICAST_ADDRESS` | `app_flutter/lib/domain/domain_errors.dart` | `final class InvalidUnicastAddressError` | `/// Realises: [Feat-023/IpUnicastAddress]` |
| `ERR_INVALID_MULTICAST_ADDRESS` | `app_flutter/lib/domain/domain_errors.dart` | `final class InvalidMulticastAddressError` | `/// Realises: [Feat-023/IpMulticastAddress]` |
| `ERR_UNRESOLVABLE_SCOPE_TYPE` | `app_flutter/lib/domain/domain_errors.dart` | `final class UnresolvableScopeTypeError` | `/// Realises: [Feat-023/IpScopeType]` |
| Repository Contract | `app_flutter/lib/domain/repositories/ip_unicast_multicast_and_scope_repository.dart` | `abstract class IpUnicastMulticastAndScopeRepository` | `/// Realises: [Feat-023/IpUnicastMulticastAndScopeRepository]` |
| SQLite Repository | `app_flutter/lib/data/repositories/sqlite_ip_unicast_multicast_and_scope_repository.dart` | `class SqliteIpUnicastMulticastAndScopeRepository` | `/// Realises: [Feat-023/SqliteIpUnicastMulticastAndScopeRepository]` |
| ViewModel | `app_flutter/lib/presentation/viewmodels/ip_unicast_multicast_and_scope_viewmodel.dart` | `class IpUnicastMulticastAndScopeViewModel` | `/// Realises: [Feat-023/IpUnicastMulticastAndScopeViewModel]` |
| LUI Property Widget | `app_flutter/lib/presentation/widgets/ip_unicast_multicast_and_scope_property_widget.dart` | `class IpUnicastMulticastAndScopePropertyWidget` | `/// Realises: [Feat-023/IpUnicastMulticastAndScopePropertyWidget]` |

## Layer 1: Domain Model

### Files Created/Modified
- **Created:** `app_flutter/lib/domain/models/ip_unicast_multicast_and_scope_types.dart` — `enum IpScopeType`, `ipScopeTypeCode()`, `isGlobalScope()`, `@immutable class IpUnicastMulticastAndScopeTypes` (10 fields), 8 validation/classification functions
- **Modified:** `app_flutter/lib/domain/domain_errors.dart` — 5 new domain error subclasses

### Key Design Decisions
1. **Scope types** implemented as an `enum` with a standalone `ipScopeTypeCode()` function mapping to YANG-defined scope codes (1, 2, 4, 5, 8, 14).
2. **IPv4/IPv6 validation** reuses the private validation helpers (`_isValidIpv4DottedQuad`, `_isValidIpv6`) which implement the same logic as RFC 6021's dotted-quad and colon-hex patterns.
3. **Multicast detection** uses first-octet range check for IPv4 (224–239) and prefix detection for IPv6 (ff00::/8).
4. **Scope extraction** from IPv6 multicast addresses parses the 3rd-4th hex digits containing the 4-bit scope field.
5. All validation functions return `Result<T>` per the Flutter profile domain engineering standard #1.

### Tests
- `test/domain/ip_unicast_multicast_and_scope_types_test.dart` — 58 tests covering:
  - IpScopeType enum (1)
  - ipScopeTypeCode (6)
  - isGlobalScope (2)
  - IpUnicastMulticastAndScopeTypes value object (4)
  - validateIpv6FlowLabel (5)
  - validateDscp (5)
  - validateIpv4UnicastAddress (5)
  - validateIpv6UnicastAddress (5)
  - validateIpv4MulticastAddress (4)
  - validateIpv6MulticastAddress (4)
  - validateScopeType (7)
  - classifyIpAddress (5)
  - getMulticastScope (5)

## Layer 2: ViewModel + Persistence

### Files Created
- `app_flutter/lib/domain/repositories/ip_unicast_multicast_and_scope_repository.dart` — abstract repository contract (4 methods)
- `app_flutter/lib/data/repositories/sqlite_ip_unicast_multicast_and_scope_repository.dart` — 11-column SQLite table, live `sqflite_common_ffi` persistence
- `app_flutter/lib/presentation/viewmodels/ip_unicast_multicast_and_scope_viewmodel.dart` — `ChangeNotifier` with `_disposed` guard, `load`/`save`/`update`

### SQLite Schema
```sql
CREATE TABLE IF NOT EXISTS ip_unscp_multicast_records (
  id TEXT PRIMARY KEY,
  container_id TEXT,
  ipv6_flow_label INTEGER,
  dscp INTEGER,
  ip_unicast_address TEXT,
  ipv4_unicast_address TEXT,
  ipv6_unicast_address TEXT,
  ip_multicast_address TEXT,
  ipv4_multicast_address TEXT,
  ipv6_multicast_address TEXT,
  scope_type TEXT
)
```

### Zero-Mocking Persistence (constitution §1.9)
The SQLite repository tests use `sqflite_common_ffi` with `databaseFactoryFfi` and `inMemoryDatabasePath` for live, persistent storage validation. No in-memory stubs or mocks are used in database-layer tests.

### Tests
- `test/data/sqlite_ip_unicast_multicast_and_scope_repository_test.dart` — 5 integration tests (persisting, fetching, updating, default IDs, null roundtrips)
- `test/presentation/ip_unicast_multicast_and_scope_viewmodel_test.dart` — 6 unit tests (loading state, success, error, save, update, error recovery)

## Layer 3: LUI Widget Binding + BDD Acceptance Test

### Files Created
- `app_flutter/lib/presentation/widgets/ip_unicast_multicast_and_scope_property_widget.dart` — `StatelessWidget` bound to ViewModel via `ListenableBuilder`

### Zero-Codegen Parameter Isolation
The widget drives all 10 fields at runtime via `TypeDescriptor`/`FieldDescriptor` schema. No domain attributes are hardcoded in `build()` — the `_formatValue()` mapping uses a switch on `field.key` matching the pattern established by prior features.

### Layout Binding
- **Target Container:** `properties_view`
- **Data Source Binding:** `/ietf-inet-types:ip-multicast-scope`
- **Header Text:** `PropertyGrid (/ietf-inet-types:ip-multicast-scope)`

### BDD Widget Tests (5 scenarios)
- `test/presentation/ip_unicast_multicast_and_scope_property_widget_test.dart`:
  - SCENARIO_1: Loading → `CircularProgressIndicator` rendered
  - SCENARIO_2: Error → `TextContaining('Record not found')` rendered
  - SCENARIO_3: Header → `PropertyGrid (/ietf-inet-types:ip-multicast-scope)` displayed
  - SCENARIO_4: Schema → All 10 `FieldDescriptor` labels rendered with correct values
  - SCENARIO_5: Save → `UserEvent → ViewModel Action → State Change → LUI Render` verified

## Verification Results

### flutter analyze
```
Analyzing app_flutter...
No issues found!
```

### flutter test
```
00:39 +900 ~1: All tests passed!
```

### flutter build macos --release
```
✓ Built build/macos/Build/Products/Release/Platform Console.app (100.5MB)
```

### verify_downstream_baseline.py
All 900 tests pass, zero regression.

## Manual Testing Instructions

1. **Build & run the macOS app:**
   ```bash
   cd app_flutter && flutter build macos --release
   open build/macos/Build/Products/Release/Platform\ Console.app
   ```

2. **Navigate to the properties panel:**
   - In the workspace layout, find the `properties_view` container (right panel).
   - The PropertyGrid should display the header `PropertyGrid (/ietf-inet-types:ip-multicast-scope)`.

3. **Verify field rendering:**
   - Confirm all 10 fields are visible: Container ID, IPv6 Flow Label, DSCP, IP Unicast Address, IPv4 Unicast Address, IPv6 Unicast Address, IP Multicast Address, IPv4 Multicast Address, IPv6 Multicast Address, Scope Type.
   - Each field displays as a card with label on the left and value on the right.

4. **Verify error state:**
   - If a record fails to load, a red-shaded error container with the error message should be displayed.
   - If loading, a `CircularProgressIndicator` should be shown.

5. **Run domain validation tests in isolation:**
   ```bash
   cd app_flutter && flutter test test/domain/ip_unicast_multicast_and_scope_types_test.dart
   ```
   - Confirm 58 tests pass covering all validation boundary conditions.

6. **Run SQLite persistence tests:**
   ```bash
   cd app_flutter && flutter test test/data/sqlite_ip_unicast_multicast_and_scope_repository_test.dart
   ```
   - Confirm save/fetch/update roundtrips work against a live SQLite database.

7. **Check the exhaustive error-type switch:**
   ```bash
   cd app_flutter && flutter test test/domain/domain_errors_test.dart
   ```
   - Confirm all error types including the 5 new ones (IpFlowLabelOutOfBoundsError, DscpOutOfBoundsError, InvalidUnicastAddressError, InvalidMulticastAddressError, UnresolvableScopeTypeError) are exhaustively matched.

## Spec Compliance Gate

| Spec Requirement | Realised In | Status |
|---|---|---|
| ipv6-flow-label: uint32 0..1048575 | `validateIpv6FlowLabel(int)` | PASS |
| dscp: uint8 0..63 | `validateDscp(int)` | PASS |
| ip-unicast-address: must not be multicast | `validateIpv4UnicastAddress`, `validateIpv6UnicastAddress` | PASS |
| ipv4-unicast-address: excludes 224/4 | `validateIpv4UnicastAddress` | PASS |
| ipv6-unicast-address: excludes ff00::/8 | `validateIpv6UnicastAddress` | PASS |
| ip-multicast-address: must be multicast | `validateIpv4MulticastAddress`, `validateIpv6MulticastAddress` | PASS |
| ipv4-multicast-address: 224.0.0.0/4 | `validateIpv4MulticastAddress` | PASS |
| ipv6-multicast-address: ff00::/8 | `validateIpv6MulticastAddress` | PASS |
| scope-type: 6 enum values | `validateScopeType`, `enum IpScopeType` | PASS |
| classifyIpAddress: version + mode | `classifyIpAddress` | PASS |
| getMulticastScope: 4-bit scope field | `getMulticastScope` | PASS |
| ERR_IPV6_FLOW_LABEL_OUT_OF_BOUNDS | `IpFlowLabelOutOfBoundsError` | PASS |
| ERR_DSCP_OUT_OF_BOUNDS | `DscpOutOfBoundsError` | PASS |
| ERR_INVALID_UNICAST_ADDRESS | `InvalidUnicastAddressError` | PASS |
| ERR_INVALID_MULTICAST_ADDRESS | `InvalidMulticastAddressError` | PASS |
| ERR_UNRESOLVABLE_SCOPE_TYPE | `UnresolvableScopeTypeError` | PASS |
| Zero-Mocking Persistence (§1.9) | `SqliteIpUnicastMulticastAndScopeRepository` using `sqflite_common_ffi` | PASS |
| UI driven by TypeDescriptor schemas | `IpUnicastMulticastAndScopePropertyWidget._typeDescriptor` | PASS |
| Header: PropertyGrid (/ietf-inet-types:ip-multicast-scope) | Widget `_headerText` constant | PASS |
