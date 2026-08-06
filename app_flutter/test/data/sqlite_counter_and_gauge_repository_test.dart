import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_counter_and_gauge_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteCounterAndGaugeRepository', () {
    late Database db;
    late SqliteCounterAndGaugeRepository repo;

    setUp(() async {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteCounterAndGaugeRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = CounterAndGaugeTypes(
      counter32: 100,
      zeroBasedCounter32: 0,
      counter64: BigInt.from(500),
      zeroBasedCounter64: BigInt.zero,
      gauge32: 250,
      gauge64: BigInt.from(1000),
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<CounterAndGaugeTypes>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<CounterAndGaugeTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      final updated = testRecord.copyWith(gauge32: 999);
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      expect((updateResult as Success<CounterAndGaugeTypes>).value.gauge32,
          equals(999));

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<CounterAndGaugeTypes>).value.gauge32,
          equals(999));
    });

    test('shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<CounterAndGaugeTypes>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect((error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('shouldRoundtripBigIntCounter64Value', () async {
      final bigRecord = CounterAndGaugeTypes(
        counter32: 0,
        zeroBasedCounter32: 0,
        counter64: BigInt.parse('18446744073709551610'),
        zeroBasedCounter64: BigInt.zero,
        gauge32: 0,
        gauge64: BigInt.zero,
      );
      await repo.save(bigRecord, id: 'big-test');
      final fetchResult = await repo.fetch(id: 'big-test');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<CounterAndGaugeTypes>).value;
      expect(fetched.counter64, equals(bigRecord.counter64));
    });

    test('shouldUseDefaultIdWhenNotSpecified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<CounterAndGaugeTypes>).value,
          equals(testRecord));
    });

    test('shouldFetchWithContainerIdMapping', () async {
      await repo.save(testRecord, id: 'ctr-001');
      final result = await repo.fetch(id: 'ctr-001');
      expect(result.isSuccess, isTrue);
    });
  });
}
