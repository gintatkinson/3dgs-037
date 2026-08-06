import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-020/IpAddressRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [IpAddressTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class IpAddressRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables and indexes needed for IP address record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [IpAddressTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<IpAddressTypes>> save(IpAddressTypes record, {String id});

  /// Fetches the [IpAddressTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<IpAddressTypes>> fetch({String id});

  /// Updates an existing [IpAddressTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<IpAddressTypes>> update(IpAddressTypes record, {String id});
}
