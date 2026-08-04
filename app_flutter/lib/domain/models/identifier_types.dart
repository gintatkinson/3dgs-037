import 'package:meta/meta.dart';

/// Sealed hierarchy representing the outcome of a domain operation or validation check.
sealed class Result<T> {
  /// Const constructor for sealed [Result].
  const Result();

  /// Returns true if this instance represents a successful result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this instance represents a failed result.
  bool get isFailure => this is Failure<T>;

  /// Returns the underlying value if success, or null if failure.
  T? get valueOrNull => isSuccess ? (this as Success<T>).value : null;

  /// Returns the underlying error code if failure, or null if success.
  String? get errorCodeOrNull => isFailure ? (this as Failure<T>).errorCode : null;

  /// Returns the error message if failure, or null if success.
  String? get messageOrNull => isFailure ? (this as Failure<T>).message : null;
}

/// Represents a successful outcome containing [value].
final class Success<T> extends Result<T> {
  /// The payload value of a successful result.
  final T value;

  /// Creates a [Success] instance with [value].
  const Success(this.value);
}

/// Represents a failed outcome with an [errorCode] and descriptive [message].
final class Failure<T> extends Result<T> {
  /// Specific domain error code.
  final String errorCode;

  /// Human-readable failure explanation.
  final String message;

  /// Creates a [Failure] instance with [errorCode] and optional [message].
  const Failure(this.errorCode, [this.message = '']);
}

/// Domain model and validator for ietf-yang-types identifier data types.
///
/// Realises: [Feat-002/IdentifierTypes]
@immutable
class IdentifierTypes {
  /// Primary key or container ID.
  final String containerId;

  /// Object identifier string (RFC 9911 / ASN.1 OID).
  final String objectIdentifier;

  /// Object identifier restricted to 128 sub-identifiers (RFC 2578 / SMIv2).
  final String objectIdentifier128;

  /// Universally Unique Identifier string (RFC 9562).
  final String uuid;

  /// YANG 1.1 language identifier string (RFC 7950 Section 14).
  final String yangIdentifier;

  /// Creates a new [IdentifierTypes] model instance.
  const IdentifierTypes({
    this.containerId = 'identifier-types-default',
    required this.objectIdentifier,
    required this.objectIdentifier128,
    required this.uuid,
    required this.yangIdentifier,
  });

  /// Regex pattern for UUID format (8-4-4-4-12 hex).
  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Regex pattern for YANG 1.1 identifier syntax per RFC 7950.
  static final RegExp _yangIdRegex = RegExp(r'^[a-zA-Z_][a-zA-Z0-9\-_.]*$');

  /// Validates an ASN.1 Object Identifier string according to RFC 9911 / ISO 9834-1.
  static Result<String> validateObjectIdentifier(String val) {
    if (val.isEmpty) {
      return const Failure('OID_TOO_FEW_SUBIDENTIFIERS', 'OID cannot be empty');
    }

    final parts = val.split('.');
    if (parts.length < 2) {
      return const Failure('OID_TOO_FEW_SUBIDENTIFIERS', 'OID must contain at least 2 sub-identifiers');
    }

    final firstArc = int.tryParse(parts[0]);
    if (firstArc == null || firstArc < 0 || firstArc > 2) {
      return Failure('INVALID_OID_FIRST_ARC', 'First sub-identifier must be 0, 1, or 2 (got ${parts[0]})');
    }

    final secondArc = int.tryParse(parts[1]);
    if (secondArc == null || secondArc < 0) {
      return Failure('INVALID_OID_SECOND_ARC', 'Second sub-identifier must be non-negative (got ${parts[1]})');
    }

    if ((firstArc == 0 || firstArc == 1) && secondArc > 39) {
      return Failure('INVALID_OID_SECOND_ARC', 'Second arc must be in range 0..39 when first arc is $firstArc');
    }

    for (int i = 0; i < parts.length; i++) {
      final subStr = parts[i];
      if (subStr.isEmpty) {
        return const Failure('INVALID_OID_FORMAT', 'OID contains empty sub-identifier');
      }
      if (subStr.length > 1 && subStr.startsWith('0')) {
        return Failure('INVALID_OID_FORMAT', 'Leading zero not allowed in sub-identifier $subStr');
      }
      final numVal = BigInt.tryParse(subStr);
      if (numVal == null || numVal < BigInt.zero) {
        return Failure('INVALID_OID_FORMAT', 'Invalid non-negative integer in sub-identifier $subStr');
      }
      if (numVal > BigInt.from(4294967295)) {
        return Failure('OID_SUBIDENTIFIER_OVERFLOW', 'Sub-identifier $subStr exceeds 2^32-1 limit');
      }
    }

    return Success(val);
  }

  /// Validates an object-identifier-128 string restricted to at most 128 sub-identifiers.
  static Result<String> validateObjectIdentifier128(String val) {
    final baseValidation = validateObjectIdentifier(val);
    if (baseValidation.isFailure) {
      return baseValidation;
    }

    final parts = val.split('.');
    if (parts.length > 128) {
      return Failure('OID_128_LIMIT_EXCEEDED', 'OID has ${parts.length} sub-identifiers (maximum is 128)');
    }

    return Success(val);
  }

  /// Validates a Universally Unique Identifier string (RFC 9562).
  static Result<String> validateUuid(String val) {
    if (val.length != 36 || !_uuidRegex.hasMatch(val)) {
      return Failure('INVALID_UUID_FORMAT', 'Invalid UUID string format: $val');
    }
    return Success(val);
  }

  /// Normalizes a valid UUID string to canonical lowercase representation.
  static String normalizeUuid(String val) {
    return val.toLowerCase();
  }

  /// Validates a YANG 1.1 language identifier string (RFC 7950 Section 14).
  static Result<String> validateYangIdentifier(String val) {
    if (val.isEmpty) {
      return const Failure('INVALID_YANG_IDENTIFIER_START', 'YANG identifier cannot be empty');
    }

    final firstChar = val.codeUnitAt(0);
    final isAlpha = (firstChar >= 65 && firstChar <= 90) || (firstChar >= 97 && firstChar <= 122);
    final isUnderscore = firstChar == 95;

    if (!isAlpha && !isUnderscore) {
      return Failure('INVALID_YANG_IDENTIFIER_START', 'YANG identifier must start with letter or underscore: $val');
    }

    if (!_yangIdRegex.hasMatch(val)) {
      return Failure('INVALID_YANG_IDENTIFIER_CHARACTER', 'YANG identifier contains invalid characters: $val');
    }

    return Success(val);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentifierTypes &&
          runtimeType == other.runtimeType &&
          containerId == other.containerId &&
          objectIdentifier == other.objectIdentifier &&
          objectIdentifier128 == other.objectIdentifier128 &&
          uuid == other.uuid &&
          yangIdentifier == other.yangIdentifier;

  @override
  int get hashCode =>
      containerId.hashCode ^
      objectIdentifier.hashCode ^
      objectIdentifier128.hashCode ^
      uuid.hashCode ^
      yangIdentifier.hashCode;
}
