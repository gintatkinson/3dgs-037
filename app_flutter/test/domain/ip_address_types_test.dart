import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpVersion enum', () {
    test('should expose three enum values', () {
      expect(IpVersion.values.length, equals(3));
      expect(IpVersion.unknown.index, equals(0));
      expect(IpVersion.ipv4.index, equals(1));
      expect(IpVersion.ipv6.index, equals(2));
    });
  });

  group('parseIpVersion', () {
    test('should return IpVersion.unknown for value 0', () {
      final result = parseIpVersion(0);
      expect(result.isSuccess, isTrue);
      expect((result as Success<IpVersion>).value, equals(IpVersion.unknown));
    });

    test('should return IpVersion.ipv4 for value 1', () {
      final result = parseIpVersion(1);
      expect(result.isSuccess, isTrue);
      expect((result as Success<IpVersion>).value, equals(IpVersion.ipv4));
    });

    test('should return IpVersion.ipv6 for value 2', () {
      final result = parseIpVersion(2);
      expect(result.isSuccess, isTrue);
      expect((result as Success<IpVersion>).value, equals(IpVersion.ipv6));
    });

    test('should fail with InvalidIpVersionError for value 3', () {
      final result = parseIpVersion(3);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<IpVersion>).error;
      expect(error, isA<InvalidIpVersionError>());
      expect((error as InvalidIpVersionError).value, equals(3));
    });

    test('should fail with InvalidIpVersionError for negative value', () {
      final result = parseIpVersion(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<IpVersion>).error;
      expect(error, isA<InvalidIpVersionError>());
      expect((error as InvalidIpVersionError).value, equals(-1));
    });
  });

  group('IpAddressTypes value object', () {
    test('should create instance with all eleven fields', () {
      final model = IpAddressTypes(
        containerId: 'test-1',
        ipVersion: 1,
        ipAddress: '192.168.1.1',
        ipv4Address: '192.168.1.1',
        ipv6Address: '2001:db8::1',
        ipPrefix: '192.168.1.0/24',
        ipv4Prefix: '192.168.1.0/24',
        ipv6Prefix: '2001:db8::/64',
        ipAddressNoZone: '10.0.0.1',
        ipv4AddressNoZone: '10.0.0.1',
        ipv6AddressNoZone: 'fe80::1',
      );
      expect(model.ipAddress, equals('192.168.1.1'));
      expect(model.ipv4Address, equals('192.168.1.1'));
      expect(model.ipv6Address, equals('2001:db8::1'));
      expect(model.ipPrefix, equals('192.168.1.0/24'));
      expect(model.ipv4Prefix, equals('192.168.1.0/24'));
      expect(model.ipv6Prefix, equals('2001:db8::/64'));
      expect(model.ipAddressNoZone, equals('10.0.0.1'));
      expect(model.ipv4AddressNoZone, equals('10.0.0.1'));
      expect(model.ipv6AddressNoZone, equals('fe80::1'));
    });

    test('should use default containerId and ipVersion when not specified', () {
      final model = IpAddressTypes();
      expect(model.containerId, equals('default'));
      expect(model.ipVersion, equals(0));
    });

    test('should have value equality', () {
      final a = IpAddressTypes(
        ipv4Address: '192.168.1.1',
        ipVersion: 1,
      );
      final b = IpAddressTypes(
        ipv4Address: '192.168.1.1',
        ipVersion: 1,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should have inequality with different values', () {
      final a = IpAddressTypes(ipv4Address: '192.168.1.1');
      final b = IpAddressTypes(ipv4Address: '10.0.0.1');
      expect(a, isNot(equals(b)));
    });
  });

  group('stripZoneIndex', () {
    test('shouldRemoveZoneSuffixWhenPresent', () {
      expect(stripZoneIndex('fe80::1%eth0'), equals('fe80::1'));
      expect(stripZoneIndex('169.254.1.1%eth0'), equals('169.254.1.1'));
    });

    test('should return input unchanged when no zone index present', () {
      expect(stripZoneIndex('192.168.1.1'), equals('192.168.1.1'));
      expect(stripZoneIndex('2001:db8::1'), equals('2001:db8::1'));
    });
  });

  group('hasZoneIndex', () {
    test('should return true when zone index is present', () {
      expect(hasZoneIndex('fe80::1%eth0'), isTrue);
      expect(hasZoneIndex('169.254.1.1%1'), isTrue);
    });

    test('should return false when no zone index', () {
      expect(hasZoneIndex('192.168.1.1'), isFalse);
      expect(hasZoneIndex('2001:db8::1'), isFalse);
    });
  });

  group('determineIpVersionStr', () {
    test('should return ipv4 for dotted-quad strings', () {
      expect(determineIpVersionStr('192.168.1.1'), equals('ipv4'));
    });

    test('should return ipv6 for colon-hex strings', () {
      expect(determineIpVersionStr('2001:db8::1'), equals('ipv6'));
    });

    test('should return unknown for unrecognized strings', () {
      expect(determineIpVersionStr('not-an-ip'), equals('unknown'));
    });
  });

  group('validateIpv4Address', () {
    test('should accept valid IPv4 address 192.168.1.1', () {
      final result = validateIpv4Address('192.168.1.1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept valid IPv4 address 10.0.0.254', () {
      final result = validateIpv4Address('10.0.0.254');
      expect(result.isSuccess, isTrue);
    });

    test('should accept dotted-quad with zone index 169.254.1.1%eth0', () {
      final result = validateIpv4Address('169.254.1.1%eth0');
      expect(result.isSuccess, isTrue);
    });

    test('should accept boundary octet values 0.0.0.0 and 255.255.255.255', () {
      expect(validateIpv4Address('0.0.0.0').isSuccess, isTrue);
      expect(validateIpv4Address('255.255.255.255').isSuccess, isTrue);
    });

    test('should reject malformed octet 192.168.256.1', () {
      final result = validateIpv4Address('192.168.256.1');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error, isA<InvalidIpv4FormatError>());
    });

    test('should reject leading zeros beyond single zero', () {
      final result = validateIpv4Address('192.168.001.1');
      expect(result.isFailure, isTrue);
    });

    test('should reject non-IPv4 string', () {
      final result = validateIpv4Address('not-an-address');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateIpv4AddressNoZone', () {
    test('should accept valid dotted-quad without zone index', () {
      final result = validateIpv4AddressNoZone('192.168.1.1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept valid dotted-quad 10.0.0.254', () {
      final result = validateIpv4AddressNoZone('10.0.0.254');
      expect(result.isSuccess, isTrue);
    });

    test('should reject address with zone index 169.254.1.1%eth0', () {
      final result = validateIpv4AddressNoZone('169.254.1.1%eth0');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<ZoneIndexDisallowedError>(),
      );
    });

    test('should reject malformed dotted-quad', () {
      final result = validateIpv4AddressNoZone('192.168.1');
      expect(result.isFailure, isTrue);
    });

    test('should reject leading zeros beyond single zero', () {
      final result = validateIpv4AddressNoZone('192.168.01.1');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateIpv6Address', () {
    test('should accept full IPv6 address 2001:db8:85a3:0:0:8a2e:370:7334',
        () {
      final result =
          validateIpv6Address('2001:db8:85a3:0:0:8a2e:0370:7334');
      expect(result.isSuccess, isTrue);
    });

    test('should accept compressed IPv6 address 2001:db8::1', () {
      final result = validateIpv6Address('2001:db8::1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept loopback IPv6 address ::1', () {
      final result = validateIpv6Address('::1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept scoped IPv6 address fe80::1ff:fe23:4567:890a%eth0',
        () {
      final result =
          validateIpv6Address('fe80::1ff:fe23:4567:890a%eth0');
      expect(result.isSuccess, isTrue);
    });

    test('should accept unspecified address ::', () {
      final result = validateIpv6Address('::');
      expect(result.isSuccess, isTrue);
    });

    test('should reject malformed IPv6 with double :: compression', () {
      final result = validateIpv6Address('2001::db8::1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidIpv6FormatError>(),
      );
    });

    test('should reject non-IPv6 garbage string', () {
      final result = validateIpv6Address('not-an-ipv6-address');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateIpv6AddressNoZone', () {
    test('should accept valid IPv6 address without zone index fe80::1', () {
      final result = validateIpv6AddressNoZone('fe80::1');
      expect(result.isSuccess, isTrue);
    });

    test('should reject scoped IPv6 fe80::1%eth0 with ZoneIndexDisallowedError',
        () {
      final result = validateIpv6AddressNoZone('fe80::1%eth0');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<ZoneIndexDisallowedError>(),
      );
    });

    test('should reject scoped IPv6 fe80::1%1 with ZoneIndexDisallowedError',
        () {
      final result = validateIpv6AddressNoZone('fe80::1%1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<ZoneIndexDisallowedError>(),
      );
    });
  });

  group('validateIpv4Prefix', () {
    test('should accept prefix with length 0 10.0.0.0/0', () {
      final result = validateIpv4Prefix('10.0.0.0/0');
      expect(result.isSuccess, isTrue);
    });

    test('should accept prefix with length 24 192.168.1.0/24', () {
      final result = validateIpv4Prefix('192.168.1.0/24');
      expect(result.isSuccess, isTrue);
    });

    test('should accept prefix with length 32 172.16.0.1/32', () {
      final result = validateIpv4Prefix('172.16.0.1/32');
      expect(result.isSuccess, isTrue);
    });

    test('should reject prefix with length 33 10.0.0.0/33', () {
      final result = validateIpv4Prefix('10.0.0.0/33');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<Ipv4PrefixLengthOutOfBoundsError>(),
      );
    });

    test('should reject prefix with negative length 10.0.0.0/-1', () {
      final result = validateIpv4Prefix('10.0.0.0/-1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<Ipv4PrefixLengthOutOfBoundsError>(),
      );
    });

    test('should reject prefix without slash', () {
      final result = validateIpv4Prefix('192.168.1.0');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateIpv6Prefix', () {
    test('should accept prefix with length 0 2001:db8::/0', () {
      final result = validateIpv6Prefix('2001:db8::/0');
      expect(result.isSuccess, isTrue);
    });

    test('should accept prefix with length 64 2001:db8:1234::/64', () {
      final result = validateIpv6Prefix('2001:db8:1234::/64');
      expect(result.isSuccess, isTrue);
    });

    test('should accept prefix with length 128 2001:db8::1/128', () {
      final result = validateIpv6Prefix('2001:db8::1/128');
      expect(result.isSuccess, isTrue);
    });

    test('should reject prefix with length 129 2001:db8::/129', () {
      final result = validateIpv6Prefix('2001:db8::/129');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<Ipv6PrefixLengthOutOfBoundsError>(),
      );
    });
  });

  group('validateIpAddress', () {
    test('should accept IPv4 address via dispatch', () {
      final result = validateIpAddress('192.168.1.1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept IPv6 address via dispatch', () {
      final result = validateIpAddress('2001:db8::1');
      expect(result.isSuccess, isTrue);
    });

    test('should reject invalid string', () {
      final result = validateIpAddress('xyz');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateIpPrefix', () {
    test('should accept IPv4 prefix via dispatch', () {
      final result = validateIpPrefix('10.0.0.0/8');
      expect(result.isSuccess, isTrue);
    });

    test('should accept IPv6 prefix via dispatch', () {
      final result = validateIpPrefix('2001:db8::/32');
      expect(result.isSuccess, isTrue);
    });

    test('should reject invalid prefix string', () {
      final result = validateIpPrefix('abc/xyz');
      expect(result.isFailure, isTrue);
    });
  });
}
