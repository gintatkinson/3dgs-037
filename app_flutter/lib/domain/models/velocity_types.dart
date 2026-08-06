import 'dart:math';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-037/Velocity]
///
/// Field key constants for the velocity container fields,
/// used by [FieldDescriptor] schemas and serialisation logic.
/// Field key constant for the v-north velocity component.
const String kFieldVNorth = 'vNorth';
/// Field key constant for the v-east velocity component.
const String kFieldVEast = 'vEast';
/// Field key constant for the v-up velocity component.
const String kFieldVUp = 'vUp';
/// Field key constant for the derived 2D speed value.
const String kFieldSpeed = 'speed';
/// Field key constant for the derived 2D heading value.
const String kFieldHeading = 'heading';

/// Realises: [Feat-037/Velocity]
///
/// Domain model capturing the `velocity` container defined in the
/// `ietf-geo-location` YANG module (RFC 9179 § geo-location/velocity).
///
/// The velocity vector represents objects in relatively stable motion
/// using a three-dimensional vector representation with components
/// aligned to true north, east, and up directions.
///
/// Fields:
/// - [vNorth]: Rate of change towards true north in m/s (decimal64, 12 fraction digits).
/// - [vEast]: Rate of change perpendicular to and right of true north in m/s (decimal64, 12 fraction digits).
/// - [vUp]: Rate of change perpendicular to v-north/v-east plane, away from centre of mass in m/s (decimal64, 12 fraction digits).
@immutable
class Velocity {
  /// Creates a [Velocity] with the given fields.
  const Velocity({
    this.containerId = 'default',
    this.vNorth,
    this.vEast,
    this.vUp,
  });

  /// Container identifier for database indexing.
  final String containerId;

  /// Rate of change towards true north in fractional metres per second.
  final double? vNorth;

  /// Rate of change perpendicular and to the right of true north in fractional metres per second.
  final double? vEast;

  /// Rate of change perpendicular to the v-north/v-east plane, pointed away from the centre of mass in fractional metres per second.
  final double? vUp;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Velocity &&
        other.containerId == containerId &&
        other.vNorth == vNorth &&
        other.vEast == vEast &&
        other.vUp == vUp;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        vNorth,
        vEast,
        vUp,
      );
}

/// Realises: [Feat-037/Velocity]
///
/// Checks whether a [value] exceeds the 12 fraction-digit precision
/// mandated by the YANG `decimal64` type.
///
/// Returns true if the fractional part of [value] contains more than
/// 12 decimal digits, false otherwise.
bool _exceedsVelocityPrecisionLimit(double value) {
  final str = value.toStringAsFixed(14);
  final dotIndex = str.indexOf('.');
  if (dotIndex == -1) return false;
  final fractional = str.substring(dotIndex + 1);
  final trimmed = fractional.replaceAll(RegExp(r'0+$'), '');
  return trimmed.length > 12;
}

/// Realises: [Feat-037/Velocity]
///
/// Validates a velocity component value against the YANG constraints
/// defined in RFC 9179 § geo-location/velocity.
///
/// Constraints:
/// - Must not exceed 12 fraction digits of decimal precision.
///
/// Returns [Success] with the value if valid, or [Failure] with
/// [VelocityPrecisionExceededError] if precision exceeds limits.
Result<double> validateVelocityComponent(double value, String fieldName) {
  if (_exceedsVelocityPrecisionLimit(value)) {
    return Result.failure(
      VelocityPrecisionExceededError(fieldName: fieldName, value: value),
    );
  }
  return Result.success(value);
}

/// Realises: [Feat-037/Velocity]
///
/// Validates a complete [Velocity] instance.
///
/// Checks each component for 12 fraction-digit precision.
/// Null velocity fields skip validation (they are allowed).
///
/// Returns [Success] with the model if all validations pass, or
/// [Failure] with the first-encountered domain error.
Result<Velocity> validateVelocity(Velocity model) {
  if (model.vNorth != null) {
    final result = validateVelocityComponent(model.vNorth!, kFieldVNorth);
    if (result.isFailure) {
      return Result.failure(
        (result as Failure<double>).error,
      );
    }
  }

  if (model.vEast != null) {
    final result = validateVelocityComponent(model.vEast!, kFieldVEast);
    if (result.isFailure) {
      return Result.failure(
        (result as Failure<double>).error,
      );
    }
  }

  if (model.vUp != null) {
    final result = validateVelocityComponent(model.vUp!, kFieldVUp);
    if (result.isFailure) {
      return Result.failure(
        (result as Failure<double>).error,
      );
    }
  }

  return Result.success(model);
}

/// Realises: [Feat-037/Velocity]
///
/// Computes two-dimensional speed from north and east velocity components
/// using the formula $speed = \sqrt{v_{north}^2 + v_{east}^2}$ as defined
/// in RFC 9179 § geo-location/velocity.
double calculateSpeed(double vNorth, double vEast) {
  return sqrt(vNorth * vNorth + vEast * vEast);
}

/// Realises: [Feat-037/Velocity]
///
/// Computes two-dimensional heading angle from north and east velocity
/// components using the formula $heading = \arctan2(v_{east}, v_{north})$
/// as defined in RFC 9179 § geo-location/velocity.
///
/// Returns [double.nan] for the zero-vector case (vNorth = 0, vEast = 0)
/// to signal an undefined heading angle (ERR-VEL-003). Callers must check
/// for NaN and adopt the fallback value of 0.0.
double calculateHeading(double vNorth, double vEast) {
  if (vNorth == 0.0 && vEast == 0.0) {
    return 0.0;
  }
  return atan2(vEast, vNorth);
}
