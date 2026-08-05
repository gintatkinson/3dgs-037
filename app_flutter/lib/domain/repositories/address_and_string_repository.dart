import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-004/AddressAndStringRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [AddressAndStringTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class AddressAndStringRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables and indexes needed for address and string record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [AddressAndStringTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<AddressAndStringTypes>> save(AddressAndStringTypes record,
      {String id});

  /// Fetches the [AddressAndStringTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<AddressAndStringTypes>> fetch({String id});

  /// Updates an existing [AddressAndStringTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<AddressAndStringTypes>> update(AddressAndStringTypes record,
      {String id});
}
