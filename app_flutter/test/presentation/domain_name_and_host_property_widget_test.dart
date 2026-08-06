import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/repositories/domain_name_and_host_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/domain_name_and_host_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/domain_name_and_host_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetTestRepository implements DomainNameAndHostRepository {
  Future<Result<DomainNameAndHostTypes>> Function()? _fetchFactory;
  Result<DomainNameAndHostTypes>? saveResult;
  Result<DomainNameAndHostTypes>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<DomainNameAndHostTypes>> save(
      DomainNameAndHostTypes record,
      {String id = 'default'}) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<DomainNameAndHostTypes>> fetch(
      {String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<DomainNameAndHostTypes>> update(
      DomainNameAndHostTypes record,
      {String id = 'default'}) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('DomainNameAndHostPropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late DomainNameAndHostViewModel viewModel;

    const testRecord = DomainNameAndHostTypes(
      containerId: 'test-1',
      domainName: 'example.com',
      host: '192.0.2.1',
      uri: 'https://example.com/path',
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = DomainNameAndHostViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: DomainNameAndHostPropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<DomainNameAndHostTypes>>();
      repo._fetchFactory = () => completer.future;

      await tester.pumpWidget(buildWidget());
      viewModel.load('test-1');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Result.success(testRecord));
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

    testWidgets('SCENARIO_3 shouldDisplayCorrectHeaderText',
        (tester) async {
      repo._fetchFactory = () async => const Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(
        find.text('PropertyGrid (/ietf-inet-types:domain-name)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'SCENARIO_4 shouldRenderAllFourFieldsFromFieldDescriptorSchema',
        (tester) async {
      repo._fetchFactory = () async => const Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Container ID'), findsOneWidget);
      expect(find.text('Domain Name'), findsOneWidget);
      expect(find.text('Host'), findsOneWidget);
      expect(find.text('URI'), findsOneWidget);

      expect(find.text('example.com'), findsOneWidget);
      expect(find.text('192.0.2.1'), findsOneWidget);
      expect(find.text('https://example.com/path'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5a shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => const Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(4));
    });

    testWidgets(
        'SCENARIO_5b shouldUpdateTextFieldOnUserTyping',
        (tester) async {
      repo._fetchFactory = () async => const Result.success(testRecord);

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
      repo._fetchFactory = () async => const Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('example.com'), findsOneWidget);

      const updatedRecord = DomainNameAndHostTypes(
        containerId: 'test-1',
        domainName: 'updated.org',
        host: '10.0.0.1',
        uri: 'https://updated.org',
      );
      repo.saveResult = const Result.success(updatedRecord);

      await viewModel.save(updatedRecord, recordId: 'test-1');
      await tester.pumpAndSettle();

      expect(find.text('updated.org'), findsOneWidget);
      expect(find.text('10.0.0.1'), findsOneWidget);
    });
  });
}
