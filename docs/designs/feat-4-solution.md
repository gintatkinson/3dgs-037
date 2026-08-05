---
title: "Feature #4 Solution — Address and String Data Types"
issue_id: 4
feature: "[ietf-yang-types]: Address and String Data Types"
status: fixed-resolved
created: "2026-08-06"
spec_source: "RFC 9911 — ietf-yang-types"
---

# Feature #4 Solution: Address and String Data Types

## Summary

Implements the 6 RFC 9911 typedefs for address and string data types across all 3 architectural layers (Domain Model, ViewModel + Persistence, LUI Widget + BDD Acceptance Test).

## Code Realization Table

| Layer | Specification Item | Source File | Class/Function |
|-------|-------------------|-------------|----------------|
| Layer 1 — Domain | `AddressAndStringTypes` value object | `app_flutter/lib/domain/models/address_and_string_types.dart` | `@immutable class AddressAndStringTypes` |
| Layer 1 — Domain | `validatePhysAddress` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<String> validatePhysAddress(String)` |
| Layer 1 — Domain | `validateMacAddress` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<String> validateMacAddress(String)` |
| Layer 1 — Domain | `validateHexString` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<String> validateHexString(String)` |
| Layer 1 — Domain | `validateDottedQuad` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<String> validateDottedQuad(String)` |
| Layer 1 — Domain | `validateLanguageTag` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<String> validateLanguageTag(String)` |
| Layer 1 — Domain | `validateXpath10` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<String> validateXpath10(String)` |
| Layer 1 — Domain | `canonicalizePhysAddress` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static String canonicalizePhysAddress(String)` |
| Layer 1 — Domain | `canonicalizeMacAddress` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static String canonicalizeMacAddress(String)` |
| Layer 1 — Domain | `canonicalizeHexString` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static String canonicalizeHexString(String)` |
| Layer 1 — Domain | `canonicalizeLanguageTag` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static String canonicalizeLanguageTag(String)` |
| Layer 1 — Domain | `parseDottedQuadToUint32` | `app_flutter/lib/domain/models/address_and_string_types.dart` | `static Result<int> parseDottedQuadToUint32(String)` |
| Layer 2 — Repository | Abstract repository contract | `app_flutter/lib/domain/repositories/address_and_string_repository.dart` | `abstract class AddressAndStringRepository` |
| Layer 2 — Persistence | SQLite concrete adapter | `app_flutter/lib/data/repositories/sqlite_address_and_string_repository.dart` | `class SqliteAddressAndStringRepository implements AddressAndStringRepository` |
| Layer 2 — ViewModel | State holder | `app_flutter/lib/presentation/viewmodels/address_and_string_viewmodel.dart` | `class AddressAndStringViewModel extends ChangeNotifier` |
| Layer 3 — Widget | LUI property widget | `app_flutter/lib/presentation/widgets/address_and_string_property_widget.dart` | `class AddressAndStringPropertyWidget extends StatelessWidget` |
| Layer 3 — BDD Test | 5 BDD widget scenarios | `app_flutter/test/presentation/address_and_string_property_widget_test.dart` | 5 `testWidgets` |

## RFC 9911 Typedefs Implemented

1. **phys-address** — variable-length colon-separated hex octets, pattern: `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?`
2. **mac-address** — exactly 6 colon-separated hex octets, pattern: `[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}`
3. **hex-string** — arbitrary hex octet sequence, pattern: `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?`
4. **dotted-quad** — four decimal octets (0-255) separated by dots
5. **language-tag** — BCP 47 language tag, pattern: `[a-zA-Z]{2,8}(-[a-zA-Z0-9]{1,8})*`
6. **xpath1.0** — XPath 1.0 expression string, non-empty, starts with `/`, `(`, `.`, or `@`

## TDD Execution Summary

| Micro-Task | RED Phase | GREEN Phase | Test Count |
|------------|-----------|-------------|------------|
| Domain model + validators | Compile error (class missing) | 65 tests pass | 65 |
| SQLite repository | Compile error | 6 tests pass | 6 |
| ViewModel | Compile error | 7 tests pass | 7 |
| LUI Widget + BDD | Compile error | 5 tests pass | 5 |

## Verification Results

- **flutter test**: 660 passed, 1 skipped (zero regressions)
- **flutter analyze**: No issues found
- **flutter build macos --release**: Built successfully (100.5MB)
- **verify_downstream_baseline.py**: Passed for both Flutter and React platforms

## BDD Acceptance Criteria Coverage

| Scenario | Status |
|----------|--------|
| Valid MAC Address Validation and Canonicalization | Covered in domain test `validateMacAddress` + `canonicalizeMacAddress` |
| Invalid MAC Address Rejection (5 octets) | Covered in domain test `should fail for only 5 octets` |
| Valid Physical Address Variable Octet Sequence | Covered in domain test `should succeed for valid variable-length octet sequence` |
| Valid Dotted-Quad Decimal Parsing (192.0.2.1 → 3221225985) | Covered in `parseDottedQuadToUint32 should parse 192.0.2.1 to 3221225985` |
| Out-of-Bounds Dotted-Quad Rejection (256.0.0.1) | Covered in `validateDottedQuad should fail for octet > 255` |
| Valid Language Tag Lowercasing (en-US → en-us) | Covered in `canonicalizeLanguageTag should lowercase mixed-case tag` |
| Valid XPath 1.0 Expression Evaluation | Covered in `validateXpath10 should succeed for absolute path` |
