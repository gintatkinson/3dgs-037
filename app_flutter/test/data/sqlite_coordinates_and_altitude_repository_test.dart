import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_coordinates_and_altitude_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteCoordinatesAndAltitudeRepository', () {
    late Database db;
    late SqliteCoordinatesAndAltitudeRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteCoordinatesAndAltitudeRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    const testRecord = GeoLocation(
      containerId: 'test-1',
      timestamp: '2026-08-04T12:00:00Z',
      validUntil: '2026-08-04T18:00:00Z',
      ellipsoid: EllipsoidalCoordinates(
        latitude: 37.7749,
        longitude: -122.4194,
        height: 15.5,
      ),
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<GeoLocation>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeoLocation>).value;
      expect(fetched, equals(testRecord));
    });

    test(
        'shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<GeoLocation>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('shouldRoundtripCartesianCoordinatesCorrectly', () async {
      const cartesianRecord = GeoLocation(
        containerId: 'cart',
        cartesian: CartesianCoordinates(
          x: -2696667.123456,
          y: -4294025.654321,
          z: 3887802.987654,
        ),
      );
      await repo.save(cartesianRecord, id: 'cart');
      final fetchResult = await repo.fetch(id: 'cart');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeoLocation>).value;
      expect(fetched.cartesian, equals(cartesianRecord.cartesian));
      expect(fetched.ellipsoid, isNull);
    });

    test('shouldRoundtripNullableFieldsCorrectly', () async {
      const sparseRecord = GeoLocation(containerId: 'sparse');
      await repo.save(sparseRecord, id: 'sparse');
      final fetchResult = await repo.fetch(id: 'sparse');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeoLocation>).value;
      expect(fetched.timestamp, isNull);
      expect(fetched.validUntil, isNull);
      expect(fetched.ellipsoid, isNull);
      expect(fetched.cartesian, isNull);
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      const updated = GeoLocation(
        containerId: 'test-2',
        timestamp: '2026-08-05T00:00:00Z',
        validUntil: '2026-08-05T12:00:00Z',
        cartesian: CartesianCoordinates(x: 100.0, y: 200.0, z: 300.0),
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<GeoLocation>).value;
      expect(fetched.timestamp, equals('2026-08-05T00:00:00Z'));
      expect(fetched.validUntil, equals('2026-08-05T12:00:00Z'));
      expect(fetched.ellipsoid, isNull);
      expect(fetched.cartesian, isNotNull);
    });
  });
}
