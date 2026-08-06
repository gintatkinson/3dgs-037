import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/repositories/coordinates_and_altitude_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/coordinates_and_altitude_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRepository implements CoordinatesAndAltitudeRepository {
  Future<Result<GeoLocation>> Function()? _fetchFactory;
  Result<GeoLocation>? saveResult;
  Result<GeoLocation>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<GeoLocation>> save(
    GeoLocation record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<GeoLocation>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<GeoLocation>> update(
    GeoLocation record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('CoordinatesAndAltitudeViewModel BDD', () {
    late _TestRepository repo;
    late CoordinatesAndAltitudeViewModel viewModel;

    const testRecord = GeoLocation(
      containerId: 'test-1',
      timestamp: '2026-08-04T12:00:00Z',
      validUntil: '2026-08-04T18:00:00Z',
      ellipsoid: EllipsoidalCoordinates(
        latitude: 37.7749,
        longitude: -122.4194,
        height: 15.5,
      ),
    );

    setUp(() {
      repo = _TestRepository();
      viewModel = CoordinatesAndAltitudeViewModel(repo);
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
      const updated = GeoLocation(
        containerId: 'test-1',
        cartesian: CartesianCoordinates(x: 100.0, y: 200.0, z: 300.0),
      );

      await viewModel.update(updated, recordId: 'test-1');

      expect(viewModel.model, equals(updated));
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldSetErrorMessageOnSaveFailure', () async {
      repo.saveResult = Result.failure(
        DatabaseStorageError(message: 'disk full'),
      );

      await viewModel.save(testRecord);

      expect(viewModel.errorMessage, contains('Database error'));
    });
  });
}
