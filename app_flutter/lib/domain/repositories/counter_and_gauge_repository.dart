import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-001/CounterAndGaugeRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [CounterAndGaugeTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class CounterAndGaugeRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables and indexes needed for counter and gauge record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [CounterAndGaugeTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<CounterAndGaugeTypes>> save(CounterAndGaugeTypes record,
      {String id});

  /// Fetches the [CounterAndGaugeTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<CounterAndGaugeTypes>> fetch({String id});

  /// Updates an existing [CounterAndGaugeTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<CounterAndGaugeTypes>> update(CounterAndGaugeTypes record,
      {String id});
}
