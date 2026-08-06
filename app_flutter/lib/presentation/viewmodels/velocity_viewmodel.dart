import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/repositories/velocity_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-037/VelocityViewModel]
///
/// State holder for [Velocity] UI interactions.
///
/// Manages loading, persistence, and mutation of velocity values
/// via an injected [VelocityRepository]. Notifies listeners on
/// every state transition for reactive UI binding.
class VelocityViewModel extends ChangeNotifier {
  /// Creates a [VelocityViewModel] backed by [repository].
  VelocityViewModel(this._repository);

  final VelocityRepository _repository;
  Velocity? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [Velocity] model, or null.
  Velocity? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the velocity record for [recordId] from the repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<Velocity>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<Velocity>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(Velocity record, {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<Velocity>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<Velocity>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(Velocity record, {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<Velocity>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<Velocity>(:final error):
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
    if (error is VelocityPrecisionExceededError) {
      return 'Velocity precision exceeded: ${error.fieldName}=${error.value}';
    }
    if (error is UndefinedHeadingAngleError) {
      return 'Undefined heading angle (both v-north and v-east are zero)';
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
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
