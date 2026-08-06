import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_identifier_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteIdentifierRepository', () {
    late Database db;
    late SqliteIdentifierRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteIdentifierRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = IdentifierTypes(
      containerId: 'ctr-1',
      objectIdentifier: '1.3.6.1.4.1',
      objectIdentifier128: '1.3.6.1.4.1',
      uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
      yangIdentifier: 'interfaces',
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<IdentifierTypes>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<IdentifierTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      final updated = testRecord.copyWith(
          uuid: '00000000-0000-0000-0000-000000000001');
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      expect(
        (fetchResult as Success<IdentifierTypes>).value.uuid,
        equals('00000000-0000-0000-0000-000000000001'),
      );
    });

    test('shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<IdentifierTypes>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('shouldRoundtripAllStringFields', () async {
      const record = IdentifierTypes(
        containerId: 'big-ctr',
        objectIdentifier: '0.39.4294967295',
        objectIdentifier128: '2.5.0',
        uuid: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        yangIdentifier: 'xml-element',
      );
      await repo.save(record, id: 'roundtrip');
      final fetchResult = await repo.fetch(id: 'roundtrip');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<IdentifierTypes>).value;
      expect(fetched.objectIdentifier, equals('0.39.4294967295'));
      expect(fetched.uuid, equals('a1b2c3d4-e5f6-7890-abcd-ef1234567890'));
      expect(fetched.yangIdentifier, equals('xml-element'));
    });

    test('shouldUseDefaultIdWhenNotSpecified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<IdentifierTypes>).value,
          equals(testRecord));
    });
  });
}
