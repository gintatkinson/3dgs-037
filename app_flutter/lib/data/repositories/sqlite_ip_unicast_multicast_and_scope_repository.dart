import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/repositories/ip_unicast_multicast_and_scope_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-023/SqliteIpUnicastMulticastAndScopeRepository]
///
/// SQLite-backed implementation of [IpUnicastMulticastAndScopeRepository]
/// using sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores records in an `ip_unscp_multicast_records` table with 11 columns
/// matching the [IpUnicastMulticastAndScopeTypes] fields.
class SqliteIpUnicastMulticastAndScopeRepository
    implements IpUnicastMulticastAndScopeRepository {
  /// Creates a [SqliteIpUnicastMulticastAndScopeRepository] backed by [db].
  SqliteIpUnicastMulticastAndScopeRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'ip_unscp_multicast_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          ipv6_flow_label INTEGER,
          dscp INTEGER,
          ip_unicast_address TEXT,
          ipv4_unicast_address TEXT,
          ipv6_unicast_address TEXT,
          ip_multicast_address TEXT,
          ipv4_multicast_address TEXT,
          ipv6_multicast_address TEXT,
          scope_type TEXT
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> save(
      IpUnicastMulticastAndScopeTypes record,
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
  Future<Result<IpUnicastMulticastAndScopeTypes>> fetch(
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
  Future<Result<IpUnicastMulticastAndScopeTypes>> update(
      IpUnicastMulticastAndScopeTypes record,
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

  /// Serialises an [IpUnicastMulticastAndScopeTypes] [record] and [id] into
  /// a row map.
  Map<String, Object?> _modelToRow(
      IpUnicastMulticastAndScopeTypes record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'ipv6_flow_label': record.ipv6FlowLabel,
      'dscp': record.dscp,
      'ip_unicast_address': record.ipUnicastAddress,
      'ipv4_unicast_address': record.ipv4UnicastAddress,
      'ipv6_unicast_address': record.ipv6UnicastAddress,
      'ip_multicast_address': record.ipMulticastAddress,
      'ipv4_multicast_address': record.ipv4MulticastAddress,
      'ipv6_multicast_address': record.ipv6MulticastAddress,
      'scope_type': record.scopeType,
    };
  }

  /// Deserialises a database [row] into an [IpUnicastMulticastAndScopeTypes]
  /// instance.
  IpUnicastMulticastAndScopeTypes _rowToModel(Map<String, Object?> row) {
    return IpUnicastMulticastAndScopeTypes(
      containerId: row['container_id'] as String? ?? 'default',
      ipv6FlowLabel: row['ipv6_flow_label'] as int? ?? 0,
      dscp: row['dscp'] as int? ?? 0,
      ipUnicastAddress: row['ip_unicast_address'] as String?,
      ipv4UnicastAddress: row['ipv4_unicast_address'] as String?,
      ipv6UnicastAddress: row['ipv6_unicast_address'] as String?,
      ipMulticastAddress: row['ip_multicast_address'] as String?,
      ipv4MulticastAddress: row['ipv4_multicast_address'] as String?,
      ipv6MulticastAddress: row['ipv6_multicast_address'] as String?,
      scopeType: row['scope_type'] as String?,
    );
  }
}
