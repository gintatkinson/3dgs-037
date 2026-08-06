import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-047/LocationInventoryRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [Location] inventory records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class LocationInventoryRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables needed for location and contained-chassis storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [Location] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Stores the location's flattened [PhysicalAddress] fields and all
  /// [ContainedChassis] entries in a transaction.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<Location>> save(
    Location record, {
    String id,
  });

  /// Fetches the [Location] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Reconstructs the [PhysicalAddress] and [ContainedChassis] list
  /// from related rows.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<Location>> fetch({String id});

  /// Updates an existing [Location] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Replaces the chassis list (delete old, insert new) in a transaction.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure, or
  /// [InstanceNotFoundError] when no record exists for [id].
  Future<Result<Location>> update(
    Location record, {
    String id,
  });

  /// Fetches all [Location] records from the data store.
  ///
  /// Includes reconstructed [PhysicalAddress] and [ContainedChassis]
  /// for each location.
  /// Returns [Result.success] with the list (may be empty) or
  /// [Result.failure] with [DatabaseStorageError] on query failure.
  Future<Result<List<Location>>> fetchAll();

  /// Fetches [Location] records whose [parent] field matches [parentId].
  ///
  /// Returns [Result.success] with matching locations (may be empty) or
  /// [Result.failure] with [DatabaseStorageError] on query failure.
  Future<Result<List<Location>>> fetchByParent({String parentId});

  /// Deletes the [Location] record for the given [id] and all its
  /// associated [ContainedChassis] rows in a transaction.
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] on deletion or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists, or
  /// [DatabaseStorageError] on delete failure.
  Future<Result<void>> delete({String id});

  /// Adds a [ContainedChassis] [chassis] to the location identified
  /// by [locationId] (the YANG key, i.e. [Location.id]).
  ///
  /// Returns [Result.success] with the saved chassis or [Result.failure]
  /// with [InstanceNotFoundError] if the location does not exist, or
  /// [DatabaseStorageError] on write failure.
  Future<Result<ContainedChassis>> addChassis(
    String locationId,
    ContainedChassis chassis,
  );

  /// Removes the [ContainedChassis] identified by [chassisId] from
  /// the location identified by [locationId] (the YANG key).
  ///
  /// Returns [Result.success] on removal or [Result.failure] with
  /// [InstanceNotFoundError] if no matching chassis exists, or
  /// [DatabaseStorageError] on delete failure.
  Future<Result<void>> removeChassis(
    String locationId,
    int chassisId,
  );
}
