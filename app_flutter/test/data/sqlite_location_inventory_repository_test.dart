import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_location_inventory_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteLocationInventoryRepository', () {
    late Database db;
    late SqliteLocationInventoryRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteLocationInventoryRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    const testAddress = PhysicalAddress(
      address: '123 Test St',
      postalCode: '90210',
      state: 'CA',
      city: 'Testville',
      countryCode: 'US',
    );

    const testLocation = Location(
      containerId: 'test-container',
      id: 'loc-001',
      name: 'Test Location',
      alias: 'TL1',
      description: 'A test location',
      type: 'site',
      parent: 'root-parent',
      timestamp: '2026-01-01T00:00:00Z',
      validUntil: '2027-01-01T00:00:00Z',
      physicalAddress: testAddress,
      containedChassis: [],
    );

    const testChassis1 = ContainedChassis(
      chassisId: 1,
      neRef: 'ne-001',
      componentRef: 'comp-001',
    );

    const testChassis2 = ContainedChassis(
      chassisId: 2,
      neRef: 'ne-002',
      componentRef: 'comp-002',
    );

    test('should initialize database and create both tables', () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Location>).error;
      expect(error, isA<InstanceNotFoundError>());
    });

    test('should save and fetch location with physical address', () async {
      final saveResult = await repo.save(testLocation, id: 'db-key-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<Location>).value;
      expect(saved, equals(testLocation));
      expect(saved.physicalAddress, equals(testAddress));

      final fetchResult = await repo.fetch(id: 'db-key-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched, equals(testLocation));
      expect(fetched.physicalAddress, equals(testAddress));
    });

    test('should save and fetch location with contained chassis', () async {
      const locWithChassis = Location(
        containerId: 'test-container',
        id: 'loc-002',
        name: 'Chassis Location',
        containedChassis: [testChassis1, testChassis2],
      );

      final saveResult = await repo.save(locWithChassis, id: 'db-key-2');
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'db-key-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.id, equals('loc-002'));
      expect(fetched.containedChassis.length, equals(2));
      expect(fetched.containedChassis, contains(testChassis1));
      expect(fetched.containedChassis, contains(testChassis2));
    });

    test('should return InstanceNotFoundError for missing record', () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Location>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('should update location fields', () async {
      await repo.save(testLocation, id: 'db-key-3');

      const updated = Location(
        containerId: 'updated-container',
        id: 'loc-001',
        name: 'Updated Name',
        alias: 'UAL',
        description: 'Updated description',
        type: 'building',
        parent: 'new-parent',
        timestamp: '2026-06-01T00:00:00Z',
        validUntil: '2027-06-01T00:00:00Z',
        physicalAddress: PhysicalAddress(
          address: '456 New St',
          postalCode: '10001',
          state: 'NY',
          city: 'Newville',
          countryCode: 'US',
        ),
        containedChassis: [],
      );

      final updateResult = await repo.update(updated, id: 'db-key-3');
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'db-key-3');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.name, equals('Updated Name'));
      expect(fetched.alias, equals('UAL'));
      expect(fetched.type, equals('building'));
      expect(fetched.parent, equals('new-parent'));
      expect(fetched.physicalAddress!.address, equals('456 New St'));
      expect(fetched.physicalAddress!.city, equals('Newville'));
      expect(fetched.containerId, equals('updated-container'));
    });

    test('should replace chassis list on update', () async {
      const locWithChassis = Location(
        containerId: 'test-container',
        id: 'loc-004',
        name: 'Chassis Update Location',
        containedChassis: [testChassis1, testChassis2],
      );

      await repo.save(locWithChassis, id: 'db-key-4');

      const thirdChassis = ContainedChassis(
        chassisId: 3,
        neRef: 'ne-003',
        componentRef: 'comp-003',
      );

      const updated = Location(
        containerId: 'test-container',
        id: 'loc-004',
        name: 'Chassis Update Location',
        containedChassis: [thirdChassis],
      );

      final updateResult = await repo.update(updated, id: 'db-key-4');
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'db-key-4');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.containedChassis.length, equals(1));
      expect(fetched.containedChassis.first, equals(thirdChassis));
    });

    test('should fetch all locations', () async {
      const locA = Location(
        containerId: 'test-container',
        id: 'loc-all-a',
        name: 'Location A',
      );
      const locB = Location(
        containerId: 'test-container',
        id: 'loc-all-b',
        name: 'Location B',
      );

      await repo.save(locA, id: 'key-a');
      await repo.save(locB, id: 'key-b');

      final result = await repo.fetchAll();
      expect(result.isSuccess, isTrue);
      final all = (result as Success<List<Location>>).value;
      expect(all.length, equals(2));
      expect(all.map((l) => l.id), containsAll(['loc-all-a', 'loc-all-b']));
    });

    test('should fetch locations by parent', () async {
      const childA = Location(
        containerId: 'test-container',
        id: 'child-a',
        name: 'Child A',
        parent: 'my-parent',
      );
      const childB = Location(
        containerId: 'test-container',
        id: 'child-b',
        name: 'Child B',
        parent: 'my-parent',
      );

      await repo.save(childA, id: 'key-ca');
      await repo.save(childB, id: 'key-cb');

      final result = await repo.fetchByParent(parentId: 'my-parent');
      expect(result.isSuccess, isTrue);
      final children = (result as Success<List<Location>>).value;
      expect(children.length, equals(2));
      expect(children.map((l) => l.id), containsAll(['child-a', 'child-b']));
    });

    test('should delete location and its chassis', () async {
      const locWithChassis = Location(
        containerId: 'test-container',
        id: 'loc-del',
        name: 'To Delete',
        containedChassis: [testChassis1],
      );

      await repo.save(locWithChassis, id: 'del-key');

      final deleteResult = await repo.delete(id: 'del-key');
      expect(deleteResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'del-key');
      expect(fetchResult.isFailure, isTrue);
      expect((fetchResult as Failure<Location>).error,
          isA<InstanceNotFoundError>());
    });

    test('should add chassis to existing location', () async {
      await repo.save(testLocation, id: 'key-add');

      final addResult = await repo.addChassis('loc-001', testChassis1);
      expect(addResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'key-add');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.containedChassis.length, equals(1));
      expect(fetched.containedChassis.first, equals(testChassis1));
    });

    test('should remove chassis from existing location', () async {
      const locWithChassis = Location(
        containerId: 'test-container',
        id: 'loc-rem',
        name: 'Remove Test',
        containedChassis: [testChassis1, testChassis2],
      );

      await repo.save(locWithChassis, id: 'key-rem');

      final removeResult = await repo.removeChassis('loc-rem', 1);
      expect(removeResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'key-rem');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.containedChassis.length, equals(1));
      expect(fetched.containedChassis.first, equals(testChassis2));
    });

    test('should return InstanceNotFoundError on delete nonexistent', () async {
      final result = await repo.delete(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<void>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    const testFullBuildingPosition = BuildingPosition(
      building: 'Building B',
      floor: 'Floor 3',
      room: 'Room 302',
      roomBuildingPosition: 'B/3/302',
    );

    test('should save and fetch location with full buildingPosition', () async {
      const locWithBP = Location(
        containerId: 'test-container',
        id: 'loc-bp-full',
        name: 'BP Full',
        buildingPosition: testFullBuildingPosition,
      );

      final saveResult = await repo.save(locWithBP, id: 'bp-key-full');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<Location>).value;
      expect(saved.buildingPosition, equals(testFullBuildingPosition));

      final fetchResult = await repo.fetch(id: 'bp-key-full');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.buildingPosition, equals(testFullBuildingPosition));
    });

    test('should save and fetch location with null buildingPosition', () async {
      const locNullBP = Location(
        containerId: 'test-container',
        id: 'loc-bp-null',
        name: 'BP Null',
        buildingPosition: null,
      );

      final saveResult = await repo.save(locNullBP, id: 'bp-key-null');
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'bp-key-null');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.buildingPosition, isNull);
    });

    test('should save and fetch location with partial buildingPosition',
        () async {
      const partialBP = BuildingPosition(
        building: 'Tower A',
        floor: '12',
      );
      const locPartialBP = Location(
        containerId: 'test-container',
        id: 'loc-bp-partial',
        name: 'BP Partial',
        buildingPosition: partialBP,
      );

      final saveResult = await repo.save(locPartialBP, id: 'bp-key-partial');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<Location>).value;
      expect(saved.buildingPosition, equals(partialBP));

      final fetchResult = await repo.fetch(id: 'bp-key-partial');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.buildingPosition, equals(partialBP));
    });

    test('should preserve buildingPosition on update', () async {
      const locWithBP = Location(
        containerId: 'test-container',
        id: 'loc-bp-update',
        name: 'BP Update',
        buildingPosition: testFullBuildingPosition,
      );

      await repo.save(locWithBP, id: 'bp-key-update');

      const updated = Location(
        containerId: 'updated-container',
        id: 'loc-bp-update',
        name: 'Updated BP Name',
        buildingPosition: testFullBuildingPosition,
      );

      final updateResult = await repo.update(updated, id: 'bp-key-update');
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'bp-key-update');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Location>).value;
      expect(fetched.name, equals('Updated BP Name'));
      expect(fetched.buildingPosition, equals(testFullBuildingPosition));
    });
  });
}
