import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/repositories/location_inventory_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-047/LocationInventoryViewModel]
///
/// State holder for [Location] inventory UI interactions.
///
/// Manages loading, persistence, and mutation of location inventory
/// values via an injected [LocationInventoryRepository]. Notifies
/// listeners on every state transition for reactive UI binding.
class LocationInventoryViewModel extends ChangeNotifier {
  /// Creates a [LocationInventoryViewModel] backed by [repository].
  LocationInventoryViewModel(this._repository);

  final LocationInventoryRepository _repository;
  Location? _model;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentRecordId = 'default';
  List<Location> _allLocations = [];
  bool _disposed = false;

  /// The currently loaded [Location] model, or null.
  Location? get model => _model;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message, or null.
  String? get errorMessage => _errorMessage;

  /// All [Location] records loaded from the most recent [loadAll] call.
  List<Location> get allLocations => _allLocations;

  /// Loads the location record for [recordId] from the repository.
  Future<void> load(String recordId) async {
    _currentRecordId = recordId;
    _setLoading(true);
    final result = await _repository.fetch(id: recordId);
    switch (result) {
      case Success<Location>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<Location>(:final error):
        _model = null;
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Loads all location records from the repository into [_allLocations].
  Future<void> loadAll() async {
    _setLoading(true);
    final result = await _repository.fetchAll();
    switch (result) {
      case Success<List<Location>>(:final value):
        _allLocations = value;
        _errorMessage = null;
      case Failure<List<Location>>(:final error):
        _allLocations = [];
        _errorMessage = _formatErrorMessage(error);
    }
    _setLoading(false);
  }

  /// Saves [record] with the given [recordId] to the repository.
  Future<void> save(Location record, {String recordId = 'default'}) async {
    _currentRecordId = recordId;
    final result = await _repository.save(record, id: recordId);
    switch (result) {
      case Success<Location>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<Location>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Updates [record] with the given [recordId] in the repository.
  Future<void> update(Location record, {String recordId = 'default'}) async {
    final result = await _repository.update(record, id: recordId);
    switch (result) {
      case Success<Location>(:final value):
        _model = value;
        _errorMessage = null;
      case Failure<Location>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Deletes the location record for [recordId] from the repository.
  Future<void> delete(String recordId) async {
    final result = await _repository.delete(id: recordId);
    switch (result) {
      case Success<void>():
        if (_currentRecordId == recordId) {
          _model = null;
        }
        _errorMessage = null;
      case Failure<void>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Adds [chassis] to the current model's [containedChassis] list
  /// and persists the addition via the repository.
  Future<void> addChassis(ContainedChassis chassis) async {
    if (_model == null) return;
    final updatedList = [..._model!.containedChassis, chassis];
    _model = Location(
      containerId: _model!.containerId,
      id: _model!.id,
      uuid: _model!.uuid,
      name: _model!.name,
      alias: _model!.alias,
      description: _model!.description,
      type: _model!.type,
      parent: _model!.parent,
      timestamp: _model!.timestamp,
      validUntil: _model!.validUntil,
      physicalAddress: _model!.physicalAddress,
      containedChassis: updatedList,
    );
    final result = await _repository.addChassis(_model!.id, chassis);
    switch (result) {
      case Success<ContainedChassis>():
        _errorMessage = null;
      case Failure<ContainedChassis>(:final error):
        _errorMessage = _formatErrorMessage(error);
    }
    notifyListeners();
  }

  /// Removes the chassis identified by [chassisId] from the current
  /// model's [containedChassis] list and persists the removal via
  /// the repository.
  Future<void> removeChassis(int chassisId) async {
    if (_model == null) return;
    final updatedList =
        _model!.containedChassis.where((c) => c.chassisId != chassisId).toList();
    _model = Location(
      containerId: _model!.containerId,
      id: _model!.id,
      uuid: _model!.uuid,
      name: _model!.name,
      alias: _model!.alias,
      description: _model!.description,
      type: _model!.type,
      parent: _model!.parent,
      timestamp: _model!.timestamp,
      validUntil: _model!.validUntil,
      physicalAddress: _model!.physicalAddress,
      containedChassis: updatedList,
    );
    final result = await _repository.removeChassis(_model!.id, chassisId);
    switch (result) {
      case Success<void>():
        _errorMessage = null;
      case Failure<void>(:final error):
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
    if (error is CountryCodeValidationError) {
      return 'Invalid country code: ${error.input}';
    }
    if (error is CyclicParentReferenceError) {
      return 'Cyclic parent reference: ${error.locationId} -> ${error.parentId}';
    }
    if (error is DuplicateChassisIdError) {
      return 'Duplicate chassis ID: ${error.chassisId}';
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
