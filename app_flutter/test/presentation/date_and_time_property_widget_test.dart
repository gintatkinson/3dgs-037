import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/date_and_time_types.dart';
import 'package:app_flutter/domain/repositories/date_and_time_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/date_and_time_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/date_and_time_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetTestRepository implements DateAndTimeRepository {
  Future<Result<DateAndTimeTypes>> Function()? _fetchFactory;
  Result<DateAndTimeTypes>? saveResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<DateAndTimeTypes>> save(DateAndTimeTypes record,
      {String id = 'default'}) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<DateAndTimeTypes>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<DateAndTimeTypes>> update(DateAndTimeTypes record,
      {String id = 'default'}) async {
    return Result.success(record);
  }
}

void main() {
  group('DateAndTimePropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late DateAndTimeViewModel viewModel;

    final testRecord = DateAndTimeTypes(
      containerId: 'test-1',
      dateAndTime: '2026-08-04T00:23:12+08:00',
      date: '2026-08-04',
      dateNoZone: '2026-08-04',
      time: '00:23:12+08:00',
      timeNoZone: '00:23:12',
      hours32: 100,
      minutes32: 6001,
      seconds32: 360001,
      centiseconds32: 36000001,
      milliseconds32: 360000001,
      microseconds32: 2147483001,
      microseconds64: 2400000001,
      nanoseconds32: 2000000001,
      nanoseconds64: 5000000000001,
      timeticks: 101,
      timestamp: 51,
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = DateAndTimeViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: DateAndTimePropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'shouldDisplayLoadingIndicatorWhenViewModelIsLoading_UserEvent_ViewModelAction_StateChange',
        (tester) async {
      final completer = Completer<Result<DateAndTimeTypes>>();
      repo._fetchFactory = () => completer.future;

      await tester.pumpWidget(buildWidget());
      viewModel.load('test-1');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Result.success(testRecord));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'shouldDisplayErrorMessageWhenViewModelHasError_UserEvent_ViewModelAction_StateChange',
        (tester) async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad-id'));

      await tester.pumpWidget(buildWidget());
      await viewModel.load('bad-id');
      await tester.pumpAndSettle();

      expect(find.textContaining('Record not found'), findsOneWidget);
    });

    testWidgets(
        'shouldDisplayCorrectHeaderText_UserEvent_ViewModelAction_StateChange_LuiRender',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Date and Time Types'), findsOneWidget);
    });

    testWidgets(
        'shouldRenderAll16FieldsFromTypeDescriptorSchema_UserEvent_ViewModelAction_StateChange_LuiRender',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Date and Time'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Date (No Zone)'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Time (No Zone)'), findsOneWidget);
      expect(find.text('Hours (32-bit)'), findsOneWidget);
      expect(find.text('Minutes (32-bit)'), findsOneWidget);
      expect(find.text('Seconds (32-bit)'), findsOneWidget);
      expect(find.text('Centiseconds (32-bit)'), findsOneWidget);
      expect(find.text('Milliseconds (32-bit)'), findsOneWidget);
      expect(find.text('Microseconds (32-bit)'), findsOneWidget);
      expect(find.text('Microseconds (64-bit)'), findsOneWidget);
      expect(find.text('Nanoseconds (32-bit)'), findsOneWidget);
      expect(find.text('Nanoseconds (64-bit)'), findsOneWidget);
      expect(find.text('Timeticks'), findsOneWidget);
      expect(find.text('Timestamp'), findsOneWidget);

      expect(find.text('2026-08-04T00:23:12+08:00'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('6001'), findsOneWidget);
      expect(find.text('360001'), findsOneWidget);
      expect(find.text('36000001'), findsOneWidget);
      expect(find.text('360000001'), findsOneWidget);
      expect(find.text('2147483001'), findsOneWidget);
      expect(find.text('2400000001'), findsOneWidget);
      expect(find.text('2000000001'), findsOneWidget);
      expect(find.text('5000000000001'), findsOneWidget);
      expect(find.text('101'), findsOneWidget);
      expect(find.text('51'), findsOneWidget);
    });

    testWidgets(
        'shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(16));
    });

    testWidgets(
        'shouldDisplayModelValueInTextFieldForEditableFields',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('2026-08-04T00:23:12+08:00'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('101'), findsOneWidget);
    });

    testWidgets('shouldUpdateTextFieldOnUserTyping', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      final hoursField = find.widgetWithText(TextField, '100');
      await tester.enterText(hoursField, '999');
      await tester.pumpAndSettle();

      expect(find.text('999'), findsOneWidget);
    });

    testWidgets(
        'shouldRenderModelValuesAfterSaveOperation_UserEvent_ViewModelAction_StateChange_LuiRender',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);

      final updated = testRecord.copyWith(hours32: 555);
      repo.saveResult = Result.success(updated);
      await viewModel.save(updated, recordId: 'test-1');
      await tester.pumpAndSettle();

      expect(find.text('555'), findsOneWidget);
    });
  });
}
