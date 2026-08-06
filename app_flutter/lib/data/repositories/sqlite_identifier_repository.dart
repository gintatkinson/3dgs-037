import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-002/SqliteIdentifierRepository]
///
/// SQLite-backed implementation of [IdentifierRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores identifier records in an `identifier_records` table with
/// columns matching the [IdentifierTypes] fields. All fields are
/// stored as TEXT.
class SqliteIdentifierRepository implements IdentifierRepository {
  /// Creates a [SqliteIdentifierRepository] backed by [db].
  SqliteIdentifierRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'identifier_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          object_identifier TEXT,
          object_identifier_128 TEXT,
          uuid TEXT,
          yang_identifier TEXT
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<IdentifierTypes>> save(IdentifierTypes record,
      {String id = 'default'}) async {
    try {
      await db.insert(
        _tableName,
        {
          'id': id,
          'container_id': record.containerId,
          'object_identifier': record.objectIdentifier,
          'object_identifier_128': record.objectIdentifier128,
          'uuid': record.uuid,
          'yang_identifier': record.yangIdentifier,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<IdentifierTypes>> fetch({String id = 'default'}) async {
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
  Future<Result<IdentifierTypes>> update(IdentifierTypes record,
      {String id = 'default'}) async {
    try {
      final count = await db.update(
        _tableName,
        {
          'container_id': record.containerId,
          'object_identifier': record.objectIdentifier,
          'object_identifier_128': record.objectIdentifier128,
          'uuid': record.uuid,
          'yang_identifier': record.yangIdentifier,
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

  /// Deserialises a database [row] into an [IdentifierTypes] instance.
  IdentifierTypes _rowToModel(Map<String, Object?> row) {
    return IdentifierTypes(
      containerId: (row['container_id'] as String?) ?? '',
      objectIdentifier: (row['object_identifier'] as String?) ?? '',
      objectIdentifier128: (row['object_identifier_128'] as String?) ?? '',
      uuid: (row['uuid'] as String?) ?? '',
      yangIdentifier: (row['yang_identifier'] as String?) ?? '',
    );
  }
}
