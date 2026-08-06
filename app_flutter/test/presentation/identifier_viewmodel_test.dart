import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/identifier_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test-double repository that records calls and returns predetermined
/// results. Uses a real Result-based API — no mock framework, no stubbing.
class _TestRepository implements IdentifierRepository {
  final List<String> calls = [];
  Future<Result<IdentifierTypes>> Function()? _fetchFactory;
  Result<IdentifierTypes>? saveResult;
  Result<IdentifierTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<IdentifierTypes>> save(IdentifierTypes record,
      {String id = 'default'}) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<IdentifierTypes>> fetch({String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<IdentifierTypes>> update(IdentifierTypes record,
      {String id = 'default'}) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late IdentifierViewModel viewModel;

  final testRecord = IdentifierTypes(
    containerId: 'ctr-1',
    objectIdentifier: '1.3.6.1.4.1',
    objectIdentifier128: '1.3.6.1.4.1',
    uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
    yangIdentifier: 'interfaces',
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = IdentifierViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('IdentifierViewModel', () {
    test('shouldExposeLoadingStateDuringLoad', () async {
      final completer = Completer<Result<IdentifierTypes>>();
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

    test('shouldEmitErrorMessageOnSaveFailure', () async {
      repo.saveResult =
          Result.failure(DatabaseStorageError(message: 'disk full'));

      await viewModel.save(testRecord, recordId: 'bad-1');

      expect(viewModel.errorMessage, contains('disk full'));
    });

    test('shouldUpdateRecord', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      final updated = testRecord.copyWith(
          uuid: '00000000-0000-0000-0000-000000000001');
      repo.updateResult = Result.success(updated);

      await viewModel.update(updated, recordId: 'test-1');

      expect(repo.calls, contains('update:test-1'));
      expect(viewModel.model?.uuid,
          equals('00000000-0000-0000-0000-000000000001'));
      expect(viewModel.errorMessage, isNull);
    });

    test('shouldEmitErrorMessageOnUpdateFailure', () async {
      repo.updateResult =
          Result.failure(DatabaseStorageError(message: 'update failed'));

      await viewModel.update(testRecord, recordId: 'bad-1');

      expect(viewModel.errorMessage, contains('update failed'));
    });

    test('shouldNotCrashWhenLoadingNonexistentId', () async {
      await viewModel.load('nonexistent');

      expect(viewModel.model, isNull);
      expect(viewModel.errorMessage, contains('Record not found'));
      expect(viewModel.isLoading, isFalse);
    });
  });
}
