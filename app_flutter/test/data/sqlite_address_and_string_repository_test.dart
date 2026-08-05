import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_address_and_string_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteAddressAndStringRepository', () {
    late Database db;
    late SqliteAddressAndStringRepository repo;

    setUp(() async {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteAddressAndStringRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = AddressAndStringTypes(
      containerId: 'ctr-1',
      physAddress: '00:11:22:33:44:55',
      macAddress: '08:00:27:00:a1:4c',
      hexString: 'a1:b2:c3:d4',
      dottedQuad: '192.0.2.1',
      languageTag: 'en-US',
      xpath10: '/ietf-yang-types:address-and-string-types/mac-address',
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<AddressAndStringTypes>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<AddressAndStringTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      final updated = testRecord.copyWith(physAddress: 'aa:bb:cc:dd');
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      expect(
        (updateResult as Success<AddressAndStringTypes>).value.physAddress,
        equals('aa:bb:cc:dd'),
      );

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      expect(
        (fetchResult as Success<AddressAndStringTypes>).value.physAddress,
        equals('aa:bb:cc:dd'),
      );
    });

    test('shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<AddressAndStringTypes>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
        (error as InstanceNotFoundError).instanceId,
        equals('nonexistent'),
      );
    });

    test('shouldRoundtripEmptyFields', () async {
      final emptyRecord = AddressAndStringTypes(
        containerId: 'empty-1',
        physAddress: '',
        macAddress: '00:00:00:00:00:00',
        hexString: '',
        dottedQuad: '0.0.0.0',
        languageTag: 'en',
        xpath10: '/root',
      );
      await repo.save(emptyRecord, id: 'empty-test');
      final fetchResult = await repo.fetch(id: 'empty-test');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<AddressAndStringTypes>).value;
      expect(fetched.physAddress, isEmpty);
      expect(fetched.hexString, isEmpty);
    });

    test('shouldUseDefaultIdWhenNotSpecified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect(
        (fetchResult as Success<AddressAndStringTypes>).value,
        equals(testRecord),
      );
    });

    test('shouldSaveWithContainerIdMapping', () async {
      await repo.save(testRecord, id: 'addr-001');
      final result = await repo.fetch(id: 'addr-001');
      expect(result.isSuccess, isTrue);
    });
  });
}
