import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Field key constant for the physical/media address.
const String kFieldPhysAddress = 'physAddress';
/// Field key constant for the IEEE 802 48-bit MAC address.
const String kFieldMacAddress = 'macAddress';
/// Field key constant for the hexadecimal string.
const String kFieldHexString = 'hexString';
/// Field key constant for the dotted-quad decimal notation.
const String kFieldDottedQuad = 'dottedQuad';
/// Field key constant for the BCP 47 language tag.
const String kFieldLanguageTag = 'languageTag';
/// Field key constant for the XPath 1.0 expression string.
const String kFieldXpath10 = 'xpath10';

/// Realises: [Feat-004/AddressAndStringTypes]
///
/// Domain model representing the six address and string typedefs
/// defined in ietf-yang-types (RFC 9911):
/// phys-address, mac-address, hex-string, dotted-quad, language-tag, xpath1.0.
///
/// All six fields are nullable strings representing the typed values.
/// Validation and canonicalization methods are provided as static functions
/// that operate independently of any instance state.
@immutable
class AddressAndStringTypes {
  /// Identifier linking this record to its parent container in the data store.
  final String containerId;

/// Variable-length physical/media address (colon-separated hex octets).
/// Pattern: `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?`. May be empty.
final String physAddress;

/// IEEE 802 48-bit MAC address — exactly 6 colon-separated hex octets.
/// Pattern: `[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}`.
final String macAddress;

/// Arbitrary hexadecimal string as colon-separated hex digit pairs.
/// Pattern: `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?`. May be empty.
final String hexString;

/// Unsigned 32-bit integer in dotted-quad decimal notation.
/// Pattern: `((0-255)\.){3}(0-255)` — four octets, each 0 to 255.
final String dottedQuad;

/// BCP 47 language tag, e.g. `en-US`. Canonical form uses lowercase.
final String languageTag;

/// XPath 1.0 expression string. Must be non-empty, starting with `/`, `(`, `.`, or `@`.
/// Note: This is a basic validation for starting characters, not a full XPath 1.0 parser.
final String xpath10;

/// Creates a new [AddressAndStringTypes] instance with all seven fields.
const AddressAndStringTypes({
  required this.containerId,
  required this.physAddress,
  required this.macAddress,
  required this.hexString,
  required this.dottedQuad,
  required this.languageTag,
  required this.xpath10,
});

static final RegExp _physAddressPattern =
    RegExp(r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$');

static final RegExp _macAddressPattern =
    RegExp(r'^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$');

static final RegExp _hexStringPattern =
    RegExp(r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$');

static final RegExp _dottedQuadPattern = RegExp(
  r'^(([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}'
  r'([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$',
);

static final RegExp _languageTagPattern =
    RegExp(r'^[a-zA-Z]{2,8}(-[a-zA-Z0-9]{1,8})*$');

/// Validates a [physAddress] string.
///
/// Returns [Success] with the original string if it matches the pattern
/// `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?`. The string may be empty.
/// Returns [Failure] with [SchemaFieldPatternError] on invalid format.
static Result<String> validatePhysAddress(String value) {
  if (!_physAddressPattern.hasMatch(value)) {
    return Result.failure(
      SchemaFieldPatternError(
        fieldName: 'physAddress',
        value: value,
        pattern: _physAddressPattern.pattern,
      ),
    );
  }
  return Result.success(value);
}

/// Validates a [macAddress] string.
///
/// Returns [Success] if the value matches exactly 6 colon-separated
/// hex octets. Returns [Failure] with [SchemaFieldPatternError] on
/// invalid format (wrong octet count or invalid characters).
static Result<String> validateMacAddress(String value) {
  if (!_macAddressPattern.hasMatch(value)) {
    return Result.failure(
      SchemaFieldPatternError(
        fieldName: 'macAddress',
        value: value,
        pattern: _macAddressPattern.pattern,
      ),
    );
  }
  return Result.success(value);
}

/// Validates a [hexString] value.
///
/// Returns [Success] if the value matches the pattern
/// `([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?`. May be empty.
/// Returns [Failure] with [SchemaFieldPatternError] on invalid format.
static Result<String> validateHexString(String value) {
  if (!_hexStringPattern.hasMatch(value)) {
    return Result.failure(
      SchemaFieldPatternError(
        fieldName: 'hexString',
        value: value,
        pattern: _hexStringPattern.pattern,
      ),
    );
  }
  return Result.success(value);
}

/// Validates a [dottedQuad] string.
///
/// Returns [Success] if the value matches four decimal octets (0-255)
/// separated by full stops. Returns [Failure] with
/// [SchemaFieldRangeError] if any octet exceeds 255, or
/// [SchemaFieldPatternError] if the format is malformed.
static Result<String> validateDottedQuad(String value) {
  if (!_dottedQuadPattern.hasMatch(value)) {
    final octets = value.split('.');
    for (final octet in octets) {
      final parsed = int.tryParse(octet);
      if (parsed != null && (parsed < 0 || parsed > 255)) {
        return Result.failure(
          SchemaFieldRangeError(
            fieldName: 'dottedQuad',
            value: value,
            min: 0,
            max: 255,
          ),
        );
      }
    }
    return Result.failure(
      SchemaFieldPatternError(
        fieldName: 'dottedQuad',
        value: value,
        pattern: _dottedQuadPattern.pattern,
      ),
    );
  }
  return Result.success(value);
}

/// Validates a [languageTag] string against BCP 47 structural rules.
///
/// Pattern: `[a-zA-Z]{2,8}(-[a-zA-Z0-9]{1,8})*`.
/// Returns [Success] on well-formed tags or [Failure] with
/// [SchemaFieldPatternError] otherwise.
static Result<String> validateLanguageTag(String value) {
  if (!_languageTagPattern.hasMatch(value)) {
    return Result.failure(
      SchemaFieldPatternError(
        fieldName: 'languageTag',
        value: value,
        pattern: _languageTagPattern.pattern,
      ),
    );
  }
  return Result.success(value);
}

/// Validates an [xpath10] expression string.
///
/// Must be non-empty and start with `/`, `(`, `.`, or `@`.
/// Returns [Success] on valid XPath 1.0 syntax or [Failure] with
/// [SchemaFieldPatternError] otherwise.
static Result<String> validateXpath10(String value) {
  if (value.isEmpty ||
      (!value.startsWith('/') &&
          !value.startsWith('(') &&
          !value.startsWith('.') &&
          !value.startsWith('@'))) {
    return Result.failure(
      SchemaFieldPatternError(
        fieldName: 'xpath10',
        value: value,
        pattern: r'^[/\(.@]',
      ),
    );
  }
  return Result.success(value);
}

  /// Canonicalises a [physAddress] string by lowercasing all characters.
  ///
  /// Per RFC 9911: the canonical representation uses lowercase characters.
  static String canonicalizePhysAddress(String value) => value.toLowerCase();

  /// Canonicalises a [macAddress] string by lowercasing all characters.
  ///
  /// Per RFC 9911: the canonical representation uses lowercase characters.
  /// Upper-case characters MUST be lowercased during processing.
  static String canonicalizeMacAddress(String value) => value.toLowerCase();

  /// Canonicalises a [hexString] value by lowercasing all characters.
  ///
  /// Per RFC 9911: the canonical representation uses lowercase characters.
  static String canonicalizeHexString(String value) => value.toLowerCase();

  /// Canonicalises a [languageTag] string by lowercasing all characters.
  ///
  /// Per RFC 9911 / BCP 47: the canonical representation uses lowercase.
  static String canonicalizeLanguageTag(String value) => value.toLowerCase();

  /// Parses a [dottedQuad] decimal string into an unsigned 32-bit integer.
  ///
  /// Returns [Success<int>] with the uint32 value on success, or
  /// [Failure<int>] with [SchemaFieldRangeError] if any octet exceeds 255,
  /// or [SchemaFieldPatternError] on invalid format.
  static Result<int> parseDottedQuadToUint32(String value) {
    final validation = validateDottedQuad(value);
    if (validation.isFailure) {
      return Result.failure((validation as Failure<String>).error);
    }

    final octets = value.split('.').map(int.parse).toList();
    // Cast is safe because validation already confirmed exactly 4 octets in range.
    final result = (octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3];
    return Result.success(result);
  }

  /// Creates a copy of this [AddressAndStringTypes] with the given fields replaced.
  AddressAndStringTypes copyWith({
    String? containerId,
    String? physAddress,
    String? macAddress,
    String? hexString,
    String? dottedQuad,
    String? languageTag,
    String? xpath10,
  }) {
    return AddressAndStringTypes(
      containerId: containerId ?? this.containerId,
      physAddress: physAddress ?? this.physAddress,
      macAddress: macAddress ?? this.macAddress,
      hexString: hexString ?? this.hexString,
      dottedQuad: dottedQuad ?? this.dottedQuad,
      languageTag: languageTag ?? this.languageTag,
      xpath10: xpath10 ?? this.xpath10,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressAndStringTypes &&
        other.containerId == containerId &&
        other.physAddress == physAddress &&
        other.macAddress == macAddress &&
        other.hexString == hexString &&
        other.dottedQuad == dottedQuad &&
        other.languageTag == languageTag &&
        other.xpath10 == xpath10;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        physAddress,
        macAddress,
        hexString,
        dottedQuad,
        languageTag,
        xpath10,
      );
}
