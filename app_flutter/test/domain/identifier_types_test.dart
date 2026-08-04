import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';

void main() {
  group('IdentifierTypes Domain Model Tests', () {
    test('validates standard object identifiers (OID)', () {
      final validOids = ['1.3.6.1.4.1', '0.39.100', '2.999.4294967295'];
      for (final oid in validOids) {
        final result = IdentifierTypes.validateObjectIdentifier(oid);
        expect(result.isSuccess, isTrue, reason: 'Expected $oid to be valid');
        expect(result.valueOrNull, equals(oid));
      }
    });

    test('rejects OID with invalid first arc (>2)', () {
      final result = IdentifierTypes.validateObjectIdentifier('3.1.2');
      expect(result.isFailure, isTrue);
      expect(result.errorCodeOrNull, equals('INVALID_OID_FIRST_ARC'));
    });

    test('rejects OID with invalid second arc (>39 for root 0 or 1)', () {
      final result0 = IdentifierTypes.validateObjectIdentifier('0.40.1');
      expect(result0.isFailure, isTrue);
      expect(result0.errorCodeOrNull, equals('INVALID_OID_SECOND_ARC'));

      final result1 = IdentifierTypes.validateObjectIdentifier('1.40.1');
      expect(result1.isFailure, isTrue);
      expect(result1.errorCodeOrNull, equals('INVALID_OID_SECOND_ARC'));

      // Root 2 allows second arc > 39
      final result2 = IdentifierTypes.validateObjectIdentifier('2.999.1');
      expect(result2.isSuccess, isTrue);
    });

    test('rejects OID sub-identifier overflow (> 4,294,967,295)', () {
      final result = IdentifierTypes.validateObjectIdentifier('1.3.4294967296');
      expect(result.isFailure, isTrue);
      expect(result.errorCodeOrNull, equals('OID_SUBIDENTIFIER_OVERFLOW'));
    });

    test('rejects OID with fewer than 2 sub-identifiers', () {
      final result = IdentifierTypes.validateObjectIdentifier('1');
      expect(result.isFailure, isTrue);
      expect(result.errorCodeOrNull, equals('OID_TOO_FEW_SUBIDENTIFIERS'));
    });

    test('validates object-identifier-128 boundary limits', () {
      // 128 sub-identifiers: 1.1.1... (128 ones separated by 127 dots)
      final oid128 = List.generate(128, (_) => '1').join('.');
      final result128 = IdentifierTypes.validateObjectIdentifier128(oid128);
      expect(result128.isSuccess, isTrue);

      // 129 sub-identifiers: exceeds limit
      final oid129 = List.generate(129, (_) => '1').join('.');
      final result129 = IdentifierTypes.validateObjectIdentifier128(oid129);
      expect(result129.isFailure, isTrue);
      expect(result129.errorCodeOrNull, equals('OID_128_LIMIT_EXCEEDED'));
    });

    test('validates and normalizes RFC 9562 UUID strings', () {
      const validUuid = 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6';
      final result = IdentifierTypes.validateUuid(validUuid);
      expect(result.isSuccess, isTrue);

      const upperUuid = 'F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6';
      final upperResult = IdentifierTypes.validateUuid(upperUuid);
      expect(upperResult.isSuccess, isTrue);

      final normalized = IdentifierTypes.normalizeUuid(upperUuid);
      expect(normalized, equals(validUuid));
    });

    test('rejects malformed UUID strings', () {
      final shortResult = IdentifierTypes.validateUuid('f81d4fae-7dec-11d0-a765');
      expect(shortResult.isFailure, isTrue);
      expect(shortResult.errorCodeOrNull, equals('INVALID_UUID_FORMAT'));

      final invalidCharsResult = IdentifierTypes.validateUuid('f81d4fae-7dec-11d0-a765-00a0c91e6bfg');
      expect(invalidCharsResult.isFailure, isTrue);
      expect(invalidCharsResult.errorCodeOrNull, equals('INVALID_UUID_FORMAT'));
    });

    test('validates RFC 7950 YANG identifiers', () {
      final validIds = ['interfaces', '_bgp-peer.1', 'xml-element'];
      for (final id in validIds) {
        final result = IdentifierTypes.validateYangIdentifier(id);
        expect(result.isSuccess, isTrue, reason: 'Expected $id to be valid');
      }
    });

    test('rejects invalid YANG identifiers', () {
      final startDigit = IdentifierTypes.validateYangIdentifier('123-node');
      expect(startDigit.isFailure, isTrue);
      expect(startDigit.errorCodeOrNull, equals('INVALID_YANG_IDENTIFIER_START'));

      final invalidChar = IdentifierTypes.validateYangIdentifier('interface:eth0');
      expect(invalidChar.isFailure, isTrue);
      expect(invalidChar.errorCodeOrNull, equals('INVALID_YANG_IDENTIFIER_CHARACTER'));
    });
  });
}
