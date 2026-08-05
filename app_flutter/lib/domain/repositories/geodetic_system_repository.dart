import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-035/GeodeticSystemRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [GeodeticSystem] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class GeodeticSystemRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables needed for geodetic system record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [GeodeticSystem] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<GeodeticSystem>> save(
    GeodeticSystem record, {
    String id,
  });

  /// Fetches the [GeodeticSystem] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<GeodeticSystem>> fetch({String id});

  /// Updates an existing [GeodeticSystem] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<GeodeticSystem>> update(
    GeodeticSystem record, {
    String id,
  });
}
