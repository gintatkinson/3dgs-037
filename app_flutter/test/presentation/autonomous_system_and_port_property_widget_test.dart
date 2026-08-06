import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/repositories/autonomous_system_and_port_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/autonomous_system_and_port_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/autonomous_system_and_port_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-double repository for widget-level BDD tests.
class _WidgetTestRepository implements AutonomousSystemAndPortRepository {
  Future<Result<AutonomousSystemAndPortTypes>> Function()? _fetchFactory;
  Result<AutonomousSystemAndPortTypes>? saveResult;
  Result<AutonomousSystemAndPortTypes>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<AutonomousSystemAndPortTypes>> save(
    AutonomousSystemAndPortTypes record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<AutonomousSystemAndPortTypes>> fetch(
      {String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<AutonomousSystemAndPortTypes>> update(
    AutonomousSystemAndPortTypes record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('AutonomousSystemAndPortPropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late AutonomousSystemAndPortViewModel viewModel;

    const testRecord = AutonomousSystemAndPortTypes(
      containerId: 'test-1',
      asNumber: 64512,
      portNumber: 80,
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = AutonomousSystemAndPortViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: AutonomousSystemAndPortPropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<AutonomousSystemAndPortTypes>>();
      repo._fetchFactory = () => completer.future;

      await tester.pumpWidget(buildWidget());
      viewModel.load('test-1');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Result.success(testRecord));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'SCENARIO_2 shouldDisplayErrorMessageWhenViewModelHasError',
        (tester) async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad-id'));

      await tester.pumpWidget(buildWidget());
      await viewModel.load('bad-id');
      await tester.pumpAndSettle();

      expect(find.textContaining('Record not found'), findsOneWidget);
    });

    testWidgets('SCENARIO_3 shouldDisplayCorrectHeaderText', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(
        find.text('PropertyGrid (/ietf-inet-types:as-number)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'SCENARIO_4 shouldRenderAllThreeFieldsFromFieldDescriptorSchema',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Container ID'), findsOneWidget);
      expect(find.text('AS Number'), findsOneWidget);
      expect(find.text('Port Number'), findsOneWidget);

      expect(find.text('test-1'), findsOneWidget);
      expect(find.text('64512'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5a shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets(
        'SCENARIO_5b shouldUpdateTextFieldOnUserTyping',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'new-value');
      await tester.pumpAndSettle();

      expect(find.text('new-value'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5 shouldUpdateDisplayOnUserSaveAction_UserEvent_ViewModelAction_StateChange_LuiRender',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('64512'), findsOneWidget);

      const updatedRecord = AutonomousSystemAndPortTypes(
        containerId: 'test-1',
        asNumber: 65535,
        portNumber: 443,
      );
      repo.saveResult = Result.success(updatedRecord);

      await viewModel.save(updatedRecord, recordId: 'test-1');
      await tester.pumpAndSettle();

      expect(find.text('65535'), findsOneWidget);
      expect(find.text('443'), findsOneWidget);
    });
  });
}
