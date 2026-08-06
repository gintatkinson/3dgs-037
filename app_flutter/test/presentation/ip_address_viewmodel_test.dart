import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/repositories/ip_address_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/ip_address_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test-double repository that records calls and returns predetermined
/// results. Uses a real Result-based API — no mock framework, no stubbing.
class _TestRepository implements IpAddressRepository {
  final List<String> calls = [];
  Future<Result<IpAddressTypes>> Function()? _fetchFactory;
  Result<IpAddressTypes>? saveResult;
  Result<IpAddressTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<IpAddressTypes>> save(IpAddressTypes record,
      {String id = 'default'}) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<IpAddressTypes>> fetch({String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<IpAddressTypes>> update(IpAddressTypes record,
      {String id = 'default'}) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late IpAddressViewModel viewModel;

  final testRecord = IpAddressTypes(
    containerId: 'test',
    ipVersion: 1,
    ipAddress: '192.168.1.1',
    ipv4Address: '192.168.1.1',
    ipv6Address: null,
    ipPrefix: '192.168.1.0/24',
    ipv4Prefix: '192.168.1.0/24',
    ipv6Prefix: null,
    ipAddressNoZone: '10.0.0.1',
    ipv4AddressNoZone: '10.0.0.1',
    ipv6AddressNoZone: null,
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = IpAddressViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('IpAddressViewModel', () {
    test('shouldExposeLoadingStateDuringLoad', () async {
      final completer = Completer<Result<IpAddressTypes>>();
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

      final updated = IpAddressTypes(
        containerId: 'test-1',
        ipVersion: 1,
        ipv4Address: '10.0.0.1',
        ipAddress: '10.0.0.1',
      );
      repo.updateResult = Result.success(updated);

      await viewModel.update(updated, recordId: 'test-1');

      expect(repo.calls, contains('update:test-1'));
      expect(viewModel.model?.ipv4Address, equals('10.0.0.1'));
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
  });
}
