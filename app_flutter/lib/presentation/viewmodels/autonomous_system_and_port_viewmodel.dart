import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/repositories/autonomous_system_and_port_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-022/AutonomousSystemAndPortViewModel]
///
/// State holder for [AutonomousSystemAndPortTypes] UI interactions.
///
/// Manages loading, persistence, and mutation of AS number and port values
/// via an injected [AutonomousSystemAndPortRepository]. Notifies listeners
/// on every state transition for reactive UI binding.
class AutonomousSystemAndPortViewModel extends ChangeNotifier {
  /// Creates an [AutonomousSystemAndPortViewModel] backed by [repository].
  AutonomousSystemAndPortViewModel(this._repository);

  final AutonomousSystemAndPortRepository _repository;
  AutonomousSystemAndPortTypes? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [AutonomousSystemAndPortTypes] model, or null.
  AutonomousSystemAndPortTypes? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the AS number and port record for [recordId] from the repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<AutonomousSystemAndPortTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<AutonomousSystemAndPortTypes>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(
    AutonomousSystemAndPortTypes record, {
    String recordId = 'default',
  }) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<AutonomousSystemAndPortTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<AutonomousSystemAndPortTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(
    AutonomousSystemAndPortTypes record, {
    String recordId = 'default',
  }) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<AutonomousSystemAndPortTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<AutonomousSystemAndPortTypes>(:final error):
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
