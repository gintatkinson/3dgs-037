import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_system_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/geodetic_system_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRepository implements GeodeticSystemRepository {
  Future<Result<GeodeticSystem>> Function()? _fetchFactory;
  Result<GeodeticSystem>? saveResult;
  Result<GeodeticSystem>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<GeodeticSystem>> save(
    GeodeticSystem record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<GeodeticSystem>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<GeodeticSystem>> update(
    GeodeticSystem record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('GeodeticSystemViewModel BDD', () {
    late _TestRepository repo;
    late GeodeticSystemViewModel viewModel;

    const testRecord = GeodeticSystem(
      containerId: 'test-1',
      geodeticDatum: 'wgs-84',
      coordAccuracy: 0.000005,
      heightAccuracy: 0.050000,
    );

    setUp(() {
      repo = _TestRepository();
      viewModel = GeodeticSystemViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('shouldSetModelOnLoadSuccess', () async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await viewModel.load('test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldSetErrorMessageOnLoadFailure', () async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad-id'));

      await viewModel.load('bad-id');

      expect(viewModel.model, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Record not found'));
    });

    test('shouldUpdateModelOnSaveSuccess', () async {
      await viewModel.save(testRecord, recordId: 'test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldUpdateModelOnUpdateSuccess', () async {
      const updated = GeodeticSystem(
        containerId: 'test-1',
        geodeticDatum: 'nad83',
        coordAccuracy: 0.000001,
        heightAccuracy: null,
      );

      await viewModel.update(updated, recordId: 'test-1');

      expect(viewModel.model, equals(updated));
      expect(viewModel.errorMessage, isNull);
    });
  });
}
