import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_velocity_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/repositories/velocity_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/velocity_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('VelocityViewModel BDD', () {
    late Database db;
    late SqliteVelocityRepository repo;
    late VelocityViewModel viewModel;

    const testRecord = Velocity(
      containerId: 'test-1',
      vNorth: 1.5,
      vEast: 2.5,
      vUp: 0.01,
    );

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteVelocityRepository(db);
      await repo.initDatabase();
      viewModel = VelocityViewModel(repo);
    });

    tearDown(() async {
      viewModel.dispose();
      await db.close();
    });

    test('should load velocity from repository', () async {
      await repo.save(testRecord, id: 'test-1');

      await viewModel.load('test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('should save velocity to repository', () async {
      await viewModel.save(testRecord, recordId: 'test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.errorMessage, isNull);

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<Velocity>).value, equals(testRecord));
    });

    test('should expose error message on database storage failure', () async {
      final mockRepo = _FailingSaveVelocityRepository();
      final vm = VelocityViewModel(mockRepo);

      await vm.save(testRecord, recordId: 'fail-db');

      expect(vm.errorMessage, contains('Database error:'));
      expect(vm.model, isNull);

      vm.dispose();
    });

    test('should expose error message when instance not found', () async {
      await viewModel.load('nonexistent');

      expect(viewModel.model, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Record not found'));
    });

    test('should create with initial null model and not loading', () {
      expect(viewModel.model, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });
  });
}

class _FailingSaveVelocityRepository implements VelocityRepository {
  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<Velocity>> save(
    Velocity record, {
    String id = 'default',
  }) async {
    return Result.failure(
        const DatabaseStorageError(message: 'Mock DB failure'));
  }

  @override
  Future<Result<Velocity>> fetch({String id = 'default'}) async {
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<Velocity>> update(
    Velocity record, {
    String id = 'default',
  }) async {
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }
}
