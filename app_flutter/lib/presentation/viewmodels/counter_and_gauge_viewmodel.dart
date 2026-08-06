import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-001/CounterAndGaugeViewModel]
///
/// State holder for [CounterAndGaugeTypes] UI interactions.
///
/// Manages loading, persistence, and mutation of counter and gauge values
/// via an injected [CounterAndGaugeRepository]. Notifies listeners on
/// every state transition for reactive UI binding.
class CounterAndGaugeViewModel extends ChangeNotifier {
  /// Creates a [CounterAndGaugeViewModel] backed by [repository].
  CounterAndGaugeViewModel(this._repository);

  final CounterAndGaugeRepository _repository;
  CounterAndGaugeTypes? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  bool _disposed = false;

  /// The currently loaded [CounterAndGaugeTypes] model, or null.
  CounterAndGaugeTypes? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// Loads the counter and gauge record for [recordId] from the repository.
  ///
  /// Sets [isLoading] to true during the fetch, then updates [model] on
  /// success or [errorMessage] on failure. Notifies listeners on each
  /// state transition.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<CounterAndGaugeTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<CounterAndGaugeTypes>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  ///
  /// On success, updates [model] to the saved record. On failure,
  /// sets [errorMessage]. Notifies listeners on completion.
  Future<void> save(CounterAndGaugeTypes record,
      {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<CounterAndGaugeTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<CounterAndGaugeTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  ///
  /// On success, updates [model] to the updated record. On failure,
  /// sets [errorMessage]. Notifies listeners on completion.
  Future<void> update(CounterAndGaugeTypes record,
      {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<CounterAndGaugeTypes>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<CounterAndGaugeTypes>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Increments the [counter32] value by [step] and persists.
  ///
  /// Requires a loaded model. Applies [CounterAndGaugeTypes.incrementCounter32]
  /// then saves the updated record via the repository.
  Future<void> incrementCounter32(int step) async {
    if (_model == null) return;
    final newValue =
        CounterAndGaugeTypes.incrementCounter32(_model!.counter32, step);
    final updated = _model!.copyWith(counter32: newValue);
    await save(updated, recordId: _currentRecordId);
  }

  /// Increments the [counter64] value by [step] and persists.
  ///
  /// Requires a loaded model. Applies [CounterAndGaugeTypes.incrementCounter64]
  /// then saves the updated record via the repository.
  Future<void> incrementCounter64(BigInt step) async {
    if (_model == null) return;
    final newValue =
        CounterAndGaugeTypes.incrementCounter64(_model!.counter64, step);
    final updated = _model!.copyWith(counter64: newValue);
    await save(updated, recordId: _currentRecordId);
  }

  /// Updates the [gauge32] value by [delta] and persists.
  ///
  /// Requires a loaded model. Applies [CounterAndGaugeTypes.updateGauge32]
  /// then saves the updated record via the repository.
  Future<void> updateGauge32(int delta) async {
    if (_model == null) return;
    final newValue =
        CounterAndGaugeTypes.updateGauge32(_model!.gauge32, delta);
    final updated = _model!.copyWith(gauge32: newValue);
    await save(updated, recordId: _currentRecordId);
  }

  /// Updates the [gauge64] value by [delta] and persists.
  ///
  /// Requires a loaded model. Applies [CounterAndGaugeTypes.updateGauge64]
  /// then saves the updated record via the repository.
  Future<void> updateGauge64(BigInt delta) async {
    if (_model == null) return;
    final newValue =
        CounterAndGaugeTypes.updateGauge64(_model!.gauge64, delta);
    final updated = _model!.copyWith(gauge64: newValue);
    await save(updated, recordId: _currentRecordId);
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
