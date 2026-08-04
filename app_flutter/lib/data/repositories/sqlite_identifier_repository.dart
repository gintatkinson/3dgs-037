import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/identifier_types.dart';
import '../../domain/repositories/identifier_repository.dart';

/// Concrete SQLite implementation of [IdentifierRepository] using [Database].
///
/// Realises: [Feat-002/SqliteIdentifierRepository]
class SqliteIdentifierRepository implements IdentifierRepository {
  /// Active SQLite database handle.
  final Database _db;

  /// Creates a [SqliteIdentifierRepository] instance wrapping [_db].
  SqliteIdentifierRepository(this._db);

  @override
  Future<Result<IdentifierTypes>> fetch(String containerId) async {
    try {
      final rows = await _db.query(
        'identifier_types',
        where: 'container_id = ?',
        whereArgs: [containerId],
        limit: 1,
      );

      if (rows.isEmpty) {
        return Failure('NOT_FOUND', 'Record not found for container_id: $containerId');
      }

      final row = rows.first;
      final record = IdentifierTypes(
        containerId: row['container_id'] as String,
        objectIdentifier: row['object_identifier'] as String,
        objectIdentifier128: row['object_identifier_128'] as String,
        uuid: row['uuid'] as String,
        yangIdentifier: row['yang_identifier'] as String,
      );

      return Success(record);
    } catch (e) {
      return Failure('SQLITE_FETCH_ERROR', e.toString());
    }
  }

  @override
  Future<Result<void>> save(IdentifierTypes record) async {
    try {
      await _db.insert(
        'identifier_types',
        {
          'container_id': record.containerId,
          'object_identifier': record.objectIdentifier,
          'object_identifier_128': record.objectIdentifier128,
          'uuid': record.uuid,
          'yang_identifier': record.yangIdentifier,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Success(null);
    } catch (e) {
      return Failure('SQLITE_SAVE_ERROR', e.toString());
    }
  }

  @override
  Future<Result<void>> update(IdentifierTypes record) async {
    return save(record);
  }
}
