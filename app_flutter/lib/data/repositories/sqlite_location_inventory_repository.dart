import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/repositories/location_inventory_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-047/SqliteLocationInventoryRepository]
///
/// SQLite-backed implementation of [LocationInventoryRepository]
/// using sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores location records in a `locations` table with flattened
/// [PhysicalAddress] fields, and [ContainedChassis] entries in a
/// `contained_chassis` table with a foreign key to `locations.loc_id`.
class SqliteLocationInventoryRepository
    implements LocationInventoryRepository {
  /// Creates a [SqliteLocationInventoryRepository] backed by [db].
  SqliteLocationInventoryRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _locationsTable = 'locations';
  static const String _chassisTable = 'contained_chassis';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_locationsTable (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          loc_id TEXT NOT NULL UNIQUE,
          uuid TEXT,
          name TEXT,
          alias TEXT,
          description TEXT,
          type TEXT,
          parent TEXT,
          timestamp TEXT,
          valid_until TEXT,
          address TEXT,
          postal_code TEXT,
          state TEXT,
          city TEXT,
          country_code TEXT,
          building TEXT,
          floor TEXT,
          room TEXT,
          room_building_position TEXT
        )
      ''');

      for (final col in ['building', 'floor', 'room',
          'room_building_position']) {
        try {
          await db.execute(
            'ALTER TABLE $_locationsTable ADD COLUMN $col TEXT',
          );
        } catch (_) {
          // column may already exist from a prior migration
        }
      }
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_chassisTable (
          location_id TEXT NOT NULL,
          chassis_id INTEGER NOT NULL,
          ne_ref TEXT,
          component_ref TEXT,
          PRIMARY KEY (location_id, chassis_id),
          FOREIGN KEY (location_id) REFERENCES $_locationsTable(loc_id) ON DELETE CASCADE
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<Location>> save(
    Location record, {
    String id = 'default',
  }) async {
    try {
      await db.transaction((txn) async {
        await txn.insert(_locationsTable, _modelToRow(record, id),
            conflictAlgorithm: ConflictAlgorithm.replace);
        await _deleteChassisForLocation(txn, record.id);
        await _insertChassisRows(txn, record.id, record.containedChassis);
      });
      return Result.success(record);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<Location>> fetch({String id = 'default'}) async {
    try {
      final results = await db.query(
        _locationsTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) {
        return Result.failure(InstanceNotFoundError(instanceId: id));
      }
      final row = results.first;
      final locId = row['loc_id'] as String;
      final chassisRows = await db.query(
        _chassisTable,
        where: 'location_id = ?',
        whereArgs: [locId],
      );
      return Result.success(_rowToModel(row, chassisRows));
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<Location>> update(
    Location record, {
    String id = 'default',
  }) async {
    try {
      final updated = await db.transaction((txn) async {
        final count = await txn.update(
          _locationsTable,
          _modelToRow(record, id),
          where: 'id = ?',
          whereArgs: [id],
        );
        if (count == 0) {
          return null;
        }
        await _deleteChassisForLocation(txn, record.id);
        await _insertChassisRows(txn, record.id, record.containedChassis);
        return record;
      });
      if (updated == null) {
        return Result.failure(InstanceNotFoundError(instanceId: id));
      }
      return Result.success(updated);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Location>>> fetchAll() async {
    try {
      final rows = await db.query(_locationsTable);
      final locations = <Location>[];
      for (final row in rows) {
        final locId = row['loc_id'] as String;
        final chassisRows = await db.query(
          _chassisTable,
          where: 'location_id = ?',
          whereArgs: [locId],
        );
        locations.add(_rowToModel(row, chassisRows));
      }
      return Result.success(locations);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Location>>> fetchByParent({String? parentId}) async {
    try {
      final List<Map<String, Object?>> rows;
      if (parentId != null) {
        rows = await db.query(
          _locationsTable,
          where: 'parent = ?',
          whereArgs: [parentId],
        );
      } else {
        rows = await db.query(
          _locationsTable,
          where: 'parent IS NULL',
        );
      }
      final locations = <Location>[];
      for (final row in rows) {
        final locId = row['loc_id'] as String;
        final chassisRows = await db.query(
          _chassisTable,
          where: 'location_id = ?',
          whereArgs: [locId],
        );
        locations.add(_rowToModel(row, chassisRows));
      }
      return Result.success(locations);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> delete({String id = 'default'}) async {
    try {
      final row = await db.query(
        _locationsTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
        columns: ['loc_id'],
      );
      if (row.isEmpty) {
        return Result.failure(InstanceNotFoundError(instanceId: id));
      }
      final locId = row.first['loc_id'] as String;
      await db.transaction((txn) async {
        await txn.delete(
          _chassisTable,
          where: 'location_id = ?',
          whereArgs: [locId],
        );
        await txn.delete(
          _locationsTable,
          where: 'id = ?',
          whereArgs: [id],
        );
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<ContainedChassis>> addChassis(
    String locationId,
    ContainedChassis chassis,
  ) async {
    try {
      final rows = await db.query(
        _locationsTable,
        where: 'loc_id = ?',
        whereArgs: [locationId],
        limit: 1,
      );
      if (rows.isEmpty) {
        return Result.failure(InstanceNotFoundError(instanceId: locationId));
      }
      await db.insert(_chassisTable, _chassisToRow(locationId, chassis),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(chassis);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> removeChassis(
    String locationId,
    int chassisId,
  ) async {
    try {
      final count = await db.delete(
        _chassisTable,
        where: 'location_id = ? AND chassis_id = ?',
        whereArgs: [locationId, chassisId],
      );
      if (count == 0) {
        return Result.failure(
          InstanceNotFoundError(instanceId: chassisId.toString()),
        );
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  /// Serialises a [Location] [record] and synthetic [id] into a row map
  /// for the `locations` table, flattening the [PhysicalAddress] fields.
  Map<String, Object?> _modelToRow(Location record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'loc_id': record.id,
      'uuid': record.uuid,
      'name': record.name,
      'alias': record.alias,
      'description': record.description,
      'type': record.type,
      'parent': record.parent,
      'timestamp': record.timestamp,
      'valid_until': record.validUntil,
      'address': record.physicalAddress?.address,
      'postal_code': record.physicalAddress?.postalCode,
      'state': record.physicalAddress?.state,
      'city': record.physicalAddress?.city,
      'country_code': record.physicalAddress?.countryCode,
      'building': record.buildingPosition?.building,
      'floor': record.buildingPosition?.floor,
      'room': record.buildingPosition?.room,
      'room_building_position': record.buildingPosition?.roomBuildingPosition,
    };
  }

  /// Deserialises a `locations` [row] and its associated
  /// [chassisRows] into a fully populated [Location] instance.
  Location _rowToModel(
    Map<String, Object?> row,
    List<Map<String, Object?>> chassisRows,
  ) {
    PhysicalAddress? address;
    if (row['address'] != null ||
        row['postal_code'] != null ||
        row['state'] != null ||
        row['city'] != null ||
        row['country_code'] != null) {
      address = PhysicalAddress(
        address: row['address'] as String?,
        postalCode: row['postal_code'] as String?,
        state: row['state'] as String?,
        city: row['city'] as String?,
        countryCode: row['country_code'] as String?,
      );
    }

    BuildingPosition? buildingPosition;
    if (row['building'] != null ||
        row['floor'] != null ||
        row['room'] != null ||
        row['room_building_position'] != null) {
      buildingPosition = BuildingPosition(
        building: row['building'] as String?,
        floor: row['floor'] as String?,
        room: row['room'] as String?,
        roomBuildingPosition: row['room_building_position'] as String?,
      );
    }

    final chassis = chassisRows.map(_chassisFromRow).toList();

    return Location(
      containerId: row['container_id'] as String? ?? 'default',
      id: row['loc_id'] as String,
      uuid: row['uuid'] as String?,
      name: row['name'] as String?,
      alias: row['alias'] as String?,
      description: row['description'] as String?,
      type: row['type'] as String?,
      parent: row['parent'] as String?,
      timestamp: row['timestamp'] as String?,
      validUntil: row['valid_until'] as String?,
      physicalAddress: address,
      buildingPosition: buildingPosition,
      containedChassis: chassis,
    );
  }

  /// Serialises a [ContainedChassis] into a row map keyed by the
  /// owning [locationId].
  Map<String, Object?> _chassisToRow(
    String locationId,
    ContainedChassis chassis,
  ) {
    return {
      'location_id': locationId,
      'chassis_id': chassis.chassisId,
      'ne_ref': chassis.neRef,
      'component_ref': chassis.componentRef,
    };
  }

  /// Deserialises a `contained_chassis` row into a [ContainedChassis]
  /// instance.
  ContainedChassis _chassisFromRow(Map<String, Object?> row) {
    return ContainedChassis(
      chassisId: row['chassis_id'] as int,
      neRef: row['ne_ref'] as String?,
      componentRef: row['component_ref'] as String?,
    );
  }

  /// Deletes all [ContainedChassis] rows for the given [locId] within
  /// the active [txn].
  Future<void> _deleteChassisForLocation(
    DatabaseExecutor txn,
    String locId,
  ) async {
    await txn.delete(
      _chassisTable,
      where: 'location_id = ?',
      whereArgs: [locId],
    );
  }

  /// Inserts a batch of [ContainedChassis] rows for the given [locId]
  /// within the active [txn].
  Future<void> _insertChassisRows(
    DatabaseExecutor txn,
    String locId,
    List<ContainedChassis> chassis,
  ) async {
    for (final c in chassis) {
      await txn.insert(_chassisTable, _chassisToRow(locId, c));
    }
  }
}
