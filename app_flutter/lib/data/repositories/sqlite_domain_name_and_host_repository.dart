import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/repositories/domain_name_and_host_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-021/SqliteDomainNameAndHostRepository]
///
/// SQLite-backed implementation of [DomainNameAndHostRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores domain name and host records in a
/// `domain_name_and_host_records` table with 5 columns matching the
/// [DomainNameAndHostTypes] fields.
class SqliteDomainNameAndHostRepository
    implements DomainNameAndHostRepository {
  /// Creates a [SqliteDomainNameAndHostRepository] backed by [db].
  SqliteDomainNameAndHostRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'domain_name_and_host_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          domain_name TEXT,
          host TEXT,
          uri TEXT
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<DomainNameAndHostTypes>> save(
      DomainNameAndHostTypes record,
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
  Future<Result<DomainNameAndHostTypes>> fetch(
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
  Future<Result<DomainNameAndHostTypes>> update(
      DomainNameAndHostTypes record,
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

  /// Serialises a [DomainNameAndHostTypes] [record] and [id] into a
  /// row map for SQLite insertion.
  Map<String, Object?> _modelToRow(
      DomainNameAndHostTypes record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'domain_name': record.domainName,
      'host': record.host,
      'uri': record.uri,
    };
  }

  /// Deserialises a database [row] into a [DomainNameAndHostTypes]
  /// instance.
  DomainNameAndHostTypes _rowToModel(Map<String, Object?> row) {
    return DomainNameAndHostTypes(
      containerId: row['container_id'] as String? ?? 'default',
      domainName: row['domain_name'] as String? ?? '',
      host: row['host'] as String? ?? '',
      uri: row['uri'] as String? ?? '',
    );
  }
}
