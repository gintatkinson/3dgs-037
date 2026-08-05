import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/repositories/address_and_string_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-004/AddressAndStringViewModel]
///
/// State holder for [AddressAndStringTypes] UI interactions.
///
/// Manages loading, persistence, and mutation of address and string type
/// values via an injected [AddressAndStringRepository]. Notifies listeners
/// on every state transition for reactive UI binding.
class AddressAndStringViewModel extends ChangeNotifier {
  /// Creates an [AddressAndStringViewModel] backed by [repository].
  AddressAndStringViewModel(this._repository);

  final AddressAndStringRepository _repository;
  AddressAndStringTypes? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [AddressAndStringTypes] model, or null.
  AddressAndStringTypes? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the address and string record for [recordId] from the repository.
  ///
  /// Sets [isLoading] to true during the fetch, then updates [model] on
  /// success or [errorMessage] on failure. Notifies listeners on each
  /// state transition.
  Future<void> load(String recordId) async {
    if (_disposed) return;
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<AddressAndStringTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<AddressAndStringTypes>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  ///
  /// On success, updates [model] to the saved record. On failure,
  /// sets [errorMessage]. Notifies listeners on completion.
  Future<void> save(AddressAndStringTypes record,
      {String recordId = 'default'}) async {
    if (_disposed) return;
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<AddressAndStringTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<AddressAndStringTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  ///
  /// On success, updates [model] to the updated record. On failure,
  /// sets [errorMessage]. Notifies listeners on completion.
  Future<void> update(AddressAndStringTypes record,
      {String recordId = 'default'}) async {
    if (_disposed) return;
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<AddressAndStringTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<AddressAndStringTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_disposed) return;
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
      return 'Pattern error: ${error.fieldName} value "${error.value}"';
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
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
