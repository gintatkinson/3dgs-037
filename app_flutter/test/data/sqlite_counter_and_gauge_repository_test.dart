import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/data/repositories/sqlite_counter_and_gauge_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SqliteCounterAndGaugeRepository Integration Tests', () {
    late Database db;
    late CounterAndGaugeRepository repository;

    setUp(() async {
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repository = SqliteCounterAndGaugeRepository(db: db);
      await (repository as SqliteCounterAndGaugeRepository).initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    test('should save CounterAndGaugeTypes record to SQLite and fetch it back', () async {
      final record = CounterAndGaugeTypes(
        counter32: 100,
        zeroBasedCounter32: 50,
        counter64: BigInt.parse('18446744073709551600'),
        zeroBasedCounter64: BigInt.parse('1234567890'),
        gauge32: 200,
        gauge64: BigInt.parse('9876543210'),
      );

      final saveResult = await repository.save(record);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repository.fetch();
      expect(fetchResult.isSuccess, isTrue);

      final fetchedRecord = (fetchResult as Success<CounterAndGaugeTypes>).value;
      expect(fetchedRecord, equals(record));
    });

    test('should update counter and gauge fields in SQLite', () async {
      final initialRecord = CounterAndGaugeTypes(
        counter32: 10,
        zeroBasedCounter32: 5,
        counter64: BigInt.from(100),
        zeroBasedCounter64: BigInt.from(50),
        gauge32: 30,
        gauge64: BigInt.from(300),
      );

      await repository.save(initialRecord);

      final updatedRecord = CounterAndGaugeTypes(
        counter32: 20,
        zeroBasedCounter32: 15,
        counter64: BigInt.from(200),
        zeroBasedCounter64: BigInt.from(100),
        gauge32: 40,
        gauge64: BigInt.from(400),
      );

      final updateResult = await repository.update(updatedRecord);
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repository.fetch();
      expect(fetchResult.isSuccess, isTrue);

      final fetchedRecord = (fetchResult as Success<CounterAndGaugeTypes>).value;
      expect(fetchedRecord, equals(updatedRecord));
      expect(fetchedRecord.counter32, equals(20));
      expect(fetchedRecord.gauge32, equals(40));
    });
  });
}
