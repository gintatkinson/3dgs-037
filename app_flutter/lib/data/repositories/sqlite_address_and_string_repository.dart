import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/repositories/address_and_string_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-004/SqliteAddressAndStringRepository]
///
/// SQLite-backed implementation of [AddressAndStringRepository] using
/// sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores address and string records in an `address_and_string_records` table
/// with 8 columns matching the [AddressAndStringTypes] fields.
class SqliteAddressAndStringRepository implements AddressAndStringRepository {
  /// Creates a [SqliteAddressAndStringRepository] backed by [db].
  SqliteAddressAndStringRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'address_and_string_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          phys_address TEXT,
          mac_address TEXT,
          hex_string TEXT,
          dotted_quad TEXT,
          language_tag TEXT,
          xpath10 TEXT
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<AddressAndStringTypes>> save(AddressAndStringTypes record,
      {String id = 'default'}) async {
    try {
      await db.insert(_tableName, {
        'id': id,
        'container_id': record.containerId,
        'phys_address': record.physAddress,
        'mac_address': record.macAddress,
        'hex_string': record.hexString,
        'dotted_quad': record.dottedQuad,
        'language_tag': record.languageTag,
        'xpath10': record.xpath10,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<AddressAndStringTypes>> fetch({String id = 'default'}) async {
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
  Future<Result<AddressAndStringTypes>> update(AddressAndStringTypes record,
      {String id = 'default'}) async {
    try {
      final count = await db.update(
        _tableName,
        {
          'container_id': record.containerId,
          'phys_address': record.physAddress,
          'mac_address': record.macAddress,
          'hex_string': record.hexString,
          'dotted_quad': record.dottedQuad,
          'language_tag': record.languageTag,
          'xpath10': record.xpath10,
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

  /// Deserialises a database [row] into an [AddressAndStringTypes] instance.
  AddressAndStringTypes _rowToModel(Map<String, Object?> row) {
    return AddressAndStringTypes(
      containerId: row['container_id'] as String? ?? '',
      physAddress: row['phys_address'] as String? ?? '',
      macAddress: row['mac_address'] as String? ?? '',
      hexString: row['hex_string'] as String? ?? '',
      dottedQuad: row['dotted_quad'] as String? ?? '',
      languageTag: row['language_tag'] as String? ?? '',
      xpath10: row['xpath10'] as String? ?? '',
    );
  }
}
