import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-001/CounterAndGaugeRepository]
///
/// Abstract repository interface for storing, retrieving, and updating
/// 32-bit and 64-bit counter and gauge numeric data records.
abstract class CounterAndGaugeRepository {
  /// Saves a [CounterAndGaugeTypes] record to the persistent store.
  ///
  /// Optionally takes an [id] (defaults to `'default'`).
  /// Returns [Result.success] with the saved entity on success, or [Result.failure] on error.
  Future<Result<CounterAndGaugeTypes>> save(
    CounterAndGaugeTypes record, {
    String id = 'default',
  });

  /// Fetches a [CounterAndGaugeTypes] record from the persistent store by [id].
  ///
  /// Defaults [id] to `'default'`.
  /// Returns [Result.success] with the entity on success, or [Result.failure] if not found or on error.
  Future<Result<CounterAndGaugeTypes>> fetch({
    String id = 'default',
  });

  /// Updates an existing [CounterAndGaugeTypes] record in the persistent store.
  ///
  /// Defaults [id] to `'default'`.
  /// Returns [Result.success] with the updated entity on success, or [Result.failure] on error.
  Future<Result<CounterAndGaugeTypes>> update(
    CounterAndGaugeTypes record, {
    String id = 'default',
  });
}
