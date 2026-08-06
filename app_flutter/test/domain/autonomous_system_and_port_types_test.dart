import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutonomousSystemAndPortTypes value object', () {
    test('should create instance with all three fields', () {
      const model = AutonomousSystemAndPortTypes(
        containerId: 'test-1',
        asNumber: 64512,
        portNumber: 80,
      );
      expect(model.containerId, equals('test-1'));
      expect(model.asNumber, equals(64512));
      expect(model.portNumber, equals(80));
    });

    test('should use default containerId when not specified', () {
      const model = AutonomousSystemAndPortTypes(
        asNumber: 0,
        portNumber: 0,
      );
      expect(model.containerId, equals('default'));
    });

    test('should have value equality', () {
      const a = AutonomousSystemAndPortTypes(
        asNumber: 64512,
        portNumber: 80,
      );
      const b = AutonomousSystemAndPortTypes(
        asNumber: 64512,
        portNumber: 80,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should have inequality with different values', () {
      const a = AutonomousSystemAndPortTypes(
        asNumber: 64512,
        portNumber: 80,
      );
      const b = AutonomousSystemAndPortTypes(
        asNumber: 65535,
        portNumber: 443,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('validateAsNumber', () {
    test('should accept minimum AS number 0', () {
      final result = validateAsNumber(0);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(0));
    });

    test('should accept private AS number 64512', () {
      final result = validateAsNumber(64512);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(64512));
    });

    test('should accept maximum AS number 4294967295', () {
      final result = validateAsNumber(4294967295);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(4294967295));
    });

    test('should reject AS number -1 with SchemaFieldRangeError', () {
      final result = validateAsNumber(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
      final rangeError = error as SchemaFieldRangeError;
      expect(rangeError.fieldName, equals('asNumber'));
      expect(rangeError.value, equals(-1));
      expect(rangeError.min, equals(0));
      expect(rangeError.max, equals(4294967295));
    });

    test('should reject AS number 4294967296 with SchemaFieldRangeError', () {
      final result = validateAsNumber(4294967296);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
      final rangeError = error as SchemaFieldRangeError;
      expect(rangeError.fieldName, equals('asNumber'));
      expect(rangeError.value, equals(4294967296));
    });
  });

  group('validatePortNumber', () {
    test('should accept port 0 (base type allows zero)', () {
      final result = validatePortNumber(0);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(0));
    });

    test('should accept port 80 (HTTP)', () {
      final result = validatePortNumber(80);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(80));
    });

    test('should accept port 443 (HTTPS)', () {
      final result = validatePortNumber(443);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(443));
    });

    test('should accept maximum port 65535', () {
      final result = validatePortNumber(65535);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(65535));
    });

    test('should reject port -1 with SchemaFieldRangeError', () {
      final result = validatePortNumber(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
      final rangeError = error as SchemaFieldRangeError;
      expect(rangeError.fieldName, equals('portNumber'));
      expect(rangeError.value, equals(-1));
      expect(rangeError.min, equals(0));
      expect(rangeError.max, equals(65535));
    });

    test('should reject port 65536 with SchemaFieldRangeError', () {
      final result = validatePortNumber(65536);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
      final rangeError = error as SchemaFieldRangeError;
      expect(rangeError.fieldName, equals('portNumber'));
      expect(rangeError.value, equals(65536));
    });
  });

  group('validatePortNonZero', () {
    test('should accept non-zero port 80', () {
      final result = validatePortNonZero(80);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(80));
    });

    test('should accept non-zero port 65535', () {
      final result = validatePortNonZero(65535);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(65535));
    });

    test('should reject port 0 with SchemaFieldRangeError (min 1)', () {
      final result = validatePortNonZero(0);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
      final rangeError = error as SchemaFieldRangeError;
      expect(rangeError.fieldName, equals('portNumber'));
      expect(rangeError.value, equals(0));
      expect(rangeError.min, equals(1));
      expect(rangeError.max, equals(65535));
    });

    test('should reject port -1 through port validation chain', () {
      final result = validatePortNonZero(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });
  });
}
