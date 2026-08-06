import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Field key constants for coordinate and altitude container fields,
/// used by [FieldDescriptor] schemas and serialisation logic.
/// Field key constant for the measurement timestamp.
const String kFieldTimestamp = 'timestamp';
/// Field key constant for the validity expiry date-time.
const String kFieldValidUntil = 'validUntil';
/// Field key constant for the latitude in decimal degrees.
const String kFieldLatitude = 'latitude';
/// Field key constant for the longitude in decimal degrees.
const String kFieldLongitude = 'longitude';
/// Field key constant for the height in meters relative to the reference ellipsoid.
const String kFieldHeight = 'height';
/// Field key constant for the Cartesian X coordinate.
const String kFieldCartesianX = 'cartesianX';
/// Field key constant for the Cartesian Y coordinate.
const String kFieldCartesianY = 'cartesianY';
/// Field key constant for the Cartesian Z coordinate.
const String kFieldCartesianZ = 'cartesianZ';

/// Realises: [Feat-036/EllipsoidalCoordinates]
///
/// Domain model representing ellipsoidal (geodetic) coordinates defined
/// in the `ietf-geo-location` YANG module (RFC 9179 § geo-location/ellipsoid).
///
/// Position is defined by [latitude] (decimal degrees in [-90.0, 90.0]),
/// [longitude] (decimal degrees in [-180.0, 180.0]), and an optional
/// [height] (meters relative to the reference ellipsoid).
@immutable
class EllipsoidalCoordinates {
  /// Creates an [EllipsoidalCoordinates] instance.
  const EllipsoidalCoordinates({
    required this.latitude,
    required this.longitude,
    this.height,
  });

  /// Latitude in decimal degrees, bounded between -90.0 and +90.0.
  final double latitude;

  /// Longitude in decimal degrees, bounded between -180.0 and +180.0.
  final double longitude;

  /// Height in meters relative to the reference ellipsoid (optional).
  final double? height;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EllipsoidalCoordinates &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, height);
}

/// Realises: [Feat-036/CartesianCoordinates]
///
/// Domain model representing 3D Cartesian coordinates defined in the
/// `ietf-geo-location` YANG module (RFC 9179 § geo-location/cartesian).
///
/// Position is defined in 3-space by [x], [y], and [z] coordinates
/// expressed in meters relative to the geocentric origin.
@immutable
class CartesianCoordinates {
  /// Creates a [CartesianCoordinates] instance.
  const CartesianCoordinates({
    required this.x,
    required this.y,
    required this.z,
  });

  /// X coordinate in meters relative to the geocentric origin.
  final double x;

  /// Y coordinate in meters relative to the geocentric origin.
  final double y;

  /// Z coordinate in meters relative to the geocentric origin.
  final double z;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartesianCoordinates &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Realises: [Feat-036/GeoLocation]
///
/// Domain model capturing the `geo-location` container defined in the
/// `ietf-geo-location` YANG module (RFC 9179 § geo-location).
///
/// The geo-location container provides spatial position specifications
/// on or relative to an astronomical body. Position is specified via a
/// mutually exclusive [location] choice, offering either
/// [EllipsoidalCoordinates] or [CartesianCoordinates].
///
/// Temporal validity metadata is captured via [timestamp] (UTC date-and-time
/// when coordinates were measured) and [validUntil] (UTC date-and-time until
/// which coordinates remain valid).
@immutable
class GeoLocation {
  /// Creates a [GeoLocation] instance.
  const GeoLocation({
    this.containerId = 'default',
    this.timestamp,
    this.validUntil,
    this.ellipsoid,
    this.cartesian,
  });

  /// Container identifier for database indexing.
  final String containerId;

  /// UTC date-and-time when coordinates were measured (RFC 6991).
  final String? timestamp;

  /// UTC date-and-time until which coordinates remain valid (RFC 6991).
  final String? validUntil;

  /// Ellipsoidal (geodetic) coordinate branch.
  final EllipsoidalCoordinates? ellipsoid;

  /// Cartesian (3D) coordinate branch.
  final CartesianCoordinates? cartesian;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.containerId == containerId &&
        other.timestamp == timestamp &&
        other.validUntil == validUntil &&
        other.ellipsoid == ellipsoid &&
        other.cartesian == cartesian;
  }

  @override
  int get hashCode =>
      Object.hash(containerId, timestamp, validUntil, ellipsoid, cartesian);
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Validates that [value] is within the latitude range [-90.0, +90.0]
/// as defined in RFC 9179 § geo-location/ellipsoid/latitude.
///
/// Returns [Success] with the value if valid, [Failure] with
/// [InvalidLatitudeOutOfBoundsError] if out of bounds.
Result<double> validateLatitude(double value) {
  if (value < -90.0 || value > 90.0) {
    return Result.failure(InvalidLatitudeOutOfBoundsError(value: value));
  }
  return Result.success(value);
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Validates that [value] is within the longitude range [-180.0, +180.0]
/// as defined in RFC 9179 § geo-location/ellipsoid/longitude.
///
/// Returns [Success] with the value if valid, [Failure] with
/// [InvalidLongitudeOutOfBoundsError] if out of bounds.
Result<double> validateLongitude(double value) {
  if (value < -180.0 || value > 180.0) {
    return Result.failure(InvalidLongitudeOutOfBoundsError(value: value));
  }
  return Result.success(value);
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Validates the mutual exclusivity of the location choice branches
/// defined in RFC 9179 § geo-location/location.
///
/// A geo-location instance MUST contain either [ellipsoid] OR [cartesian],
/// but never both simultaneously. Neither is also valid.
///
/// Returns [Success] if the choice constraint is satisfied, or
/// [Failure] with [MutualExclusivityViolationError] if both branches
/// are present.
Result<void> validateLocationChoice({
  EllipsoidalCoordinates? ellipsoid,
  CartesianCoordinates? cartesian,
}) {
  if (ellipsoid != null && cartesian != null) {
    return Result.failure(const MutualExclusivityViolationError());
  }
  return const Result.success(null);
}

/// The ISO 8601 date-time regex pattern corresponding to RFC 6991
/// `yang:date-and-time` format.
///
/// Matches strings like `2026-08-04T14:00:00Z`,
/// `2026-08-04T14:00:00+02:00`, `2026-08-04T14:00:00.123Z`.
final RegExp _dateTimeRegex = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$',
);

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Validates that [value] conforms to ISO 8601 / RFC 6991 `date-and-time`
/// format, or is null (optional fields pass validation).
///
/// Returns [Success] if the format is valid or null, [Failure] with
/// [InvalidDateTimeFormatError] if the format is invalid.
Result<void> validateDateTimeFormat(String? value) {
  if (value == null) return const Result.success(null);
  if (!_dateTimeRegex.hasMatch(value)) {
    return Result.failure(InvalidDateTimeFormatError(input: value));
  }
  return const Result.success(null);
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Validates the temporal consistency constraint defined in RFC 9179.
///
/// If both [timestamp] and [validUntil] are provided, [validUntil] MUST be
/// chronologically equal to or later than [timestamp]. If either is null,
/// validation passes (temporal window cannot be evaluated).
///
/// Returns [Success] if the window is valid, [Failure] with
/// [InvalidTemporalWindowError] if [validUntil] precedes [timestamp].
Result<void> validateTemporalWindow({
  String? timestamp,
  String? validUntil,
}) {
  if (timestamp == null || validUntil == null) {
    return const Result.success(null);
  }
  if (validUntil.compareTo(timestamp) < 0) {
    return Result.failure(
      InvalidTemporalWindowError(timestamp: timestamp, validUntil: validUntil),
    );
  }
  return const Result.success(null);
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
///
/// Validates a complete [GeoLocation] instance against all constraints
/// defined in RFC 9179 § geo-location.
///
/// Checks performed in order:
/// 1. Location choice mutual exclusivity.
/// 2. Ellipsoidal coordinate range constraints (latitude, longitude).
/// 3. Date-time format conformance for timestamp and validUntil.
/// 4. Temporal window consistency.
///
/// Returns [Success] with the model if all validations pass, or
/// [Failure] with the first-encountered domain error.
Result<GeoLocation> validateGeoLocation(GeoLocation model) {
  final choiceResult = validateLocationChoice(
    ellipsoid: model.ellipsoid,
    cartesian: model.cartesian,
  );
  if (choiceResult.isFailure) {
    return Result.failure((choiceResult as Failure<void>).error);
  }

  if (model.ellipsoid != null) {
    final latResult = validateLatitude(model.ellipsoid!.latitude);
    if (latResult.isFailure) {
      return Result.failure((latResult as Failure<double>).error);
    }
    final lonResult = validateLongitude(model.ellipsoid!.longitude);
    if (lonResult.isFailure) {
      return Result.failure((lonResult as Failure<double>).error);
    }
  }

  final tsResult = validateDateTimeFormat(model.timestamp);
  if (tsResult.isFailure) {
    return Result.failure((tsResult as Failure<void>).error);
  }

  final vuResult = validateDateTimeFormat(model.validUntil);
  if (vuResult.isFailure) {
    return Result.failure((vuResult as Failure<void>).error);
  }

  final windowResult = validateTemporalWindow(
    timestamp: model.timestamp,
    validUntil: model.validUntil,
  );
  if (windowResult.isFailure) {
    return Result.failure((windowResult as Failure<void>).error);
  }

  return Result.success(model);
}
