import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_system_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-035/GeodeticSystemViewModel]
///
/// State holder for [GeodeticSystem] UI interactions.
///
/// Manages loading, persistence, and mutation of geodetic system values
/// via an injected [GeodeticSystemRepository]. Notifies listeners on
/// every state transition for reactive UI binding.
class GeodeticSystemViewModel extends ChangeNotifier {
  /// Creates a [GeodeticSystemViewModel] backed by [repository].
  GeodeticSystemViewModel(this._repository);

  final GeodeticSystemRepository _repository;
  GeodeticSystem? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [GeodeticSystem] model, or null.
  GeodeticSystem? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the geodetic system record for [recordId] from the repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<GeodeticSystem>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeodeticSystem>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(GeodeticSystem record,
      {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<GeodeticSystem>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeodeticSystem>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(GeodeticSystem record,
      {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<GeodeticSystem>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeodeticSystem>(:final error):
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
    if (error is InvalidGeodeticDatumError) {
      return 'Invalid geodetic datum: ${error.input}';
    }
    if (error is NegativeAccuracyValueError) {
      return 'Negative accuracy value: ${error.fieldName}=${error.value}';
    }
    if (error is AccuracyPrecisionExceededError) {
      return 'Accuracy precision exceeded: ${error.fieldName}=${error.value}';
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
