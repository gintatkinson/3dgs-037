import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressAndStringTypes Value Object', () {
    test('should create instance with all seven fields', () {
      final model = AddressAndStringTypes(
        containerId: 'ctr-1',
        physAddress: '00:11:22:33:44:55',
        macAddress: '08:00:27:00:a1:4c',
        hexString: 'a1:b2:c3:d4',
        dottedQuad: '192.0.2.1',
        languageTag: 'en-US',
        xpath10: '/ietf-yang-types:address-and-string-types/mac-address',
      );
      expect(model.containerId, equals('ctr-1'));
      expect(model.physAddress, equals('00:11:22:33:44:55'));
      expect(model.macAddress, equals('08:00:27:00:a1:4c'));
      expect(model.hexString, equals('a1:b2:c3:d4'));
      expect(model.dottedQuad, equals('192.0.2.1'));
      expect(model.languageTag, equals('en-US'));
      expect(model.xpath10, equals('/ietf-yang-types:address-and-string-types/mac-address'));
    });

    test('should have value equality', () {
      final a = AddressAndStringTypes(
        containerId: 'ctr-1',
        physAddress: '00:11:22:33:44:55',
        macAddress: '08:00:27:00:a1:4c',
        hexString: 'a1:b2:c3:d4',
        dottedQuad: '192.0.2.1',
        languageTag: 'en-US',
        xpath10: '/xpath',
      );
      final b = AddressAndStringTypes(
        containerId: 'ctr-1',
        physAddress: '00:11:22:33:44:55',
        macAddress: '08:00:27:00:a1:4c',
        hexString: 'a1:b2:c3:d4',
        dottedQuad: '192.0.2.1',
        languageTag: 'en-US',
        xpath10: '/xpath',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should have inequality with different values', () {
      final a = AddressAndStringTypes(
        containerId: 'ctr-1',
        physAddress: '',
        macAddress: '08:00:27:00:a1:4c',
        hexString: '',
        dottedQuad: '192.0.2.1',
        languageTag: 'en-US',
        xpath10: '/xpath',
      );
      final b = AddressAndStringTypes(
        containerId: 'ctr-2',
        physAddress: '',
        macAddress: '08:00:27:00:a1:4c',
        hexString: '',
        dottedQuad: '192.0.2.1',
        languageTag: 'en-US',
        xpath10: '/xpath',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('validatePhysAddress', () {
    test('should succeed for valid variable-length octet sequence', () {
      final result = AddressAndStringTypes.validatePhysAddress('00:11:22:33:44:55:66:77');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for single octet', () {
      final result = AddressAndStringTypes.validatePhysAddress('ab');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for empty string', () {
      final result = AddressAndStringTypes.validatePhysAddress('');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for standard 6-octet MAC-like address', () {
      final result = AddressAndStringTypes.validatePhysAddress('00:00:5e:00:53:01');
      expect(result.isSuccess, isTrue);
    });

    test('should fail for invalid hex characters', () {
      final result = AddressAndStringTypes.validatePhysAddress('gg:11:22');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
      expect((error as SchemaFieldPatternError).fieldName, equals('physAddress'));
    });

    test('should fail for malformed colon separators', () {
      final result = AddressAndStringTypes.validatePhysAddress('00:11:22:');
      expect(result.isFailure, isTrue);
    });

    test('should fail for incomplete octet', () {
      final result = AddressAndStringTypes.validatePhysAddress('00:1:22');
      expect(result.isFailure, isTrue);
    });

    test('should succeed for uppercase hex characters', () {
      final result = AddressAndStringTypes.validatePhysAddress('A1:B2:C3');
      expect(result.isSuccess, isTrue);
    });
  });

  group('validateMacAddress', () {
    test('should succeed for valid 6-octet MAC address', () {
      final result = AddressAndStringTypes.validateMacAddress('08:00:27:00:a1:4c');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for standard MAC address', () {
      final result = AddressAndStringTypes.validateMacAddress('00:00:5e:00:53:01');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for all-zero MAC', () {
      final result = AddressAndStringTypes.validateMacAddress('00:00:00:00:00:00');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for all-ones MAC', () {
      final result = AddressAndStringTypes.validateMacAddress('ff:ff:ff:ff:ff:ff');
      expect(result.isSuccess, isTrue);
    });

    test('should fail for only 5 octets', () {
      final result = AddressAndStringTypes.validateMacAddress('08:00:27:00:a1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
      expect((error as SchemaFieldPatternError).fieldName, equals('macAddress'));
    });

    test('should fail for 7 octets', () {
      final result = AddressAndStringTypes.validateMacAddress('08:00:27:00:a1:4c:01');
      expect(result.isFailure, isTrue);
    });

    test('should fail for invalid hex characters', () {
      final result = AddressAndStringTypes.validateMacAddress('zz:00:27:00:a1:4c');
      expect(result.isFailure, isTrue);
    });

    test('should fail for missing colons', () {
      final result = AddressAndStringTypes.validateMacAddress('08002700a14c');
      expect(result.isFailure, isTrue);
    });

    test('should succeed for mixed-case input', () {
      final result = AddressAndStringTypes.validateMacAddress('08:00:27:00:A1:4C');
      expect(result.isSuccess, isTrue);
    });
  });

  group('validateHexString', () {
    test('should succeed for valid hex octet sequence', () {
      final result = AddressAndStringTypes.validateHexString('a1:b2:c3:d4');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for single octet', () {
      final result = AddressAndStringTypes.validateHexString('ff');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for empty string', () {
      final result = AddressAndStringTypes.validateHexString('');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for uppercase hex', () {
      final result = AddressAndStringTypes.validateHexString('DE:AD:BE:EF');
      expect(result.isSuccess, isTrue);
    });

    test('should fail for invalid characters', () {
      final result = AddressAndStringTypes.validateHexString('gg:bb');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
      expect((error as SchemaFieldPatternError).fieldName, equals('hexString'));
    });

    test('should fail for incomplete octet', () {
      final result = AddressAndStringTypes.validateHexString('a:b:c');
      expect(result.isFailure, isTrue);
    });

    test('should fail for trailing colon', () {
      final result = AddressAndStringTypes.validateHexString('a1:b2:');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateDottedQuad', () {
    test('should succeed for standard dotted-quad 192.0.2.1', () {
      final result = AddressAndStringTypes.validateDottedQuad('192.0.2.1');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for boundary min 0.0.0.0', () {
      final result = AddressAndStringTypes.validateDottedQuad('0.0.0.0');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for boundary max 255.255.255.255', () {
      final result = AddressAndStringTypes.validateDottedQuad('255.255.255.255');
      expect(result.isSuccess, isTrue);
    });

    test('should fail for octet > 255 (256.0.0.1)', () {
      final result = AddressAndStringTypes.validateDottedQuad('256.0.0.1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
      expect((error as SchemaFieldRangeError).fieldName, equals('dottedQuad'));
    });

    test('should fail for negative octet', () {
      final result = AddressAndStringTypes.validateDottedQuad('-1.0.0.0');
      expect(result.isFailure, isTrue);
    });

    test('should fail for only three octets', () {
      final result = AddressAndStringTypes.validateDottedQuad('192.0.2');
      expect(result.isFailure, isTrue);
    });

    test('should fail for five octets', () {
      final result = AddressAndStringTypes.validateDottedQuad('192.0.2.1.1');
      expect(result.isFailure, isTrue);
    });

    test('should fail for leading zero with 3 digits (not valid dotted-quad format)', () {
      final result = AddressAndStringTypes.validateDottedQuad('192.00.2.1');
      expect(result.isFailure, isTrue);
    });

    test('should succeed for 10.0.0.1', () {
      final result = AddressAndStringTypes.validateDottedQuad('10.0.0.1');
      expect(result.isSuccess, isTrue);
    });
  });

  group('validateLanguageTag', () {
    test('should succeed for simple language code en', () {
      final result = AddressAndStringTypes.validateLanguageTag('en');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for language-region en-US', () {
      final result = AddressAndStringTypes.validateLanguageTag('en-US');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for language-script-region zh-Hans-CN', () {
      final result = AddressAndStringTypes.validateLanguageTag('zh-Hans-CN');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for single digit subtag sr-Latn', () {
      final result = AddressAndStringTypes.validateLanguageTag('sr-Latn');
      expect(result.isSuccess, isTrue);
    });

    test('should fail for empty string', () {
      final result = AddressAndStringTypes.validateLanguageTag('');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
      expect((error as SchemaFieldPatternError).fieldName, equals('languageTag'));
    });

    test('should fail for tag starting with digit', () {
      final result = AddressAndStringTypes.validateLanguageTag('1en');
      expect(result.isFailure, isTrue);
    });

    test('should fail for tag with special characters', () {
      final result = AddressAndStringTypes.validateLanguageTag('en@US');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateXpath10', () {
    test('should succeed for absolute path starting with /', () {
      final result = AddressAndStringTypes.validateXpath10('/ietf-yang-types:address-and-string-types/mac-address');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for expression starting with (', () {
      final result = AddressAndStringTypes.validateXpath10('(//device)[1]');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for expression starting with .', () {
      final result = AddressAndStringTypes.validateXpath10('./child');
      expect(result.isSuccess, isTrue);
    });

    test('should succeed for expression starting with @', () {
      final result = AddressAndStringTypes.validateXpath10('@attribute');
      expect(result.isSuccess, isTrue);
    });

    test('should fail for empty string', () {
      final result = AddressAndStringTypes.validateXpath10('');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
      expect((error as SchemaFieldPatternError).fieldName, equals('xpath10'));
    });

    test('should fail for string not starting with /,(,.,@', () {
      final result = AddressAndStringTypes.validateXpath10('mac-address');
      expect(result.isFailure, isTrue);
    });
  });

  group('canonicalize functions', () {
    test('canonicalizePhysAddress should lowercase mixed-case input', () {
      final result = AddressAndStringTypes.canonicalizePhysAddress('00:00:5E:00:53:01');
      expect(result, equals('00:00:5e:00:53:01'));
    });

    test('canonicalizePhysAddress should preserve already-lowercase input', () {
      final result = AddressAndStringTypes.canonicalizePhysAddress('00:00:5e:00:53:01');
      expect(result, equals('00:00:5e:00:53:01'));
    });

    test('canonicalizeMacAddress should lowercase mixed-case input', () {
      final result = AddressAndStringTypes.canonicalizeMacAddress('08:00:27:00:A1:4C');
      expect(result, equals('08:00:27:00:a1:4c'));
    });

    test('canonicalizeMacAddress should preserve already-lowercase input', () {
      final result = AddressAndStringTypes.canonicalizeMacAddress('08:00:27:00:a1:4c');
      expect(result, equals('08:00:27:00:a1:4c'));
    });

    test('canonicalizeHexString should lowercase mixed-case input', () {
      final result = AddressAndStringTypes.canonicalizeHexString('A1:B2:C3:D4');
      expect(result, equals('a1:b2:c3:d4'));
    });

    test('canonicalizeHexString should preserve already-lowercase input', () {
      final result = AddressAndStringTypes.canonicalizeHexString('a1:b2:c3:d4');
      expect(result, equals('a1:b2:c3:d4'));
    });

    test('canonicalizeLanguageTag should lowercase mixed-case tag', () {
      final result = AddressAndStringTypes.canonicalizeLanguageTag('en-US');
      expect(result, equals('en-us'));
    });

    test('canonicalizeLanguageTag should preserve already-lowercase tag', () {
      final result = AddressAndStringTypes.canonicalizeLanguageTag('en-us');
      expect(result, equals('en-us'));
    });

    test('canonicalizeLanguageTag should lowercase zh-Hans-CN', () {
      final result = AddressAndStringTypes.canonicalizeLanguageTag('zh-Hans-CN');
      expect(result, equals('zh-hans-cn'));
    });
  });

  group('parseDottedQuadToUint32', () {
    test('should parse 192.0.2.1 to 3221225985', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('192.0.2.1');
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(3221225985));
    });

    test('should parse 0.0.0.0 to 0', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('0.0.0.0');
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(0));
    });

    test('should parse 255.255.255.255 to 4294967295', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('255.255.255.255');
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(4294967295));
    });

    test('should parse 10.0.0.1 to 167772161', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('10.0.0.1');
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(167772161));
    });

    test('should parse 172.16.0.1 to 2886729729', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('172.16.0.1');
      expect(result.isSuccess, isTrue);
      expect((result as Success<int>).value, equals(2886729729));
    });

    test('should fail for invalid format with >255 octet', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('256.0.0.1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<int>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });

    test('should fail for incomplete dotted-quad', () {
      final result = AddressAndStringTypes.parseDottedQuadToUint32('192.0.2');
      expect(result.isFailure, isTrue);
    });
  });
}
