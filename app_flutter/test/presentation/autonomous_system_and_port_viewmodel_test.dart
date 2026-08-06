import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/repositories/autonomous_system_and_port_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/autonomous_system_and_port_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test-double repository that records calls and returns predetermined
/// results. Uses a real Result-based API — no mock framework, no stubbing.
class _TestRepository implements AutonomousSystemAndPortRepository {
  final List<String> calls = [];
  Future<Result<AutonomousSystemAndPortTypes>> Function()? _fetchFactory;
  Result<AutonomousSystemAndPortTypes>? saveResult;
  Result<AutonomousSystemAndPortTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<AutonomousSystemAndPortTypes>> save(
    AutonomousSystemAndPortTypes record, {
    String id = 'default',
  }) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<AutonomousSystemAndPortTypes>> fetch(
      {String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<AutonomousSystemAndPortTypes>> update(
    AutonomousSystemAndPortTypes record, {
    String id = 'default',
  }) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late AutonomousSystemAndPortViewModel viewModel;

  const testRecord = AutonomousSystemAndPortTypes(
    containerId: 'test',
    asNumber: 64512,
    portNumber: 80,
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = AutonomousSystemAndPortViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AutonomousSystemAndPortViewModel', () {
    test('shouldExposeLoadingStateDuringLoad', () async {
      final completer = Completer<Result<AutonomousSystemAndPortTypes>>();
      repo._fetchFactory = () => completer.future;

      final future = viewModel.load('test-1');
      await Future.microtask(() {});
      expect(viewModel.isLoading, isTrue);

      completer.complete(Result.success(testRecord));
      await future;
      expect(viewModel.isLoading, isFalse);
    });

    test('shouldEmitModelAfterSuccessfulLoad', () async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await viewModel.load('test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldEmitErrorMessageOnLoadFailure', () async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'missing'));

      await viewModel.load('missing');

      expect(viewModel.model, isNull);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, contains('missing'));
    });

    test('shouldSaveNewRecord', () async {
      await viewModel.save(testRecord, recordId: 'new-1');

      expect(repo.calls, contains('save:new-1'));
      expect(viewModel.model, equals(testRecord));
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldUpdateExistingRecord', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      const updated = AutonomousSystemAndPortTypes(
        containerId: 'test-1',
        asNumber: 65535,
        portNumber: 443,
      );
      repo.updateResult = Result.success(updated);

      await viewModel.update(updated, recordId: 'test-1');

      expect(repo.calls, contains('update:test-1'));
      expect(viewModel.model?.asNumber, equals(65535));
    });

    test('shouldClearErrorMessageOnRecovery', () async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad'));
      await viewModel.load('bad');
      expect(viewModel.errorMessage, isNotNull);

      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('good');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.model, isNotNull);
    });

    test('shouldSaveWithDefaultRecordId', () async {
      await viewModel.save(testRecord);

      expect(repo.calls, contains('save:default'));
      expect(viewModel.model, equals(testRecord));
    });
  });
}
