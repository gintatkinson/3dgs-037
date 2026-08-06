import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Field key constant for the container identifier.
const String kFieldContainerId = 'containerId';
/// Field key constant for the ASN.1 object identifier.
const String kFieldObjectIdentifier = 'objectIdentifier';
/// Field key constant for the ASN.1 object identifier with at most 128 sub-identifiers.
const String kFieldObjectIdentifier128 = 'objectIdentifier128';
/// Field key constant for the RFC 9562 UUID.
const String kFieldUuid = 'uuid';
/// Field key constant for the RFC 7950 YANG identifier.
const String kFieldYangIdentifier = 'yangIdentifier';

/// Realises: [Feat-002/IdentifierTypes]
///
/// Domain model representing the four identifier data types defined in
/// ietf-yang-types (RFC 9911): object-identifier, object-identifier-128,
/// uuid, and yang-identifier.
///
/// Provides validation functions per ASN.1 OID structural rules,
/// RFC 9562 UUID canonicalisation, and RFC 7950 YANG identifier syntax.
@immutable
class IdentifierTypes {
  /// Maximum value for a 32-bit unsigned sub-identifier (2^32 - 1).
  static const int kMaxUint32 = 4294967295;

  /// Maximum number of sub-identifiers for object-identifier-128 (SMIv2).
  static const int kMaxOid128SubIdentifiers = 128;

  /// The maximum allowed second sub-identifier when the first is 0 or 1.
  static const int kMaxSecondArcRoot01 = 39;

  /// UUID format pattern: 8-4-4-4-12 hex digits separated by hyphens.
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// YANG identifier pattern per RFC 7950 §14.
  static final RegExp _yangIdentifierPattern = RegExp(
    r'^[a-zA-Z_][a-zA-Z0-9\-_.]*$',
  );

  /// A string uniquely identifying the container.
  final String containerId;

  /// ASN.1 object identifier string.
  final String objectIdentifier;

  /// ASN.1 object identifier string with at most 128 sub-identifiers.
  final String objectIdentifier128;

  /// RFC 9562 UUID string.
  final String uuid;

  /// RFC 7950 YANG identifier string.
  final String yangIdentifier;

  /// Creates a new [IdentifierTypes] instance with all five fields.
  const IdentifierTypes({
    required this.containerId,
    required this.objectIdentifier,
    required this.objectIdentifier128,
    required this.uuid,
    required this.yangIdentifier,
  });

  /// Creates a copy of this [IdentifierTypes] with the given fields replaced.
  IdentifierTypes copyWith({
    String? containerId,
    String? objectIdentifier,
    String? objectIdentifier128,
    String? uuid,
    String? yangIdentifier,
  }) {
    return IdentifierTypes(
      containerId: containerId ?? this.containerId,
      objectIdentifier: objectIdentifier ?? this.objectIdentifier,
      objectIdentifier128: objectIdentifier128 ?? this.objectIdentifier128,
      uuid: uuid ?? this.uuid,
      yangIdentifier: yangIdentifier ?? this.yangIdentifier,
    );
  }

  /// Parses a dot-separated OID string into a list of sub-identifier integers.
  ///
  /// Returns [Result.success] with the integer list on success, or
  /// [Result.failure] with [SchemaFieldPatternError] on format errors
  /// or [SchemaFieldRangeError] on numeric range violations.
  static Result<List<int>> parseOidSubIdentifiers(String value) {
    if (value.isEmpty) {
      return Result.failure(SchemaFieldPatternError(
        fieldName: 'objectIdentifier',
        value: '',
        pattern: 'non-empty dot-separated sub-identifiers',
      ));
    }
    if (value.contains(RegExp(r'\s'))) {
      return Result.failure(SchemaFieldPatternError(
        fieldName: 'objectIdentifier',
        value: '',
        pattern: 'no whitespace',
      ));
    }
    final parts = value.split('.');
    if (parts.length < 2) {
      return Result.failure(SchemaFieldRangeError(
        fieldName: 'objectIdentifier',
        value: value,
        min: 2,
        max: null,
      ));
    }
    final subIds = <int>[];
    for (final part in parts) {
      if (part.isEmpty) {
        return Result.failure(SchemaFieldPatternError(
          fieldName: 'objectIdentifier',
          value: '',
          pattern: 'non-empty sub-identifier',
        ));
      }
      if (part.length > 1 && part.startsWith('0')) {
        return Result.failure(SchemaFieldPatternError(
          fieldName: 'objectIdentifier',
          value: '',
          pattern: 'no leading zeros',
        ));
      }
      final intValue = int.tryParse(part);
      if (intValue == null) {
        return Result.failure(SchemaFieldPatternError(
          fieldName: 'objectIdentifier',
          value: '',
          pattern: 'numeric sub-identifier',
        ));
      }
      if (intValue > kMaxUint32) {
        return Result.failure(SchemaFieldRangeError(
          fieldName: 'objectIdentifier',
          value: intValue,
          min: 0,
          max: kMaxUint32,
        ));
      }
      subIds.add(intValue);
    }
    return Result.success(subIds);
  }

  /// Validates an [object-identifier] value per ASN.1 structural rules.
  ///
  /// Checks: at least two sub-identifiers, first arc 0/1/2, second arc ≤39
  /// for root 0/1, each sub-identifier ≤2^32-1, no leading zeros,
  /// no whitespace.
  ///
  /// Returns [Result.success] with the value on success, or
  /// [Result.failure] on validation failure.
  static Result<String> validateObjectIdentifier(String value) {
    final parseResult = parseOidSubIdentifiers(value);
    if (parseResult.isFailure) return _castFailure(parseResult);
    final subIds = (parseResult as Success<List<int>>).value;
    if (subIds.first > 2) {
      return Result.failure(SchemaFieldRangeError(
        fieldName: 'objectIdentifier',
        value: subIds.first,
        min: 0,
        max: 2,
      ));
    }
    if ((subIds.first == 0 || subIds.first == 1) &&
        subIds[1] > kMaxSecondArcRoot01) {
      return Result.failure(SchemaFieldRangeError(
        fieldName: 'objectIdentifier',
        value: subIds[1],
        min: 0,
        max: kMaxSecondArcRoot01,
      ));
    }
    return Result.success(value);
  }

  /// Validates an [object-identifier-128] value.
  ///
  /// Inherits all [object-identifier] validation rules and additionally
  /// enforces at most 128 sub-identifiers per SMIv2 (RFC 2578).
  ///
  /// Returns [Result.success] on success, or [Result.failure] otherwise.
  static Result<String> validateObjectIdentifier128(String value) {
    final oidResult = validateObjectIdentifier(value);
    if (oidResult.isFailure) return oidResult;
    final parseResult = parseOidSubIdentifiers(value);
    if (parseResult.isFailure) return _castFailure(parseResult);
    final subIds = (parseResult as Success<List<int>>).value;
    if (subIds.length > kMaxOid128SubIdentifiers) {
      return Result.failure(SchemaFieldRangeError(
        fieldName: 'objectIdentifier128',
        value: 0,
        min: 1,
        max: kMaxOid128SubIdentifiers,
      ));
    }
    return Result.success(value);
  }

  /// Validates a [uuid] value per RFC 9562.
  ///
  /// Enforces the 8-4-4-4-12 hexadecimal pattern with hyphens.
  /// Both uppercase and lowercase hex characters are accepted;
  /// call [normalizeUuid] for canonical representation.
  ///
  /// Returns [Result.success] on success, or [Result.failure] with
  /// [SchemaFieldPatternError] otherwise.
  static Result<String> validateUuid(String value) {
    if (!_uuidPattern.hasMatch(value)) {
      return Result.failure(SchemaFieldPatternError(
        fieldName: 'uuid',
        value: '',
        pattern: '8-4-4-4-12 hex digits with hyphens',
      ));
    }
    return Result.success(value);
  }

  /// Validates a [yang-identifier] value per RFC 7950 §14.
  ///
  /// Must start with an alphabetic character or underscore, followed by
  /// alphanumeric characters, underscores, hyphens, or dots. Minimum
  /// length of 1 character.
  ///
  /// Returns [Result.success] on success, or [Result.failure] with
  /// [SchemaFieldPatternError] otherwise.
  static Result<String> validateYangIdentifier(String value) {
    if (value.isEmpty) {
      return Result.failure(SchemaFieldPatternError(
        fieldName: 'yangIdentifier',
        value: '',
        pattern: 'min 1 character',
      ));
    }
    if (!_yangIdentifierPattern.hasMatch(value)) {
      return Result.failure(SchemaFieldPatternError(
        fieldName: 'yangIdentifier',
        value: value,
        pattern: '[a-zA-Z_][a-zA-Z0-9\\-_.]*',
      ));
    }
    return Result.success(value);
  }

  /// Canonicalises a UUID string to RFC 9562 canonical lowercase form.
  ///
  /// Converts all uppercase hex characters A-F to lowercase a-f.
  /// Does not validate the input — call [validateUuid] first for
  /// format checking.
  static String normalizeUuid(String value) {
    return value.toLowerCase();
  }

  /// Returns `true` if [val] contains only lowercase hex characters.
  ///
  /// Used to verify that a UUID is in its canonical lowercase form.
  /// Non-hex characters (hyphens) are ignored in the check.
  static bool isCanonicalLowercase(String val) {
    return val == val.toLowerCase();
  }

  /// Casts a [Result.failure] from [List<int>] to [String] for validation
  /// function return types.
  static Result<String> _castFailure(Result<List<int>> result) {
    if (result is Failure<List<int>>) {
      return Result.failure(result.error);
    }
    return Result.success('');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IdentifierTypes &&
        other.containerId == containerId &&
        other.objectIdentifier == objectIdentifier &&
        other.objectIdentifier128 == objectIdentifier128 &&
        other.uuid == uuid &&
        other.yangIdentifier == yangIdentifier;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        objectIdentifier,
        objectIdentifier128,
        uuid,
        yangIdentifier,
      );
}
