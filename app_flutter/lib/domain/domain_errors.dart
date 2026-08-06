import 'package:flutter/foundation.dart';

/// Realises: [Feat-10/DomainError]
///
/// Sealed base class representing domain-level errors with structured context.
@immutable
sealed class DomainError {
  /// Abstract const constructor for [DomainError].
  const DomainError();
}

/// Realises: [Feat-10/DomainError]
/// Error raised when a mandatory schema field is missing.
@immutable
final class SchemaFieldRequiredError extends DomainError {
  /// Creates a [SchemaFieldRequiredError] for [fieldName] in [schemaName].
  const SchemaFieldRequiredError({
    required this.fieldName,
    required this.schemaName,
  });

  /// The name of the required field.
  final String fieldName;

  /// The name or identifier of the target schema.
  final String schemaName;
}

/// Realises: [Feat-10/DomainError]
/// Error raised when a schema field value has an unexpected type.
@immutable
final class SchemaFieldTypeError extends DomainError {
  /// Creates a [SchemaFieldTypeError].
  const SchemaFieldTypeError({
    required this.fieldName,
    required this.expectedType,
    required this.actualType,
  });

  /// The name of the field with invalid type.
  final String fieldName;

  /// The expected type identifier or name.
  final String expectedType;

  /// The actual type received or encountered.
  final String actualType;
}

/// Realises: [Feat-10/DomainError]
/// Realises: [Feat-001/CounterAndGaugeTypes]
/// Error raised when a schema field value falls outside allowed numeric ranges.
@immutable
final class SchemaFieldRangeError extends DomainError {
  /// Creates a [SchemaFieldRangeError].
  const SchemaFieldRangeError({
    required this.fieldName,
    required this.value,
    this.min,
    this.max,
  });

  /// The name of the out-of-range field.
  final String fieldName;

  /// The value that violated the range constraint.
  final Object value;

  /// The minimum allowable value, if bounded below.
  final Object? min;

  /// The maximum allowable value, if bounded above.
  final Object? max;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchemaFieldRangeError &&
        other.fieldName == fieldName &&
        other.value == value &&
        other.min == min &&
        other.max == max;
  }

  @override
  int get hashCode => Object.hash(fieldName, value, min, max);
}

/// Realises: [Feat-10/DomainError]
/// Error raised when a schema field value fails string regex pattern validation.
@immutable
final class SchemaFieldPatternError extends DomainError {
  /// Creates a [SchemaFieldPatternError].
  const SchemaFieldPatternError({
    required this.fieldName,
    required this.value,
    required this.pattern,
  });

  /// The name of the field failing pattern match.
  final String fieldName;

  /// The string value that failed regex matching.
  final String value;

  /// The regex pattern string that was evaluated against.
  final String pattern;
}

/// Realises: [Feat-10/DomainError]
/// Error raised when a schema field value is not among allowed enum values.
@immutable
final class SchemaFieldEnumError extends DomainError {
  /// Creates a [SchemaFieldEnumError].
  const SchemaFieldEnumError({
    required this.fieldName,
    required this.value,
    required this.allowedValues,
  });

  /// The name of the enum field.
  final String fieldName;

  /// The actual invalid enum value provided.
  final String value;

  /// The list of valid permitted enum string representations.
  final List<String> allowedValues;
}

/// Realises: [Feat-10/DomainError]
/// Error raised when serialization or deserialization fails.
@immutable
final class SerializationError extends DomainError {
  /// Creates a [SerializationError].
  const SerializationError({
    required this.targetType,
    required this.reason,
    this.payload,
  });

  /// The target type attempted during serialization/deserialization.
  final String targetType;

  /// The structured rationale or cause description.
  final String reason;

  /// Optional raw payload data associated with the failure.
  final Object? payload;
}

/// Realises: [Feat-10/DomainError]
/// Error raised when database or storage operation fails.
@immutable
final class DatabaseStorageError extends DomainError {
  /// Creates a [DatabaseStorageError].
  const DatabaseStorageError({
    required this.message,
  });

  /// Detailed message explaining the storage error.
  final String message;
}

/// Realises: [Feat-020/IpVersion]
/// Error raised when an ip-version enumeration value is outside the
/// defined set {unknown(0), ipv4(1), ipv6(2)}.
@immutable
final class InvalidIpVersionError extends DomainError {
  /// Creates an [InvalidIpVersionError] for [value].
  const InvalidIpVersionError({required this.value});

  /// The invalid version value that was provided.
  final int value;
}

/// Realises: [Feat-020/Ipv4Address]
/// Error raised when an IPv4 address string fails dotted-quad format
/// validation, including octet range and dot placement checks.
@immutable
final class InvalidIpv4FormatError extends DomainError {
  /// Creates an [InvalidIpv4FormatError] for [input].
  const InvalidIpv4FormatError({required this.input});

  /// The invalid IPv4 address string.
  final String input;
}

/// Realises: [Feat-020/Ipv6Address]
/// Error raised when an IPv6 address string fails colon-hex format
/// validation, including double-colon compression and hex group checks.
@immutable
final class InvalidIpv6FormatError extends DomainError {
  /// Creates an [InvalidIpv6FormatError] for [input].
  const InvalidIpv6FormatError({required this.input});

  /// The invalid IPv6 address string.
  final String input;
}

/// Realises: [Feat-020/Ipv4AddressNoZone]
/// Realises: [Feat-020/Ipv6AddressNoZone]
/// Error raised when a zone index (% delimited suffix) is supplied to
/// an address type that prohibits zone identifiers.
@immutable
final class ZoneIndexDisallowedError extends DomainError {
  /// Creates a [ZoneIndexDisallowedError] for [input].
  const ZoneIndexDisallowedError({required this.input});

  /// The address string that contained a disallowed zone index.
  final String input;
}

/// Realises: [Feat-020/Ipv4Prefix]
/// Error raised when an IPv4 prefix length is negative or exceeds 32.
@immutable
final class Ipv4PrefixLengthOutOfBoundsError extends DomainError {
  /// Creates an [Ipv4PrefixLengthOutOfBoundsError] for [length].
  const Ipv4PrefixLengthOutOfBoundsError({required this.length});

  /// The invalid prefix length value.
  final int length;
}

/// Realises: [Feat-020/Ipv6Prefix]
/// Error raised when an IPv6 prefix length is negative or exceeds 128.
@immutable
final class Ipv6PrefixLengthOutOfBoundsError extends DomainError {
  /// Creates an [Ipv6PrefixLengthOutOfBoundsError] for [length].
  const Ipv6PrefixLengthOutOfBoundsError({required this.length});

  /// The invalid prefix length value.
  final int length;
}

/// Realises: [Feat-10/DomainError]
/// Error raised when a requested record or instance is not found.
@immutable
final class InstanceNotFoundError extends DomainError {
  /// Creates an [InstanceNotFoundError].
  const InstanceNotFoundError({
    required this.instanceId,
  });

  /// The identifier of the instance that was not found.
  final String instanceId;
}

/// Realises: [Feat-021/DomainNameAndHostTypes]
/// Error raised when a domain name exceeds the 253-character length limit.
@immutable
final class DomainNameLengthExceededError extends DomainError {
  /// Creates a [DomainNameLengthExceededError] for [length].
  const DomainNameLengthExceededError({required this.length});

  /// The invalid domain name length that was provided.
  final int length;
}

/// Realises: [Feat-021/DomainNameAndHostTypes]
/// Error raised when a domain name label exceeds 63 characters, contains
/// invalid characters, or starts/ends with an invalid hyphen.
@immutable
final class InvalidLabelSyntaxError extends DomainError {
  /// Creates an [InvalidLabelSyntaxError] for [label].
  const InvalidLabelSyntaxError({required this.label});

  /// The invalid label string.
  final String label;
}

/// Realises: [Feat-021/DomainNameAndHostTypes]
/// Error raised when a host string fails validation as both an IP address
/// and a domain name.
@immutable
final class InvalidHostFormatError extends DomainError {
  /// Creates an [InvalidHostFormatError] for [input].
  const InvalidHostFormatError({required this.input});

  /// The invalid host string.
  final String input;
}

/// Realises: [Feat-021/DomainNameAndHostTypes]
/// Error raised when a URI input string is empty (zero-length).
@immutable
final class UriZeroLengthError extends DomainError {
  /// Creates a [UriZeroLengthError].
  const UriZeroLengthError();
}

/// Realises: [Feat-021/DomainNameAndHostTypes]
/// Error raised when a URI string contains non-US-ASCII characters.
@immutable
final class UriNonAsciiError extends DomainError {
  /// Creates a [UriNonAsciiError] for [input].
  const UriNonAsciiError({required this.input});

  /// The URI string containing non-ASCII characters.
  final String input;
}

/// Realises: [Feat-023/IpFlowLabel]
/// Error raised when an IPv6 flow label value is negative or exceeds 1048575.
@immutable
final class IpFlowLabelOutOfBoundsError extends DomainError {
  /// Creates an [IpFlowLabelOutOfBoundsError] for [value].
  const IpFlowLabelOutOfBoundsError({required this.value});

  /// The out-of-bounds flow label value.
  final int value;
}

/// Realises: [Feat-023/Dscp]
/// Error raised when a DSCP value is negative or exceeds 63.
@immutable
final class DscpOutOfBoundsError extends DomainError {
  /// Creates a [DscpOutOfBoundsError] for [value].
  const DscpOutOfBoundsError({required this.value});

  /// The out-of-bounds DSCP value.
  final int value;
}

/// Realises: [Feat-023/IpUnicastAddress]
/// Error raised when a multicast address is provided in a context expecting
/// a unicast address.
@immutable
final class InvalidUnicastAddressError extends DomainError {
  /// Creates an [InvalidUnicastAddressError] for [input].
  const InvalidUnicastAddressError({required this.input});

  /// The invalid unicast address string.
  final String input;
}

/// Realises: [Feat-023/IpMulticastAddress]
/// Error raised when a unicast address or invalid IP string is provided
/// where a multicast address is required.
@immutable
final class InvalidMulticastAddressError extends DomainError {
  /// Creates an [InvalidMulticastAddressError] for [input].
  const InvalidMulticastAddressError({required this.input});

  /// The invalid multicast address string.
  final String input;
}

/// Realises: [Feat-023/IpScopeType]
/// Error raised when an unknown or invalid scope identifier is supplied.
@immutable
final class UnresolvableScopeTypeError extends DomainError {
  /// Creates an [UnresolvableScopeTypeError] for [value].
  const UnresolvableScopeTypeError({required this.value});

  /// The invalid scope identifier string.
  final String value;
}

/// Realises: [Feat-034/ReferenceFrame]
/// Error raised when an astronomical-body string contains characters
/// outside the allowed printable ASCII range (32–126), matching the
/// normative description in RFC 9179: printable ASCII excluding
/// control characters.
@immutable
final class InvalidAstronomicalBodyError extends DomainError {
  /// Creates an [InvalidAstronomicalBodyError] for [input].
  const InvalidAstronomicalBodyError({required this.input});

  /// The invalid astronomical-body string.
  final String input;
}

/// Realises: [Feat-034/ReferenceFrame]
/// Error raised when a payload contains the `alternate-system` field
/// but the underlying system has not enabled the `alternate-systems`
/// YANG feature capability.
@immutable
final class FeatureDisabledAlternateSystemError extends DomainError {
  /// Creates a [FeatureDisabledAlternateSystemError] for [value].
  const FeatureDisabledAlternateSystemError({required this.value});

  /// The alternate-system value that was rejected.
  final String value;
}

/// Realises: [Feat-035/GeodeticSystem]
/// Error raised when a `geodeticDatum` string contains characters
/// outside the pattern `[ -@\[-\^_-~]*` defined in RFC 9179
/// for the geodetic datum field.
@immutable
final class InvalidGeodeticDatumError extends DomainError {
  /// Creates an [InvalidGeodeticDatumError] for [input].
  const InvalidGeodeticDatumError({required this.input});

  /// The invalid geodetic datum string.
  final String input;
}

/// Realises: [Feat-035/GeodeticSystem]
/// Error raised when `coordAccuracy` or `heightAccuracy` is negative
/// (< 0.0), violating the non-negative constraint in RFC 9179.
@immutable
final class NegativeAccuracyValueError extends DomainError {
  /// Creates a [NegativeAccuracyValueError].
  const NegativeAccuracyValueError({
    required this.fieldName,
    required this.value,
  });

  /// The name of the accuracy field that failed validation.
  final String fieldName;

  /// The negative value that was rejected.
  final double value;
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
/// Error raised when a `latitude` value is less than -90.0 or greater
/// than +90.0 decimal degrees, violating the range constraint defined
/// in RFC 9179 § geo-location/ellipsoid/latitude.
@immutable
final class InvalidLatitudeOutOfBoundsError extends DomainError {
  /// Creates an [InvalidLatitudeOutOfBoundsError] for [value].
  const InvalidLatitudeOutOfBoundsError({required this.value});

  /// The out-of-bounds latitude value.
  final double value;
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
/// Error raised when a `longitude` value is less than -180.0 or greater
/// than +180.0 decimal degrees, violating the range constraint defined
/// in RFC 9179 § geo-location/ellipsoid/longitude.
@immutable
final class InvalidLongitudeOutOfBoundsError extends DomainError {
  /// Creates an [InvalidLongitudeOutOfBoundsError] for [value].
  const InvalidLongitudeOutOfBoundsError({required this.value});

  /// The out-of-bounds longitude value.
  final double value;
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
/// Error raised when both `ellipsoid` and `cartesian` coordinate branches
/// are present in a `geo-location` payload, violating the mutual exclusivity
/// choice constraint defined in RFC 9179 § geo-location/location.
@immutable
final class MutualExclusivityViolationError extends DomainError {
  /// Creates a [MutualExclusivityViolationError].
  const MutualExclusivityViolationError();
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
/// Error raised when the `ellipsoid` branch is selected without providing
/// both `latitude` and `longitude`, or when the `cartesian` branch is
/// selected without providing `x`, `y`, and `z`.
@immutable
final class MissingMandatoryCoordinatesError extends DomainError {
  /// Creates a [MissingMandatoryCoordinatesError] for [branch].
  const MissingMandatoryCoordinatesError({required this.branch});

  /// The branch name that is missing mandatory fields.
  final String branch;
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
/// Error raised when `timestamp` or `valid-until` fails RFC 6991
/// `date-and-time` format validation (ISO 8601).
@immutable
final class InvalidDateTimeFormatError extends DomainError {
  /// Creates an [InvalidDateTimeFormatError] for [input].
  const InvalidDateTimeFormatError({required this.input});

  /// The invalid date-time string.
  final String input;
}

/// Realises: [Feat-036/CoordinatesAndAltitudeTypes]
/// Error raised when `valid-until` precedes `timestamp` in a
/// `geo-location` record, violating the temporal consistency constraint
/// defined in RFC 9179.
@immutable
final class InvalidTemporalWindowError extends DomainError {
  /// Creates an [InvalidTemporalWindowError].
  const InvalidTemporalWindowError({
    required this.timestamp,
    required this.validUntil,
  });

  /// The timestamp that should be earlier or equal.
  final String timestamp;

  /// The valid-until time that should be later or equal.
  final String validUntil;
}

/// Realises: [Feat-035/GeodeticSystem]
/// Error raised when `coordAccuracy` or `heightAccuracy` exceeds
/// 6 fraction digits of decimal precision as mandated by the
/// `decimal64 { fraction-digits 6 }` YANG type.
@immutable
final class AccuracyPrecisionExceededError extends DomainError {
  /// Creates an [AccuracyPrecisionExceededError].
  const AccuracyPrecisionExceededError({
    required this.fieldName,
    required this.value,
  });

  /// The name of the accuracy field that exceeded precision limits.
  final String fieldName;

  /// The value that exceeded 6 fraction-digit precision.
  final double value;
}
