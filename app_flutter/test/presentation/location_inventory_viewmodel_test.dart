import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_location_inventory_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/repositories/location_inventory_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/location_inventory_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('LocationInventoryViewModel BDD', () {
    late Database db;
    late SqliteLocationInventoryRepository repo;
    late LocationInventoryViewModel viewModel;

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
      physicalAddress: PhysicalAddress(
        address: '123 Test St',
        postalCode: '90210',
        state: 'CA',
        city: 'Testville',
        countryCode: 'US',
      ),
      containedChassis: [],
    );

    const testChassis = ContainedChassis(
      chassisId: 1,
      neRef: 'ne-001',
      componentRef: 'comp-001',
    );

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteLocationInventoryRepository(db);
      await repo.initDatabase();
      viewModel = LocationInventoryViewModel(repo);
    });

    tearDown(() async {
      viewModel.dispose();
      await db.close();
    });

    test('should load location from repository', () async {
      await repo.save(testLocation, id: 'test-key-1');

      await viewModel.load('test-key-1');

      expect(viewModel.model, equals(testLocation));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('should load all locations from repository', () async {
      const locA = Location(
        containerId: 'test-container',
        id: 'loc-a',
        name: 'Location A',
      );
      const locB = Location(
        containerId: 'test-container',
        id: 'loc-b',
        name: 'Location B',
      );

      await repo.save(locA, id: 'key-a');
      await repo.save(locB, id: 'key-b');

      await viewModel.loadAll();

      expect(viewModel.allLocations.length, equals(2));
      expect(viewModel.allLocations.map((l) => l.id),
          containsAll(['loc-a', 'loc-b']));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('should save location to repository', () async {
      await viewModel.save(testLocation, recordId: 'save-key');

      expect(viewModel.model, equals(testLocation));
      expect(viewModel.errorMessage, isNull);

      final fetchResult = await repo.fetch(id: 'save-key');
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<Location>).value, equals(testLocation));
    });

    test('should update location in repository', () async {
      await repo.save(testLocation, id: 'update-key');

      const updated = Location(
        containerId: 'test-container',
        id: 'loc-001',
        name: 'Updated Name',
        containedChassis: [],
      );

      await viewModel.update(updated, recordId: 'update-key');

      expect(viewModel.model, equals(updated));
      expect(viewModel.errorMessage, isNull);

      final fetchResult = await repo.fetch(id: 'update-key');
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<Location>).value.name,
          equals('Updated Name'));
    });

    test('should delete location from repository', () async {
      await repo.save(testLocation, id: 'delete-key');

      await viewModel.delete('delete-key');

      expect(viewModel.model, isNull);
      expect(viewModel.errorMessage, isNull);

      final fetchResult = await repo.fetch(id: 'delete-key');
      expect(fetchResult.isFailure, isTrue);
      expect((fetchResult as Failure<Location>).error,
          isA<InstanceNotFoundError>());
    });

    test('should expose error message on InstanceNotFoundError', () async {
      await viewModel.load('nonexistent');

      expect(viewModel.model, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Record not found'));
    });

    test('should expose error message on DatabaseStorageError', () async {
      final mockRepo = _FailingSaveLocationInventoryRepository();
      final vm = LocationInventoryViewModel(mockRepo);

      await vm.save(testLocation, recordId: 'fail-db');

      expect(vm.errorMessage, contains('Database error:'));
      expect(vm.model, isNull);

      vm.dispose();
    });

    test('should create with initial null model and not loading', () {
      expect(viewModel.model, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.allLocations, isEmpty);
    });
  });
}

class _FailingSaveLocationInventoryRepository
    implements LocationInventoryRepository {
  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<Location>> save(
    Location record, {
    String id = 'default',
  }) async {
    return Result.failure(
        const DatabaseStorageError(message: 'Mock DB failure'));
  }

  @override
  Future<Result<Location>> fetch({String id = 'default'}) async {
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<Location>> update(
    Location record, {
    String id = 'default',
  }) async {
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<List<Location>>> fetchAll() async {
    return Result.success([]);
  }

  @override
  Future<Result<List<Location>>> fetchByParent({String? parentId}) async {
    return Result.success([]);
  }

  @override
  Future<Result<void>> delete({String id = 'default'}) async {
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<ContainedChassis>> addChassis(
    String locationId,
    ContainedChassis chassis,
  ) async {
    return Result.failure(
        const DatabaseStorageError(message: 'Mock DB failure'));
  }

  @override
  Future<Result<void>> removeChassis(
    String locationId,
    int chassisId,
  ) async {
    return Result.failure(
        const DatabaseStorageError(message: 'Mock DB failure'));
  }
}
