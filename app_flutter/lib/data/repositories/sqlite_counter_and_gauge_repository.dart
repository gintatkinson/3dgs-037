import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-001/SqliteCounterAndGaugeRepository]
///
/// SQLite-backed implementation of [CounterAndGaugeRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores counter and gauge records in a `counter_and_gauge_records` table
/// with columns matching the [CounterAndGaugeTypes] fields.
/// 64-bit values (counter64, zeroBasedCounter64, gauge64) are stored as
/// TEXT to preserve full precision beyond native integer limits.
class SqliteCounterAndGaugeRepository implements CounterAndGaugeRepository {
  /// Creates a [SqliteCounterAndGaugeRepository] backed by [db].
  SqliteCounterAndGaugeRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'counter_and_gauge_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          counter32 INTEGER,
          zero_based_counter32 INTEGER,
          counter64 TEXT,
          zero_based_counter64 TEXT,
          gauge32 INTEGER,
          gauge64 TEXT
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<CounterAndGaugeTypes>> save(CounterAndGaugeTypes record,
      {String id = 'default'}) async {
    try {
      await db.insert(_tableName, {
        'id': id,
        'container_id': id,
        'counter32': record.counter32,
        'zero_based_counter32': record.zeroBasedCounter32,
        'counter64': record.counter64.toString(),
        'zero_based_counter64': record.zeroBasedCounter64.toString(),
        'gauge32': record.gauge32,
        'gauge64': record.gauge64.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<CounterAndGaugeTypes>> fetch({String id = 'default'}) async {
    try {
      final results = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) {
        return Result.failure(InstanceNotFoundError(instanceId: id));
      }
      return Result.success(_rowToModel(results.first));
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<CounterAndGaugeTypes>> update(CounterAndGaugeTypes record,
      {String id = 'default'}) async {
    try {
      final count = await db.update(
        _tableName,
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
        return Result.failure(InstanceNotFoundError(instanceId: id));
      }
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  /// Deserialises a database [row] into a [CounterAndGaugeTypes] instance.
  CounterAndGaugeTypes _rowToModel(Map<String, Object?> row) {
    return CounterAndGaugeTypes(
      counter32: row['counter32'] as int? ?? 0,
      zeroBasedCounter32: row['zero_based_counter32'] as int? ?? 0,
      counter64: _parseBigInt(row['counter64']),
      zeroBasedCounter64: _parseBigInt(row['zero_based_counter64']),
      gauge32: row['gauge32'] as int? ?? 0,
      gauge64: _parseBigInt(row['gauge64']),
    );
  }

  /// Parses a string column value to [BigInt], defaulting to [BigInt.zero].
  BigInt _parseBigInt(Object? value) {
    if (value == null) return BigInt.zero;
    return BigInt.tryParse(value.toString()) ?? BigInt.zero;
  }
}
