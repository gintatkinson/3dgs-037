import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-022/AutonomousSystemAndPortRepository]
///
/// Abstract repository contract for persisting and retrieving
/// [AutonomousSystemAndPortTypes] records from a live data store.
///
/// Implementations MUST use a persistent database or transport layer
/// (constitution §1.9). In-memory mocks are prohibited in DI.
abstract class AutonomousSystemAndPortRepository {
  /// Initialises the underlying database schema.
  ///
  /// Creates tables and indexes needed for AS number and port record storage.
  /// Idempotent — safe to call multiple times.
  /// Returns [Result.success] on success or [Result.failure] with
  /// [DatabaseStorageError] on schema creation failure.
  Future<Result<void>> initDatabase();

  /// Saves a new [AutonomousSystemAndPortTypes] record with the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the saved record or [Result.failure]
  /// with [DatabaseStorageError] on write failure.
  Future<Result<AutonomousSystemAndPortTypes>> save(
    AutonomousSystemAndPortTypes record, {
    String id,
  });

  /// Fetches the [AutonomousSystemAndPortTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the record or [Result.failure] with
  /// [InstanceNotFoundError] if no record exists.
  Future<Result<AutonomousSystemAndPortTypes>> fetch({String id});

  /// Updates an existing [AutonomousSystemAndPortTypes] record for the given [id].
  ///
  /// Defaults [id] to 'default' if not specified.
  /// Returns [Result.success] with the updated record or [Result.failure]
  /// with [DatabaseStorageError] on update failure.
  Future<Result<AutonomousSystemAndPortTypes>> update(
    AutonomousSystemAndPortTypes record, {
    String id,
  });
}
