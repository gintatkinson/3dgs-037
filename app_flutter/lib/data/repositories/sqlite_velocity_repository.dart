import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/repositories/velocity_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-037/SqliteVelocityRepository]
///
/// SQLite-backed implementation of [VelocityRepository]
/// using sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores velocity records in a `velocity_records` table
/// with 5 data columns matching the [Velocity] fields.
class SqliteVelocityRepository implements VelocityRepository {
  /// Creates a [SqliteVelocityRepository] backed by [db].
  SqliteVelocityRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'velocity_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          v_north REAL,
          v_east REAL,
          v_up REAL
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<Velocity>> save(
    Velocity record, {
    String id = 'default',
  }) async {
    try {
      await db.insert(_tableName, _modelToRow(record, id),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<Velocity>> fetch({String id = 'default'}) async {
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
  Future<Result<Velocity>> update(
    Velocity record, {
    String id = 'default',
  }) async {
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

  /// Serialises a [Velocity] [record] and [id] into a row map.
  Map<String, Object?> _modelToRow(Velocity record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'v_north': record.vNorth,
      'v_east': record.vEast,
      'v_up': record.vUp,
    };
  }

  /// Deserialises a database [row] into a [Velocity] instance.
  Velocity _rowToModel(Map<String, Object?> row) {
    return Velocity(
      containerId: row['container_id'] as String? ?? 'default',
      vNorth: row['v_north'] as double?,
      vEast: row['v_east'] as double?,
      vUp: row['v_up'] as double?,
    );
  }
}
