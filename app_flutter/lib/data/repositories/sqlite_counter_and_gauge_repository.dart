import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-001/CounterAndGaugeRepository]
///
/// Concrete SQLite implementation of [CounterAndGaugeRepository] using [Database].
class SqliteCounterAndGaugeRepository implements CounterAndGaugeRepository {
  /// Creates a [SqliteCounterAndGaugeRepository] wrapping an active SQLite [db].
  SqliteCounterAndGaugeRepository({required this.db});

  /// The active SQLite database connection instance.
  final Database db;

  /// Table name for counter and gauge records.
  static const String tableName = 'counter_and_gauge_records';

  /// Initializes the database table for counter and gauge records if it does not already exist.
  Future<void> initDatabase() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        counter32 INTEGER NOT NULL,
        zero_based_counter32 INTEGER NOT NULL,
        counter64 TEXT NOT NULL,
        zero_based_counter64 TEXT NOT NULL,
        gauge32 INTEGER NOT NULL,
        gauge64 TEXT NOT NULL
      );
    ''');
  }

  @override
  Future<Result<CounterAndGaugeTypes>> save(
    CounterAndGaugeTypes record, {
    String id = 'default',
  }) async {
    try {
      await initDatabase();
      await db.insert(
        tableName,
        {
          'id': id,
          'counter32': record.counter32,
          'zero_based_counter32': record.zeroBasedCounter32,
          'counter64': record.counter64.toString(),
          'zero_based_counter64': record.zeroBasedCounter64.toString(),
          'gauge32': record.gauge32,
          'gauge64': record.gauge64.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(
        message: 'Failed to save counter and gauge record: $e',
      ));
    }
  }

  @override
  Future<Result<CounterAndGaugeTypes>> fetch({
    String id = 'default',
  }) async {
    try {
      await initDatabase();
      final maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return const Result.failure(InstanceNotFoundError(
          instanceId: 'counter_and_gauge_record',
        ));
      }

      final map = maps.first;
      final record = CounterAndGaugeTypes(
        counter32: map['counter32'] as int,
        zeroBasedCounter32: map['zero_based_counter32'] as int,
        counter64: BigInt.parse(map['counter64'] as String),
        zeroBasedCounter64: BigInt.parse(map['zero_based_counter64'] as String),
        gauge32: map['gauge32'] as int,
        gauge64: BigInt.parse(map['gauge64'] as String),
      );

      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(
        message: 'Failed to fetch counter and gauge record: $e',
      ));
    }
  }

  @override
  Future<Result<CounterAndGaugeTypes>> update(
    CounterAndGaugeTypes record, {
    String id = 'default',
  }) async {
    try {
      await initDatabase();
      final count = await db.update(
        tableName,
        {
          'counter32': record.counter32,
          'zero_based_counter32': record.zeroBasedCounter32,
          'counter64': record.counter64.toString(),
          'zero_based_counter64': record.zeroBasedCounter64.toString(),
          'gauge32': record.gauge32,
          'gauge64': record.gauge64.toString(),
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        return save(record, id: id);
      }

      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(
        message: 'Failed to update counter and gauge record: $e',
      ));
    }
  }
}
