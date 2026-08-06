import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_reference_frame_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-034/SqliteGeodeticReferenceFrameRepository]
///
/// SQLite-backed implementation of [GeodeticReferenceFrameRepository]
/// using sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores geodetic reference frame records in a
/// `geodetic_reference_frame_records` table with 4 data columns
/// matching the [GeodeticReferenceFrame] fields.
class SqliteGeodeticReferenceFrameRepository
    implements GeodeticReferenceFrameRepository {
  /// Creates a [SqliteGeodeticReferenceFrameRepository] backed by [db].
  SqliteGeodeticReferenceFrameRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'geodetic_reference_frame_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          astronomical_body TEXT,
          alternate_system TEXT,
          alternate_systems INTEGER
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<GeodeticReferenceFrame>> save(
    GeodeticReferenceFrame record, {
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
  Future<Result<GeodeticReferenceFrame>> fetch(
      {String id = 'default'}) async {
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
  Future<Result<GeodeticReferenceFrame>> update(
    GeodeticReferenceFrame record, {
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

  /// Serialises a [GeodeticReferenceFrame] [record] and [id] into a row map.
  Map<String, Object?> _modelToRow(
      GeodeticReferenceFrame record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'astronomical_body': record.astronomicalBody,
      'alternate_system': record.alternateSystem,
      'alternate_systems': record.alternateSystems ? 1 : 0,
    };
  }

  /// Deserialises a database [row] into a [GeodeticReferenceFrame] instance.
  GeodeticReferenceFrame _rowToModel(Map<String, Object?> row) {
    return GeodeticReferenceFrame(
      containerId: row['container_id'] as String? ?? 'default',
      astronomicalBody: row['astronomical_body'] as String? ?? 'earth',
      alternateSystem: row['alternate_system'] as String?,
      alternateSystems: (row['alternate_systems'] as int?) == 1,
    );
  }
}
