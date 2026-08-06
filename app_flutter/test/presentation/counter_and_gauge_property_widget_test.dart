import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/repositories/counter_and_gauge_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/counter_and_gauge_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/counter_and_gauge_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-double repository for widget-level BDD tests.
class _WidgetTestRepository implements CounterAndGaugeRepository {
  Future<Result<CounterAndGaugeTypes>> Function()? _fetchFactory;
  Result<CounterAndGaugeTypes>? saveResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<CounterAndGaugeTypes>> save(CounterAndGaugeTypes record,
      {String id = 'default'}) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<CounterAndGaugeTypes>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<CounterAndGaugeTypes>> update(CounterAndGaugeTypes record,
      {String id = 'default'}) async {
    return Result.success(record);
  }
}

void main() {
  group('CounterAndGaugePropertyWidget BDD', () {
    late _WidgetTestRepository repo;
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
      repo = _WidgetTestRepository();
      viewModel = CounterAndGaugeViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CounterAndGaugePropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets('shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<CounterAndGaugeTypes>>();
      repo._fetchFactory = () => completer.future;

      await tester.pumpWidget(buildWidget());
      viewModel.load('test-1');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Result.success(testRecord));
      await tester.pumpAndSettle();
    });

    testWidgets('shouldDisplayErrorMessageWhenViewModelHasError',
        (tester) async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad-id'));

      await tester.pumpWidget(buildWidget());
      await viewModel.load('bad-id');
      await tester.pumpAndSettle();

      expect(find.textContaining('Record not found'), findsOneWidget);
    });

    testWidgets('shouldDisplayCorrectHeaderText', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Counter and Gauge Types'), findsOneWidget);
    });

    testWidgets('shouldRenderFieldsFromFieldDescriptorSchema', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Counter32'), findsOneWidget);
      expect(find.text('Zero Based Counter32'), findsOneWidget);
      expect(find.text('Counter64'), findsOneWidget);
      expect(find.text('Zero Based Counter64'), findsOneWidget);
      expect(find.text('Gauge32'), findsOneWidget);
      expect(find.text('Gauge64'), findsOneWidget);

      expect(find.text('100'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets(
        'shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets(
        'shouldDisplayModelValueInTextFieldForEditableFields',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('shouldUpdateTextFieldOnUserTyping', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, '42');
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets(
        'shouldUpdateValueWhenIncrementButtonTapped_UserEvent_ViewModelAction_StateChange_LuiRender',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);
      repo.saveResult = Result.success(testRecord.copyWith(counter32: 105));

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);

      final incrementButton = find.byKey(const ValueKey('inc_counter32'));
      await tester.tap(incrementButton);
      await tester.pumpAndSettle();

      expect(find.text('105'), findsOneWidget);
    });
  });
}
