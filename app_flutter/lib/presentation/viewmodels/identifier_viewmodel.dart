import 'package:flutter/foundation.dart';
import '../../domain/models/identifier_types.dart';
import '../../domain/repositories/identifier_repository.dart';

/// ViewModel managing state and user actions for [IdentifierTypes].
///
/// Realises: [Feat-002/IdentifierViewModel]
class IdentifierViewModel extends ChangeNotifier {
  /// Injected repository interface.
  final IdentifierRepository _repository;

  /// Active domain model instance.
  IdentifierTypes? _model;

  /// True while async fetch or save operations are in progress.
  bool _isLoading = false;

  /// Human-readable error message, if any error occurred.
  String? _errorMessage;

  /// Creates an [IdentifierViewModel] injecting [_repository].
  IdentifierViewModel(this._repository);

  /// Getter for the active [IdentifierTypes] model instance.
  IdentifierTypes? get model => _model;

  /// Getter for the loading flag.
  bool get isLoading => _isLoading;

  /// Getter for the error message string.
  String? get errorMessage => _errorMessage;

  /// Loads an [IdentifierTypes] record by [containerId].
  Future<void> load(String containerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.fetch(containerId);
    _isLoading = false;

    if (result.isSuccess) {
      _model = result.valueOrNull;
    } else {
      // Create default fallback record if not found
      _model = const IdentifierTypes(
        containerId: 'id-001',
        objectIdentifier: '1.3.6.1.4.1',
        objectIdentifier128: '1.3.6.1.4.1.100',
        uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
        yangIdentifier: 'interfaces',
      );
      await _repository.save(_model!);
    }

    notifyListeners();
  }

  /// Updates the objectIdentifier field if valid.
  Future<Result<void>> updateObjectIdentifier(String newOid) async {
    final validation = IdentifierTypes.validateObjectIdentifier(newOid);
    if (validation.isFailure) {
      _errorMessage = validation.messageOrNull;
      notifyListeners();
      return Failure(validation.errorCodeOrNull!, validation.messageOrNull!);
    }

    if (_model == null) return const Failure('NO_MODEL', 'No active record');

    final updated = IdentifierTypes(
      containerId: _model!.containerId,
      objectIdentifier: newOid,
      objectIdentifier128: _model!.objectIdentifier128,
      uuid: _model!.uuid,
      yangIdentifier: _model!.yangIdentifier,
    );

    final saveResult = await _repository.save(updated);
    if (saveResult.isSuccess) {
      _model = updated;
      _errorMessage = null;
    } else {
      _errorMessage = saveResult.messageOrNull;
    }
    notifyListeners();
    return saveResult;
  }

  /// Updates the objectIdentifier128 field if valid.
  Future<Result<void>> updateObjectIdentifier128(String newOid128) async {
    final validation = IdentifierTypes.validateObjectIdentifier128(newOid128);
    if (validation.isFailure) {
      _errorMessage = validation.messageOrNull;
      notifyListeners();
      return Failure(validation.errorCodeOrNull!, validation.messageOrNull!);
    }

    if (_model == null) return const Failure('NO_MODEL', 'No active record');

    final updated = IdentifierTypes(
      containerId: _model!.containerId,
      objectIdentifier: _model!.objectIdentifier,
      objectIdentifier128: newOid128,
      uuid: _model!.uuid,
      yangIdentifier: _model!.yangIdentifier,
    );

    final saveResult = await _repository.save(updated);
    if (saveResult.isSuccess) {
      _model = updated;
      _errorMessage = null;
    } else {
      _errorMessage = saveResult.messageOrNull;
    }
    notifyListeners();
    return saveResult;
  }

  /// Updates the uuid field with canonical lowercase normalization if valid.
  Future<Result<void>> updateUuid(String newUuid) async {
    final validation = IdentifierTypes.validateUuid(newUuid);
    if (validation.isFailure) {
      _errorMessage = validation.messageOrNull;
      notifyListeners();
      return Failure(validation.errorCodeOrNull!, validation.messageOrNull!);
    }

    if (_model == null) return const Failure('NO_MODEL', 'No active record');

    final normalized = IdentifierTypes.normalizeUuid(newUuid);
    final updated = IdentifierTypes(
      containerId: _model!.containerId,
      objectIdentifier: _model!.objectIdentifier,
      objectIdentifier128: _model!.objectIdentifier128,
      uuid: normalized,
      yangIdentifier: _model!.yangIdentifier,
    );

    final saveResult = await _repository.save(updated);
    if (saveResult.isSuccess) {
      _model = updated;
      _errorMessage = null;
    } else {
      _errorMessage = saveResult.messageOrNull;
    }
    notifyListeners();
    return saveResult;
  }

  /// Updates the yangIdentifier field if valid.
  Future<Result<void>> updateYangIdentifier(String newYangId) async {
    final validation = IdentifierTypes.validateYangIdentifier(newYangId);
    if (validation.isFailure) {
      _errorMessage = validation.messageOrNull;
      notifyListeners();
      return Failure(validation.errorCodeOrNull!, validation.messageOrNull!);
    }

    if (_model == null) return const Failure('NO_MODEL', 'No active record');

    final updated = IdentifierTypes(
      containerId: _model!.containerId,
      objectIdentifier: _model!.objectIdentifier,
      objectIdentifier128: _model!.objectIdentifier128,
      uuid: _model!.uuid,
      yangIdentifier: newYangId,
    );

    final saveResult = await _repository.save(updated);
    if (saveResult.isSuccess) {
      _model = updated;
      _errorMessage = null;
    } else {
      _errorMessage = saveResult.messageOrNull;
    }
    notifyListeners();
    return saveResult;
  }
}
