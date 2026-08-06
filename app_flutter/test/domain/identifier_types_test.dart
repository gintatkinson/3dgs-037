import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdentifierTypes Value Object', () {
    test('shouldCreateInstanceWithAllFields', () {
      final model = const IdentifierTypes(
        containerId: 'ctr-1',
        objectIdentifier: '1.3.6.1',
        objectIdentifier128: '1.3.6.1',
        uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
        yangIdentifier: 'interfaces',
      );
      expect(model.containerId, equals('ctr-1'));
      expect(model.objectIdentifier, equals('1.3.6.1'));
      expect(model.objectIdentifier128, equals('1.3.6.1'));
      expect(model.uuid, equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
      expect(model.yangIdentifier, equals('interfaces'));
    });

    test('shouldHaveValueEquality', () {
      const a = IdentifierTypes(
        containerId: 'a',
        objectIdentifier: '1.2',
        objectIdentifier128: '1.2',
        uuid: '00000000-0000-0000-0000-000000000000',
        yangIdentifier: 'x',
      );
      const b = IdentifierTypes(
        containerId: 'a',
        objectIdentifier: '1.2',
        objectIdentifier128: '1.2',
        uuid: '00000000-0000-0000-0000-000000000000',
        yangIdentifier: 'x',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('shouldHaveInequalityWithDifferentValues', () {
      const a = IdentifierTypes(
        containerId: 'a',
        objectIdentifier: '1.2',
        objectIdentifier128: '1.2',
        uuid: '00000000-0000-0000-0000-000000000000',
        yangIdentifier: 'x',
      );
      const b = IdentifierTypes(
        containerId: 'b',
        objectIdentifier: '1.2',
        objectIdentifier128: '1.2',
        uuid: '00000000-0000-0000-0000-000000000000',
        yangIdentifier: 'x',
      );
      expect(a, isNot(equals(b)));
    });

    test('shouldSupportCopyWith', () {
      const model = IdentifierTypes(
        containerId: 'a',
        objectIdentifier: '1.2',
        objectIdentifier128: '1.2',
        uuid: '00000000-0000-0000-0000-000000000001',
        yangIdentifier: 'x',
      );
      final copy = model.copyWith(containerId: 'z');
      expect(copy.containerId, equals('z'));
      expect(copy.objectIdentifier, equals('1.2'));
      expect(copy.uuid, equals('00000000-0000-0000-0000-000000000001'));
    });
  });

  group('validateObjectIdentifier', () {
    test('shouldAcceptValidOid_1_3_6_1_4_1', () {
      final result = IdentifierTypes.validateObjectIdentifier('1.3.6.1.4.1');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('1.3.6.1.4.1'));
    });

    test('shouldAcceptValidOid_0_39_100', () {
      final result = IdentifierTypes.validateObjectIdentifier('0.39.100');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptValidOid_2_999_4294967295', () {
      final result =
          IdentifierTypes.validateObjectIdentifier('2.999.4294967295');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptMinimalOid_0_0', () {
      final result = IdentifierTypes.validateObjectIdentifier('0.0');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptRoot2WithSecondArcAbove39', () {
      final result = IdentifierTypes.validateObjectIdentifier('2.100.1');
      expect(result.isSuccess, isTrue);
    });

    test('shouldRejectFirstArcTooHigh', () {
      final result = IdentifierTypes.validateObjectIdentifier('3.1.2');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
      expect((error as SchemaFieldRangeError).fieldName,
          equals('objectIdentifier'));
    });

    test('shouldRejectSecondArcTooHighForRoot0', () {
      final result = IdentifierTypes.validateObjectIdentifier('0.40.1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
      expect((error as SchemaFieldRangeError).fieldName,
          equals('objectIdentifier'));
    });

    test('shouldRejectSecondArcTooHighForRoot1', () {
      final result = IdentifierTypes.validateObjectIdentifier('1.50.1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });

    test('shouldRejectSubIdentifierOverflow', () {
      final result =
          IdentifierTypes.validateObjectIdentifier('1.3.4294967296');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });

    test('shouldRejectTooFewSubIdentifiers', () {
      final result = IdentifierTypes.validateObjectIdentifier('1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });

    test('shouldRejectEmptyString', () {
      final result = IdentifierTypes.validateObjectIdentifier('');
      expect(result.isFailure, isTrue);
    });

    test('shouldRejectWhitespace', () {
      final result = IdentifierTypes.validateObjectIdentifier('1. 3.6');
      expect(result.isFailure, isTrue);
    });

    test('shouldRejectLeadingZerosInMultiDigitSubId', () {
      final result = IdentifierTypes.validateObjectIdentifier('01.3.6');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateObjectIdentifier128', () {
    test('shouldAcceptValidOid128UnderLimit', () {
      final result =
          IdentifierTypes.validateObjectIdentifier128('1.3.6.1.4.1');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptOid128WithExactly128SubIdentifiers', () {
      final oid128 =
          List.generate(128, (i) => i.toString()).join('.');
      final result = IdentifierTypes.validateObjectIdentifier128(oid128);
      expect(result.isSuccess, isTrue);
    });

    test('shouldRejectOid128With129SubIdentifiers', () {
      final oid129 =
          List.generate(129, (i) => i.toString()).join('.');
      final result = IdentifierTypes.validateObjectIdentifier128(oid129);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });

    test('shouldStillEnforceOidAsn1Rules', () {
      final result = IdentifierTypes.validateObjectIdentifier128('3.1.2');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error, isA<SchemaFieldRangeError>());
    });
  });

  group('validateUuid', () {
    test('shouldAcceptValidLowercaseUuid', () {
      final result = IdentifierTypes
          .validateUuid('f81d4fae-7dec-11d0-a765-00a0c91e6bf6');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptValidUppercaseUuid', () {
      final result = IdentifierTypes
          .validateUuid('F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6');
      expect(result.isSuccess, isTrue);
    });

    test('shouldRejectUuidTooShort', () {
      final result =
          IdentifierTypes.validateUuid('f81d4fae-7dec-11d0-a765');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
    });

    test('shouldRejectUuidTooLong', () {
      final result = IdentifierTypes
          .validateUuid('f81d4fae-7dec-11d0-a765-00a0c91e6bf60');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error, isA<SchemaFieldPatternError>());
    });

    test('shouldRejectMalformedUuidNoHyphens', () {
      final result = IdentifierTypes
          .validateUuid('f81d4fae7dec11d0a76500a0c91e6bf6');
      expect(result.isFailure, isTrue);
      expect((result as Failure<String>).error, isA<SchemaFieldPatternError>());
    });

    test('shouldRejectEmptyString', () {
      final result = IdentifierTypes.validateUuid('');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateYangIdentifier', () {
    test('shouldAcceptIdentifier_interfaces', () {
      final result =
          IdentifierTypes.validateYangIdentifier('interfaces');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptIdentifierStartingWithUnderscore', () {
      final result =
          IdentifierTypes.validateYangIdentifier('_bgp-peer.1');
      expect(result.isSuccess, isTrue);
    });

    test('shouldAcceptIdentifier_xml_element', () {
      final result =
          IdentifierTypes.validateYangIdentifier('xml-element');
      expect(result.isSuccess, isTrue);
    });

    test('shouldRejectIdentifierStartingWithDigit', () {
      final result =
          IdentifierTypes.validateYangIdentifier('123-node');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
      expect((error as SchemaFieldPatternError).fieldName,
          equals('yangIdentifier'));
    });

    test('shouldRejectIdentifierWithColon', () {
      final result =
          IdentifierTypes.validateYangIdentifier('interface:eth0');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<SchemaFieldPatternError>());
    });

    test('shouldRejectEmptyString', () {
      final result = IdentifierTypes.validateYangIdentifier('');
      expect(result.isFailure, isTrue);
    });
  });

  group('normalizeUuid', () {
    test('shouldCanonicalizeUppercaseToLowercase', () {
      final result = IdentifierTypes
          .normalizeUuid('F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6');
      expect(result, equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
    });

    test('shouldPreserveAlreadyLowercaseUuid', () {
      final result = IdentifierTypes
          .normalizeUuid('f81d4fae-7dec-11d0-a765-00a0c91e6bf6');
      expect(result, equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
    });
  });

  group('parseOidSubIdentifiers', () {
    test('shouldParseValidOidToIntegerList', () {
      final result =
          IdentifierTypes.parseOidSubIdentifiers('1.3.6.1');
      expect(result.isSuccess, isTrue);
      expect((result as Success<List<int>>).value, equals([1, 3, 6, 1]));
    });

    test('shouldParseOidWithMaxSubIdentifier', () {
      final result = IdentifierTypes
          .parseOidSubIdentifiers('4294967295.0');
      expect(result.isSuccess, isTrue);
      expect((result as Success<List<int>>).value,
          equals([4294967295, 0]));
    });

    test('shouldFailOnNonNumericSubIdentifier', () {
      final result =
          IdentifierTypes.parseOidSubIdentifiers('1.abc.3');
      expect(result.isFailure, isTrue);
      expect((result as Failure<List<int>>).error,
          isA<SchemaFieldPatternError>());
    });

    test('shouldFailOnSubIdentifierOverflow', () {
      final result = IdentifierTypes
          .parseOidSubIdentifiers('1.4294967296.1');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<List<int>>).error;
      expect(error, isA<SchemaFieldRangeError>());
    });

    test('shouldFailOnTooFewSubIdentifiers', () {
      final result = IdentifierTypes.parseOidSubIdentifiers('1');
      expect(result.isFailure, isTrue);
    });
  });

  group('isCanonicalLowercase', () {
    test('shouldReturnTrueForLowercaseHex', () {
      expect(IdentifierTypes.isCanonicalLowercase('f81d4fae'), isTrue);
    });

    test('shouldReturnFalseForUppercaseHex', () {
      expect(IdentifierTypes.isCanonicalLowercase('F81D4FAE'), isFalse);
    });

    test('shouldReturnFalseForMixedCaseHex', () {
      expect(IdentifierTypes.isCanonicalLowercase('F81d4fae'), isFalse);
    });

    test('shouldReturnTrueForAllLowercaseWithHyphens', () {
      expect(
        IdentifierTypes
            .isCanonicalLowercase('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'),
        isTrue,
      );
    });
  });
}
