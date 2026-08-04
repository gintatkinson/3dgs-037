import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';

void main() {
  group('CounterAndGaugeTypes Domain Model Tests', () {
    test('should initialize zeroBasedCounter32 to 0 by default', () {
      const types = CounterAndGaugeTypes();
      expect(types.zeroBasedCounter32, equals(0));
    });

    test('should initialize zeroBasedCounter64 to BigInt.zero by default', () {
      const types = CounterAndGaugeTypes();
      expect(types.zeroBasedCounter64, equals(BigInt.zero));
    });

    test('should support monotonic increase and wraparound at 4294967295 for counter32', () {
      const max32 = 4294967295;
      expect(incrementCounter32(100, 50), equals(150));
      expect(incrementCounter32(max32, 1), equals(0));
      expect(incrementCounter32(max32, 5), equals(4));
    });

    test('should support monotonic increase and wraparound at 18446744073709551615 for counter64', () {
      final max64 = BigInt.parse('18446744073709551615');
      expect(incrementCounter64(BigInt.from(100), BigInt.from(50)), equals(BigInt.from(150)));
      expect(incrementCounter64(max64, BigInt.one), equals(BigInt.zero));
      expect(incrementCounter64(max64, BigInt.from(5)), equals(BigInt.from(4)));
    });

    test('should handle dynamic variation and latching at bounds for gauge32', () {
      const max32 = 4294967295;
      expect(updateGauge32(100, 50), equals(150));
      expect(updateGauge32(100, -50), equals(50));
      expect(updateGauge32(max32 - 10, 20), equals(max32));
      expect(updateGauge32(10, -20), equals(0));
    });

    test('should handle dynamic variation and latching at bounds for gauge64', () {
      final max64 = BigInt.parse('18446744073709551615');
      expect(updateGauge64(BigInt.from(100), BigInt.from(50)), equals(BigInt.from(150)));
      expect(updateGauge64(BigInt.from(100), BigInt.from(-50)), equals(BigInt.from(50)));
      expect(updateGauge64(max64 - BigInt.from(10), BigInt.from(20)), equals(max64));
      expect(updateGauge64(BigInt.from(10), BigInt.from(-20)), equals(BigInt.zero));
    });

    test('should reject invalid negative values with Result.failure', () {
      final resCounter32 = validateCounter32(-1);
      expect(resCounter32.isFailure, isTrue);
      expect((resCounter32 as Failure).error, isA<SchemaFieldRangeError>());

      final resZeroCounter32 = validateZeroBasedCounter32(-10);
      expect(resZeroCounter32.isFailure, isTrue);

      final resCounter64 = validateCounter64(BigInt.from(-1));
      expect(resCounter64.isFailure, isTrue);

      final resZeroCounter64 = validateZeroBasedCounter64(BigInt.from(-5));
      expect(resZeroCounter64.isFailure, isTrue);

      final resGauge32 = validateGauge32(-1);
      expect(resGauge32.isFailure, isTrue);

      final resGauge64 = validateGauge64(BigInt.from(-100));
      expect(resGauge64.isFailure, isTrue);
    });

    test('should accept valid non-negative values within bounds with Result.success', () {
      final resCounter32 = validateCounter32(4294967295);
      expect(resCounter32.isSuccess, isTrue);
      expect((resCounter32 as Success).value, equals(4294967295));

      final resGauge64 = validateGauge64(BigInt.parse('18446744073709551615'));
      expect(resGauge64.isSuccess, isTrue);
    });

    test('should enforce value equality and hashCode on CounterAndGaugeTypes', () {
      const a = CounterAndGaugeTypes(counter32: 10, gauge32: 20);
      const b = CounterAndGaugeTypes(counter32: 10, gauge32: 20);
      const c = CounterAndGaugeTypes(counter32: 5, gauge32: 20);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a == c, isFalse);
    });
  });
}
