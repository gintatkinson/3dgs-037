import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/identifier_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/identifier_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-double repository for widget-level BDD tests.
class _WidgetTestRepository implements IdentifierRepository {
  Future<Result<IdentifierTypes>> Function()? _fetchFactory;
  Result<IdentifierTypes>? saveResult;
  Result<IdentifierTypes>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<IdentifierTypes>> save(IdentifierTypes record,
      {String id = 'default'}) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<IdentifierTypes>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<IdentifierTypes>> update(IdentifierTypes record,
      {String id = 'default'}) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('IdentifierPropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late IdentifierViewModel viewModel;

    final testRecord = IdentifierTypes(
      containerId: 'ctr-1',
      objectIdentifier: '1.3.6.1.4.1',
      objectIdentifier128: '1.3.6.1.4.1',
      uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
      yangIdentifier: 'interfaces',
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = IdentifierViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: IdentifierPropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets('shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<IdentifierTypes>>();
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

      expect(find.text('Identifier Types'), findsOneWidget);
    });

    testWidgets('shouldRenderFieldsFromFieldDescriptorSchema', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Container ID'), findsOneWidget);
      expect(find.text('Object Identifier'), findsOneWidget);
      expect(find.text('Object Identifier 128'), findsOneWidget);
      expect(find.text('UUID'), findsOneWidget);
      expect(find.text('YANG Identifier'), findsOneWidget);

      expect(find.text('ctr-1'), findsOneWidget);
      expect(find.text('1.3.6.1.4.1'), findsNWidgets(2));
    });

    testWidgets(
        'shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets(
        'shouldDisplayModelValueInTextFieldForEditableFields',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('ctr-1'), findsOneWidget);
      expect(find.text('1.3.6.1.4.1'), findsNWidgets(2));
    });

    testWidgets('shouldUpdateTextFieldOnUserTyping', (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'changed-value');
      await tester.pumpAndSettle();

      expect(find.text('changed-value'), findsOneWidget);
    });

    testWidgets(
        'shouldUpdateValueWhenUserSavesNewData_UserEvent_ViewModelAction_StateChange_LuiRender',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);
      final updated = testRecord.copyWith(
          uuid: '00000000-0000-0000-0000-000000000001');
      repo.updateResult = Result.success(updated);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'), findsOneWidget);

      await viewModel.update(updated, recordId: 'test-1');
      await tester.pumpAndSettle();

      expect(find.text('00000000-0000-0000-0000-000000000001'), findsOneWidget);
    });
  });
}
