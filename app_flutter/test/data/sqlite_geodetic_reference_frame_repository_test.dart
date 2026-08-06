import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_geodetic_reference_frame_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteGeodeticReferenceFrameRepository', () {
    late Database db;
    late SqliteGeodeticReferenceFrameRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteGeodeticReferenceFrameRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = GeodeticReferenceFrame(
      containerId: 'test-1',
      astronomicalBody: 'mars',
      alternateSystem: 'wgs84-3d',
      alternateSystems: true,
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved =
          (saveResult as Success<GeodeticReferenceFrame>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<GeodeticReferenceFrame>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      final updated = GeodeticReferenceFrame(
        containerId: 'test-2',
        astronomicalBody: 'earth',
        alternateSystem: null,
        alternateSystems: false,
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      expect(
        (updateResult as Success<GeodeticReferenceFrame>).value.astronomicalBody,
        equals('earth'),
      );

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<GeodeticReferenceFrame>).value;
      expect(fetched.astronomicalBody, equals('earth'));
      expect(fetched.alternateSystem, isNull);
      expect(fetched.alternateSystems, isFalse);
    });

    test('shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<GeodeticReferenceFrame>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('shouldUseDefaultIdWhenNotSpecified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect(
        (fetchResult as Success<GeodeticReferenceFrame>).value,
        equals(testRecord),
      );
    });

    test('shouldRoundtripNullableFieldsCorrectly', () async {
      const sparseRecord = GeodeticReferenceFrame(
        containerId: 'sparse',
        astronomicalBody: 'earth',
      );
      await repo.save(sparseRecord, id: 'sparse');
      final fetchResult = await repo.fetch(id: 'sparse');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<GeodeticReferenceFrame>).value;
      expect(fetched.astronomicalBody, equals('earth'));
      expect(fetched.alternateSystem, isNull);
      expect(fetched.alternateSystems, isFalse);
    });

    test('shouldRoundtripWithAlternateSystemsEnabled', () async {
      await repo.save(testRecord, id: 'feat-true');
      final fetchResult = await repo.fetch(id: 'feat-true');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<GeodeticReferenceFrame>).value;
      expect(fetched.alternateSystems, isTrue);
      expect(fetched.alternateSystem, equals('wgs84-3d'));
    });
  });
}
