import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/presentation/viewmodels/counter_and_gauge_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/counter_and_gauge_property_widget.dart';

/// Fake repository implementation for BDD acceptance widget testing.
class FakeCounterAndGaugeRepository implements CounterAndGaugeRepository {
  CounterAndGaugeTypes _data = const CounterAndGaugeTypes();

  @override
  Future<Result<CounterAndGaugeTypes>> fetch({String id = 'default'}) async {
    return Result.success(_data);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> save(
    CounterAndGaugeTypes record, {
    String id = 'default',
  }) async {
    _data = record;
    return Result.success(_data);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> update(
    CounterAndGaugeTypes record, {
    String id = 'default',
  }) async {
    _data = record;
    return Result.success(_data);
  }
}

void main() {
  group('CounterAndGaugePropertyWidget BDD Acceptance Widget Tests', () {
    late FakeCounterAndGaugeRepository repository;
    late CounterAndGaugeViewModel viewModel;

    setUp(() {
      repository = FakeCounterAndGaugeRepository();
      viewModel = CounterAndGaugeViewModel(repository: repository);
    });

    testWidgets('given loaded model, should render counter and gauge fields in PropertyGrid layout', (tester) async {
      await viewModel.load('test-id');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterAndGaugePropertyWidget(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('counter32'), findsOneWidget);
      expect(find.text('zeroBasedCounter32'), findsOneWidget);
      expect(find.text('counter64'), findsOneWidget);
      expect(find.text('zeroBasedCounter64'), findsOneWidget);
      expect(find.text('gauge32'), findsOneWidget);
      expect(find.text('gauge64'), findsOneWidget);
    });

    testWidgets('given user taps counter32 increment button, should execute ViewModel action and update LUI render', (tester) async {
      await viewModel.load('test-id');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterAndGaugePropertyWidget(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('counter32_value')), findsOneWidget);
      expect(find.text('0'), findsAtLeastNWidgets(1));

      final incrementCounter32Button = find.byKey(const Key('increment_counter32_button'));
      expect(incrementCounter32Button, findsOneWidget);

      await tester.tap(incrementCounter32Button);
      await tester.pumpAndSettle();

      expect(viewModel.model.counter32, 1);
      expect(find.text('1'), findsAtLeastNWidgets(1));
    });

    testWidgets('given user taps counter64 increment button, should execute ViewModel action and update LUI render', (tester) async {
      await viewModel.load('test-id');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterAndGaugePropertyWidget(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final incrementCounter64Button = find.byKey(const Key('increment_counter64_button'));
      expect(incrementCounter64Button, findsOneWidget);

      await tester.tap(incrementCounter64Button);
      await tester.pumpAndSettle();

      expect(viewModel.model.counter64, BigInt.one);
    });

    testWidgets('given user taps gauge32 and gauge64 delta buttons, should execute ViewModel action and update LUI render', (tester) async {
      await viewModel.load('test-id');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CounterAndGaugePropertyWidget(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final incrementGauge32Button = find.byKey(const Key('increment_gauge32_button'));
      expect(incrementGauge32Button, findsOneWidget);

      await tester.tap(incrementGauge32Button);
      await tester.pumpAndSettle();

      expect(viewModel.model.gauge32, 10);

      final incrementGauge64Button = find.byKey(const Key('increment_gauge64_button'));
      expect(incrementGauge64Button, findsOneWidget);

      await tester.tap(incrementGauge64Button);
      await tester.pumpAndSettle();

      expect(viewModel.model.gauge64, BigInt.from(100));
    });
  });
}
