import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/repositories/ip_address_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/ip_address_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/ip_address_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-double repository for widget-level BDD tests.
class _WidgetTestRepository implements IpAddressRepository {
  Future<Result<IpAddressTypes>> Function()? _fetchFactory;
  Result<IpAddressTypes>? saveResult;
  Result<IpAddressTypes>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<IpAddressTypes>> save(IpAddressTypes record,
      {String id = 'default'}) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<IpAddressTypes>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<IpAddressTypes>> update(IpAddressTypes record,
      {String id = 'default'}) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('IpAddressPropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late IpAddressViewModel viewModel;

    final testRecord = IpAddressTypes(
      containerId: 'test-1',
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
      repo = _WidgetTestRepository();
      viewModel = IpAddressViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: IpAddressPropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<IpAddressTypes>>();
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

    testWidgets('SCENARIO_3 shouldDisplayCorrectHeaderText',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(
        find.text('PropertyGrid (/ietf-inet-types:ip-address)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'SCENARIO_4 shouldRenderAllElevenFieldsFromFieldDescriptorSchema',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Container ID'), findsOneWidget);
      expect(find.text('IP Version'), findsOneWidget);
      expect(find.text('IP Address'), findsOneWidget);
      expect(find.text('IPv4 Address'), findsOneWidget);
      expect(find.text('IPv6 Address'), findsOneWidget);
      expect(find.text('IP Prefix'), findsOneWidget);
      expect(find.text('IPv4 Prefix'), findsOneWidget);
      expect(find.text('IPv6 Prefix'), findsOneWidget);
      expect(find.text('IP Address (No Zone)'), findsOneWidget);
      expect(find.text('IPv4 Address (No Zone)'), findsOneWidget);
      expect(find.text('IPv6 Address (No Zone)'), findsOneWidget);

      expect(find.text('192.168.1.1'), findsNWidgets(2));
      expect(find.text('192.168.1.0/24'), findsNWidgets(2));
      expect(find.text('10.0.0.1'), findsNWidgets(2));
    });

    testWidgets(
        'SCENARIO_5a shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(11));
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

      expect(find.text('192.168.1.1'), findsNWidgets(2));

      final updatedRecord = IpAddressTypes(
        containerId: 'test-1',
        ipVersion: 1,
        ipAddress: '10.0.0.254',
        ipv4Address: '10.0.0.254',
      );
      repo.saveResult = Result.success(updatedRecord);

      await viewModel.save(updatedRecord, recordId: 'test-1');
      await tester.pumpAndSettle();

      expect(find.text('10.0.0.254'), findsNWidgets(2));
    });
  });
}
