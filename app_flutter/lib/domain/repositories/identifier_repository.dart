import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-002/IdentifierRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [IdentifierTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class IdentifierRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables needed for identifier record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [IdentifierTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<IdentifierTypes>> save(IdentifierTypes record, {String id});

  /// Fetches the [IdentifierTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<IdentifierTypes>> fetch({String id});

  /// Updates an existing [IdentifierTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<IdentifierTypes>> update(IdentifierTypes record, {String id});
}
