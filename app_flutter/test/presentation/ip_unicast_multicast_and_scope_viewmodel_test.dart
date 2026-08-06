import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/repositories/ip_unicast_multicast_and_scope_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/ip_unicast_multicast_and_scope_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test-double repository that records calls and returns predetermined
/// results. Uses a real Result-based API — no mock framework, no stubbing.
class _TestRepository implements IpUnicastMulticastAndScopeRepository {
  final List<String> calls = [];
  Future<Result<IpUnicastMulticastAndScopeTypes>> Function()? _fetchFactory;
  Result<IpUnicastMulticastAndScopeTypes>? saveResult;
  Result<IpUnicastMulticastAndScopeTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> save(
      IpUnicastMulticastAndScopeTypes record,
      {String id = 'default'}) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> fetch(
      {String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> update(
      IpUnicastMulticastAndScopeTypes record,
      {String id = 'default'}) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late IpUnicastMulticastAndScopeViewModel viewModel;

  final testRecord = IpUnicastMulticastAndScopeTypes(
    containerId: 'test',
    ipv6FlowLabel: 42,
    dscp: 46,
    ipUnicastAddress: '192.168.1.1',
    ipv4UnicastAddress: '192.168.1.1',
    ipv6UnicastAddress: null,
    ipMulticastAddress: '224.0.0.1',
    ipv4MulticastAddress: '224.0.0.1',
    ipv6MulticastAddress: null,
    scopeType: 'link-local',
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = IpUnicastMulticastAndScopeViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('IpUnicastMulticastAndScopeViewModel', () {
    test('shouldExposeLoadingStateDuringLoad', () async {
      final completer =
          Completer<Result<IpUnicastMulticastAndScopeTypes>>();
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

      const updated = IpUnicastMulticastAndScopeTypes(
        containerId: 'test-1',
        ipv6FlowLabel: 100,
        dscp: 10,
        ipv4UnicastAddress: '10.0.0.1',
        ipUnicastAddress: '10.0.0.1',
      );
      repo.updateResult = Result.success(updated);

      await viewModel.update(updated, recordId: 'test-1');

      expect(repo.calls, contains('update:test-1'));
      expect(viewModel.model?.ipv4UnicastAddress, equals('10.0.0.1'));
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
