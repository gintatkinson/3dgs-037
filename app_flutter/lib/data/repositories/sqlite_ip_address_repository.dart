import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/repositories/ip_address_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-020/SqliteIpAddressRepository]
///
/// SQLite-backed implementation of [IpAddressRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores IP address records in an `ip_address_records` table with
/// 12 columns matching the [IpAddressTypes] fields.
class SqliteIpAddressRepository implements IpAddressRepository {
  /// Creates a [SqliteIpAddressRepository] backed by [db].
  SqliteIpAddressRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'ip_address_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          ip_version INTEGER,
          ip_address TEXT,
          ipv4_address TEXT,
          ipv6_address TEXT,
          ip_prefix TEXT,
          ipv4_prefix TEXT,
          ipv6_prefix TEXT,
          ip_address_no_zone TEXT,
          ipv4_address_no_zone TEXT,
          ipv6_address_no_zone TEXT
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<IpAddressTypes>> save(IpAddressTypes record,
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
  Future<Result<IpAddressTypes>> fetch({String id = 'default'}) async {
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
  Future<Result<IpAddressTypes>> update(IpAddressTypes record,
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

  /// Serialises an [IpAddressTypes] [record] and [id] into a row map.
  Map<String, Object?> _modelToRow(IpAddressTypes record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'ip_version': record.ipVersion,
      'ip_address': record.ipAddress,
      'ipv4_address': record.ipv4Address,
      'ipv6_address': record.ipv6Address,
      'ip_prefix': record.ipPrefix,
      'ipv4_prefix': record.ipv4Prefix,
      'ipv6_prefix': record.ipv6Prefix,
      'ip_address_no_zone': record.ipAddressNoZone,
      'ipv4_address_no_zone': record.ipv4AddressNoZone,
      'ipv6_address_no_zone': record.ipv6AddressNoZone,
    };
  }

  /// Deserialises a database [row] into an [IpAddressTypes] instance.
  IpAddressTypes _rowToModel(Map<String, Object?> row) {
    return IpAddressTypes(
      containerId: row['container_id'] as String? ?? 'default',
      ipVersion: row['ip_version'] as int? ?? 0,
      ipAddress: row['ip_address'] as String?,
      ipv4Address: row['ipv4_address'] as String?,
      ipv6Address: row['ipv6_address'] as String?,
      ipPrefix: row['ip_prefix'] as String?,
      ipv4Prefix: row['ipv4_prefix'] as String?,
      ipv6Prefix: row['ipv6_prefix'] as String?,
      ipAddressNoZone: row['ip_address_no_zone'] as String?,
      ipv4AddressNoZone: row['ipv4_address_no_zone'] as String?,
      ipv6AddressNoZone: row['ipv6_address_no_zone'] as String?,
    );
  }
}
