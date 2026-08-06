import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-037/VelocityRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [Velocity] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class VelocityRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables needed for velocity record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [Velocity] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<Velocity>> save(
    Velocity record, {
    String id,
  });

  /// Fetches the [Velocity] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<Velocity>> fetch({String id});

  /// Updates an existing [Velocity] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure, or
  /// [InstanceNotFoundError] when no record exists for [id].
  Future<Result<Velocity>> update(
    Velocity record, {
    String id,
  });
}
