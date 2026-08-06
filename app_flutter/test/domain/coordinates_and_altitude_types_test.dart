import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Coordinates and Altitude Domain Types BDD', () {
    group('EllipsoidalCoordinates', () {
      test('should construct with valid values', () {
        const coords = EllipsoidalCoordinates(
          latitude: 37.7749,
          longitude: -122.4194,
          height: 15.5,
        );
        expect(coords.latitude, 37.7749);
        expect(coords.longitude, -122.4194);
        expect(coords.height, 15.5);
      });

      test('should support value equality', () {
        const a = EllipsoidalCoordinates(
          latitude: 37.7749,
          longitude: -122.4194,
          height: 15.5,
        );
        const b = EllipsoidalCoordinates(
          latitude: 37.7749,
          longitude: -122.4194,
          height: 15.5,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('should differ when fields differ', () {
        const a = EllipsoidalCoordinates(
          latitude: 37.7749,
          longitude: -122.4194,
        );
        const b = EllipsoidalCoordinates(
          latitude: 37.7749,
          longitude: -122.4194,
          height: 15.5,
        );
        expect(a, isNot(equals(b)));
      });
    });

    group('CartesianCoordinates', () {
      test('should construct with valid values', () {
        const coords = CartesianCoordinates(
          x: -2696667.123456,
          y: -4294025.654321,
          z: 3887802.987654,
        );
        expect(coords.x, -2696667.123456);
        expect(coords.y, -4294025.654321);
        expect(coords.z, 3887802.987654);
      });

      test('should support value equality', () {
        const a = CartesianCoordinates(x: 1.0, y: 2.0, z: 3.0);
        const b = CartesianCoordinates(x: 1.0, y: 2.0, z: 3.0);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('GeoLocation', () {
      test('should construct with ellipsoidal coordinates', () {
        const geo = GeoLocation(
          containerId: 'test-1',
          timestamp: '2026-08-04T12:00:00Z',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
            height: 15.5,
          ),
        );
        expect(geo.containerId, 'test-1');
        expect(geo.timestamp, '2026-08-04T12:00:00Z');
        expect(geo.ellipsoid, isNotNull);
        expect(geo.cartesian, isNull);
      });

      test('should construct with cartesian coordinates', () {
        const geo = GeoLocation(
          containerId: 'test-2',
          cartesian: CartesianCoordinates(x: 100.0, y: 200.0, z: 300.0),
        );
        expect(geo.ellipsoid, isNull);
        expect(geo.cartesian, isNotNull);
      });

      test('should support value equality', () {
        const a = GeoLocation(
          containerId: 'eq',
          timestamp: '2026-08-04T12:00:00Z',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
        );
        const b = GeoLocation(
          containerId: 'eq',
          timestamp: '2026-08-04T12:00:00Z',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });

    group('validateLatitude', () {
      test('should return success for valid latitude', () {
        final result = validateLatitude(37.7749);
        expect(result.isSuccess, isTrue);
      });

      test('should return failure for latitude above 90', () {
        final result = validateLatitude(95.1234);
        expect(result.isFailure, isTrue);
        final error = (result as Failure<double>).error;
        expect(error, isA<InvalidLatitudeOutOfBoundsError>());
        expect((error as InvalidLatitudeOutOfBoundsError).value, 95.1234);
      });

      test('should return failure for latitude below -90', () {
        final result = validateLatitude(-95.0);
        expect(result.isFailure, isTrue);
        final error = (result as Failure<double>).error;
        expect(error, isA<InvalidLatitudeOutOfBoundsError>());
      });

      test('should accept exact boundary -90.0', () {
        final result = validateLatitude(-90.0);
        expect(result.isSuccess, isTrue);
      });

      test('should accept exact boundary 90.0', () {
        final result = validateLatitude(90.0);
        expect(result.isSuccess, isTrue);
      });
    });

    group('validateLongitude', () {
      test('should return success for valid longitude', () {
        final result = validateLongitude(-122.4194);
        expect(result.isSuccess, isTrue);
      });

      test('should return failure for longitude above 180', () {
        final result = validateLongitude(195.0);
        expect(result.isFailure, isTrue);
        final error = (result as Failure<double>).error;
        expect(error, isA<InvalidLongitudeOutOfBoundsError>());
      });

      test('should return failure for longitude below -180', () {
        final result = validateLongitude(-190.0);
        expect(result.isFailure, isTrue);
      });

      test('should accept exact boundary -180.0', () {
        final result = validateLongitude(-180.0);
        expect(result.isSuccess, isTrue);
      });

      test('should accept exact boundary 180.0', () {
        final result = validateLongitude(180.0);
        expect(result.isSuccess, isTrue);
      });
    });

    group('validateLocationChoice', () {
      test('should return success when only ellipsoid is provided', () {
        final result = validateLocationChoice(
          ellipsoid: const EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
        );
        expect(result.isSuccess, isTrue);
      });

      test('should return success when only cartesian is provided', () {
        final result = validateLocationChoice(
          cartesian: const CartesianCoordinates(x: 1, y: 2, z: 3),
        );
        expect(result.isSuccess, isTrue);
      });

      test('should return mutual exclusivity error when both are provided',
          () {
        final result = validateLocationChoice(
          ellipsoid: const EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          cartesian: const CartesianCoordinates(x: 1, y: 2, z: 3),
        );
        expect(result.isFailure, isTrue);
        final error = (result as Failure<void>).error;
        expect(error, isA<MutualExclusivityViolationError>());
      });

      test('should return success when neither is provided', () {
        final result = validateLocationChoice();
        expect(result.isSuccess, isTrue);
      });
    });

    group('validateDateTimeFormat', () {
      test('should return success for valid ISO 8601 timestamp', () {
        final result = validateDateTimeFormat('2026-08-04T14:00:00Z');
        expect(result.isSuccess, isTrue);
      });

      test('should return success for valid date-time with offset', () {
        final result = validateDateTimeFormat('2026-08-04T14:00:00+02:00');
        expect(result.isSuccess, isTrue);
      });

      test('should return success for null value (optional field)', () {
        final result = validateDateTimeFormat(null);
        expect(result.isSuccess, isTrue);
      });

      test('should return failure for invalid format', () {
        final result = validateDateTimeFormat('not-a-date');
        expect(result.isFailure, isTrue);
        final error = (result as Failure<void>).error;
        expect(error, isA<InvalidDateTimeFormatError>());
      });
    });

    group('validateTemporalWindow', () {
      test('should return success when validUntil is after timestamp', () {
        final result = validateTemporalWindow(
          timestamp: '2026-08-04T12:00:00Z',
          validUntil: '2026-08-04T18:00:00Z',
        );
        expect(result.isSuccess, isTrue);
      });

      test('should return success when validUntil equals timestamp', () {
        final result = validateTemporalWindow(
          timestamp: '2026-08-04T12:00:00Z',
          validUntil: '2026-08-04T12:00:00Z',
        );
        expect(result.isSuccess, isTrue);
      });

      test('should return success when one or both are null', () {
        final result = validateTemporalWindow(
          timestamp: '2026-08-04T12:00:00Z',
        );
        expect(result.isSuccess, isTrue);
      });

      test('should return failure when validUntil precedes timestamp', () {
        final result = validateTemporalWindow(
          timestamp: '2026-08-04T18:00:00Z',
          validUntil: '2026-08-04T12:00:00Z',
        );
        expect(result.isFailure, isTrue);
        final error = (result as Failure<void>).error;
        expect(error, isA<InvalidTemporalWindowError>());
      });
    });

    group('validateGeoLocation', () {
      test('should pass validation for valid ellipsoidal record', () {
        const geo = GeoLocation(
          containerId: 'test-1',
          timestamp: '2026-08-04T12:00:00Z',
          validUntil: '2026-08-04T18:00:00Z',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
            height: 15.5,
          ),
        );
        final result = validateGeoLocation(geo);
        expect(result.isSuccess, isTrue);
      });

      test('should fail validation for out-of-bounds latitude', () {
        const geo = GeoLocation(
          containerId: 'test-1',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 95.1234,
            longitude: -122.4194,
          ),
        );
        final result = validateGeoLocation(geo);
        expect(result.isFailure, isTrue);
        final error = (result as Failure<GeoLocation>).error;
        expect(error, isA<InvalidLatitudeOutOfBoundsError>());
      });

      test('should fail validation for mutual exclusivity violation', () {
        const geo = GeoLocation(
          containerId: 'test-1',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          cartesian: CartesianCoordinates(x: 1, y: 2, z: 3),
        );
        final result = validateGeoLocation(geo);
        expect(result.isFailure, isTrue);
        final error = (result as Failure<GeoLocation>).error;
        expect(error, isA<MutualExclusivityViolationError>());
      });

      test('should fail validation for invalid temporal window', () {
        const geo = GeoLocation(
          containerId: 'test-1',
          timestamp: '2026-08-04T18:00:00Z',
          validUntil: '2026-08-04T12:00:00Z',
          ellipsoid: EllipsoidalCoordinates(
            latitude: 37.7749,
            longitude: -122.4194,
          ),
        );
        final result = validateGeoLocation(geo);
        expect(result.isFailure, isTrue);
        final error = (result as Failure<GeoLocation>).error;
        expect(error, isA<InvalidTemporalWindowError>());
      });
    });
  });
}
