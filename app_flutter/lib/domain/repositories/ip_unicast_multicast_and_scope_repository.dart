import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-023/IpUnicastMulticastAndScopeRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [IpUnicastMulticastAndScopeTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class IpUnicastMulticastAndScopeRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables and indexes needed for record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [IpUnicastMulticastAndScopeTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<IpUnicastMulticastAndScopeTypes>> save(
      IpUnicastMulticastAndScopeTypes record,
      {String id});

  /// Fetches the [IpUnicastMulticastAndScopeTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<IpUnicastMulticastAndScopeTypes>> fetch({String id});

  /// Updates an existing [IpUnicastMulticastAndScopeTypes] record for the
  /// given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<IpUnicastMulticastAndScopeTypes>> update(
      IpUnicastMulticastAndScopeTypes record,
      {String id});
}
