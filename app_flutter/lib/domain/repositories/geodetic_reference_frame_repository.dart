import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-034/GeodeticReferenceFrameRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [GeodeticReferenceFrame] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class GeodeticReferenceFrameRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables needed for geodetic reference frame record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [GeodeticReferenceFrame] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<GeodeticReferenceFrame>> save(
    GeodeticReferenceFrame record, {
    String id,
  });

  /// Fetches the [GeodeticReferenceFrame] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<GeodeticReferenceFrame>> fetch({String id});

  /// Updates an existing [GeodeticReferenceFrame] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<GeodeticReferenceFrame>> update(
    GeodeticReferenceFrame record, {
    String id,
  });
}
