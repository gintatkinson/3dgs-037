import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-020/IpVersion]
///
/// Enumerates Internet Protocol versions as defined in ietf-inet-types
/// (RFC 6021 § ip-version). Maps integer values 0, 1, 2 to names.
enum IpVersion {
  /// Unknown or unspecified protocol version. Integer value 0.
  unknown,

  /// IPv4 protocol as defined in RFC 791. Integer value 1.
  ipv4,

  /// IPv6 protocol as defined in RFC 2460. Integer value 2.
  ipv6,
}

/// Realises: [Feat-020/IpVersion]
///
/// Parses an integer version code into an [IpVersion] enum value.
///
/// Returns [Success] with the corresponding [IpVersion] or [Failure]
/// with [InvalidIpVersionError] when [raw] is outside {0, 1, 2}.
Result<IpVersion> parseIpVersion(int raw) {
  return switch (raw) {
    0 => const Result.success(IpVersion.unknown),
    1 => const Result.success(IpVersion.ipv4),
    2 => const Result.success(IpVersion.ipv6),
    _ => Result.failure(InvalidIpVersionError(value: raw)),
  };
}

/// Field key constant for the container identifier.
const String kFieldContainerId = 'containerId';
/// Field key constant for the IP version code.
const String kFieldIpVersion = 'ipVersion';
/// Field key constant for the IP-version neutral address.
const String kFieldIpAddress = 'ipAddress';
/// Field key constant for the IPv4 address in dotted-quad notation.
const String kFieldIpv4Address = 'ipv4Address';
/// Field key constant for the IPv6 address in colon-hex notation.
const String kFieldIpv6Address = 'ipv6Address';
/// Field key constant for the IP-version neutral prefix.
const String kFieldIpPrefix = 'ipPrefix';
/// Field key constant for the IPv4 prefix in dotted-quad/prefix-length format.
const String kFieldIpv4Prefix = 'ipv4Prefix';
/// Field key constant for the IPv6 prefix in colon-hex/prefix-length format.
const String kFieldIpv6Prefix = 'ipv6Prefix';
/// Field key constant for the IP-version neutral address strictly without zone index.
const String kFieldIpAddressNoZone = 'ipAddressNoZone';
/// Field key constant for the IPv4 address in dotted-quad format without zone index.
const String kFieldIpv4AddressNoZone = 'ipv4AddressNoZone';
/// Field key constant for the IPv6 address in colon-hex format without zone index.
const String kFieldIpv6AddressNoZone = 'ipv6AddressNoZone';

/// Realises: [Feat-020/IpAddressTypes]
///
/// Domain model aggregating the ten IP address textual conventions
/// defined in ietf-inet-types (RFC 6021):
/// ip-version, ip-address, ipv4-address, ipv6-address, ip-prefix,
/// ipv4-prefix, ipv6-prefix, ip-address-no-zone, ipv4-address-no-zone,
/// ipv6-address-no-zone.
///
/// All fields are nullable [String] except [containerId] and [ipVersion]
/// which have defaults. The model captures a complete snapshot of one
/// IP address configuration record.
@immutable
class IpAddressTypes {
  /// Container identifier for database indexing.
  final String containerId;

  /// Integer IP version code (0=unknown, 1=ipv4, 2=ipv6).
  final int ipVersion;

  /// IP-version neutral address with optional zone index.
  final String? ipAddress;

  /// IPv4 address in dotted-quad notation with optional %zone.
  final String? ipv4Address;

  /// IPv6 address in colon-hex notation with optional %zone.
  final String? ipv6Address;

  /// IP-version neutral prefix (IPv4 /0..32 or IPv6 /0..128).
  final String? ipPrefix;

  /// IPv4 prefix in dotted-quad/prefix-length format.
  final String? ipv4Prefix;

  /// IPv6 prefix in colon-hex/prefix-length format.
  final String? ipv6Prefix;

  /// IP-version neutral address strictly without zone index.
  final String? ipAddressNoZone;

  /// IPv4 address in dotted-quad format, rejecting %zone.
  final String? ipv4AddressNoZone;

  /// IPv6 address in colon-hex format, rejecting %zone.
  final String? ipv6AddressNoZone;

  /// Creates a new [IpAddressTypes] instance.
  const IpAddressTypes({
    this.containerId = 'default',
    this.ipVersion = 0,
    this.ipAddress,
    this.ipv4Address,
    this.ipv6Address,
    this.ipPrefix,
    this.ipv4Prefix,
    this.ipv6Prefix,
    this.ipAddressNoZone,
    this.ipv4AddressNoZone,
    this.ipv6AddressNoZone,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IpAddressTypes &&
        other.containerId == containerId &&
        other.ipVersion == ipVersion &&
        other.ipAddress == ipAddress &&
        other.ipv4Address == ipv4Address &&
        other.ipv6Address == ipv6Address &&
        other.ipPrefix == ipPrefix &&
        other.ipv4Prefix == ipv4Prefix &&
        other.ipv6Prefix == ipv6Prefix &&
        other.ipAddressNoZone == ipAddressNoZone &&
        other.ipv4AddressNoZone == ipv4AddressNoZone &&
        other.ipv6AddressNoZone == ipv6AddressNoZone;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        ipVersion,
        ipAddress,
        ipv4Address,
        ipv6Address,
        ipPrefix,
        ipv4Prefix,
        ipv6Prefix,
        ipAddressNoZone,
        ipv4AddressNoZone,
        ipv6AddressNoZone,
      );
}

/// Realises: [Feat-020/Ipv4Address]
/// Realises: [Feat-020/Ipv6Address]
///
/// Removes the zone index suffix from a scoped IP address string.
///
/// If [input] contains a `%` character, returns the substring before the
/// first `%`. Otherwise returns [input] unchanged.
String stripZoneIndex(String input) {
  final idx = input.indexOf('%');
  if (idx >= 0) return input.substring(0, idx);
  return input;
}

/// Realises: [Feat-020/Ipv4Address]
/// Realises: [Feat-020/Ipv6Address]
///
/// Returns `true` if [input] contains a `%` character indicating
/// the presence of a zone index suffix.
bool hasZoneIndex(String input) {
  return input.contains('%');
}

/// Realises: [Feat-020/Ipv4Prefix]
/// Realises: [Feat-020/Ipv6Prefix]
///
/// Determines the IP version of an address or prefix string by
/// inspecting its format.
///
/// Returns `'ipv4'` for dotted-quad strings, `'ipv6'` for colon-delimited
/// strings, or `'unknown'` if neither pattern matches.
String determineIpVersionStr(String input) {
  if (input.isEmpty) return 'unknown';
  if (input.contains(':')) return 'ipv6';
  if (RegExp(r'^\d+\.\d+\.\d+\.\d+').hasMatch(input)) return 'ipv4';
  return 'unknown';
}

/// The octet part of an IPv4 address: a number 0–255 with no leading
/// zeros beyond the single digit 0.
///
/// Pattern: `0` OR `[1-9][0-9]?` OR `1[0-9]{2}` OR `2[0-4][0-9]` OR `25[0-5]`.
const String _ipv4OctetPattern =
    r'(?:0|(?:[1-9][0-9]?)|(?:1[0-9]{2})|(?:2[0-4][0-9])|(?:25[0-5]))';

/// The full dotted-quad pattern (four octets separated by dots).
///
/// Built from four repetitions of [_ipv4OctetPattern] joined by `\.`.
const String _ipv4DottedQuadPattern =
    '^$_ipv4OctetPattern\\.$_ipv4OctetPattern\\.$_ipv4OctetPattern\\.$_ipv4OctetPattern';

/// Optional zone index suffix: `%` followed by one or more alphanumeric
/// characters. Dart does not support `\p{N}\p{L}`, so we approximate
/// with `[a-zA-Z0-9_]+` which covers interface names like `eth0`, `lo0`,
/// and numeric indices.
const String _zoneIndexPattern = r'(?:%[a-zA-Z0-9_]+)?';

final RegExp _ipv4AddressRegex =
    RegExp('$_ipv4DottedQuadPattern$_zoneIndexPattern\$');
final RegExp _ipv4AddressNoZoneRegex = RegExp('$_ipv4DottedQuadPattern\$');

/// A hex group in an IPv6 address: 1–4 hex digits (case-insensitive).
const String _hexGroup = r'[0-9a-fA-F]{1,4}';

/// Matches a full (non-compressed) IPv6 address: 8 hex groups separated
/// by colons, with an optional trailing dotted-quad for IPv4-mapped addresses.
final RegExp _ipv6FullRegex = RegExp(
  '^$_hexGroup(?::$_hexGroup){7}'
  r'(?:\.[0-9a-fA-F]{1,4})?' // optional trailing dotted-quad
  r'(?:%[a-zA-Z0-9_]+)?\$$',
);

/// Validates an IPv6 address string by decomposing it and checking
/// group counts rather than using the full complex RFC 6021 regex.
///
/// Supports: full (8 groups), compressed (::), loopback (::1), and
/// IPv4-mapped formats. Approximates `\p{N}\p{L}` with `[a-zA-Z0-9_]`
/// for the zone index since Dart does not support Unicode character
/// class escapes.
bool _isValidIpv6(String input) {
  if (input.isEmpty) return false;

  final zoneIndex = input.indexOf('%');
  var addr = input;
  if (zoneIndex >= 0) {
    addr = input.substring(0, zoneIndex);
  }

  if (addr.isEmpty) return false;

  // Count :: occurrences — at most one allowed
  final doubleColons = '::'.allMatches(addr).length;
  if (doubleColons > 1) return false;

  // Split on :: if present
  final parts = addr.split('::');
  if (parts.length > 2) return false;

  // Collect groups from each part
  final leftGroups = parts.isNotEmpty ? parts[0].split(':') : <String>[];
  final rightGroups = parts.length > 1 ? parts[1].split(':') : <String>[];

  // Remove empty strings from edge cases like "::1" → ["", "1"]
  final filteredLeft =
      leftGroups.where((g) => g.isNotEmpty).toList();
  final filteredRight =
      rightGroups.where((g) => g.isNotEmpty).toList();

  final hasCompression = doubleColons == 1;

  if (hasCompression) {
    // With compression, groups on both sides must be <= 7 total
    if (filteredLeft.length + filteredRight.length > 7) return false;
  } else {
    // Without compression, must have exactly 8 groups
    if (filteredLeft.length != 8) return false;
  }

  // Validate each hex group (1-4 hex digits) or dotted-quad
  final hexGroupRe = RegExp('^$_hexGroup\$');
  final ipv4Re = RegExp(
      '^$_ipv4OctetPattern\\.$_ipv4OctetPattern\\.$_ipv4OctetPattern\\.$_ipv4OctetPattern\$');

  for (final group in [...filteredLeft, ...filteredRight]) {
    if (hexGroupRe.hasMatch(group)) continue;
    if (ipv4Re.hasMatch(group)) continue;
    return false;
  }

  return true;
}

/// Realises: [Feat-020/Ipv6Address]
///
/// Validates an IPv6 address string in colon-hex notation supporting
/// full (8 groups), compressed (::), and IPv4-mapped formats, with an
/// optional `%`-separated zone index.
///
/// Each hex group is 1–4 valid hex digits. At most one `::` compression
/// is permitted. The optional zone index follows a `%` delimiter.
///
/// Returns [Success] with the input string if valid, or [Failure] with
/// [InvalidIpv6FormatError] if the format is invalid.
Result<String> validateIpv6Address(String input) {
  if (_isValidIpv6(input)) {
    return Result.success(input);
  }
  return Result.failure(InvalidIpv6FormatError(input: input));
}

/// Realises: [Feat-020/Ipv6AddressNoZone]
///
/// Validates an IPv6 address string that explicitly excludes zone indices.
///
/// Same format rules as [validateIpv6Address] but the `%` character
/// triggers a [ZoneIndexDisallowedError].
///
/// Returns [Success] with the input if valid, or [Failure] with the
/// appropriate error.
Result<String> validateIpv6AddressNoZone(String input) {
  if (input.contains('%')) {
    return Result.failure(ZoneIndexDisallowedError(input: input));
  }
  if (_isValidIpv6(input)) {
    return Result.success(input);
  }
  return Result.failure(InvalidIpv6FormatError(input: input));
}

/// Realises: [Feat-020/Ipv4Prefix]
///
/// Validates an IPv4 prefix string in dotted-quad/prefix-length format
/// (e.g. `"192.168.1.0/24"`).
///
/// The prefix length must be in range 0–32 inclusive. The IPv4 address
/// component is validated via [validateIpv4Address] without zone index.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [InvalidIpv4FormatError] or [Ipv4PrefixLengthOutOfBoundsError].
Result<String> validateIpv4Prefix(String input) {
  final lastSlash = input.lastIndexOf('/');
  if (lastSlash < 0) {
    return Result.failure(InvalidIpv4FormatError(input: input));
  }
  final addrPart = input.substring(0, lastSlash);
  final lenPart = input.substring(lastSlash + 1);

  final length = int.tryParse(lenPart);
  if (length == null || length < 0 || length > 32) {
    return Result.failure(Ipv4PrefixLengthOutOfBoundsError(
      length: length ?? -1,
    ));
  }

  final addrResult = validateIpv4AddressNoZone(addrPart);
  if (addrResult.isFailure) {
    return Result.failure(InvalidIpv4FormatError(input: input));
  }

  return Result.success(input);
}

/// Realises: [Feat-020/Ipv6Prefix]
///
/// Validates an IPv6 prefix string in colon-hex/prefix-length format
/// (e.g. `"2001:db8::/64"`).
///
/// The prefix length must be in range 0–128 inclusive. The IPv6 address
/// component is validated via [validateIpv6Address] without zone index.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [InvalidIpv6FormatError] or [Ipv6PrefixLengthOutOfBoundsError].
Result<String> validateIpv6Prefix(String input) {
  final lastSlash = input.lastIndexOf('/');
  if (lastSlash < 0) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }
  final addrPart = input.substring(0, lastSlash);
  final lenPart = input.substring(lastSlash + 1);

  final length = int.tryParse(lenPart);
  if (length == null || length < 0 || length > 128) {
    return Result.failure(Ipv6PrefixLengthOutOfBoundsError(
      length: length ?? -1,
    ));
  }

  final addrResult = validateIpv6AddressNoZone(addrPart);
  if (addrResult.isFailure) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }

  return Result.success(input);
}

/// Realises: [Feat-020/IpAddress]
///
/// Validates an IP address string by dispatching to the appropriate
/// version-specific validator.
///
/// Uses [determineIpVersionStr] to detect the format, then delegates
/// to [validateIpv4Address] or [validateIpv6Address]. Returns
/// [Failure] with [InvalidIpv4FormatError] if version is unknown.
///
/// Returns [Success] with the input if valid, or [Failure] with the
/// appropriate error.
Result<String> validateIpAddress(String input) {
  final version = determineIpVersionStr(input);
  return switch (version) {
    'ipv4' => validateIpv4Address(input),
    'ipv6' => validateIpv6Address(input),
    _ => Result.failure(InvalidIpv4FormatError(input: input)),
  };
}

/// Realises: [Feat-020/IpPrefix]
///
/// Validates an IP prefix string by dispatching to the appropriate
/// version-specific prefix validator.
///
/// Uses [determineIpVersionStr] on the address component (before `/`)
/// to detect the format, then delegates to [validateIpv4Prefix] or
/// [validateIpv6Prefix].
///
/// Returns [Success] with the input if valid, or [Failure] with the
/// appropriate error.
Result<String> validateIpPrefix(String input) {
  final lastSlash = input.lastIndexOf('/');
  if (lastSlash < 0) {
    return Result.failure(InvalidIpv4FormatError(input: input));
  }
  final addrPart = input.substring(0, lastSlash);
  final version = determineIpVersionStr(addrPart);
  return switch (version) {
    'ipv4' => validateIpv4Prefix(input),
    'ipv6' => validateIpv6Prefix(input),
    _ => Result.failure(InvalidIpv4FormatError(input: input)),
  };
}

/// Realises: [Feat-020/Ipv4Address]
///
/// Validates an IPv4 address string in dotted-quad notation with an
/// optional `%`-separated zone index.
///
/// Each octet must be in range 0–255. Leading zeros beyond a single
/// digit are considered invalid. The optional zone index suffix
/// follows a `%` delimiter.
///
/// Returns [Success] with the input string if valid, or [Failure] with
/// [InvalidIpv4FormatError] if the format is invalid.
Result<String> validateIpv4Address(String input) {
  if (_ipv4AddressRegex.hasMatch(input)) {
    return Result.success(input);
  }
  return Result.failure(InvalidIpv4FormatError(input: input));
}

/// Realises: [Feat-020/Ipv4AddressNoZone]
///
/// Validates an IPv4 address string that explicitly excludes zone indices.
///
/// The address must be in dotted-quad notation (0–255 per octet, no
/// leading zeros beyond single 0). The `%` character triggers a
/// [ZoneIndexDisallowedError].
///
/// Returns [Success] with the input string if valid, or [Failure] with
/// the appropriate error.
Result<String> validateIpv4AddressNoZone(String input) {
  if (input.contains('%')) {
    return Result.failure(ZoneIndexDisallowedError(input: input));
  }
  if (_ipv4AddressNoZoneRegex.hasMatch(input)) {
    return Result.success(input);
  }
  return Result.failure(InvalidIpv4FormatError(input: input));
}
