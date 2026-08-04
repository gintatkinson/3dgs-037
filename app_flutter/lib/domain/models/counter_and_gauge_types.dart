import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';

export 'package:app_flutter/domain/result.dart';
export 'package:app_flutter/domain/domain_errors.dart';

/// Maximum value for 32-bit unsigned counter/gauge (2^32 - 1).
const int kMaxUint32 = 4294967295;

/// Modulo multiplier for 32-bit unsigned integer wraparound (2^32).
const int kModUint32 = 4294967296;

/// Maximum value for 64-bit unsigned counter/gauge (2^64 - 1).
final BigInt kMaxUint64 = BigInt.parse('18446744073709551615');

/// Modulo multiplier for 64-bit unsigned integer wraparound (2^64).
final BigInt kModUint64 = BigInt.from(2).pow(64);

/// Realises: [Feat-001/CounterAndGaugeTypes]
///
/// Data model representing 32-bit and 64-bit counter and gauge numeric types
/// with range validation, monotonic wraparound, and limit latching semantics.
@immutable
class CounterAndGaugeTypes {
  /// Creates an immutable [CounterAndGaugeTypes] instance with optional defaults.
  const CounterAndGaugeTypes({
    this.counter32 = 0,
    this.zeroBasedCounter32 = 0,
    BigInt? counter64,
    BigInt? zeroBasedCounter64,
    this.gauge32 = 0,
    BigInt? gauge64,
  })  : _counter64 = counter64,
        _zeroBasedCounter64 = zeroBasedCounter64,
        _gauge64 = gauge64;

  /// Monotonically increasing 32-bit counter value.
  final int counter32;

  /// Monotonically increasing zero-based 32-bit counter value.
  final int zeroBasedCounter32;

  final BigInt? _counter64;

  /// Monotonically increasing 64-bit counter value.
  BigInt get counter64 => _counter64 ?? BigInt.zero;

  final BigInt? _zeroBasedCounter64;

  /// Monotonically increasing zero-based 64-bit counter value.
  BigInt get zeroBasedCounter64 => _zeroBasedCounter64 ?? BigInt.zero;

  /// Dynamic 32-bit gauge value bounded between 0 and 4294967295.
  final int gauge32;

  final BigInt? _gauge64;

  /// Dynamic 64-bit gauge value bounded between 0 and 18446744073709551615.
  BigInt get gauge64 => _gauge64 ?? BigInt.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterAndGaugeTypes &&
          runtimeType == other.runtimeType &&
          counter32 == other.counter32 &&
          zeroBasedCounter32 == other.zeroBasedCounter32 &&
          counter64 == other.counter64 &&
          zeroBasedCounter64 == other.zeroBasedCounter64 &&
          gauge32 == other.gauge32 &&
          gauge64 == other.gauge64;

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

/// Validates that [val] is a non-negative 32-bit integer within [0, 4294967295].
Result<int> validateCounter32(int val) {
  if (val < 0 || val > kMaxUint32) {
    return Result.failure(SchemaFieldRangeError(
      fieldName: 'counter32',
      value: val,
      min: 0,
      max: kMaxUint32,
    ));
  }
  return Result.success(val);
}

/// Validates that [val] is a non-negative zero-based 32-bit integer within [0, 4294967295].
Result<int> validateZeroBasedCounter32(int val) {
  if (val < 0 || val > kMaxUint32) {
    return Result.failure(SchemaFieldRangeError(
      fieldName: 'zeroBasedCounter32',
      value: val,
      min: 0,
      max: kMaxUint32,
    ));
  }
  return Result.success(val);
}

/// Validates that [val] is a non-negative 64-bit integer within [0, 18446744073709551615].
Result<BigInt> validateCounter64(BigInt val) {
  if (val < BigInt.zero || val > kMaxUint64) {
    return Result.failure(SchemaFieldRangeError(
      fieldName: 'counter64',
      value: val.toDouble(),
      min: 0,
      max: kMaxUint64.toDouble(),
    ));
  }
  return Result.success(val);
}

/// Validates that [val] is a non-negative zero-based 64-bit integer within [0, 18446744073709551615].
Result<BigInt> validateZeroBasedCounter64(BigInt val) {
  if (val < BigInt.zero || val > kMaxUint64) {
    return Result.failure(SchemaFieldRangeError(
      fieldName: 'zeroBasedCounter64',
      value: val.toDouble(),
      min: 0,
      max: kMaxUint64.toDouble(),
    ));
  }
  return Result.success(val);
}

/// Validates that [val] is a non-negative 32-bit gauge integer within [0, 4294967295].
Result<int> validateGauge32(int val) {
  if (val < 0 || val > kMaxUint32) {
    return Result.failure(SchemaFieldRangeError(
      fieldName: 'gauge32',
      value: val,
      min: 0,
      max: kMaxUint32,
    ));
  }
  return Result.success(val);
}

/// Validates that [val] is a non-negative 64-bit gauge integer within [0, 18446744073709551615].
Result<BigInt> validateGauge64(BigInt val) {
  if (val < BigInt.zero || val > kMaxUint64) {
    return Result.failure(SchemaFieldRangeError(
      fieldName: 'gauge64',
      value: val.toDouble(),
      min: 0,
      max: kMaxUint64.toDouble(),
    ));
  }
  return Result.success(val);
}

/// Increments a 32-bit counter with wraparound at 4294967295 (2^32 - 1).
int incrementCounter32(int current, int step) {
  final _total = current + step;
  return _total % kModUint32;
}

/// Increments a 64-bit counter with wraparound at 18446744073709551615 (2^64 - 1).
BigInt incrementCounter64(BigInt current, BigInt step) {
  final _total = current + step;
  return _total % kModUint64;
}

/// Updates a 32-bit gauge value with lower limit latching at 0 and upper limit latching at 4294967295.
int updateGauge32(int current, int delta) {
  final _total = current + delta;
  if (_total > kMaxUint32) return kMaxUint32;
  if (_total < 0) return 0;
  return _total;
}

/// Updates a 64-bit gauge value with lower limit latching at 0 and upper limit latching at 18446744073709551615.
BigInt updateGauge64(BigInt current, BigInt delta) {
  final _total = current + delta;
  if (_total > kMaxUint64) return kMaxUint64;
  if (_total < BigInt.zero) return BigInt.zero;
  return _total;
}
