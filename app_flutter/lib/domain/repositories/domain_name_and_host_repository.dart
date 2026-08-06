import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-021/DomainNameAndHostRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [DomainNameAndHostTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class DomainNameAndHostRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables and indexes needed for domain name and host record
  /// storage. Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [DomainNameAndHostTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<DomainNameAndHostTypes>> save(
      DomainNameAndHostTypes record,
      {String id});

  /// Fetches the [DomainNameAndHostTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<DomainNameAndHostTypes>> fetch({String id});

  /// Updates an existing [DomainNameAndHostTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [InstanceNotFoundError] if no matching record exists or
  /// [DatabaseStorageError] on write failure.
  Future<Result<DomainNameAndHostTypes>> update(
      DomainNameAndHostTypes record,
      {String id});
}
