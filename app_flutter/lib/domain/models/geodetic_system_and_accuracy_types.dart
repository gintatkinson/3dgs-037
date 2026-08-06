import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-035/GeodeticSystem]
///
/// Field key constants for the geodetic system container fields,
/// used by [FieldDescriptor] schemas and serialisation logic.
/// Field key constant for the geodetic datum string.
const String kFieldGeodeticDatum = 'geodeticDatum';
/// Field key constant for the horizontal coordinate accuracy.
const String kFieldCoordAccuracy = 'coordAccuracy';
/// Field key constant for the vertical height accuracy.
const String kFieldHeightAccuracy = 'heightAccuracy';

/// Realises: [Feat-035/GeodeticSystem]
///
/// Domain model capturing the `geodetic-system` container defined in the
/// `ietf-geo-location` YANG module (RFC 9179 § reference-frame/geodetic-system).
///
/// The geodetic system defines the spatial reference datum for geographic
/// coordinates and establishes precision parameters for coordinate and
/// vertical height accuracy.
///
/// Fields:
/// - [geodeticDatum]: The reference datum string (default: `"wgs-84"`).
///   Constrained by YANG pattern `'[ -@\\[-\\^_-~]*'`.
/// - [coordAccuracy]: Horizontal coordinate accuracy in `decimal64` with
///   6 fraction digits. Must be non-negative.
/// - [heightAccuracy]: Vertical height accuracy in meters with 6 fraction
///   digits. Must be non-negative.
@immutable
class GeodeticSystem {
  /// Creates a [GeodeticSystem] with the given fields.
  const GeodeticSystem({
    this.containerId = 'default',
    this.geodeticDatum = 'wgs-84',
    this.coordAccuracy,
    this.heightAccuracy,
  });

  /// Container identifier for database indexing.
  final String containerId;

  /// The reference datum string (default: `"wgs-84"`).
  final String geodeticDatum;

  /// Horizontal coordinate accuracy (decimal64, 6 fraction digits).
  final double? coordAccuracy;

  /// Vertical height accuracy in meters (decimal64, 6 fraction digits).
  final double? heightAccuracy;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeodeticSystem &&
        other.containerId == containerId &&
        other.geodeticDatum == geodeticDatum &&
        other.coordAccuracy == coordAccuracy &&
        other.heightAccuracy == heightAccuracy;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        geodeticDatum,
        coordAccuracy,
        heightAccuracy,
      );
}

/// The compiled regex matching the geodetic datum YANG pattern
/// `'[ -@\\[-\\^_-~]*'` as defined in RFC 9179 § geodetic-system.
///
/// Matches zero or more characters in the printable ranges:
/// space (32), ! (33), " (34), # (35), $ (36), % (37), & (38),
/// ' (39) through @ (64), [ (91) through ^ (94), _ (95), and
/// ` (96) through ~ (126).
///
/// Excludes control characters (0–31), DEL (127), and the
/// backtick-range gap characters (65–90: A-Z) that are outside
/// the permitted set. An empty string is allowed — the default
/// `"wgs-84"` fills the gap when unasserted.
final RegExp _geodeticDatumRegex = RegExp(r'^[ -@\[-\^_-~]*$');

/// The maximum number of decimal fraction digits allowed for
/// `decimal64` accuracy values per the YANG type definition.
const int _maxAccuracyFractionDigits = 6;

/// Realises: [Feat-035/GeodeticSystem]
///
/// Validates a geodetic datum string against the YANG pattern
/// defined in RFC 9179 § geodetic-system.
///
/// The pattern `[ -@\[-\^_-~]*` permits printable ASCII characters
/// in ranges space through @, [ through ^, _ through ~, and `.
///
/// Returns [Success] with the input string if valid, or [Failure] with
/// [InvalidGeodeticDatumError] if the pattern does not match.
Result<String> validateGeodeticDatum(String input) {
  if (_geodeticDatumRegex.hasMatch(input)) {
    return Result.success(input);
  }
  return Result.failure(InvalidGeodeticDatumError(input: input));
}

/// Realises: [Feat-035/GeodeticSystem]
///
/// Checks whether a [value] exceeds the 6 fraction-digit precision
/// mandated by the YANG `decimal64` type.
///
/// Returns true if the fractional part of [value] contains more than
/// 6 decimal digits, false otherwise.
bool _exceedsPrecisionLimit(double value) {
  final str = value.toStringAsFixed(10);
  final dotIndex = str.indexOf('.');
  if (dotIndex == -1) return false;
  final fractional = str.substring(dotIndex + 1);
  final trimmed = fractional.replaceAll(RegExp(r'0+$'), '');
  return trimmed.length > _maxAccuracyFractionDigits;
}

/// Realises: [Feat-035/GeodeticSystem]
///
/// Validates a coordinate accuracy value against the YANG constraints
/// defined in RFC 9179 § geodetic-system.
///
/// Constraints:
/// - Must be non-negative (>= 0.0).
/// - Must not exceed 6 fraction digits of decimal precision.
///
/// Returns [Success] with the value if valid, [Failure] with
/// [NegativeAccuracyValueError] if negative, or
/// [AccuracyPrecisionExceededError] if precision exceeds limits.
Result<double> validateCoordAccuracy(double value) {
  if (value < 0.0) {
    return Result.failure(
      NegativeAccuracyValueError(fieldName: 'coordAccuracy', value: value),
    );
  }
  if (_exceedsPrecisionLimit(value)) {
    return Result.failure(
      AccuracyPrecisionExceededError(fieldName: 'coordAccuracy', value: value),
    );
  }
  return Result.success(value);
}

/// Realises: [Feat-035/GeodeticSystem]
///
/// Validates a height accuracy value against the YANG constraints
/// defined in RFC 9179 § geodetic-system.
///
/// Constraints:
/// - Must be non-negative (>= 0.0).
/// - Must not exceed 6 fraction digits of decimal precision.
///
/// Returns [Success] with the value if valid, [Failure] with
/// [NegativeAccuracyValueError] if negative, or
/// [AccuracyPrecisionExceededError] if precision exceeds limits.
Result<double> validateHeightAccuracy(double value) {
  if (value < 0.0) {
    return Result.failure(
      NegativeAccuracyValueError(fieldName: 'heightAccuracy', value: value),
    );
  }
  if (_exceedsPrecisionLimit(value)) {
    return Result.failure(
      AccuracyPrecisionExceededError(fieldName: 'heightAccuracy', value: value),
    );
  }
  return Result.success(value);
}

/// Realises: [Feat-035/GeodeticSystem]
///
/// Validates a complete [GeodeticSystem] instance.
///
/// Checks:
/// 1. [geodeticDatum] against the YANG printable ASCII pattern.
/// 2. [coordAccuracy] for non-negative and 6 fraction-digit precision.
/// 3. [heightAccuracy] for non-negative and 6 fraction-digit precision.
///
/// Null accuracy values skip validation (they are allowed).
///
/// Returns [Success] with the model if all validations pass, or
/// [Failure] with the first-encountered domain error.
Result<GeodeticSystem> validateGeodeticSystem(GeodeticSystem model) {
  final datumResult = validateGeodeticDatum(model.geodeticDatum);
  if (datumResult.isFailure) {
    return Result.failure(
      (datumResult as Failure<String>).error,
    );
  }

  if (model.coordAccuracy != null) {
    final coordResult = validateCoordAccuracy(model.coordAccuracy!);
    if (coordResult.isFailure) {
      return Result.failure(
        (coordResult as Failure<double>).error,
      );
    }
  }

  if (model.heightAccuracy != null) {
    final heightResult = validateHeightAccuracy(model.heightAccuracy!);
    if (heightResult.isFailure) {
      return Result.failure(
        (heightResult as Failure<double>).error,
      );
    }
  }

  return Result.success(model);
}
