import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpScopeType enum', () {
    test('should expose six enum values', () {
      expect(IpScopeType.values.length, equals(6));
    });
  });

  group('ipScopeTypeCode', () {
    test('should return 1 for interfaceLocal', () {
      expect(ipScopeTypeCode(IpScopeType.interfaceLocal), equals(1));
    });
    test('should return 2 for linkLocal', () {
      expect(ipScopeTypeCode(IpScopeType.linkLocal), equals(2));
    });
    test('should return 4 for adminLocal', () {
      expect(ipScopeTypeCode(IpScopeType.adminLocal), equals(4));
    });
    test('should return 5 for siteLocal', () {
      expect(ipScopeTypeCode(IpScopeType.siteLocal), equals(5));
    });
    test('should return 8 for organizationLocal', () {
      expect(ipScopeTypeCode(IpScopeType.organizationLocal), equals(8));
    });
    test('should return 14 for global', () {
      expect(ipScopeTypeCode(IpScopeType.global), equals(14));
    });
  });

  group('isGlobalScope', () {
    test('should return true for global', () {
      expect(isGlobalScope(IpScopeType.global), isTrue);
    });
    test('should return false for linkLocal', () {
      expect(isGlobalScope(IpScopeType.linkLocal), isFalse);
    });
  });

  group('IpUnicastMulticastAndScopeTypes value object', () {
    test('should create instance with all ten fields', () {
      const model = IpUnicastMulticastAndScopeTypes(
        containerId: 'test-1',
        ipv6FlowLabel: 42,
        dscp: 46,
        ipUnicastAddress: '192.168.1.1',
        ipv4UnicastAddress: '192.168.1.1',
        ipv6UnicastAddress: '2001:db8::1',
        ipMulticastAddress: '224.0.0.1',
        ipv4MulticastAddress: '224.0.0.1',
        ipv6MulticastAddress: 'ff02::1',
        scopeType: 'link-local',
      );
      expect(model.ipv6FlowLabel, equals(42));
      expect(model.dscp, equals(46));
      expect(model.ipUnicastAddress, equals('192.168.1.1'));
      expect(model.ipv4UnicastAddress, equals('192.168.1.1'));
      expect(model.ipv6UnicastAddress, equals('2001:db8::1'));
      expect(model.ipMulticastAddress, equals('224.0.0.1'));
      expect(model.ipv4MulticastAddress, equals('224.0.0.1'));
      expect(model.ipv6MulticastAddress, equals('ff02::1'));
      expect(model.scopeType, equals('link-local'));
    });

    test('should use default containerId and required values when not specified',
        () {
      const model = IpUnicastMulticastAndScopeTypes();
      expect(model.containerId, equals('default'));
      expect(model.ipv6FlowLabel, equals(0));
      expect(model.dscp, equals(0));
    });

    test('should have value equality', () {
      const a = IpUnicastMulticastAndScopeTypes(
        ipv6FlowLabel: 100,
        dscp: 10,
        ipv4UnicastAddress: '10.0.0.1',
      );
      const b = IpUnicastMulticastAndScopeTypes(
        ipv6FlowLabel: 100,
        dscp: 10,
        ipv4UnicastAddress: '10.0.0.1',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should have inequality with different values', () {
      const a = IpUnicastMulticastAndScopeTypes(ipv6FlowLabel: 0);
      const b = IpUnicastMulticastAndScopeTypes(ipv6FlowLabel: 1);
      expect(a, isNot(equals(b)));
    });
  });

  group('validateIpv6FlowLabel', () {
    test('should accept boundary value 0', () {
      final result = validateIpv6FlowLabel(0);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(0));
    });

    test('should accept intermediate value 524287', () {
      final result = validateIpv6FlowLabel(524287);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(524287));
    });

    test('should accept boundary value 1048575', () {
      final result = validateIpv6FlowLabel(1048575);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(1048575));
    });

    test('should reject value -1 with IpFlowLabelOutOfBoundsError', () {
      final result = validateIpv6FlowLabel(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<IpFlowLabelOutOfBoundsError>());
      expect((error as IpFlowLabelOutOfBoundsError).value, equals(-1));
    });

    test('should reject value 1048576 with IpFlowLabelOutOfBoundsError', () {
      final result = validateIpv6FlowLabel(1048576);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<IpFlowLabelOutOfBoundsError>());
      expect((error as IpFlowLabelOutOfBoundsError).value, equals(1048576));
    });
  });

  group('validateDscp', () {
    test('should accept boundary value 0 (CS0)', () {
      final result = validateDscp(0);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(0));
    });

    test('should accept value 46 (EF)', () {
      final result = validateDscp(46);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(46));
    });

    test('should accept boundary value 63', () {
      final result = validateDscp(63);
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(63));
    });

    test('should reject value -1 with DscpOutOfBoundsError', () {
      final result = validateDscp(-1);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<DscpOutOfBoundsError>());
      expect((error as DscpOutOfBoundsError).value, equals(-1));
    });

    test('should reject value 64 with DscpOutOfBoundsError', () {
      final result = validateDscp(64);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<DscpOutOfBoundsError>());
      expect((error as DscpOutOfBoundsError).value, equals(64));
    });
  });

  group('validateIpv4UnicastAddress', () {
    test('should accept valid IPv4 unicast 192.168.1.1', () {
      final result = validateIpv4UnicastAddress('192.168.1.1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept valid IPv4 unicast 10.0.0.1', () {
      final result = validateIpv4UnicastAddress('10.0.0.1');
      expect(result.isSuccess, isTrue);
    });

    test('should reject multicast 224.0.0.1 with InvalidUnicastAddressError',
        () {
      final result = validateIpv4UnicastAddress('224.0.0.1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidUnicastAddressError>(),
      );
    });

    test('should reject multicast 239.255.255.255 with InvalidUnicastAddressError',
        () {
      final result = validateIpv4UnicastAddress('239.255.255.255');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidUnicastAddressError>(),
      );
    });

    test('should reject invalid dotted-quad with InvalidIpv4FormatError', () {
      final result = validateIpv4UnicastAddress('192.168.256.1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidIpv4FormatError>(),
      );
    });
  });

  group('validateIpv6UnicastAddress', () {
    test('should accept valid IPv6 unicast 2001:db8::1', () {
      final result = validateIpv6UnicastAddress('2001:db8::1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept valid IPv6 unicast fe80::1', () {
      final result = validateIpv6UnicastAddress('fe80::1');
      expect(result.isSuccess, isTrue);
    });

    test('should reject multicast ff02::1 with InvalidUnicastAddressError', () {
      final result = validateIpv6UnicastAddress('ff02::1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidUnicastAddressError>(),
      );
    });

    test('should reject multicast ff0e::1 with InvalidUnicastAddressError', () {
      final result = validateIpv6UnicastAddress('ff0e::1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidUnicastAddressError>(),
      );
    });

    test('should reject invalid IPv6 with InvalidIpv6FormatError', () {
      final result = validateIpv6UnicastAddress('not-an-ipv6');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidIpv6FormatError>(),
      );
    });
  });

  group('validateIpv4MulticastAddress', () {
    test('should accept valid IPv4 multicast 224.0.0.1', () {
      final result = validateIpv4MulticastAddress('224.0.0.1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept valid IPv4 multicast 239.255.255.255', () {
      final result = validateIpv4MulticastAddress('239.255.255.255');
      expect(result.isSuccess, isTrue);
    });

    test('should reject unicast 192.168.1.1 with InvalidMulticastAddressError',
        () {
      final result = validateIpv4MulticastAddress('192.168.1.1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidMulticastAddressError>(),
      );
    });

    test('should reject invalid dotted-quad with InvalidIpv4FormatError', () {
      final result = validateIpv4MulticastAddress('300.0.0.1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidIpv4FormatError>(),
      );
    });
  });

  group('validateIpv6MulticastAddress', () {
    test('should accept valid IPv6 multicast ff02::1', () {
      final result = validateIpv6MulticastAddress('ff02::1');
      expect(result.isSuccess, isTrue);
    });

    test('should accept valid IPv6 multicast ff0e::1', () {
      final result = validateIpv6MulticastAddress('ff0e::1');
      expect(result.isSuccess, isTrue);
    });

    test('should reject unicast 2001:db8::1 with InvalidMulticastAddressError',
        () {
      final result = validateIpv6MulticastAddress('2001:db8::1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidMulticastAddressError>(),
      );
    });

    test('should reject invalid IPv6 with InvalidIpv6FormatError', () {
      final result = validateIpv6MulticastAddress('not-an-ipv6');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<String>).error,
        isA<InvalidIpv6FormatError>(),
      );
    });
  });

  group('validateScopeType', () {
    test('should accept interface-local', () {
      final result = validateScopeType('interface-local');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.interfaceLocal),
      );
    });

    test('should accept link-local', () {
      final result = validateScopeType('link-local');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.linkLocal),
      );
    });

    test('should accept admin-local', () {
      final result = validateScopeType('admin-local');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.adminLocal),
      );
    });

    test('should accept site-local', () {
      final result = validateScopeType('site-local');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.siteLocal),
      );
    });

    test('should accept organization-local', () {
      final result = validateScopeType('organization-local');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.organizationLocal),
      );
    });

    test('should accept global', () {
      final result = validateScopeType('global');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.global),
      );
    });

    test('should reject invalid scope with UnresolvableScopeTypeError', () {
      final result = validateScopeType('cosmic');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<IpScopeType>).error;
      expect(error, isA<UnresolvableScopeTypeError>());
      expect((error as UnresolvableScopeTypeError).value, equals('cosmic'));
    });
  });

  group('classifyIpAddress', () {
    test('should classify 192.168.1.1 as ipv4-unicast', () {
      expect(classifyIpAddress('192.168.1.1'), equals('ipv4-unicast'));
    });

    test('should classify 224.0.0.1 as ipv4-multicast', () {
      expect(classifyIpAddress('224.0.0.1'), equals('ipv4-multicast'));
    });

    test('should classify 2001:db8::1 as ipv6-unicast', () {
      expect(classifyIpAddress('2001:db8::1'), equals('ipv6-unicast'));
    });

    test('should classify ff02::1 as ipv6-multicast', () {
      expect(classifyIpAddress('ff02::1'), equals('ipv6-multicast'));
    });

    test('should return unknown for invalid address', () {
      expect(classifyIpAddress('not-an-ip'), equals('unknown'));
    });
  });

  group('getMulticastScope', () {
    test('should extract scope code 2 (link-local) from ff02::1', () {
      final result = getMulticastScope('ff02::1');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.linkLocal),
      );
    });

    test('should extract scope code 1 (interface-local) from ff01::1', () {
      final result = getMulticastScope('ff01::1');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.interfaceLocal),
      );
    });

    test('should extract scope code 14 (global) from ff0e::1', () {
      final result = getMulticastScope('ff0e::1');
      expect(result.isSuccess, isTrue);
      expect(
        (result as Success<IpScopeType>).value,
        equals(IpScopeType.global),
      );
    });

    test('should reject unicast address with InvalidIpv6FormatError', () {
      final result = getMulticastScope('2001:db8::1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<IpScopeType>).error,
        isA<InvalidIpv6FormatError>(),
      );
    });

    test('should reject unknown scope with UnresolvableScopeTypeError', () {
      final result = getMulticastScope('ff80::1');
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<IpScopeType>).error,
        isA<UnresolvableScopeTypeError>(),
      );
    });
  });
}
