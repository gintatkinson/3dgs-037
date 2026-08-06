import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-023/IpScopeType]
///
/// Enumerates architectural scope identifiers for scoped IP addresses
/// as defined in RFC 4007 and RFC 4291.
///
/// Each scope maps to its 4-bit scope code as embedded in IPv6
/// multicast headers.
enum IpScopeType {
  /// Interface-local scope. Scope code 1.
  interfaceLocal,

  /// Link-local scope. Scope code 2.
  linkLocal,

  /// Admin-local scope. Scope code 4.
  adminLocal,

  /// Site-local scope. Scope code 5.
  siteLocal,

  /// Organization-local scope. Scope code 8.
  organizationLocal,

  /// Global scope. Scope code 14.
  global,
}

/// Realises: [Feat-023/IpScopeType]
///
/// Returns the 4-bit scope code associated with [scope].
int ipScopeTypeCode(IpScopeType scope) {
  return switch (scope) {
    IpScopeType.interfaceLocal => 1,
    IpScopeType.linkLocal => 2,
    IpScopeType.adminLocal => 4,
    IpScopeType.siteLocal => 5,
    IpScopeType.organizationLocal => 8,
    IpScopeType.global => 14,
  };
}

/// Realises: [Feat-023/IpScopeType]
///
/// Returns `true` when [scope] is [IpScopeType.global].
bool isGlobalScope(IpScopeType scope) => scope == IpScopeType.global;

/// Field key constant for the container identifier.
const String kFieldContainerId = 'containerId';
/// Field key constant for the IPv6 flow label.
const String kFieldIpv6FlowLabel = 'ipv6FlowLabel';
/// Field key constant for the Differentiated Services Code Point.
const String kFieldDscp = 'dscp';
/// Field key constant for the IP unicast address.
const String kFieldIpUnicastAddress = 'ipUnicastAddress';
/// Field key constant for the IPv4 unicast address.
const String kFieldIpv4UnicastAddress = 'ipv4UnicastAddress';
/// Field key constant for the IPv6 unicast address.
const String kFieldIpv6UnicastAddress = 'ipv6UnicastAddress';
/// Field key constant for the IP multicast group address.
const String kFieldIpMulticastAddress = 'ipMulticastAddress';
/// Field key constant for the IPv4 multicast address.
const String kFieldIpv4MulticastAddress = 'ipv4MulticastAddress';
/// Field key constant for the IPv6 multicast address.
const String kFieldIpv6MulticastAddress = 'ipv6MulticastAddress';
/// Field key constant for the architectural scope identifier.
const String kFieldScopeType = 'scopeType';

/// Realises: [Feat-023/IpUnicastMulticastAndScopeTypes]
///
/// Domain model aggregating the IP unicast, multicast, flow label,
/// DSCP, and scope data types defined in ietf-inet-types (RFC 6021).
///
/// All fields are nullable except [ipv6FlowLabel] and [dscp] which
/// are required by the payload schema. The model captures a complete
/// snapshot of one unicast-multicast-scope configuration record.
@immutable
class IpUnicastMulticastAndScopeTypes {
  /// Container identifier for database indexing.
  final String containerId;

  /// IPv6 flow label (20-bit unsigned integer, 0–1048575).
  final int ipv6FlowLabel;

  /// Differentiated Services Code Point (6-bit, 0–63).
  final int dscp;

  /// IP unicast address (IPv4 dotted-quad or IPv6 colon-hex).
  final String? ipUnicastAddress;

  /// IPv4 unicast address excluding 224.0.0.0/4.
  final String? ipv4UnicastAddress;

  /// IPv6 unicast address excluding ff00::/8.
  final String? ipv6UnicastAddress;

  /// IP multicast group address.
  final String? ipMulticastAddress;

  /// IPv4 multicast address within 224.0.0.0/4.
  final String? ipv4MulticastAddress;

  /// IPv6 multicast address with ff00::/8 prefix.
  final String? ipv6MulticastAddress;

  /// Architectural scope identifier for scoped addresses.
  final String? scopeType;

  /// Creates a new [IpUnicastMulticastAndScopeTypes] instance.
  const IpUnicastMulticastAndScopeTypes({
    this.containerId = 'default',
    this.ipv6FlowLabel = 0,
    this.dscp = 0,
    this.ipUnicastAddress,
    this.ipv4UnicastAddress,
    this.ipv6UnicastAddress,
    this.ipMulticastAddress,
    this.ipv4MulticastAddress,
    this.ipv6MulticastAddress,
    this.scopeType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IpUnicastMulticastAndScopeTypes &&
        other.containerId == containerId &&
        other.ipv6FlowLabel == ipv6FlowLabel &&
        other.dscp == dscp &&
        other.ipUnicastAddress == ipUnicastAddress &&
        other.ipv4UnicastAddress == ipv4UnicastAddress &&
        other.ipv6UnicastAddress == ipv6UnicastAddress &&
        other.ipMulticastAddress == ipMulticastAddress &&
        other.ipv4MulticastAddress == ipv4MulticastAddress &&
        other.ipv6MulticastAddress == ipv6MulticastAddress &&
        other.scopeType == scopeType;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        ipv6FlowLabel,
        dscp,
        ipUnicastAddress,
        ipv4UnicastAddress,
        ipv6UnicastAddress,
        ipMulticastAddress,
        ipv4MulticastAddress,
        ipv6MulticastAddress,
        scopeType,
      );
}

/// Realises: [Feat-023/IpFlowLabel]
///
/// Validates that [input] is within the 20-bit range 0–1048575.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [IpFlowLabelOutOfBoundsError] when the value is negative or
/// exceeds the 20-bit maximum.
Result<int> validateIpv6FlowLabel(int input) {
  if (input < 0 || input > 1048575) {
    return Result.failure(IpFlowLabelOutOfBoundsError(value: input));
  }
  return Result.success(input);
}

/// Realises: [Feat-023/Dscp]
///
/// Validates that [input] is within the 6-bit range 0–63.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [DscpOutOfBoundsError] when the value is negative or exceeds
/// the 6-bit maximum.
Result<int> validateDscp(int input) {
  if (input < 0 || input > 63) {
    return Result.failure(DscpOutOfBoundsError(value: input));
  }
  return Result.success(input);
}

/// The octet part of an IPv4 address: a number 0–255 with no leading
/// zeros beyond the single digit 0.
const String _ipv4OctetPattern =
    r'(?:0|(?:[1-9][0-9]?)|(?:1[0-9]{2})|(?:2[0-4][0-9])|(?:25[0-5]))';

/// The full dotted-quad pattern (four octets separated by dots).
const String _ipv4DottedQuadPattern =
    '^$_ipv4OctetPattern\\.$_ipv4OctetPattern\\.$_ipv4OctetPattern\\.$_ipv4OctetPattern\$';

final RegExp _ipv4DottedQuadRe = RegExp(_ipv4DottedQuadPattern);

/// A hex group in an IPv6 address: 1–4 hex digits (case-insensitive).
const String _hexGroup = r'[0-9a-fA-F]{1,4}';

/// Returns `true` when [input] is a valid dotted-quad IPv4 address
/// (each octet 0–255, no leading zeros beyond single zero).
bool _isValidIpv4DottedQuad(String input) {
  return _ipv4DottedQuadRe.hasMatch(input);
}

/// Returns `true` when [octet] (a string) is in range 0–255.
bool _isValidIpv4OctetRange(String octet) {
  final n = int.tryParse(octet);
  if (n == null) return false;
  return n >= 0 && n <= 255;
}

/// Returns `true` if [input] falls within the IPv4 multicast block
/// 224.0.0.0–239.255.255.255 as a dotted-quad string.
bool _isIpv4Multicast(String input) {
  final cleaned = input.split('%').first;
  final parts = cleaned.split('.');
  if (parts.length != 4) return false;
  final first = int.tryParse(parts[0]);
  if (first == null) return false;
  if (first < 224 || first > 239) return false;
  for (final p in parts) {
    if (!_isValidIpv4OctetRange(p)) return false;
  }
  return true;
}

/// Returns `true` when [input] starts with `ff` (case-insensitive)
/// followed by a valid hex character, indicating IPv6 multicast.
bool _isIpv6Multicast(String input) {
  final cleaned = input.split('%').first;
  if (cleaned.length < 2) return false;
  final firstTwo = cleaned.substring(0, 2);
  return (firstTwo == 'ff' || firstTwo == 'FF') &&
      RegExp(r'^[fF][fF][0-9a-fA-F]').hasMatch(cleaned.substring(0, 3));
}

/// Validates an IPv6 address string by checking hex group structure
/// and compression rules. Supports full (8 groups), compressed (::),
/// loopback (::1), and IPv4-mapped formats.
bool _isValidIpv6(String input) {
  final zoneIndex = input.indexOf('%');
  var addr = input;
  if (zoneIndex >= 0) {
    addr = input.substring(0, zoneIndex);
  }
  if (addr.isEmpty) return false;

  final doubleColons = '::'.allMatches(addr).length;
  if (doubleColons > 1) return false;

  final parts = addr.split('::');
  if (parts.length > 2) return false;

  final leftGroups = parts.isNotEmpty ? parts[0].split(':') : <String>[];
  final rightGroups = parts.length > 1 ? parts[1].split(':') : <String>[];

  final filteredLeft = leftGroups.where((g) => g.isNotEmpty).toList();
  final filteredRight = rightGroups.where((g) => g.isNotEmpty).toList();

  final hasCompression = doubleColons == 1;
  if (hasCompression) {
    if (filteredLeft.length + filteredRight.length > 7) return false;
  } else {
    if (filteredLeft.length != 8) return false;
  }

  final hexGroupRe = RegExp('^$_hexGroup\$');
  for (final group in [...filteredLeft, ...filteredRight]) {
    if (!hexGroupRe.hasMatch(group)) return false;
  }

  return true;
}

/// Realises: [Feat-023/Ipv4UnicastAddress]
///
/// Validates an IPv4 unicast address string in dotted-quad notation.
/// The address must be a valid IPv4 address AND must not fall within
/// the multicast block 224.0.0.0/4.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [InvalidIpv4FormatError] or [InvalidUnicastAddressError].
Result<String> validateIpv4UnicastAddress(String input) {
  final cleaned = input.split('%').first;
  if (!_isValidIpv4DottedQuad(cleaned)) {
    return Result.failure(InvalidIpv4FormatError(input: input));
  }
  if (_isIpv4Multicast(cleaned)) {
    return Result.failure(InvalidUnicastAddressError(input: input));
  }
  return Result.success(input);
}

/// Realises: [Feat-023/Ipv6UnicastAddress]
///
/// Validates an IPv6 unicast address string.
/// The address must be a valid IPv6 address AND must not start with
/// the multicast prefix ff00::/8.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [InvalidIpv6FormatError] or [InvalidUnicastAddressError].
Result<String> validateIpv6UnicastAddress(String input) {
  if (!_isValidIpv6(input)) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }
  if (_isIpv6Multicast(input)) {
    return Result.failure(InvalidUnicastAddressError(input: input));
  }
  return Result.success(input);
}

/// Realises: [Feat-023/Ipv4MulticastAddress]
///
/// Validates an IPv4 multicast address string in dotted-quad notation.
/// The address MUST be within the IPv4 multicast range 224.0.0.0/4.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [InvalidIpv4FormatError] or [InvalidMulticastAddressError].
Result<String> validateIpv4MulticastAddress(String input) {
  final cleaned = input.split('%').first;
  if (!_isValidIpv4DottedQuad(cleaned)) {
    return Result.failure(InvalidIpv4FormatError(input: input));
  }
  if (!_isIpv4Multicast(cleaned)) {
    return Result.failure(InvalidMulticastAddressError(input: input));
  }
  return Result.success(input);
}

/// Realises: [Feat-023/Ipv6MulticastAddress]
///
/// Validates an IPv6 multicast address string.
/// The address MUST be a valid IPv6 address AND must start with
/// the multicast prefix ff00::/8.
///
/// Returns [Success] with the input if valid, or [Failure] with
/// [InvalidIpv6FormatError] or [InvalidMulticastAddressError].
Result<String> validateIpv6MulticastAddress(String input) {
  if (!_isValidIpv6(input)) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }
  if (!_isIpv6Multicast(input)) {
    return Result.failure(InvalidMulticastAddressError(input: input));
  }
  return Result.success(input);
}

/// Realises: [Feat-023/IpScopeType]
///
/// Parses a scope identifier string into an [IpScopeType] enum value.
///
/// Accepts the architectural scope names: interface-local, link-local,
/// admin-local, site-local, organization-local, global.
///
/// Returns [Success] with the [IpScopeType] if valid, or [Failure] with
/// [UnresolvableScopeTypeError].
Result<IpScopeType> validateScopeType(String input) {
  return switch (input) {
    'interface-local' => const Result.success(IpScopeType.interfaceLocal),
    'link-local' => const Result.success(IpScopeType.linkLocal),
    'admin-local' => const Result.success(IpScopeType.adminLocal),
    'site-local' => const Result.success(IpScopeType.siteLocal),
    'organization-local' =>
      const Result.success(IpScopeType.organizationLocal),
    'global' => const Result.success(IpScopeType.global),
    _ => Result.failure(UnresolvableScopeTypeError(value: input)),
  };
}

/// Realises: [Feat-023/IpAddressClassification]
///
/// Classifies an IP address string by version and addressing mode.
///
/// Returns a short classification string:
/// - `'ipv4-unicast'` — valid IPv4 not in 224.0.0.0/4
/// - `'ipv4-multicast'` — valid IPv4 in 224.0.0.0/4
/// - `'ipv6-unicast'` — valid IPv6 not in ff00::/8
/// - `'ipv6-multicast'` — valid IPv6 in ff00::/8
/// - `'unknown'` — unrecognized format
String classifyIpAddress(String input) {
  final cleaned = input.split('%').first;
  // Check IPv4
  if (_isValidIpv4DottedQuad(cleaned)) {
    return _isIpv4Multicast(cleaned) ? 'ipv4-multicast' : 'ipv4-unicast';
  }
  // Check IPv6
  if (_isValidIpv6(input)) {
    return _isIpv6Multicast(input) ? 'ipv6-multicast' : 'ipv6-unicast';
  }
  return 'unknown';
}

/// Realises: [Feat-023/IpScopeType]
/// Realises: [Feat-023/IpMulticastAddress]
///
/// Extracts the 4-bit multicast scope field from an IPv6 multicast
/// address.
///
/// For an address like `ff02::1`, the scope is encoded in the 3rd and
/// 4th hex digits (here `02` → scope code 2 → `link-local`).
///
/// Returns [Success] with the [IpScopeType] if the scope can be resolved,
/// or [Failure] with [InvalidIpv6FormatError] or [UnresolvableScopeTypeError].
Result<IpScopeType> getMulticastScope(String input) {
  final cleaned = input.split('%').first;
  if (!_isIpv6Multicast(input)) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }
  if (cleaned.length < 4) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }
  final scopeHex = cleaned.substring(2, 4);
  final scopeCode = int.tryParse(scopeHex, radix: 16);
  if (scopeCode == null) {
    return Result.failure(InvalidIpv6FormatError(input: input));
  }
  return switch (scopeCode) {
    1 => const Result.success(IpScopeType.interfaceLocal),
    2 => const Result.success(IpScopeType.linkLocal),
    4 => const Result.success(IpScopeType.adminLocal),
    5 => const Result.success(IpScopeType.siteLocal),
    8 => const Result.success(IpScopeType.organizationLocal),
    14 => const Result.success(IpScopeType.global),
    _ => Result.failure(UnresolvableScopeTypeError(value: input)),
  };
}
