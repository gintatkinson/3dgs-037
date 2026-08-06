import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/repositories/autonomous_system_and_port_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-022/SqliteAutonomousSystemAndPortRepository]
///
/// SQLite-backed implementation of [AutonomousSystemAndPortRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores AS number and port records in an `as_number_port_records` table
/// with 4 columns matching the [AutonomousSystemAndPortTypes] fields.
class SqliteAutonomousSystemAndPortRepository
    implements AutonomousSystemAndPortRepository {
  /// Creates a [SqliteAutonomousSystemAndPortRepository] backed by [db].
  SqliteAutonomousSystemAndPortRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'as_number_port_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          as_number INTEGER,
          port_number INTEGER
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<AutonomousSystemAndPortTypes>> save(
    AutonomousSystemAndPortTypes record, {
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
  Future<Result<AutonomousSystemAndPortTypes>> fetch(
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
  Future<Result<AutonomousSystemAndPortTypes>> update(
    AutonomousSystemAndPortTypes record, {
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

  /// Serialises an [AutonomousSystemAndPortTypes] [record] and [id] into
  /// a row map.
  Map<String, Object?> _modelToRow(
    AutonomousSystemAndPortTypes record,
    String id,
  ) {
    return {
      'id': id,
      'container_id': record.containerId,
      'as_number': record.asNumber,
      'port_number': record.portNumber,
    };
  }

  /// Deserialises a database [row] into an [AutonomousSystemAndPortTypes]
  /// instance.
  AutonomousSystemAndPortTypes _rowToModel(Map<String, Object?> row) {
    return AutonomousSystemAndPortTypes(
      containerId: row['container_id'] as String? ?? 'default',
      asNumber: row['as_number'] as int? ?? 0,
      portNumber: row['port_number'] as int? ?? 0,
    );
  }
}
