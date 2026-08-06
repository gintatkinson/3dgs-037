import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Field key constant for the 32-bit counter.
const String kFieldCounter32 = 'counter32';
/// Field key constant for the 32-bit zero-based counter.
const String kFieldZeroBasedCounter32 = 'zeroBasedCounter32';
/// Field key constant for the 64-bit counter.
const String kFieldCounter64 = 'counter64';
/// Field key constant for the 64-bit zero-based counter.
const String kFieldZeroBasedCounter64 = 'zeroBasedCounter64';
/// Field key constant for the 32-bit gauge.
const String kFieldGauge32 = 'gauge32';
/// Field key constant for the 64-bit gauge.
const String kFieldGauge64 = 'gauge64';

/// Realises: [Feat-001/CounterAndGaugeTypes]
///
/// Domain model representing the six counter and gauge numeric types
/// defined in ietf-yang-types (RFC 9911):
/// counter32, zeroBasedCounter32, counter64, zeroBasedCounter64, gauge32, gauge64.
///
/// Counters monotonically increase and wraparound at their max values.
/// Gauges increase/decrease dynamically and latch at 0 and max limits.
/// Zero-based counters are initialised to 0 on creation.
@immutable
class CounterAndGaugeTypes {
  /// Maximum value for 32-bit unsigned integer (2^32 - 1).
  static const int kMaxUint32 = 4294967295;

  /// Modulus for 32-bit unsigned arithmetic (2^32).
  static const int kModUint32 = 4294967296;

  /// Maximum value for 64-bit unsigned integer (2^64 - 1).
  static final BigInt kMaxUint64 = BigInt.parse('18446744073709551615');

  /// Modulus for 64-bit unsigned arithmetic (2^64).
  static final BigInt kModUint64 = BigInt.parse('18446744073709551616');

  /// 32-bit counter — monotonically increases, wraps at 2^32-1.
  final int counter32;

  /// 32-bit zero-based counter — initialised to 0, wraps at 2^32-1.
  final int zeroBasedCounter32;

  /// 64-bit counter — monotonically increases, wraps at 2^64-1.
  final BigInt counter64;

  /// 64-bit zero-based counter — initialised to 0, wraps at 2^64-1.
  final BigInt zeroBasedCounter64;

  /// 32-bit gauge — increases/decreases, latches at 0 and 2^32-1.
  final int gauge32;

  /// 64-bit gauge — increases/decreases, latches at 0 and 2^64-1.
  final BigInt gauge64;

  /// Creates a new [CounterAndGaugeTypes] instance with all six fields.
  const CounterAndGaugeTypes({
    required this.counter32,
    required this.zeroBasedCounter32,
    required this.counter64,
    required this.zeroBasedCounter64,
    required this.gauge32,
    required this.gauge64,
  });

  /// Validates a [counter32] value.
  ///
  /// Returns [Success] with the value if in range [0, kMaxUint32],
  /// or [Failure] with [SchemaFieldRangeError] otherwise.
  static Result<int> validateCounter32(int value) {
    if (value < 0 || value > kMaxUint32) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'counter32',
          value: value,
          min: 0,
          max: kMaxUint32,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a [zeroBasedCounter32] value.
  ///
  /// Returns [Success] with the value if in range [0, kMaxUint32],
  /// or [Failure] with [SchemaFieldRangeError] otherwise.
  static Result<int> validateZeroBasedCounter32(int value) {
    if (value < 0 || value > kMaxUint32) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'zeroBasedCounter32',
          value: value,
          min: 0,
          max: kMaxUint32,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a [counter64] value.
  ///
  /// Returns [Success] with the value if in range [0, kMaxUint64],
  /// or [Failure] with [SchemaFieldRangeError] otherwise.
  static Result<BigInt> validateCounter64(BigInt value) {
    if (value < BigInt.zero || value > kMaxUint64) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'counter64',
          value: value,
          min: 0,
          max: kMaxUint64,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a [zeroBasedCounter64] value.
  ///
  /// Returns [Success] with the value if in range [0, kMaxUint64],
  /// or [Failure] with [SchemaFieldRangeError] otherwise.
  static Result<BigInt> validateZeroBasedCounter64(BigInt value) {
    if (value < BigInt.zero || value > kMaxUint64) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'zeroBasedCounter64',
          value: value,
          min: 0,
          max: kMaxUint64,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a [gauge32] value.
  ///
  /// Returns [Success] with the value if in range [0, kMaxUint32],
  /// or [Failure] with [SchemaFieldRangeError] otherwise.
  static Result<int> validateGauge32(int value) {
    if (value < 0 || value > kMaxUint32) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'gauge32',
          value: value,
          min: 0,
          max: kMaxUint32,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a [gauge64] value.
  ///
  /// Returns [Success] with the value if in range [0, kMaxUint64],
  /// or [Failure] with [SchemaFieldRangeError] otherwise.
  static Result<BigInt> validateGauge64(BigInt value) {
    if (value < BigInt.zero || value > kMaxUint64) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'gauge64',
          value: value,
          min: 0,
          max: kMaxUint64,
        ),
      );
    }
    return Result.success(value);
  }

  /// Increments a counter32 value by [step] with wraparound at kMaxUint32.
  ///
  /// When the sum exceeds kMaxUint32, the value wraps to 0 and continues
  /// counting from there, per RFC 9911 § counter32 semantics.
  static int incrementCounter32(int current, int step) {
    final sum = current + step;
    if (sum > kMaxUint32) {
      return sum % kModUint32;
    }
    return sum;
  }

  /// Increments a counter64 value by [step] with wraparound at kMaxUint64.
  ///
  /// When the sum exceeds kMaxUint64, the value wraps to 0 and continues
  /// counting from there, per RFC 9911 § counter64 semantics.
  static BigInt incrementCounter64(BigInt current, BigInt step) {
    final sum = current + step;
    if (sum > kMaxUint64) {
      return sum % kModUint64;
    }
    return sum;
  }

  /// Updates a gauge32 value by [delta], latching at 0 and kMaxUint32.
  ///
  /// If the result would exceed kMaxUint32, the value latches at kMaxUint32.
  /// If the result would fall below 0, the value latches at 0.
  static int updateGauge32(int current, int delta) {
    final result = current + delta;
    if (result > kMaxUint32) return kMaxUint32;
    if (result < 0) return 0;
    return result;
  }

  /// Updates a gauge64 value by [delta], latching at 0 and kMaxUint64.
  ///
  /// If the result would exceed kMaxUint64, the value latches at kMaxUint64.
  /// If the result would fall below 0, the value latches at 0.
  static BigInt updateGauge64(BigInt current, BigInt delta) {
    final result = current + delta;
    if (result > kMaxUint64) return kMaxUint64;
    if (result < BigInt.zero) return BigInt.zero;
    return result;
  }

  /// Computes a 32-bit counter delta using modulo 2^32 arithmetic.
  ///
  /// delta = (current - previous) mod 2^32. This handles counter wraparound
  /// correctly even when the counter has wrapped since the previous reading.
  static int computeCounterDelta32(int current, int previous) {
    final diff = current - previous;
    if (diff < 0) {
      return diff + kModUint32;
    }
    return diff;
  }

  /// Computes a 64-bit counter delta using modulo 2^64 arithmetic.
  ///
  /// delta = (current - previous) mod 2^64. This handles counter wraparound
  /// correctly even when the counter has wrapped since the previous reading.
  static BigInt computeCounterDelta64(BigInt current, BigInt previous) {
    final diff = current - previous;
    if (diff < BigInt.zero) {
      return diff + kModUint64;
    }
    return diff;
  }

  /// Creates a copy of this [CounterAndGaugeTypes] with the given fields replaced.
  CounterAndGaugeTypes copyWith({
    int? counter32,
    int? zeroBasedCounter32,
    BigInt? counter64,
    BigInt? zeroBasedCounter64,
    int? gauge32,
    BigInt? gauge64,
  }) {
    return CounterAndGaugeTypes(
      counter32: counter32 ?? this.counter32,
      zeroBasedCounter32: zeroBasedCounter32 ?? this.zeroBasedCounter32,
      counter64: counter64 ?? this.counter64,
      zeroBasedCounter64: zeroBasedCounter64 ?? this.zeroBasedCounter64,
      gauge32: gauge32 ?? this.gauge32,
      gauge64: gauge64 ?? this.gauge64,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterAndGaugeTypes &&
        other.counter32 == counter32 &&
        other.zeroBasedCounter32 == zeroBasedCounter32 &&
        other.counter64 == counter64 &&
        other.zeroBasedCounter64 == zeroBasedCounter64 &&
        other.gauge32 == gauge32 &&
        other.gauge64 == gauge64;
  }

  @override
  int get hashCode => Object.hash(
        counter32,
        zeroBasedCounter32,
        counter64,
        zeroBasedCounter64,
        gauge32,
        gauge64,
      );
}
