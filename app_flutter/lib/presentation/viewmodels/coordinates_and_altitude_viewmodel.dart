import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/repositories/coordinates_and_altitude_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-036/CoordinatesAndAltitudeViewModel]
///
/// State holder for [GeoLocation] UI interactions.
///
/// Manages loading, persistence, and mutation of geo-location values
/// via an injected [CoordinatesAndAltitudeRepository]. Notifies listeners
/// on every state transition for reactive UI binding.
class CoordinatesAndAltitudeViewModel extends ChangeNotifier {
  /// Creates a [CoordinatesAndAltitudeViewModel] backed by [repository].
  CoordinatesAndAltitudeViewModel(this._repository);

  final CoordinatesAndAltitudeRepository _repository;
  GeoLocation? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [GeoLocation] model, or null.
  GeoLocation? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the geo-location record for [recordId] from the repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<GeoLocation>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeoLocation>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(GeoLocation record,
      {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<GeoLocation>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeoLocation>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(GeoLocation record,
      {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<GeoLocation>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<GeoLocation>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _formatErrorMessage(DomainError error) {
    if (error is InstanceNotFoundError) {
      return 'Record not found: ${error.instanceId}';
    }
    if (error is DatabaseStorageError) {
      return 'Database error: ${error.message}';
    }
    if (error is InvalidLatitudeOutOfBoundsError) {
      return 'Invalid latitude: ${error.value}';
    }
    if (error is InvalidLongitudeOutOfBoundsError) {
      return 'Invalid longitude: ${error.value}';
    }
    if (error is MutualExclusivityViolationError) {
      return 'Mutual exclusivity violation';
    }
    if (error is InvalidDateTimeFormatError) {
      return 'Invalid date-time format: ${error.input}';
    }
    if (error is InvalidTemporalWindowError) {
      return 'Invalid temporal window';
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
