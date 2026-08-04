import '../models/identifier_types.dart';

/// Abstract repository contract for managing [IdentifierTypes] persistence.
///
/// Realises: [Feat-002/IdentifierRepository]
abstract class IdentifierRepository {
  /// Fetches an [IdentifierTypes] record by its [containerId].
  Future<Result<IdentifierTypes>> fetch(String containerId);

  /// Saves a new [IdentifierTypes] record.
  Future<Result<void>> save(IdentifierTypes record);

  /// Updates an existing [IdentifierTypes] record.
  Future<Result<void>> update(IdentifierTypes record);
}
