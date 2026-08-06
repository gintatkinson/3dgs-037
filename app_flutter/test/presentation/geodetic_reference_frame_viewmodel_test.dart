import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_reference_frame_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/geodetic_reference_frame_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRepository implements GeodeticReferenceFrameRepository {
  Future<Result<GeodeticReferenceFrame>> Function()? _fetchFactory;
  Result<GeodeticReferenceFrame>? saveResult;
  Result<GeodeticReferenceFrame>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<GeodeticReferenceFrame>> save(
    GeodeticReferenceFrame record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<GeodeticReferenceFrame>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<GeodeticReferenceFrame>> update(
    GeodeticReferenceFrame record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('GeodeticReferenceFrameViewModel', () {
    late _TestRepository repo;
    late GeodeticReferenceFrameViewModel viewModel;

    const testRecord = GeodeticReferenceFrame(
      containerId: 'test-1',
      astronomicalBody: 'mars',
      alternateSystem: 'wgs84-3d',
      alternateSystems: true,
    );

    setUp(() {
      repo = _TestRepository();
      viewModel = GeodeticReferenceFrameViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('shouldSetLoadingTrueDuringFetch', () async {
      final completer = Completer<Result<GeodeticReferenceFrame>>();
      repo._fetchFactory = () => completer.future;

      viewModel.load('test-1');
      await Future.microtask(() {});
      expect(viewModel.isLoading, isTrue);

      completer.complete(Result.success(testRecord));
      await completer.future;
      await Future.microtask(() {});
      expect(viewModel.isLoading, isFalse);
    });

    test('shouldPopulateModelOnSuccessfulFetch', () async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await viewModel.load('test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('shouldSetErrorMessageOnFailedFetch', () async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad-id'));

      await viewModel.load('bad-id');

      expect(viewModel.model, isNull);
      expect(viewModel.errorMessage, contains('Record not found'));
      expect(viewModel.isLoading, isFalse);
    });

    test('shouldSetErrorMessageOnDatabaseStorageError', () async {
      repo._fetchFactory = () async =>
          Result.failure(DatabaseStorageError(message: 'disk full'));

      await viewModel.load('test-1');

      expect(viewModel.errorMessage, contains('Database error'));
    });

    test('shouldUpdateModelOnSave', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      const updated = GeodeticReferenceFrame(
        astronomicalBody: 'earth',
        alternateSystems: false,
      );
      repo.saveResult = Result.success(updated);

      await viewModel.save(updated, recordId: 'test-1');

      expect(viewModel.model, equals(updated));
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldSetErrorMessageOnFailedSave', () async {
      repo.saveResult =
          Result.failure(DatabaseStorageError(message: 'write failed'));

      await viewModel.save(testRecord, recordId: 'test-1');

      expect(viewModel.errorMessage, contains('Database error'));
    });

    test('shouldUpdateModelOnUpdate', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      const updated = GeodeticReferenceFrame(
        astronomicalBody: 'earth',
        alternateSystems: false,
      );
      repo.updateResult = Result.success(updated);

      await viewModel.update(updated, recordId: 'test-1');

      expect(viewModel.model, equals(updated));
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldFormatInvalidAstronomicalBodyError', () async {
      repo._fetchFactory = () async =>
          Result.failure(InvalidAstronomicalBodyError(input: 'bad\x00'));

      await viewModel.load('test-1');

      expect(viewModel.errorMessage, contains('Invalid astronomical body'));
    });

    test('shouldFormatFeatureDisabledAlternateSystemError', () async {
      repo._fetchFactory = () async =>
          Result.failure(FeatureDisabledAlternateSystemError(value: 'fail'));

      await viewModel.load('test-1');

      expect(viewModel.errorMessage,
          contains('Alternate system feature disabled'));
    });

    test('shouldNotNotifyAfterDispose', () async {
      viewModel.dispose();

      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      // Should not throw — _disposed guard prevents notifyListeners
      expect(true, isTrue);
    });
  });
}
