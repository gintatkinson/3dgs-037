import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/repositories/domain_name_and_host_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-021/DomainNameAndHostViewModel]
///
/// State holder for [DomainNameAndHostTypes] UI interactions.
///
/// Manages loading, persistence, and mutation of domain name and host
/// values via an injected [DomainNameAndHostRepository]. Notifies
/// listeners on every state transition for reactive UI binding.
class DomainNameAndHostViewModel extends ChangeNotifier {
  /// Creates a [DomainNameAndHostViewModel] backed by [repository].
  DomainNameAndHostViewModel(this._repository);

  final DomainNameAndHostRepository _repository;
  DomainNameAndHostTypes? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [DomainNameAndHostTypes] model, or null.
  DomainNameAndHostTypes? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the domain name and host record for [recordId] from the
  /// repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<DomainNameAndHostTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<DomainNameAndHostTypes>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(DomainNameAndHostTypes record,
      {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<DomainNameAndHostTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<DomainNameAndHostTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(DomainNameAndHostTypes record,
      {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<DomainNameAndHostTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<DomainNameAndHostTypes>(:final error):
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
