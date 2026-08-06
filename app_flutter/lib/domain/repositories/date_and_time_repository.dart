import 'package:app_flutter/domain/models/date_and_time_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-003/DateAndTimeRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [DateAndTimeTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class DateAndTimeRepository {
  /// Initialises the underlying database schema for date-and-time records.
  ///
  /// Creates tables and indexes needed for storage. Idempotent.
  Future<Result<void>> initDatabase();

  /// Saves a new [DateAndTimeTypes] [record] with the given [id].
  ///
  /// Defaults [id] to 'default'. Returns [Result.success] with the saved
  /// record or [Result.failure] on write failure.
  Future<Result<DateAndTimeTypes>> save(DateAndTimeTypes record, {String id});

  /// Fetches the [DateAndTimeTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default'. Returns [Result.success] with the record
  /// or [Result.failure] if no record exists.
  Future<Result<DateAndTimeTypes>> fetch({String id});

  /// Updates an existing [DateAndTimeTypes] [record] for the given [id].
  ///
  /// Defaults [id] to 'default'. Returns [Result.success] with the updated
  /// record or [Result.failure] on update failure.
  Future<Result<DateAndTimeTypes>> update(DateAndTimeTypes record, {String id});
}
