import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_system_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-035/SqliteGeodeticSystemRepository]
///
/// SQLite-backed implementation of [GeodeticSystemRepository]
/// using sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores geodetic system records in a `geodetic_system_records` table
/// with 4 data columns matching the [GeodeticSystem] fields.
class SqliteGeodeticSystemRepository implements GeodeticSystemRepository {
  /// Creates a [SqliteGeodeticSystemRepository] backed by [db].
  SqliteGeodeticSystemRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'geodetic_system_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          geodetic_datum TEXT,
          coord_accuracy REAL,
          height_accuracy REAL
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<GeodeticSystem>> save(
    GeodeticSystem record, {
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
  Future<Result<GeodeticSystem>> fetch({String id = 'default'}) async {
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
  Future<Result<GeodeticSystem>> update(
    GeodeticSystem record, {
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

  /// Serialises a [GeodeticSystem] [record] and [id] into a row map.
  Map<String, Object?> _modelToRow(GeodeticSystem record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'geodetic_datum': record.geodeticDatum,
      'coord_accuracy': record.coordAccuracy,
      'height_accuracy': record.heightAccuracy,
    };
  }

  /// Deserialises a database [row] into a [GeodeticSystem] instance.
  GeodeticSystem _rowToModel(Map<String, Object?> row) {
    return GeodeticSystem(
      containerId: row['container_id'] as String? ?? 'default',
      geodeticDatum: row['geodetic_datum'] as String? ?? 'wgs-84',
      coordAccuracy: row['coord_accuracy'] as double?,
      heightAccuracy: row['height_accuracy'] as double?,
    );
  }
}
