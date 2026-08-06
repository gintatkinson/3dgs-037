import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_velocity_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteVelocityRepository', () {
    late Database db;
    late SqliteVelocityRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteVelocityRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    const testRecord = Velocity(
      containerId: 'test-1',
      vNorth: 1.5,
      vEast: 2.5,
      vUp: 0.01,
    );

    test('should initialize database and create velocity_records table',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Velocity>).error;
      expect(error, isA<InstanceNotFoundError>());
    });

    test('should save and fetch velocity record', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<Velocity>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Velocity>).value;
      expect(fetched, equals(testRecord));
    });

    test('should return InstanceNotFoundError for missing record', () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Velocity>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('should update existing velocity record', () async {
      await repo.save(testRecord, id: 'test-2');

      const updated = Velocity(
        containerId: 'test-2',
        vNorth: 3.0,
        vEast: 4.0,
        vUp: null,
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      final updatedVal = (updateResult as Success<Velocity>).value;
      expect(updatedVal.vNorth, equals(3.0));
      expect(updatedVal.vEast, equals(4.0));
      expect(updatedVal.vUp, isNull);

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<Velocity>).value;
      expect(fetched.vNorth, equals(3.0));
      expect(fetched.vEast, equals(4.0));
      expect(fetched.vUp, isNull);
    });

    test('should return InstanceNotFoundError on update of nonexistent record',
        () async {
      const record = Velocity(
        containerId: 'missing',
        vNorth: 1.0,
      );
      final result = await repo.update(record, id: 'missing');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<Velocity>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('missing'));
    });
  });
}
