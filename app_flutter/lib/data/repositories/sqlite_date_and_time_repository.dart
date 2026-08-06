import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/date_and_time_types.dart';
import 'package:app_flutter/domain/repositories/date_and_time_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-003/SqliteDateAndTimeRepository]
///
/// SQLite-backed implementation of [DateAndTimeRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores date-and-time records in a `date_and_time_records` table
/// with columns matching all 16 [DateAndTimeTypes] fields.
class SqliteDateAndTimeRepository implements DateAndTimeRepository {
  /// Creates a [SqliteDateAndTimeRepository] backed by [db].
  SqliteDateAndTimeRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'date_and_time_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          date_and_time TEXT,
          date TEXT,
          date_no_zone TEXT,
          time TEXT,
          time_no_zone TEXT,
          hours32 INTEGER,
          minutes32 INTEGER,
          seconds32 INTEGER,
          centiseconds32 INTEGER,
          milliseconds32 INTEGER,
          microseconds32 INTEGER,
          microseconds64 INTEGER,
          nanoseconds32 INTEGER,
          nanoseconds64 INTEGER,
          timeticks INTEGER,
          timestamp INTEGER
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<DateAndTimeTypes>> save(DateAndTimeTypes record,
      {String id = 'default'}) async {
    try {
      await db.insert(_tableName, _modelToRow(record, id),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<DateAndTimeTypes>> fetch({String id = 'default'}) async {
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
  Future<Result<DateAndTimeTypes>> update(DateAndTimeTypes record,
      {String id = 'default'}) async {
    try {
      final count = await db.update(
        _tableName,
        _modelToRow(record, id),
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

  Map<String, Object?> _modelToRow(DateAndTimeTypes record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'date_and_time': record.dateAndTime,
      'date': record.date,
      'date_no_zone': record.dateNoZone,
      'time': record.time,
      'time_no_zone': record.timeNoZone,
      'hours32': record.hours32,
      'minutes32': record.minutes32,
      'seconds32': record.seconds32,
      'centiseconds32': record.centiseconds32,
      'milliseconds32': record.milliseconds32,
      'microseconds32': record.microseconds32,
      'microseconds64': record.microseconds64,
      'nanoseconds32': record.nanoseconds32,
      'nanoseconds64': record.nanoseconds64,
      'timeticks': record.timeticks,
      'timestamp': record.timestamp,
    };
  }

  DateAndTimeTypes _rowToModel(Map<String, Object?> row) {
    return DateAndTimeTypes(
      containerId: row['container_id'] as String? ?? '',
      dateAndTime: row['date_and_time'] as String? ?? '',
      date: row['date'] as String? ?? '',
      dateNoZone: row['date_no_zone'] as String? ?? '',
      time: row['time'] as String? ?? '',
      timeNoZone: row['time_no_zone'] as String? ?? '',
      hours32: row['hours32'] as int? ?? 0,
      minutes32: row['minutes32'] as int? ?? 0,
      seconds32: row['seconds32'] as int? ?? 0,
      centiseconds32: row['centiseconds32'] as int? ?? 0,
      milliseconds32: row['milliseconds32'] as int? ?? 0,
      microseconds32: row['microseconds32'] as int? ?? 0,
      microseconds64: row['microseconds64'] as int? ?? 0,
      nanoseconds32: row['nanoseconds32'] as int? ?? 0,
      nanoseconds64: row['nanoseconds64'] as int? ?? 0,
      timeticks: row['timeticks'] as int? ?? 0,
      timestamp: row['timestamp'] as int? ?? 0,
    );
  }
}
