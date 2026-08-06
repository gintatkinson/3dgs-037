import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_autonomous_system_and_port_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteAutonomousSystemAndPortRepository', () {
    late Database db;
    late SqliteAutonomousSystemAndPortRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteAutonomousSystemAndPortRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    const testRecord = AutonomousSystemAndPortTypes(
      containerId: 'test-1',
      asNumber: 64512,
      portNumber: 80,
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<AutonomousSystemAndPortTypes>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<AutonomousSystemAndPortTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      const updated = AutonomousSystemAndPortTypes(
        containerId: 'test-2',
        asNumber: 65535,
        portNumber: 443,
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      expect(
        (updateResult as Success<AutonomousSystemAndPortTypes>).value.asNumber,
        equals(65535),
      );

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<AutonomousSystemAndPortTypes>).value;
      expect(fetched.asNumber, equals(65535));
      expect(fetched.portNumber, equals(443));
    });

    test('shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error =
          (result as Failure<AutonomousSystemAndPortTypes>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
        (error as InstanceNotFoundError).instanceId,
        equals('nonexistent'),
      );
    });

    test('shouldUseDefaultIdWhenNotSpecified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect(
        (fetchResult as Success<AutonomousSystemAndPortTypes>).value,
        equals(testRecord),
      );
    });

    test('shouldRoundtripBoundaryValues', () async {
      const boundaryRecord = AutonomousSystemAndPortTypes(
        containerId: 'boundary',
        asNumber: 4294967295,
        portNumber: 65535,
      );
      await repo.save(boundaryRecord, id: 'boundary');
      final fetchResult = await repo.fetch(id: 'boundary');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<AutonomousSystemAndPortTypes>).value;
      expect(fetched.asNumber, equals(4294967295));
      expect(fetched.portNumber, equals(65535));
    });

    test('shouldRoundtripPortZeroRecord', () async {
      const zeroPortRecord = AutonomousSystemAndPortTypes(
        containerId: 'zero',
        asNumber: 0,
        portNumber: 0,
      );
      await repo.save(zeroPortRecord, id: 'zero');
      final fetchResult = await repo.fetch(id: 'zero');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<AutonomousSystemAndPortTypes>).value;
      expect(fetched.portNumber, equals(0));
    });
  });
}
