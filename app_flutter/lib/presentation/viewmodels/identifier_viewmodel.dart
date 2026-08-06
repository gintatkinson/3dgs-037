import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-002/IdentifierViewModel]
///
/// State holder for [IdentifierTypes] UI interactions.
///
/// Manages loading, persistence, and mutation of identifier values
/// via an injected [IdentifierRepository]. Notifies listeners on
/// every state transition for reactive UI binding.
class IdentifierViewModel extends ChangeNotifier {
  /// Creates an [IdentifierViewModel] backed by [repository].
  IdentifierViewModel(this._repository);

  final IdentifierRepository _repository;
  IdentifierTypes? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [IdentifierTypes] model, or null.
  IdentifierTypes? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the identifier record for [recordId] from the repository.
  ///
  /// Sets [isLoading] to true during the fetch, then updates [model] on
  /// success or [errorMessage] on failure. Notifies listeners on each
  /// state transition.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<IdentifierTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<IdentifierTypes>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  ///
  /// On success, updates [model] to the saved record. On failure,
  /// sets [errorMessage]. Notifies listeners on completion.
  Future<void> save(IdentifierTypes record,
      {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<IdentifierTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<IdentifierTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  ///
  /// On success, updates [model] to the updated record. On failure,
  /// sets [errorMessage]. Notifies listeners on completion.
  Future<void> update(IdentifierTypes record,
      {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<IdentifierTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<IdentifierTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Formats a [DomainError] into a human-readable message.
  String _formatErrorMessage(DomainError error) {
    if (error is InstanceNotFoundError) {
      return 'Record not found: ${error.instanceId}';
    }
    if (error is DatabaseStorageError) {
      return 'Database error: ${error.message}';
    }
    if (error is SchemaFieldPatternError) {
      return 'Pattern error: ${error.fieldName} does not match ${error.pattern}';
    }
    if (error is SchemaFieldRangeError) {
      return 'Range error: ${error.fieldName} value ${error.value}';
    }
    return error.runtimeType.toString();
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
