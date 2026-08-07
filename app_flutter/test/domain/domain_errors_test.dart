import 'package:app_flutter/domain/domain_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainError Hierarchy', () {
    test('shouldStoreStructuredContextWhenSchemaFieldRequiredErrorInstantiated', () {
      const error = SchemaFieldRequiredError(
        fieldName: 'title',
        schemaName: 'Document',
      );

      expect(error.fieldName, equals('title'));
      expect(error.schemaName, equals('Document'));
      expect(error, isA<DomainError>());
    });

    test('shouldStoreStructuredContextWhenSchemaFieldTypeErrorInstantiated', () {
      const error = SchemaFieldTypeError(
        fieldName: 'age',
        expectedType: 'int',
        actualType: 'String',
      );

      expect(error.fieldName, equals('age'));
      expect(error.expectedType, equals('int'));
      expect(error.actualType, equals('String'));
      expect(error, isA<DomainError>());
    });

    test('shouldStoreStructuredContextWhenSchemaFieldRangeErrorInstantiated', () {
      const error = SchemaFieldRangeError(
        fieldName: 'score',
        value: 105,
        min: 0,
        max: 100,
      );

      expect(error.fieldName, equals('score'));
      expect(error.value, equals(105));
      expect(error.min, equals(0));
      expect(error.max, equals(100));
      expect(error, isA<DomainError>());
    });

    test('shouldStoreStructuredContextWhenSchemaFieldPatternErrorInstantiated', () {
      const error = SchemaFieldPatternError(
        fieldName: 'email',
        value: 'invalid-email',
        pattern: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      expect(error.fieldName, equals('email'));
      expect(error.value, equals('invalid-email'));
      expect(error.pattern, equals(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'));
      expect(error, isA<DomainError>());
    });

    test('shouldStoreStructuredContextWhenSchemaFieldEnumErrorInstantiated', () {
      const error = SchemaFieldEnumError(
        fieldName: 'status',
        value: 'UNKNOWN',
        allowedValues: ['ACTIVE', 'INACTIVE', 'PENDING'],
      );

      expect(error.fieldName, equals('status'));
      expect(error.value, equals('UNKNOWN'));
      expect(error.allowedValues, equals(['ACTIVE', 'INACTIVE', 'PENDING']));
      expect(error, isA<DomainError>());
    });

    test('shouldStoreStructuredContextWhenSerializationErrorInstantiated', () {
      const payload = {'raw': 123};
      const error = SerializationError(
        targetType: 'InstanceRecord',
        reason: 'Malformed JSON key',
        payload: payload,
      );

      expect(error.targetType, equals('InstanceRecord'));
      expect(error.reason, equals('Malformed JSON key'));
      expect(error.payload, equals(payload));
      expect(error, isA<DomainError>());
    });

    test('shouldSupportExhaustivePatternMatchingWhenEvaluatingDomainError', () {
      final List<DomainError> errors = [
        const SchemaFieldRequiredError(fieldName: 'f', schemaName: 's'),
        const SchemaFieldTypeError(fieldName: 'f', expectedType: 'int', actualType: 'String'),
        const SchemaFieldRangeError(fieldName: 'f', value: 10),
        const SchemaFieldPatternError(fieldName: 'f', value: 'v', pattern: 'p'),
        const SchemaFieldEnumError(fieldName: 'f', value: 'e', allowedValues: ['e']),
        const SerializationError(targetType: 't', reason: 'r'),
        const DatabaseStorageError(message: 'm'),
        const InstanceNotFoundError(instanceId: 'i'),
        const DomainNameLengthExceededError(length: 300),
        const InvalidLabelSyntaxError(label: 'invalid..label'),
        const InvalidHostFormatError(input: 'bad_host_@#\$%'),
        const UriZeroLengthError(),
        const UriNonAsciiError(input: 'https://x.com/ñ'),
        const IpFlowLabelOutOfBoundsError(value: -1),
        const DscpOutOfBoundsError(value: 64),
        const InvalidUnicastAddressError(input: '224.0.0.1'),
        const InvalidMulticastAddressError(input: '192.168.1.1'),
        const UnresolvableScopeTypeError(value: 'cosmic'),
        const InvalidAstronomicalBodyError(input: 'bad\x00'),
        const FeatureDisabledAlternateSystemError(value: 'wgs84-3d'),
        const InvalidGeodeticDatumError(input: 'bad\x00'),
        const NegativeAccuracyValueError(fieldName: 'coordAccuracy', value: -1.0),
        const AccuracyPrecisionExceededError(fieldName: 'heightAccuracy', value: 0.00000001),
        const InvalidLatitudeOutOfBoundsError(value: 95.0),
        const InvalidLongitudeOutOfBoundsError(value: 200.0),
        const MutualExclusivityViolationError(),
        const MissingMandatoryCoordinatesError(branch: 'ellipsoid'),
        const InvalidDateTimeFormatError(input: 'bad-date'),
        const InvalidTemporalWindowError(timestamp: '2026-08-04T18:00:00Z', validUntil: '2026-08-04T12:00:00Z'),
        const VelocityPrecisionExceededError(fieldName: 'vNorth', value: 0.0000000000001),
        const UndefinedHeadingAngleError(),
        const CountryCodeValidationError(input: 'USA'),
        const CyclicParentReferenceError(locationId: 'loc-A', parentId: 'loc-B'),
        const DuplicateChassisIdError(chassisId: 101),
        const BuildingPositionValidationError(building: 'Building B', floor: 'Floor 3', room: 'Room 302', roomBuildingPosition: null),
        const BuildingPositionLengthError(field: 'building', maxLength: 64, actualLength: 65),
      ];

      for (final err in errors) {
        final description = switch (err) {
          SchemaFieldRequiredError(:final fieldName, :final schemaName) =>
            'Required: $fieldName in $schemaName',
          SchemaFieldTypeError(:final fieldName, :final expectedType, :final actualType) =>
            'Type: $fieldName ($expectedType != $actualType)',
          SchemaFieldRangeError(:final fieldName, :final value) =>
            'Range: $fieldName = $value',
          SchemaFieldPatternError(:final fieldName, :final value, :final pattern) =>
            'Pattern: $fieldName ($value !~ $pattern)',
          SchemaFieldEnumError(:final fieldName, :final value, :final allowedValues) =>
            'Enum: $fieldName ($value not in $allowedValues)',
          SerializationError(:final targetType, :final reason) =>
            'Serialization: $targetType — $reason',
          DatabaseStorageError(:final message) =>
            'Database: $message',
          InstanceNotFoundError(:final instanceId) =>
            'NotFound: $instanceId',
          InvalidIpVersionError(:final value) =>
            'InvalidIpVersion: $value',
          InvalidIpv4FormatError(:final input) =>
            'InvalidIpv4Format: $input',
          InvalidIpv6FormatError(:final input) =>
            'InvalidIpv6Format: $input',
          ZoneIndexDisallowedError(:final input) =>
            'ZoneIndexDisallowed: $input',
          Ipv4PrefixLengthOutOfBoundsError(:final length) =>
            'Ipv4PrefixLen: $length',
          Ipv6PrefixLengthOutOfBoundsError(:final length) =>
            'Ipv6PrefixLen: $length',
          DomainNameLengthExceededError(:final length) =>
            'DomainNameLen: $length',
          InvalidLabelSyntaxError(:final label) =>
            'InvalidLabel: $label',
          InvalidHostFormatError(:final input) =>
            'InvalidHost: $input',
          UriZeroLengthError() =>
            'UriZeroLen',
          UriNonAsciiError(:final input) =>
            'UriNonAscii: $input',
          IpFlowLabelOutOfBoundsError(:final value) =>
            'IpFlowLabel: $value',
          DscpOutOfBoundsError(:final value) =>
            'Dscp: $value',
          InvalidUnicastAddressError(:final input) =>
            'InvalidUnicast: $input',
          InvalidMulticastAddressError(:final input) =>
            'InvalidMulticast: $input',
          UnresolvableScopeTypeError(:final value) =>
            'UnresolvableScope: $value',
          InvalidAstronomicalBodyError(:final input) =>
            'InvalidAstroBody: $input',
          FeatureDisabledAlternateSystemError(:final value) =>
            'FeatureDisabledAltSys: $value',
          InvalidGeodeticDatumError(:final input) =>
            'InvalidGeodeticDatum: $input',
          NegativeAccuracyValueError(:final fieldName, :final value) =>
            'NegativeAccuracy: $fieldName=$value',
          AccuracyPrecisionExceededError(:final fieldName, :final value) =>
            'AccuracyPrecision: $fieldName=$value',
          InvalidLatitudeOutOfBoundsError(:final value) =>
            'InvalidLat: $value',
          InvalidLongitudeOutOfBoundsError(:final value) =>
            'InvalidLon: $value',
          MutualExclusivityViolationError() =>
            'MutualExcl',
          MissingMandatoryCoordinatesError(:final branch) =>
            'MissingCoords: $branch',
          InvalidDateTimeFormatError(:final input) =>
            'InvalidDateTime: $input',
          InvalidTemporalWindowError(:final timestamp, :final validUntil) =>
            'InvalidWindow: $timestamp -> $validUntil',
          VelocityPrecisionExceededError(:final fieldName, :final value) =>
            'VelocityPrecision: $fieldName=$value',
          UndefinedHeadingAngleError() =>
            'UndefinedHeading',
          CountryCodeValidationError(:final input) =>
            'CountryCode: $input',
          CyclicParentReferenceError(:final locationId, :final parentId) =>
            'CyclicParent: $locationId -> $parentId',
          DuplicateChassisIdError(:final chassisId) =>
            'DuplicateChassis: $chassisId',
          BuildingPositionValidationError(:final building, :final floor, :final room, :final roomBuildingPosition) =>
            'BuildingPosition: $building, $floor, $room, $roomBuildingPosition',
          BuildingPositionLengthError(:final field, :final maxLength, :final actualLength) =>
            'BuildingPosition: $field len=$actualLength max=$maxLength',
        };
        expect(description, isNotEmpty);
      }
    });
  });
}
