import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Location', () {
    test('should create Location with id and default values', () {
      const a = Location(id: 'test');
      const b = Location(id: 'test');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.id, equals('test'));
      expect(a.uuid, isNull);
      expect(a.name, isNull);
      expect(a.alias, isNull);
      expect(a.description, isNull);
      expect(a.type, isNull);
      expect(a.parent, isNull);
      expect(a.timestamp, isNull);
      expect(a.validUntil, isNull);
      expect(a.physicalAddress, isNull);
      expect(a.containedChassis, equals(const []));
      expect(a.containerId, equals('default'));
    });

    test('should create Location with full fields including PhysicalAddress', () {
      const addr = PhysicalAddress(
        address: '500 Howard Street, Suite 400',
        postalCode: '94105',
        state: 'California',
        city: 'San Francisco',
        countryCode: 'US',
      );
      const chassis = ContainedChassis(
        chassisId: 101,
        neRef:
            "/nwi:network-inventory/nwi:network-elements/nwi:network-element[nwi:ne-id='router-sfo-core-01']",
        componentRef:
            "/nwi:network-inventory/nwi:network-elements/nwi:network-element[nwi:ne-id='router-sfo-core-01']/nwi:components/nwi:component[nwi:component-id='chassis-main']",
      );
      const loc = Location(
        id: 'loc-site-sfo-01',
        uuid: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        name: 'San Francisco Primary Data Center',
        alias: 'SFO-DC1',
        description: 'Main West Coast regional data center site',
        type: 'site',
        parent: null,
        timestamp: '2026-07-06T10:00:00Z',
        validUntil: '2030-12-31T23:59:59Z',
        physicalAddress: addr,
        containedChassis: const [chassis],
      );
      expect(loc.id, equals('loc-site-sfo-01'));
      expect(loc.uuid, equals('f47ac10b-58cc-4372-a567-0e02b2c3d479'));
      expect(loc.name, equals('San Francisco Primary Data Center'));
      expect(loc.alias, equals('SFO-DC1'));
      expect(loc.description, equals('Main West Coast regional data center site'));
      expect(loc.type, equals('site'));
      expect(loc.timestamp, equals('2026-07-06T10:00:00Z'));
      expect(loc.validUntil, equals('2030-12-31T23:59:59Z'));
      expect(loc.physicalAddress, equals(addr));
      expect(loc.containedChassis.length, equals(1));
      expect(loc.containedChassis.first, equals(chassis));
    });

    test('should distinguish different locations by id', () {
      const a = Location(id: 'loc-a');
      const b = Location(id: 'loc-b');
      expect(a, isNot(equals(b)));
    });
  });

  group('PhysicalAddress', () {
    test('should create PhysicalAddress with country code', () {
      const addr = PhysicalAddress(countryCode: 'US');
      expect(addr.countryCode, equals('US'));
      expect(addr.address, isNull);
      expect(addr.postalCode, isNull);
      expect(addr.state, isNull);
      expect(addr.city, isNull);
    });

    test('should have value equality', () {
      const a = PhysicalAddress(
        address: '500 Howard Street',
        postalCode: '94105',
        city: 'San Francisco',
        state: 'California',
        countryCode: 'US',
      );
      const b = PhysicalAddress(
        address: '500 Howard Street',
        postalCode: '94105',
        city: 'San Francisco',
        state: 'California',
        countryCode: 'US',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('ContainedChassis', () {
    test('should create ContainedChassis with chassisId', () {
      const c = ContainedChassis(chassisId: 101);
      expect(c.chassisId, equals(101));
      expect(c.neRef, isNull);
      expect(c.componentRef, isNull);
    });

    test('should have value equality', () {
      const a = ContainedChassis(
        chassisId: 101,
        neRef: '/nwi:ne[ne-id=router-01]',
        componentRef: '/nwi:ne[ne-id=router-01]/comp[id=chassis-main]',
      );
      const b = ContainedChassis(
        chassisId: 101,
        neRef: '/nwi:ne[ne-id=router-01]',
        componentRef: '/nwi:ne[ne-id=router-01]/comp[id=chassis-main]',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('validateCountryCode', () {
    test('should validate ISO country code US as valid', () {
      final result = validateCountryCode('US');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('US'));
    });

    test('should reject country code USA as invalid (too long)', () {
      final result = validateCountryCode('USA');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CountryCodeValidationError>());
      final ceError = error as CountryCodeValidationError;
      expect(ceError.input, equals('USA'));
    });

    test('should reject country code us as invalid (lowercase)', () {
      final result = validateCountryCode('us');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CountryCodeValidationError>());
      final ceError = error as CountryCodeValidationError;
      expect(ceError.input, equals('us'));
    });

    test('should reject country code 123 as invalid (digits)', () {
      final result = validateCountryCode('123');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CountryCodeValidationError>());
      final ceError = error as CountryCodeValidationError;
      expect(ceError.input, equals('123'));
    });

    test('should reject empty country code', () {
      final result = validateCountryCode('');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CountryCodeValidationError>());
    });

    test('should accept DE and FR as valid country codes', () {
      expect(validateCountryCode('DE').isSuccess, isTrue);
      expect(validateCountryCode('FR').isSuccess, isTrue);
      expect(validateCountryCode('JP').isSuccess, isTrue);
    });
  });

  group('validateCyclicParent', () {
    test('should detect cyclic parent reference A->B->A', () {
      const locA = Location(id: 'loc-A', parent: 'loc-B');
      const locB = Location(id: 'loc-B', parent: null);
      final allLocations = <Location>[locA, locB];

      final result = validateCyclicParent('loc-B', 'loc-A', allLocations);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CyclicParentReferenceError>());
      final cpError = error as CyclicParentReferenceError;
      expect(cpError.locationId, equals('loc-B'));
      expect(cpError.parentId, equals('loc-A'));
    });

    test('should detect self-referential parent reference', () {
      const locA = Location(id: 'loc-A');
      final result = validateCyclicParent('loc-A', 'loc-A', const []);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CyclicParentReferenceError>());
    });

    test('should allow non-cyclic parent reference', () {
      const locA = Location(id: 'loc-A', parent: null);
      const locB = Location(id: 'loc-B', parent: null);
      final allLocations = <Location>[locA, locB];

      final result = validateCyclicParent('loc-A', 'loc-B', allLocations);
      expect(result.isSuccess, isTrue);
    });

    test('should allow null parentId as acyclic', () {
      const locA = Location(id: 'loc-A');
      final result = validateCyclicParent('loc-A', null, const [locA]);
      expect(result.isSuccess, isTrue);
    });

    test('should detect deep cyclic chain A->B->C->A', () {
      const locA = Location(id: 'loc-A', parent: 'loc-C');
      const locB = Location(id: 'loc-B', parent: 'loc-A');
      const locC = Location(id: 'loc-C', parent: 'loc-B');
      final allLocations = <Location>[locA, locB, locC];

      final result = validateCyclicParent('loc-C', 'loc-A', allLocations);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<CyclicParentReferenceError>());
    });
  });

  group('validateDuplicateChassisId', () {
    test('should detect duplicate chassis-id values', () {
      const chassisList = <ContainedChassis>[
        ContainedChassis(chassisId: 101),
        ContainedChassis(chassisId: 101),
      ];
      final result = validateDuplicateChassisId(chassisList);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<List<ContainedChassis>>).error;
      expect(error, isA<DuplicateChassisIdError>());
      final dupError = error as DuplicateChassisIdError;
      expect(dupError.chassisId, equals(101));
    });

    test('should allow unique chassis-id values', () {
      const chassisList = <ContainedChassis>[
        ContainedChassis(chassisId: 101),
        ContainedChassis(chassisId: 102),
        ContainedChassis(chassisId: 103),
      ];
      final result = validateDuplicateChassisId(chassisList);
      expect(result.isSuccess, isTrue);
    });

    test('should allow empty chassis list', () {
      final result = validateDuplicateChassisId(const []);
      expect(result.isSuccess, isTrue);
    });
  });

  group('validateLocation', () {
    test('should validate complete Location model', () {
      const addr = PhysicalAddress(countryCode: 'US');
      const loc = Location(
        id: 'loc-site-sfo-01',
        physicalAddress: addr,
      );
      final result = validateLocation(loc);
      expect(result.isSuccess, isTrue);
      expect((result as Success<Location>).value, equals(loc));
    });

    test('should fail validation on empty location id', () {
      const loc = Location(id: '');
      final result = validateLocation(loc);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Location>).error;
      expect(error, isA<SchemaFieldRequiredError>());
    });

    test('should fail validation on invalid country code in address', () {
      const addr = PhysicalAddress(countryCode: 'USA');
      const loc = Location(id: 'loc-test', physicalAddress: addr);
      final result = validateLocation(loc);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Location>).error;
      expect(error, isA<CountryCodeValidationError>());
    });

    test('should fail validation on duplicate chassis ids', () {
      const chassisList = <ContainedChassis>[
        ContainedChassis(chassisId: 101),
        ContainedChassis(chassisId: 101),
      ];
      const loc = Location(id: 'loc-test', containedChassis: chassisList);
      final result = validateLocation(loc);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Location>).error;
      expect(error, isA<DuplicateChassisIdError>());
    });
  });

  group('validatePhysicalAddress', () {
    test('should accept address with null country code', () {
      const addr = PhysicalAddress(address: '500 Howard Street');
      final result = validatePhysicalAddress(addr);
      expect(result.isSuccess, isTrue);
    });

    test('should accept address with valid country code', () {
      const addr = PhysicalAddress(countryCode: 'DE');
      final result = validatePhysicalAddress(addr);
      expect(result.isSuccess, isTrue);
    });

    test('should reject address with invalid country code', () {
      const addr = PhysicalAddress(countryCode: 'usa');
      final result = validatePhysicalAddress(addr);
      expect(result.isFailure, isTrue);
      final error = (result as Failure<PhysicalAddress>).error;
      expect(error, isA<CountryCodeValidationError>());
    });
  });

  group('Field key constants', () {
    test('should define kFieldLocationId', () {
      expect(kFieldLocationId, equals('id'));
    });
    test('should define kFieldUuid', () {
      expect(kFieldUuid, equals('uuid'));
    });
    test('should define kFieldName', () {
      expect(kFieldName, equals('name'));
    });
    test('should define kFieldAlias', () {
      expect(kFieldAlias, equals('alias'));
    });
    test('should define kFieldDescription', () {
      expect(kFieldDescription, equals('description'));
    });
    test('should define kFieldType', () {
      expect(kFieldType, equals('type'));
    });
    test('should define kFieldParent', () {
      expect(kFieldParent, equals('parent'));
    });
    test('should define kFieldTimestamp', () {
      expect(kFieldTimestamp, equals('timestamp'));
    });
    test('should define kFieldValidUntil', () {
      expect(kFieldValidUntil, equals('validUntil'));
    });
    test('should define kFieldAddress', () {
      expect(kFieldAddress, equals('address'));
    });
    test('should define kFieldPostalCode', () {
      expect(kFieldPostalCode, equals('postalCode'));
    });
    test('should define kFieldState', () {
      expect(kFieldState, equals('state'));
    });
    test('should define kFieldCity', () {
      expect(kFieldCity, equals('city'));
    });
    test('should define kFieldCountryCode', () {
      expect(kFieldCountryCode, equals('countryCode'));
    });
    test('should define kFieldChassisId', () {
      expect(kFieldChassisId, equals('chassisId'));
    });
    test('should define kFieldNeRef', () {
      expect(kFieldNeRef, equals('neRef'));
    });
    test('should define kFieldComponentRef', () {
      expect(kFieldComponentRef, equals('componentRef'));
    });
    test('should define kFieldContainedChassis', () {
      expect(kFieldContainedChassis, equals('containedChassis'));
    });
  });
}
