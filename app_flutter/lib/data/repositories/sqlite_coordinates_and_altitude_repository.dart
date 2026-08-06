import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/repositories/coordinates_and_altitude_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Realises: [Feat-036/SqliteCoordinatesAndAltitudeRepository]
///
/// SQLite-backed implementation of [CoordinatesAndAltitudeRepository]
/// using sqflite_common_ffi for live persistent storage (constitution §1.9).
///
/// Stores geo-location records in a `geo_location_records` table
/// with columns for timestamp, validUntil, and embedded ellipsoidal
/// or cartesian coordinate fields.
class SqliteCoordinatesAndAltitudeRepository
    implements CoordinatesAndAltitudeRepository {
  /// Creates a [SqliteCoordinatesAndAltitudeRepository] backed by [db].
  SqliteCoordinatesAndAltitudeRepository(this.db);

  /// The underlying SQLite database connection.
  final Database db;

  static const String _tableName = 'geo_location_records';

  @override
  Future<Result<void>> initDatabase() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_tableName (
          id TEXT PRIMARY KEY,
          container_id TEXT,
          timestamp TEXT,
          valid_until TEXT,
          ellipsoid_latitude REAL,
          ellipsoid_longitude REAL,
          ellipsoid_height REAL,
          cartesian_x REAL,
          cartesian_y REAL,
          cartesian_z REAL
        )
      ''');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseStorageError(message: e.toString()));
    }
  }

  @override
  Future<Result<GeoLocation>> save(
    GeoLocation record, {
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
  Future<Result<GeoLocation>> fetch({String id = 'default'}) async {
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
  Future<Result<GeoLocation>> update(
    GeoLocation record, {
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

  Map<String, Object?> _modelToRow(GeoLocation record, String id) {
    return {
      'id': id,
      'container_id': record.containerId,
      'timestamp': record.timestamp,
      'valid_until': record.validUntil,
      'ellipsoid_latitude': record.ellipsoid?.latitude,
      'ellipsoid_longitude': record.ellipsoid?.longitude,
      'ellipsoid_height': record.ellipsoid?.height,
      'cartesian_x': record.cartesian?.x,
      'cartesian_y': record.cartesian?.y,
      'cartesian_z': record.cartesian?.z,
    };
  }

  GeoLocation _rowToModel(Map<String, Object?> row) {
    final hasEllipsoid =
        row['ellipsoid_latitude'] != null || row['ellipsoid_longitude'] != null;
    final hasCartesian =
        row['cartesian_x'] != null || row['cartesian_y'] != null || row['cartesian_z'] != null;

    return GeoLocation(
      containerId: row['container_id'] as String? ?? 'default',
      timestamp: row['timestamp'] as String?,
      validUntil: row['valid_until'] as String?,
      ellipsoid: hasEllipsoid
          ? EllipsoidalCoordinates(
              latitude: (row['ellipsoid_latitude'] as num?)?.toDouble() ?? 0.0,
              longitude: (row['ellipsoid_longitude'] as num?)?.toDouble() ?? 0.0,
              height: (row['ellipsoid_height'] as num?)?.toDouble(),
            )
          : null,
      cartesian: hasCartesian
          ? CartesianCoordinates(
              x: (row['cartesian_x'] as num?)?.toDouble() ?? 0.0,
              y: (row['cartesian_y'] as num?)?.toDouble() ?? 0.0,
              z: (row['cartesian_z'] as num?)?.toDouble() ?? 0.0,
            )
          : null,
    );
  }
}
