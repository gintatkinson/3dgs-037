import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_reference_frame_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-034/GeodeticReferenceFrameViewModel]
///
/// State holder for [GeodeticReferenceFrame] UI interactions.
///
/// Manages loading, persistence, and mutation of geodetic reference frame
/// values via an injected [GeodeticReferenceFrameRepository]. Notifies
/// listeners on every state transition for reactive UI binding.
class GeodeticReferenceFrameViewModel extends ChangeNotifier {
  /// Creates a [GeodeticReferenceFrameViewModel] backed by [repository].
  GeodeticReferenceFrameViewModel(this._repository);

  final GeodeticReferenceFrameRepository _repository;
  GeodeticReferenceFrame? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [GeodeticReferenceFrame] model, or null.
  GeodeticReferenceFrame? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the geodetic reference frame record for [recordId] from the
  /// repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<GeodeticReferenceFrame>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeodeticReferenceFrame>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(GeodeticReferenceFrame record,
      {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<GeodeticReferenceFrame>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeodeticReferenceFrame>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(GeodeticReferenceFrame record,
      {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<GeodeticReferenceFrame>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeodeticReferenceFrame>(:final error):
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
    if (error is InvalidAstronomicalBodyError) {
      return 'Invalid astronomical body: ${error.input}';
    }
    if (error is FeatureDisabledAlternateSystemError) {
      return 'Alternate system feature disabled: ${error.value}';
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
