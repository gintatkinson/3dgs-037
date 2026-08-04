import 'package:flutter/foundation.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart' as types;
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';

/// Realises: [Feat-001/CounterAndGaugeViewModel]
///
/// ViewModel managing presentation state and user actions for 32-bit and 64-bit counter and gauge numeric types.
class CounterAndGaugeViewModel extends ChangeNotifier {
  /// Creates a [CounterAndGaugeViewModel] instance with injected [CounterAndGaugeRepository].
  CounterAndGaugeViewModel({
    required CounterAndGaugeRepository repository,
  }) : _repository = repository;

  final CounterAndGaugeRepository _repository;

  types.CounterAndGaugeTypes _model = const types.CounterAndGaugeTypes();
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';

  /// Currently loaded [types.CounterAndGaugeTypes] model instance.
  types.CounterAndGaugeTypes get model => _model;

  /// Whether a data operation is currently loading.
  bool get isLoading => _isLoading;

  /// Error message string if the last operation failed, or `null` if no error.
  String? get errorMessage => _errorMessage;

  String _formatErrorMessage(DomainError error) {
    if (error is DatabaseStorageError) {
      return error.message;
    }
    return error.toString();
  }

  /// Loads a [types.CounterAndGaugeTypes] record from the repository by [recordId].
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetch(id: recordId);
    _isLoading = false;

    if (result is Success<types.CounterAndGaugeTypes>) {
      _model = result.value;
      _errorMessage = null;
    } else if (result is Failure<types.CounterAndGaugeTypes>) {
      _errorMessage = _formatErrorMessage(result.error);
    }
    notifyListeners();
  }

  /// Increments the 32-bit counter value by [step] with wraparound semantics.
  Future<void> incrementCounter32(int step) async {
    _errorMessage = null;
    final newCounter32 = types.incrementCounter32(_model.counter32, step);
    final updatedModel = types.CounterAndGaugeTypes(
      counter32: newCounter32,
      zeroBasedCounter32: _model.zeroBasedCounter32,
      counter64: _model.counter64,
      zeroBasedCounter64: _model.zeroBasedCounter64,
      gauge32: _model.gauge32,
      gauge64: _model.gauge64,
    );

    final result = await _repository.update(updatedModel, id: _currentRecordId);
    if (result is Success<types.CounterAndGaugeTypes>) {
      _model = result.value;
      _errorMessage = null;
    } else if (result is Failure<types.CounterAndGaugeTypes>) {
      _errorMessage = _formatErrorMessage(result.error);
    }
    notifyListeners();
  }

  /// Increments the 64-bit counter value by [step] with wraparound semantics.
  Future<void> incrementCounter64(BigInt step) async {
    _errorMessage = null;
    final newCounter64 = types.incrementCounter64(_model.counter64, step);
    final updatedModel = types.CounterAndGaugeTypes(
      counter32: _model.counter32,
      zeroBasedCounter32: _model.zeroBasedCounter32,
      counter64: newCounter64,
      zeroBasedCounter64: _model.zeroBasedCounter64,
      gauge32: _model.gauge32,
      gauge64: _model.gauge64,
    );

    final result = await _repository.update(updatedModel, id: _currentRecordId);
    if (result is Success<types.CounterAndGaugeTypes>) {
      _model = result.value;
      _errorMessage = null;
    } else if (result is Failure<types.CounterAndGaugeTypes>) {
      _errorMessage = _formatErrorMessage(result.error);
    }
    notifyListeners();
  }

  /// Updates the 32-bit gauge value by [delta] with lower/upper limit latching semantics.
  Future<void> updateGauge32(int delta) async {
    _errorMessage = null;
    final newGauge32 = types.updateGauge32(_model.gauge32, delta);
    final updatedModel = types.CounterAndGaugeTypes(
      counter32: _model.counter32,
      zeroBasedCounter32: _model.zeroBasedCounter32,
      counter64: _model.counter64,
      zeroBasedCounter64: _model.zeroBasedCounter64,
      gauge32: newGauge32,
      gauge64: _model.gauge64,
    );

    final result = await _repository.update(updatedModel, id: _currentRecordId);
    if (result is Success<types.CounterAndGaugeTypes>) {
      _model = result.value;
      _errorMessage = null;
    } else if (result is Failure<types.CounterAndGaugeTypes>) {
      _errorMessage = _formatErrorMessage(result.error);
    }
    notifyListeners();
  }

  /// Updates the 64-bit gauge value by [delta] with lower/upper limit latching semantics.
  Future<void> updateGauge64(BigInt delta) async {
    _errorMessage = null;
    final newGauge64 = types.updateGauge64(_model.gauge64, delta);
    final updatedModel = types.CounterAndGaugeTypes(
      counter32: _model.counter32,
      zeroBasedCounter32: _model.zeroBasedCounter32,
      counter64: _model.counter64,
      zeroBasedCounter64: _model.zeroBasedCounter64,
      gauge32: _model.gauge32,
      gauge64: newGauge64,
    );

    final result = await _repository.update(updatedModel, id: _currentRecordId);
    if (result is Success<types.CounterAndGaugeTypes>) {
      _model = result.value;
      _errorMessage = null;
    } else if (result is Failure<types.CounterAndGaugeTypes>) {
      _errorMessage = _formatErrorMessage(result.error);
    }
    notifyListeners();
  }
}
