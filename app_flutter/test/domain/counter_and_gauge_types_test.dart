import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterAndGaugeTypes Constants', () {
    test('kMaxUint32 should be 4294967295', () {
      expect(CounterAndGaugeTypes.kMaxUint32, equals(4294967295));
    });

    test('kModUint32 should be 4294967296', () {
      expect(CounterAndGaugeTypes.kModUint32, equals(4294967296));
    });

    test('kMaxUint64 should be 18446744073709551615', () {
      expect(
        CounterAndGaugeTypes.kMaxUint64,
        equals(BigInt.parse('18446744073709551615')),
      );
    });

    test('kModUint64 should be 2^64', () {
      expect(
        CounterAndGaugeTypes.kModUint64,
        equals(BigInt.parse('18446744073709551616')),
      );
    });
  });

  group('CounterAndGaugeTypes Value Object', () {
    test('should create instance with all six fields', () {
      final model = CounterAndGaugeTypes(
        counter32: 100,
        zeroBasedCounter32: 0,
        counter64: BigInt.from(500),
        zeroBasedCounter64: BigInt.zero,
        gauge32: 250,
        gauge64: BigInt.from(1000),
      );
      expect(model.counter32, equals(100));
      expect(model.zeroBasedCounter32, equals(0));
      expect(model.counter64, equals(BigInt.from(500)));
      expect(model.zeroBasedCounter64, equals(BigInt.zero));
      expect(model.gauge32, equals(250));
      expect(model.gauge64, equals(BigInt.from(1000)));
    });

    test('should have value equality', () {
      final a = CounterAndGaugeTypes(
        counter32: 1,
        zeroBasedCounter32: 2,
        counter64: BigInt.from(3),
        zeroBasedCounter64: BigInt.from(4),
        gauge32: 5,
        gauge64: BigInt.from(6),
      );
      final b = CounterAndGaugeTypes(
        counter32: 1,
        zeroBasedCounter32: 2,
        counter64: BigInt.from(3),
        zeroBasedCounter64: BigInt.from(4),
        gauge32: 5,
        gauge64: BigInt.from(6),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should have inequality with different values', () {
      final a = CounterAndGaugeTypes(
        counter32: 1,
        zeroBasedCounter32: 2,
        counter64: BigInt.from(3),
        zeroBasedCounter64: BigInt.from(4),
        gauge32: 5,
        gauge64: BigInt.from(6),
      );
      final b = CounterAndGaugeTypes(
        counter32: 99,
        zeroBasedCounter32: 2,
        counter64: BigInt.from(3),
        zeroBasedCounter64: BigInt.from(4),
        gauge32: 5,
        gauge64: BigInt.from(6),
      );
      expect(a, isNot(equals(b)));
    });

    test('should support copyWith', () {
      final model = CounterAndGaugeTypes(
        counter32: 10,
        zeroBasedCounter32: 20,
        counter64: BigInt.from(30),
        zeroBasedCounter64: BigInt.from(40),
        gauge32: 50,
        gauge64: BigInt.from(60),
      );
      final copy = model.copyWith(counter32: 99);
      expect(copy.counter32, equals(99));
      expect(copy.zeroBasedCounter32, equals(20));
      expect(copy.counter64, equals(BigInt.from(30)));
    });
  });

  group('validateCounter32', () {
    test('should succeed for in-range values', () {
      final result = CounterAndGaugeTypes.validateCounter32(0);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(0));
    });

    test('should succeed for max value', () {
      final result =
          CounterAndGaugeTypes.validateCounter32(CounterAndGaugeTypes.kMaxUint32);
      expect(result.isSuccess, isTrue);
    });

    test('should fail for negative values', () {
      final result = CounterAndGaugeTypes.validateCounter32(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
      expect((error as SchemaFieldRangeError).fieldName, equals('counter32'));
    });

    test('should fail for overflow values', () {
      final result =
          CounterAndGaugeTypes.validateCounter32(CounterAndGaugeTypes.kMaxUint32 + 1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });
  });

  group('validateZeroBasedCounter32', () {
    test('should succeed for in-range values', () {
      final result = CounterAndGaugeTypes.validateZeroBasedCounter32(0);
      expect(result.isSuccess, isTrue);
    });

    test('should fail for negative values', () {
      final result = CounterAndGaugeTypes.validateZeroBasedCounter32(-5);
      expect(result.isFailure, isTrue);
    });

    test('should fail for overflow values', () {
      final result = CounterAndGaugeTypes
          .validateZeroBasedCounter32(CounterAndGaugeTypes.kMaxUint32 + 1);
      expect(result.isFailure, isTrue);
    });
  });

  group('validateCounter64', () {
    test('should succeed for in-range values', () {
      final result = CounterAndGaugeTypes.validateCounter64(BigInt.zero);
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for max value', () {
      final result = CounterAndGaugeTypes
          .validateCounter64(CounterAndGaugeTypes.kMaxUint64);
      expect(result.isSuccess, isTrue);
    });

    test('should fail for negative values', () {
      final result = CounterAndGaugeTypes.validateCounter64(BigInt.from(-1));
      expect(result.isFailure, isTrue);
      final error = (result as Failure<BigInt>).error;
      expect(error, isA<SchemaFieldRangeError>());
      expect((error as SchemaFieldRangeError).fieldName, equals('counter64'));
    });

    test('should fail for overflow values', () {
      final result = CounterAndGaugeTypes
          .validateCounter64(CounterAndGaugeTypes.kMaxUint64 + BigInt.one);
      expect(result.isFailure, isTrue);
    });
  });

  group('validateZeroBasedCounter64', () {
    test('should succeed for in-range values', () {
      final result =
          CounterAndGaugeTypes.validateZeroBasedCounter64(BigInt.zero);
      expect(result.isSuccess, isTrue);
    });

    test('should fail for negative values', () {
      final result =
          CounterAndGaugeTypes.validateZeroBasedCounter64(BigInt.from(-1));
      expect(result.isFailure, isTrue);
    });

    test('should fail for overflow values', () {
      final result = CounterAndGaugeTypes.validateZeroBasedCounter64(
          CounterAndGaugeTypes.kMaxUint64 + BigInt.one);
      expect(result.isFailure, isTrue);
    });
  });

  group('validateGauge32', () {
    test('should succeed for in-range values', () {
      final result = CounterAndGaugeTypes.validateGauge32(500);
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for max value', () {
      final result =
          CounterAndGaugeTypes.validateGauge32(CounterAndGaugeTypes.kMaxUint32);
      expect(result.isSuccess, isTrue);
    });

    test('should fail for negative values', () {
      final result = CounterAndGaugeTypes.validateGauge32(-1);
      expect(result.isFailure, isTrue);
    });

    test('should fail for overflow values', () {
      final result =
          CounterAndGaugeTypes.validateGauge32(CounterAndGaugeTypes.kMaxUint32 + 1);
      expect(result.isFailure, isTrue);
    });
  });

  group('validateGauge64', () {
    test('should succeed for in-range values', () {
      final result = CounterAndGaugeTypes.validateGauge64(BigInt.from(1000));
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for max value', () {
      final result = CounterAndGaugeTypes
          .validateGauge64(CounterAndGaugeTypes.kMaxUint64);
      expect(result.isSuccess, isTrue);
    });

    test('should fail for negative values', () {
      final result = CounterAndGaugeTypes.validateGauge64(BigInt.from(-1));
      expect(result.isFailure, isTrue);
    });

    test('should fail for overflow values', () {
      final result = CounterAndGaugeTypes
          .validateGauge64(CounterAndGaugeTypes.kMaxUint64 + BigInt.one);
      expect(result.isFailure, isTrue);
    });
  });

  group('incrementCounter32', () {
    test('should add step normally within range', () {
      final result = CounterAndGaugeTypes.incrementCounter32(0, 10);
      expect(result, equals(10));
    });

    test('should wraparound at max value', () {
      final result = CounterAndGaugeTypes.incrementCounter32(
        CounterAndGaugeTypes.kMaxUint32,
        1,
      );
      expect(result, equals(0));
    });

    test('should wraparound with overflow step', () {
      final result = CounterAndGaugeTypes.incrementCounter32(
        CounterAndGaugeTypes.kMaxUint32 - 1,
        3,
      );
      expect(result, equals(1));
    });
  });

  group('incrementCounter64', () {
    test('should add step normally within range', () {
      final result =
          CounterAndGaugeTypes.incrementCounter64(BigInt.zero, BigInt.from(10));
      expect(result, equals(BigInt.from(10)));
    });

    test('should wraparound at max value', () {
      final result = CounterAndGaugeTypes.incrementCounter64(
        CounterAndGaugeTypes.kMaxUint64,
        BigInt.one,
      );
      expect(result, equals(BigInt.zero));
    });

    test('should wraparound with overflow step', () {
      final result = CounterAndGaugeTypes.incrementCounter64(
        CounterAndGaugeTypes.kMaxUint64 - BigInt.one,
        BigInt.from(3),
      );
      expect(result, equals(BigInt.one));
    });
  });

  group('updateGauge32', () {
    test('should increase value with positive delta', () {
      final result = CounterAndGaugeTypes.updateGauge32(100, 50);
      expect(result, equals(150));
    });

    test('should decrease value with negative delta', () {
      final result = CounterAndGaugeTypes.updateGauge32(100, -50);
      expect(result, equals(50));
    });

    test('should latch at max value', () {
      final result = CounterAndGaugeTypes.updateGauge32(
        CounterAndGaugeTypes.kMaxUint32 - 10,
        100,
      );
      expect(result, equals(CounterAndGaugeTypes.kMaxUint32));
    });

    test('should latch at min value (0)', () {
      final result = CounterAndGaugeTypes.updateGauge32(5, -100);
      expect(result, equals(0));
    });
  });

  group('updateGauge64', () {
    test('should increase value with positive delta', () {
      final result = CounterAndGaugeTypes.updateGauge64(
        BigInt.from(100),
        BigInt.from(50),
      );
      expect(result, equals(BigInt.from(150)));
    });

    test('should decrease value with negative delta', () {
      final result = CounterAndGaugeTypes.updateGauge64(
        BigInt.from(100),
        BigInt.from(-50),
      );
      expect(result, equals(BigInt.from(50)));
    });

    test('should latch at max value', () {
      final result = CounterAndGaugeTypes.updateGauge64(
        CounterAndGaugeTypes.kMaxUint64 - BigInt.from(10),
        BigInt.from(100),
      );
      expect(result, equals(CounterAndGaugeTypes.kMaxUint64));
    });

    test('should latch at min value (0)', () {
      final result = CounterAndGaugeTypes.updateGauge64(
        BigInt.from(5),
        BigInt.from(-100),
      );
      expect(result, equals(BigInt.zero));
    });
  });

  group('computeCounterDelta32', () {
    test('should compute simple delta', () {
      final delta = CounterAndGaugeTypes.computeCounterDelta32(100, 50);
      expect(delta, equals(50));
    });

    test('should compute delta with wraparound using mod 2^32', () {
      // current=5, previous=4294967295 (near max)
      // delta = (5 - 4294967295) mod 2^32 = (5 - 4294967295 + 4294967296) mod 2^32
      // = 6
      final delta = CounterAndGaugeTypes.computeCounterDelta32(
        5,
        CounterAndGaugeTypes.kMaxUint32,
      );
      expect(delta, equals(6));
    });
  });

  group('computeCounterDelta64', () {
    test('should compute simple delta', () {
      final delta = CounterAndGaugeTypes.computeCounterDelta64(
        BigInt.from(200),
        BigInt.from(50),
      );
      expect(delta, equals(BigInt.from(150)));
    });

    test('should compute delta with wraparound using mod 2^64', () {
      final delta = CounterAndGaugeTypes.computeCounterDelta64(
        BigInt.from(5),
        CounterAndGaugeTypes.kMaxUint64,
      );
      expect(delta, equals(BigInt.from(6)));
    });
  });
}
