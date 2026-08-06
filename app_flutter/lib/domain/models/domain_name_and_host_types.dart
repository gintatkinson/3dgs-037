import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Field key constant for the container identifier.
const String kFieldContainerId = 'containerId';
/// Field key constant for the DNS domain name.
const String kFieldDomainName = 'domainName';
/// Field key constant for the host identifier.
const String kFieldHost = 'host';
/// Field key constant for the URI identifier.
const String kFieldUri = 'uri';

/// Realises: [Feat-021/DomainNameAndHostTypes]
///
/// Domain model aggregating the three domain name, host, and URI textual
/// conventions defined in ietf-inet-types (RFC 6021):
/// domain-name, host, uri.
///
/// Captures a complete snapshot of one domain-name-and-host configuration
/// record with nullable [String] fields except [containerId] which has a
/// default. The model is immutable with value equality.
@immutable
class DomainNameAndHostTypes {
  /// Container identifier for database indexing.
  final String containerId;

  /// The domain name string conforming to RFC 1034/RFC 1123 syntax.
  final String domainName;

  /// The host identifier, either an IP address or domain name.
  final String host;

  /// The Uniform Resource Identifier conforming to RFC 3986.
  final String uri;

  /// Creates a new [DomainNameAndHostTypes] instance.
  const DomainNameAndHostTypes({
    this.containerId = 'default',
    this.domainName = '',
    this.host = '',
    this.uri = '',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DomainNameAndHostTypes &&
        other.containerId == containerId &&
        other.domainName == domainName &&
        other.host == host &&
        other.uri == uri;
  }

  @override
  int get hashCode => Object.hash(containerId, domainName, host, uri);
}

/// The YANG pattern for domain-name from RFC 6021 § domain-name typedef.
///
/// Accommodates DNS domain names including SRV records, fully qualified
/// names with trailing dots, and root domain `.`.
///
/// Pattern (verbatim from YANG):
///   '((([a-zA-Z0-9_]([a-zA-Z0-9\-_]){0,61})?[a-zA-Z0-9]\.)*'
///   + '([a-zA-Z0-9_]([a-zA-Z0-9\-_]){0,61})?[a-zA-Z0-9]\.?)'
///   + '|\.'
const String _domainNamePattern =
    r'^((([a-zA-Z0-9_]([a-zA-Z0-9\-_]){0,61})?[a-zA-Z0-9]\.)*'
    r'([a-zA-Z0-9_]([a-zA-Z0-9\-_]){0,61})?[a-zA-Z0-9]\.?)$'
    r'|^\.$';

final RegExp _domainNameRegex = RegExp(_domainNamePattern);

/// Maximum total length of a domain name in textual dotted notation.
///
/// RFC 1034 § 3.1 limits the DNS wire format to 255 octets. With label
/// length prefixes and a trailing null byte, at most 253 characters can
/// appear in the dotted textual form.
const int _domainNameMaxLength = 253;

/// Maximum length of a single domain name label per RFC 1034.
const int _domainNameMaxLabelLength = 63;

/// Reserved US-ASCII unreserved characters (RFC 3986 § 2.3) that may be
/// decoded during percent-encoding normalization.
///
/// Alpha, digit, hyphen, period, underscore, tilde.
const String _unreservedChars = r'A-Za-z0-9\-._~';

/// Realises: [Feat-021/validateDomainName]
///
/// Validates a [domainName] string against the ietf-inet-types domain-name
/// YANG pattern and length constraints.
///
/// Rules:
/// - Length must be 1..253 characters.
/// - Must match the RFC 952 / RFC 1034 domain name pattern.
/// - Each label must be 1..63 characters.
/// - Labels must not start or end with a hyphen.
/// - US-ASCII encoding; IDN values must be A-labels (punycode).
///
/// Returns [Success] with the validated string, or [Failure] with
/// [DomainNameLengthExceededError] or [InvalidLabelSyntaxError].
Result<String> validateDomainName(String domainName) {
  if (domainName.isEmpty || domainName.length > _domainNameMaxLength) {
    return Result.failure(
        DomainNameLengthExceededError(length: domainName.length));
  }

  if (domainName == '.') {
    return Result.success(domainName);
  }

  if (!_domainNameRegex.hasMatch(domainName)) {
    return Result.failure(InvalidLabelSyntaxError(label: domainName));
  }

  if (!_validateDomainNameLabels(domainName)) {
    return Result.failure(InvalidLabelSyntaxError(label: domainName));
  }

  return Result.success(domainName);
}

/// Validates individual labels of a dotted domain name.
///
/// Each label must be 1..63 characters. A label must not start or end
/// with a hyphen. A label must not be empty (consecutive dots).
bool _validateDomainNameLabels(String domainName) {
  final stripTrailing = domainName.endsWith('.')
      ? domainName.substring(0, domainName.length - 1)
      : domainName;
  final labels = stripTrailing.split('.');
  for (final label in labels) {
    if (label.isEmpty || label.length > _domainNameMaxLabelLength) {
      return false;
    }
    if (label.startsWith('-') || label.endsWith('-')) {
      return false;
    }
  }
  return true;
}

/// Realises: [Feat-021/canonicalizeDomainName]
///
/// Converts a valid domain name to lowercase US-ASCII canonical form.
///
/// Validates the input first via [validateDomainName]. On success,
/// lowercases the entire string. Returns [Success] with the canonical
/// form or [Failure] with the validation error.
Result<String> canonicalizeDomainName(String input) {
  final validateResult = validateDomainName(input);
  if (validateResult.isFailure) {
    return validateResult;
  }
  return Result.success(input.toLowerCase());
}

/// Realises: [Feat-021/validateHost]
///
/// Validates a [host] string by trying each member type of the YANG
/// host union in order: IPv4 address → IPv6 address → domain name.
///
/// Returns [Success] with the validated string if any validator accepts
/// it, or [Failure] with [InvalidHostFormatError] if all reject it.
Result<String> validateHost(String input) {
  if (input.isEmpty) {
    return Result.failure(InvalidHostFormatError(input: input));
  }

  final ipv4Result = validateIpv4Address(input);
  if (ipv4Result.isSuccess) return Result.success(input);

  final ipv6Result = validateIpv6Address(input);
  if (ipv6Result.isSuccess) return Result.success(input);

  final domainResult = validateDomainName(input);
  if (domainResult.isSuccess) return Result.success(input);

  return Result.failure(InvalidHostFormatError(input: input));
}

/// Realises: [Feat-021/validateUri]
///
/// Validates a URI string against STD 66 / RFC 3986 constraints.
///
/// Rules:
/// - Length must be ≥ 1 (zero-length is invalid).
/// - Must be US-ASCII encoded (no non-ASCII characters).
/// - Must conform to basic URI syntax.
///
/// Returns [Success] with the validated string, or [Failure] with
/// [UriZeroLengthError] or [UriNonAsciiError].
Result<String> validateUri(String input) {
  if (input.isEmpty) {
    return Result.failure(const UriZeroLengthError());
  }

  if (!_isAscii(input)) {
    return Result.failure(UriNonAsciiError(input: input));
  }

  if (input.contains(RegExp(r'\s'))) {
    return Result.failure(UriNonAsciiError(input: input));
  }

  return Result.success(input);
}

/// Returns true if all characters in [input] are US-ASCII (code points
/// 0x00–0x7F inclusive).
bool _isAscii(String input) {
  for (var i = 0; i < input.length; i++) {
    if (input.codeUnitAt(i) > 127) {
      return false;
    }
  }
  return true;
}

/// Realises: [Feat-021/normalizeUri]
///
/// Applies RFC 3986 normalization procedures to [input]:
///
/// - Case normalization: scheme and host components lowercased.
/// - Percent-encoding normalization: unreserved characters decoded,
///   hexadecimal digits uppercased (Section 6.2.2.1).
///
/// Validates the input first via [validateUri]. On success, performs
/// normalization and returns [Success] with the normalized string.
Result<String> normalizeUri(String input) {
  final validateResult = validateUri(input);
  if (validateResult.isFailure) {
    return validateResult;
  }

  final result = _rfc3986Normalize(input);
  return Result.success(result);
}

/// Normalises a US-ASCII URI string per RFC 3986 Sections 6.2.1 and
/// 6.2.2.1.
///
/// Returns the normalized URI string.
String _rfc3986Normalize(String input) {
  String normalized = input;

  normalized = _lowercaseSchemeAndHost(normalized);

  normalized = _uppercasePercentHex(normalized);

  normalized = _decodeUnreservedPercentEncoding(normalized);

  return normalized;
}

/// Lowercases the scheme and host components of a URI.
///
/// The scheme is everything before `://`. The host is the authority
/// component between `://` and the next `/`, `?`, `#`, or end of string.
String _lowercaseSchemeAndHost(String input) {
  final schemeSep = input.indexOf('://');
  if (schemeSep < 0) return input;

  final scheme = input.substring(0, schemeSep).toLowerCase();
  final afterScheme = input.substring(schemeSep + 3);

  final authorityEnd = _findAuthorityEnd(afterScheme);
  final authority = afterScheme.substring(0, authorityEnd);

  final userinfoHostSep = authority.lastIndexOf('@');
  String hostPart;
  String? userinfoPart;
  if (userinfoHostSep >= 0) {
    userinfoPart = authority.substring(0, userinfoHostSep + 1);
    hostPart = authority.substring(userinfoHostSep + 1);
  } else {
    hostPart = authority;
    userinfoPart = null;
  }

  final portSep = hostPart.lastIndexOf(':');
  final bracketClose = hostPart.lastIndexOf(']');
  String? portSuffix;
  // If there's a colon AFTER an IPv6 bracket or NO bracket at all, it
  // could be a port separator. We check if the colon is after a ']' in
  // which case it's definitely a port, or if there's no bracket then
  // the last colon before the first non-host character is the port.
  if (bracketClose >= 0 && portSep > bracketClose) {
    portSuffix = hostPart.substring(portSep);
    hostPart = hostPart.substring(0, portSep);
  } else if (bracketClose < 0 && portSep >= 0) {
    portSuffix = hostPart.substring(portSep);
    hostPart = hostPart.substring(0, portSep);
  }

  final lowerHost = hostPart.toLowerCase();
  final lowerAuthority = '${userinfoPart ?? ""}$lowerHost${portSuffix ?? ""}';
  final remainder = afterScheme.substring(authorityEnd);

  return '$scheme://$lowerAuthority$remainder';
}

/// Finds the index within [afterScheme] where the authority component
/// ends (before path, query, or fragment).
int _findAuthorityEnd(String afterScheme) {
  for (var i = 0; i < afterScheme.length; i++) {
    final c = afterScheme[i];
    if (c == '/' || c == '?' || c == '#') {
      return i;
    }
  }
  return afterScheme.length;
}

/// Uppercases all hexadecimal digits in percent-encoded sequences
/// (e.g. `%3a` → `%3A`).
String _uppercasePercentHex(String input) {
  return input.replaceAllMapped(
    RegExp(r'%([0-9a-fA-F]{2})'),
    (match) => '%${match.group(1)!.toUpperCase()}',
  );
}

/// Decodes percent-encoded unreserved characters (`A-Z`, `a-z`, `0-9`,
/// `-`, `.`, `_`, `~`) back to their native US-ASCII representation
/// per RFC 3986 § 2.3.
String _decodeUnreservedPercentEncoding(String input) {
  final unreservedRe = RegExp(
    '%('
    '[3][0-9]|' // 0-9  (%30-%39)
    '[4][1-5A]|' // A-F (%41-%46)
    '[5][7-9A]|' // W-Z (%57-%5A)
    '[6][1-7A]|' // a-f (%61-%66)
    '[7][7-9A]|' // w-z (%77-%7A)
    '[2][DdEe]|' // - . (%2D %2E)
    '[5][Ff]|' // _   (%5F)
    '[7][Ee]' // ~   (%7E)
    ')',
    caseSensitive: false,
  );

  return input.replaceAllMapped(unreservedRe, (match) {
    final hex = match.group(1)!;
    final codePoint = int.parse(hex, radix: 16);
    return String.fromCharCode(codePoint);
  });
}
