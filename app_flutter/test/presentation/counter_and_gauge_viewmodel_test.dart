import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/counter_and_gauge_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A test-double repository that records calls and returns predetermined
/// results. Uses a real Result-based API — no mock framework, no stubbing.
class _TestRepository implements CounterAndGaugeRepository {
  final List<String> calls = [];
  Future<Result<CounterAndGaugeTypes>> Function()? _fetchFactory;
  Result<CounterAndGaugeTypes>? saveResult;
  Result<CounterAndGaugeTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> save(CounterAndGaugeTypes record,
      {String id = 'default'}) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> fetch({String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<CounterAndGaugeTypes>> update(CounterAndGaugeTypes record,
      {String id = 'default'}) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late CounterAndGaugeViewModel viewModel;

  final testRecord = CounterAndGaugeTypes(
    counter32: 100,
    zeroBasedCounter32: 0,
    counter64: BigInt.from(500),
    zeroBasedCounter64: BigInt.zero,
    gauge32: 250,
    gauge64: BigInt.from(1000),
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = CounterAndGaugeViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('CounterAndGaugeViewModel', () {
    test('shouldExposeLoadingStateDuringLoad', () async {
      final completer = Completer<Result<CounterAndGaugeTypes>>();
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

    test('shouldIncrementCounter32AndPersist', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      final updated = CounterAndGaugeTypes.incrementCounter32(
          testRecord.counter32, 5);
      repo.saveResult = Result.success(testRecord.copyWith(counter32: updated));

      await viewModel.incrementCounter32(5);

      expect(repo.calls, contains('save:test-1'));
      expect(viewModel.model?.counter32, equals(updated));
    });

    test('shouldUpdateGauge32AndPersist', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      final updated =
          CounterAndGaugeTypes.updateGauge32(testRecord.gauge32, -50);
      repo.saveResult = Result.success(testRecord.copyWith(gauge32: updated));

      await viewModel.updateGauge32(-50);

      expect(viewModel.model?.gauge32, equals(updated));
    });

    test('shouldUpdateGauge64AndPersist', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      final updated = CounterAndGaugeTypes.updateGauge64(
          testRecord.gauge64, BigInt.from(500));
      repo.saveResult =
          Result.success(testRecord.copyWith(gauge64: updated));

      await viewModel.updateGauge64(BigInt.from(500));

      expect(viewModel.model?.gauge64, equals(updated));
    });

    test('shouldSaveNewRecord', () async {
      await viewModel.save(testRecord, recordId: 'new-1');

      expect(repo.calls, contains('save:new-1'));
      expect(viewModel.model, equals(testRecord));
      expect(viewModel.errorMessage, isNull);
    });
  });
}
