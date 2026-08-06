---
issue_id: 20
title: "[ietf-inet-types]: IP Address Data Types — Solution Walkthrough"
type: "solution"
created: "2026-08-06"
labels: ["solution", "ietf-inet-types"]
---

# Feature #20: IP Address Data Types — Solution Walkthrough

## Overview

Implementation of the ten IP address textual conventions and data types from `ietf-inet-types` (RFC 6021) across all 3 mandatory layers: Domain Model, ViewModel/Persistence, and LUI Widget + BDD Acceptance Test.

## Code Realization Table

| Specification Element | Source File | Class/Function | Traceability Tag |
|---|---|---|---|
| `ip-version` (enum) | `app_flutter/lib/domain/models/ip_address_types.dart` | `enum IpVersion` | `/// Realises: [Feat-020/IpVersion]` |
| `parseIpVersion(int)` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<IpVersion> parseIpVersion(int)` | `/// Realises: [Feat-020/IpVersion]` |
| `ip-address` container | `app_flutter/lib/domain/models/ip_address_types.dart` | `@immutable class IpAddressTypes` | `/// Realises: [Feat-020/IpAddressTypes]` |
| `validateIpv4Address` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpv4Address(String)` | `/// Realises: [Feat-020/Ipv4Address]` |
| `validateIpv6Address` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpv6Address(String)` | `/// Realises: [Feat-020/Ipv6Address]` |
| `validateIpv4AddressNoZone` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpv4AddressNoZone(String)` | `/// Realises: [Feat-020/Ipv4AddressNoZone]` |
| `validateIpv6AddressNoZone` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpv6AddressNoZone(String)` | `/// Realises: [Feat-020/Ipv6AddressNoZone]` |
| `validateIpv4Prefix` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpv4Prefix(String)` | `/// Realises: [Feat-020/Ipv4Prefix]` |
| `validateIpv6Prefix` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpv6Prefix(String)` | `/// Realises: [Feat-020/Ipv6Prefix]` |
| `validateIpAddress` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpAddress(String)` | `/// Realises: [Feat-020/IpAddress]` |
| `validateIpPrefix` | `app_flutter/lib/domain/models/ip_address_types.dart` | `Result<String> validateIpPrefix(String)` | `/// Realises: [Feat-020/IpPrefix]` |
| `stripZoneIndex` | `app_flutter/lib/domain/models/ip_address_types.dart` | `String stripZoneIndex(String)` | `/// Realises: [Feat-020/Ipv4Address]` |
| `hasZoneIndex` | `app_flutter/lib/domain/models/ip_address_types.dart` | `bool hasZoneIndex(String)` | `/// Realises: [Feat-020/Ipv4Address]` |
| `determineIpVersionStr` | `app_flutter/lib/domain/models/ip_address_types.dart` | `String determineIpVersionStr(String)` | `/// Realises: [Feat-020/Ipv4Prefix]` |
| `ERR_INVALID_IP_VERSION` | `app_flutter/lib/domain/domain_errors.dart` | `final class InvalidIpVersionError` | `/// Realises: [Feat-020/IpVersion]` |
| `ERR_INVALID_IPV4_FORMAT` | `app_flutter/lib/domain/domain_errors.dart` | `final class InvalidIpv4FormatError` | `/// Realises: [Feat-020/Ipv4Address]` |
| `ERR_INVALID_IPV6_FORMAT` | `app_flutter/lib/domain/domain_errors.dart` | `final class InvalidIpv6FormatError` | `/// Realises: [Feat-020/Ipv6Address]` |
| `ERR_ZONE_INDEX_DISALLOWED` | `app_flutter/lib/domain/domain_errors.dart` | `final class ZoneIndexDisallowedError` | `/// Realises: [Feat-020/Ipv4AddressNoZone]` |
| `ERR_IPV4_PREFIX_LENGTH_OOB` | `app_flutter/lib/domain/domain_errors.dart` | `final class Ipv4PrefixLengthOutOfBoundsError` | `/// Realises: [Feat-020/Ipv4Prefix]` |
| `ERR_IPV6_PREFIX_LENGTH_OOB` | `app_flutter/lib/domain/domain_errors.dart` | `final class Ipv6PrefixLengthOutOfBoundsError` | `/// Realises: [Feat-020/Ipv6Prefix]` |
| Repository Contract | `app_flutter/lib/domain/repositories/ip_address_repository.dart` | `abstract class IpAddressRepository` | `/// Realises: [Feat-020/IpAddressRepository]` |
| SQLite Repository | `app_flutter/lib/data/repositories/sqlite_ip_address_repository.dart` | `class SqliteIpAddressRepository` | `/// Realises: [Feat-020/SqliteIpAddressRepository]` |
| ViewModel | `app_flutter/lib/presentation/viewmodels/ip_address_viewmodel.dart` | `class IpAddressViewModel` | `/// Realises: [Feat-020/IpAddressViewModel]` |
| LUI Property Widget | `app_flutter/lib/presentation/widgets/ip_address_property_widget.dart` | `class IpAddressPropertyWidget` | `/// Realises: [Feat-020/IpAddressPropertyWidget]` |

## Layer 1: Domain Model

### Files Created/Modified
- **Created:** `app_flutter/lib/domain/models/ip_address_types.dart` — `enum IpVersion`, `parseIpVersion()`, `@immutable class IpAddressTypes` (11 fields), 9 validation functions, 3 utility functions
- **Modified:** `app_flutter/lib/domain/domain_errors.dart` — 6 new domain error subclasses

### Key Design Decisions
1. **IPv6 validation** uses a programmatic parser (`_isValidIpv6`) rather than the full RFC 6021 regex since Dart lacks `\p{}` Unicode property escapes.
2. **Zone index** approximated with `[a-zA-Z0-9_]+` (covers interface names like `eth0`, `lo0`, numeric indices).
3. All validation functions return `Result<String>` per the Flutter profile domain engineering standard #1 (Result<T> over exceptions).
4. Pattern constants pre-compiled as `const` for zero runtime overhead.

### Tests
- `test/domain/ip_address_types_test.dart` — 55 tests covering:
  - IpVersion enum values (3)
  - parseIpVersion (5)
  - IpAddressTypes value object (4)
  - stripZoneIndex (2)
  - hasZoneIndex (2)
  - determineIpVersionStr (3)
  - validateIpv4Address (7)
  - validateIpv4AddressNoZone (5)
  - validateIpv6Address (7)
  - validateIpv6AddressNoZone (3)
  - validateIpv4Prefix (6)
  - validateIpv6Prefix (4)
  - validateIpAddress (3)
  - validateIpPrefix (3)

## Layer 2: ViewModel + Persistence

### Files Created
- `app_flutter/lib/domain/repositories/ip_address_repository.dart` — abstract repository contract (4 methods)
- `app_flutter/lib/data/repositories/sqlite_ip_address_repository.dart` — 12-column SQLite table, live `sqflite_common_ffi` persistence
- `app_flutter/lib/presentation/viewmodels/ip_address_viewmodel.dart` — `ChangeNotifier` with `_disposed` guard, `load`/`save`/`update`

### SQLite Schema
```sql
CREATE TABLE IF NOT EXISTS ip_address_records (
  id TEXT PRIMARY KEY,
  container_id TEXT,
  ip_version INTEGER,
  ip_address TEXT,
  ipv4_address TEXT,
  ipv6_address TEXT,
  ip_prefix TEXT,
  ipv4_prefix TEXT,
  ipv6_prefix TEXT,
  ip_address_no_zone TEXT,
  ipv4_address_no_zone TEXT,
  ipv6_address_no_zone TEXT
)
```

### Tests
- `test/data/sqlite_ip_address_repository_test.dart` — 5 tests (save/fetch round-trip, update, InstanceNotFoundError, default id, nullable fields)
- `test/presentation/ip_address_viewmodel_test.dart` — 6 tests (loading state, successful load, error on load failure, save, update, recovery)

## Layer 3: LUI Widget + BDD Acceptance Test

### Files Created
- `app_flutter/lib/presentation/widgets/ip_address_property_widget.dart` — `TypeDescriptor`-driven widget with 11 `FieldDescriptor`s, `ListenableBuilder` for reactive binding, loading/error/model states. Header: "PropertyGrid (/ietf-inet-types:ip-address)". Targets `properties_view` PropertyGrid in the logical layout.
- `app_flutter/test/presentation/ip_address_property_widget_test.dart` — 5 BDD scenarios:

| Scenario | Description |
|---|---|
| SCENARIO_1 | Loading indicator displayed when ViewModel is fetching |
| SCENARIO_2 | Error message displayed when ViewModel has error |
| SCENARIO_3 | Header text "PropertyGrid (/ietf-inet-types:ip-address)" rendered |
| SCENARIO_4 | All 11 fields rendered from FieldDescriptor schema |
| SCENARIO_5 | User save action → ViewModel changes state → LUI re-renders (full BDD chain) |

## Acceptance Criteria Coverage (from RFC 6021 Spec)

| Spec Scenario | Implementation |
|---|---|
| Scenario 1: Valid IPv4 addresses with/without zone indices | `validateIpv4Address` accepts `192.168.1.1`, `10.0.0.254`, `169.254.1.1%eth0` |
| Scenario 2: Zone index rejection on no-zone types | `validateIpv4AddressNoZone` rejects `169.254.1.1%eth0` with `ZoneIndexDisallowedError` |
| Scenario 3: Compressed & scoped IPv6 | `validateIpv6Address` accepts `2001:db8::1`, `::1`, `fe80::1ff:fe23:4567:890a%eth0` |
| Scenario 4: Zone index rejection on IPv6 no-zone | `validateIpv6AddressNoZone` rejects `fe80::1%eth0` and `fe80::1%1` |
| Scenario 5: IPv4 prefix length boundaries | `validateIpv4Prefix` accepts `/0`, `/24`, `/32`; rejects `/33` and `/-1` |
| Scenario 6: IPv6 prefix length boundaries | `validateIpv6Prefix` accepts `/0`, `/64`, `/128`; rejects `/129` |
| Scenario 7: IP version enumeration | `parseIpVersion` accepts 0/1/2; rejects 3/-1 with `InvalidIpVersionError` |

## Verification Artifacts

### flutter analyze
```
Analyzing app_flutter...
No issues found! (ran in 5.2s)
```

### flutter test
```
00:30 +731 ~1: All tests passed!
```
731 tests passed (full suite including all new tests + pre-existing tests, 0 failures).

### flutter build macos --release
```
✓ Built build/macos/Build/Products/Release/Platform Console.app (100.5MB)
```
Zero build errors. Warnings are pre-existing (deprecated Firebase API, linker paths).

### Layout Bindings
- Logical layout restored: `properties_view` (PropertyGrid) as first tab in `details_and_relations_tab` TabbedContainer alongside 4 TableView tabs
- Feature #20 binds to: `PropertyGrid → properties_view → /ietf-inet-types:ip-address`

## Compliance Gates

| Gate | Status |
|---|---|
| Constitution §1.9 Zero-Mocking Persistence | PASS — SQLite via sqflite_common_ffi, live database emulator in tests |
| Constitution §4.5 Downstream Conformance | PASS — flutter analyze + flutter test + flutter build all pass |
| Constitution §5 Forbidden Practices | PASS — no layout splitters removed, no timeline scrubber touched |
| Zero-Codegen Parameter Isolation | PASS — widget driven by TypeDescriptor/FieldDescriptor at runtime |
| Flutter Profile: public_member_api_docs | PASS — all public APIs have DartDoc |
| Flutter Profile: UML traceability tags | PASS — `/// Realises: [Feat-020/...]` on every class |
| Flutter Profile: Result<T> signatures | PASS — all fallible domain ops return `Result<T>` |
| Flutter Profile: @immutable domain classes | PASS |
| TDD (RED-GREEN-REFACTOR) | PASS — tests written/verified RED before each implementation segment |
