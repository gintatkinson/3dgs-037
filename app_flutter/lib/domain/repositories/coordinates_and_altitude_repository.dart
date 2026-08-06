import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-036/CoordinatesAndAltitudeRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [GeoLocation] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class CoordinatesAndAltitudeRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables needed for geo-location record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [GeoLocation] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<GeoLocation>> save(
    GeoLocation record, {
    String id,
  });

  /// Fetches the [GeoLocation] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<GeoLocation>> fetch({String id});

  /// Updates an existing [GeoLocation] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<GeoLocation>> update(
    GeoLocation record, {
    String id,
  });
}
