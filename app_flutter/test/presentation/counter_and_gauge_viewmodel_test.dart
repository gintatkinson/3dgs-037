import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/presentation/viewmodels/counter_and_gauge_viewmodel.dart';

/// Fake repository implementation for testing [CounterAndGaugeViewModel].
class FakeCounterAndGaugeRepository implements CounterAndGaugeRepository {
  CounterAndGaugeTypes _data = const CounterAndGaugeTypes();
  bool shouldFailFetch = false;
  bool shouldFailUpdate = false;

  @override
  Future<Result<CounterAndGaugeTypes>> fetch({String id = 'default'}) async {
    if (shouldFailFetch) {
      return Result.failure(const DatabaseStorageError(message: 'Fetch failed'));
    }
    return Result.success(_data);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> save(
    CounterAndGaugeTypes record, {
    String id = 'default',
  }) async {
    if (shouldFailUpdate) {
      return Result.failure(const DatabaseStorageError(message: 'Save failed'));
    }
    _data = record;
    return Result.success(_data);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> update(
    CounterAndGaugeTypes record, {
    String id = 'default',
  }) async {
    if (shouldFailUpdate) {
      return Result.failure(const DatabaseStorageError(message: 'Update failed'));
    }
    _data = record;
    return Result.success(_data);
  }
}

void main() {
  group('CounterAndGaugeViewModel Tests', () {
    late FakeCounterAndGaugeRepository repository;
    late CounterAndGaugeViewModel viewModel;

    setUp(() {
      repository = FakeCounterAndGaugeRepository();
      viewModel = CounterAndGaugeViewModel(repository: repository);
    });

    test('should load initial state from CounterAndGaugeRepository successfully', () async {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);

      await viewModel.load('test-id');

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.model.counter32, 0);
      expect(viewModel.model.counter64, BigInt.zero);
      expect(viewModel.model.gauge32, 0);
      expect(viewModel.model.gauge64, BigInt.zero);
    });

    test('should increment counter32 and counter64 values via ViewModel methods', () async {
      await viewModel.load('test-id');

      await viewModel.incrementCounter32(5);
      expect(viewModel.model.counter32, 5);

      await viewModel.incrementCounter64(BigInt.from(100));
      expect(viewModel.model.counter64, BigInt.from(100));
    });

    test('should update gauge32 and gauge64 values with upper/lower latching via ViewModel methods', () async {
      await viewModel.load('test-id');

      // Test lower bound latching (should not drop below 0)
      await viewModel.updateGauge32(-50);
      expect(viewModel.model.gauge32, 0);

      // Test valid gauge increase
      await viewModel.updateGauge32(1000);
      expect(viewModel.model.gauge32, 1000);

      // Test upper bound latching (kMaxUint32 = 4294967295)
      await viewModel.updateGauge32(4294967295);
      expect(viewModel.model.gauge32, 4294967295);

      // Test gauge64 lower bound latching
      await viewModel.updateGauge64(BigInt.from(-10));
      expect(viewModel.model.gauge64, BigInt.zero);

      // Test gauge64 upper bound latching (18446744073709551615)
      final maxUint64 = BigInt.parse('18446744073709551615');
      await viewModel.updateGauge64(maxUint64);
      expect(viewModel.model.gauge64, maxUint64);
    });

    test('should handle error state when fetch or update fails', () async {
      repository.shouldFailFetch = true;
      await viewModel.load('test-id');

      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, contains('Fetch failed'));

      repository.shouldFailFetch = false;
      repository.shouldFailUpdate = true;

      await viewModel.incrementCounter32(10);
      expect(viewModel.errorMessage, contains('Update failed'));
    });
  });
}
