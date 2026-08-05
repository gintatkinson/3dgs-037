import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/repositories/address_and_string_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/address_and_string_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test-double repository that records calls and returns predetermined
/// results. Uses a real Result-based API — no mock framework, no stubbing.
class _TestRepository implements AddressAndStringRepository {
  final List<String> calls = [];
  Future<Result<AddressAndStringTypes>> Function()? _fetchFactory;
  Result<AddressAndStringTypes>? saveResult;
  Result<AddressAndStringTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<AddressAndStringTypes>> save(AddressAndStringTypes record,
      {String id = 'default'}) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<AddressAndStringTypes>> fetch({String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<AddressAndStringTypes>> update(AddressAndStringTypes record,
      {String id = 'default'}) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late AddressAndStringViewModel viewModel;

  final testRecord = AddressAndStringTypes(
    containerId: 'ctr-1',
    physAddress: '00:11:22:33:44:55',
    macAddress: '08:00:27:00:a1:4c',
    hexString: 'a1:b2:c3:d4',
    dottedQuad: '192.0.2.1',
    languageTag: 'en-US',
    xpath10: '/ietf-yang-types:address-and-string-types/mac-address',
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = AddressAndStringViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AddressAndStringViewModel', () {
    test('shouldExposeLoadingStateDuringLoad', () async {
      final completer = Completer<Result<AddressAndStringTypes>>();
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
      await viewModel.load('test-1');
      repo._fetchFactory = () async => Result.success(testRecord);

      final updated = testRecord.copyWith(macAddress: 'aa:bb:cc:dd:ee:ff');

      await viewModel.update(updated, recordId: 'test-1');

      expect(repo.calls, contains('update:test-1'));
      expect(viewModel.model?.macAddress, equals('aa:bb:cc:dd:ee:ff'));
    });

    test('shouldHandleDatabaseStorageErrorOnSave', () async {
      repo.saveResult = Result.failure(
        DatabaseStorageError(message: 'Disk full'),
      );

      await viewModel.save(testRecord, recordId: 'err-1');

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, contains('Disk full'));
    });

    test('shouldNotNotifyAfterDisposed', () async {
      var notified = false;
      viewModel.addListener(() => notified = true);
      viewModel.dispose();

      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      expect(notified, isFalse);
    });
  });
}
