import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_geodetic_system_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteGeodeticSystemRepository', () {
    late Database db;
    late SqliteGeodeticSystemRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteGeodeticSystemRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    const testRecord = GeodeticSystem(
      containerId: 'test-1',
      geodeticDatum: 'wgs-84',
      coordAccuracy: 0.000005,
      heightAccuracy: 0.050000,
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<GeodeticSystem>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeodeticSystem>).value;
      expect(fetched, equals(testRecord));
    });

    test(
        'shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<GeodeticSystem>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('shouldRoundtripNullableFieldsCorrectly', () async {
      const sparseRecord = GeodeticSystem(
        containerId: 'sparse',
        geodeticDatum: 'nad83',
      );
      await repo.save(sparseRecord, id: 'sparse');
      final fetchResult = await repo.fetch(id: 'sparse');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeodeticSystem>).value;
      expect(fetched.geodeticDatum, equals('nad83'));
      expect(fetched.coordAccuracy, isNull);
      expect(fetched.heightAccuracy, isNull);
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      const updated = GeodeticSystem(
        containerId: 'test-2',
        geodeticDatum: 'epsg-4979',
        coordAccuracy: 0.000001,
        heightAccuracy: null,
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      final updatedVal =
          (updateResult as Success<GeodeticSystem>).value;
      expect(updatedVal.geodeticDatum, equals('epsg-4979'));

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeodeticSystem>).value;
      expect(fetched.geodeticDatum, equals('epsg-4979'));
      expect(fetched.coordAccuracy, equals(0.000001));
      expect(fetched.heightAccuracy, isNull);
    });
  });
}
