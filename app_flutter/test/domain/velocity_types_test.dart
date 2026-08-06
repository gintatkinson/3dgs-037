import 'dart:math';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Velocity', () {
    test('should create Velocity with default values and compute equality', () {
      const a = Velocity();
      const b = Velocity();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.vNorth, isNull);
      expect(a.vEast, isNull);
      expect(a.vUp, isNull);
      expect(a.containerId, equals('default'));
    });

    test('should parse valid velocity vector with all components', () {
      const v = Velocity(
        vNorth: 15.123456789012,
        vEast: 8.654321098765,
        vUp: 0.5,
      );
      expect(v.vNorth, equals(15.123456789012));
      expect(v.vEast, equals(8.654321098765));
      expect(v.vUp, equals(0.5));
    });

    test('should reject velocity component exceeding 12 fraction digits', () {
      final result = validateVelocityComponent(
        10.123456789012345,
        kFieldVNorth,
      );
      expect(result.isFailure, isTrue);
      final error = (result as Failure<double>).error;
      expect(error, isA<VelocityPrecisionExceededError>());
      final veError = error as VelocityPrecisionExceededError;
      expect(veError.fieldName, equals(kFieldVNorth));
      expect(veError.value, equals(10.123456789012345));
    });

    test('should calculate 2D speed as sqrt(v_north^2 + v_east^2)', () {
      final speed = calculateSpeed(3.0, 4.0);
      expect(speed, closeTo(5.0, 1e-10));
    });

    test('should calculate 2D heading as atan2(vEast, vNorth)', () {
      final heading = calculateHeading(3.0, 4.0);
      expect(heading, closeTo(0.927295218, 1e-9));
    });

    test('should handle zero vector heading gracefully', () {
      final speed = calculateSpeed(0.0, 0.0);
      expect(speed, closeTo(0.0, 1e-10));
      final heading = calculateHeading(0.0, 0.0);
      expect(heading, closeTo(0.0, 1e-10));
    });

    test('should validate complete Velocity model', () {
      const model = Velocity(
        vNorth: 15.123456789012,
        vEast: 8.654321098765,
        vUp: 0.5,
      );
      final result = validateVelocity(model);
      expect(result.isSuccess, isTrue);
      expect((result as Success<Velocity>).value, equals(model));
    });

    test('should fail validation on invalid vNorth', () {
      const model = Velocity(
        vNorth: 10.123456789012345,
        vEast: 8.654321098765,
        vUp: 0.5,
      );
      final result = validateVelocity(model);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Velocity>).error;
      expect(error, isA<VelocityPrecisionExceededError>());
      final veError = error as VelocityPrecisionExceededError;
      expect(veError.fieldName, equals(kFieldVNorth));
    });
  });

  group('Field key constants', () {
    test('should define kFieldVNorth', () {
      expect(kFieldVNorth, equals('vNorth'));
    });

    test('should define kFieldVEast', () {
      expect(kFieldVEast, equals('vEast'));
    });

    test('should define kFieldVUp', () {
      expect(kFieldVUp, equals('vUp'));
    });

    test('should define kFieldSpeed', () {
      expect(kFieldSpeed, equals('speed'));
    });

    test('should define kFieldHeading', () {
      expect(kFieldHeading, equals('heading'));
    });
  });
}
