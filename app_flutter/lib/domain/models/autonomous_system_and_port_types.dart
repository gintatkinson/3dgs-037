import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

const String kFieldContainerId = 'containerId';
const String kFieldAsNumber = 'asNumber';
const String kFieldPortNumber = 'portNumber';

/// Realises: [Feat-022/AutonomousSystemAndPortTypes]
///
/// Domain model aggregating the two typedefs defined in ietf-inet-types
/// (RFC 6021): as-number (uint32) and port-number (uint16).
///
/// The as-number type represents a 32-bit unsigned integer (0..4294967295)
/// identifying an Autonomous System. The port-number type represents a
/// 16-bit unsigned integer (0..65535) for transport-layer protocol port
/// assignment by IANA. Port zero is valid in the base type but reserved;
/// subtypes may exclude it via validatePortNonZero.
@immutable
class AutonomousSystemAndPortTypes {
  /// Maximum value for 32-bit unsigned integer (2^32 - 1).
  static const int kMaxAsNumber = 4294967295;

  /// Maximum value for 16-bit unsigned integer (2^16 - 1).
  static const int kMaxPortNumber = 65535;

  /// Container identifier for database indexing.
  final String containerId;

  /// 32-bit Autonomous System number in range 0..4294967295.
  final int asNumber;

  /// 16-bit transport protocol port number in range 0..65535.
  final int portNumber;

  /// Creates a new [AutonomousSystemAndPortTypes] instance.
  const AutonomousSystemAndPortTypes({
    this.containerId = 'default',
    required this.asNumber,
    required this.portNumber,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutonomousSystemAndPortTypes &&
        other.containerId == containerId &&
        other.asNumber == asNumber &&
        other.portNumber == portNumber;
  }

  @override
  int get hashCode => Object.hash(containerId, asNumber, portNumber);
}

/// Realises: [Feat-022/AsNumber]
///
/// Validates an Autonomous System number as a 32-bit unsigned integer.
///
/// Accepts values in the inclusive range 0 to 4294967295 (2^32 - 1).
/// Returns [Success] with the value if valid, or [Failure] with
/// [SchemaFieldRangeError] if the value is outside the allowed range.
Result<int> validateAsNumber(int value) {
  if (value < 0 || value > AutonomousSystemAndPortTypes.kMaxAsNumber) {
    return Result.failure(
      SchemaFieldRangeError(
        fieldName: 'asNumber',
        value: value,
        min: 0,
        max: AutonomousSystemAndPortTypes.kMaxAsNumber,
      ),
    );
  }
  return Result.success(value);
}

/// Realises: [Feat-022/PortNumber]
///
/// Validates a transport protocol port number as a 16-bit unsigned integer.
///
/// Accepts values in the inclusive range 0 to 65535 (2^16 - 1).
/// Note that port 0 is valid in the base type but is reserved by IANA.
/// Use [validatePortNonZero] in contexts where zero is disallowed.
/// Returns [Success] with the value if valid, or [Failure] with
/// [SchemaFieldRangeError] if the value is outside the allowed range.
Result<int> validatePortNumber(int value) {
  if (value < 0 || value > AutonomousSystemAndPortTypes.kMaxPortNumber) {
    return Result.failure(
      SchemaFieldRangeError(
        fieldName: 'portNumber',
        value: value,
        min: 0,
        max: AutonomousSystemAndPortTypes.kMaxPortNumber,
      ),
    );
  }
  return Result.success(value);
}

/// Realises: [Feat-022/PortNumber]
///
/// Validates a transport protocol port number excluding the reserved zero.
///
/// First delegates to [validatePortNumber] for range validation (0..65535),
/// then rejects port 0 with [SchemaFieldRangeError] where min is 1.
/// Returns [Success] with the value if valid and non-zero, or [Failure]
/// with the appropriate error if the value is out of range or zero.
Result<int> validatePortNonZero(int value) {
  final rangeResult = validatePortNumber(value);
  if (rangeResult.isFailure) {
    return rangeResult;
  }
  if (value == 0) {
    return Result.failure(
      SchemaFieldRangeError(
        fieldName: 'portNumber',
        value: 0,
        min: 1,
        max: AutonomousSystemAndPortTypes.kMaxPortNumber,
      ),
    );
  }
  return Result.success(value);
}
