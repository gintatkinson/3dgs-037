import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/repositories/ip_unicast_multicast_and_scope_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/ip_unicast_multicast_and_scope_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/ip_unicast_multicast_and_scope_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-double repository for widget-level BDD tests.
class _WidgetTestRepository
    implements IpUnicastMulticastAndScopeRepository {
  Future<Result<IpUnicastMulticastAndScopeTypes>> Function()? _fetchFactory;
  Result<IpUnicastMulticastAndScopeTypes>? saveResult;
  Result<IpUnicastMulticastAndScopeTypes>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> save(
      IpUnicastMulticastAndScopeTypes record,
      {String id = 'default'}) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> fetch(
      {String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<IpUnicastMulticastAndScopeTypes>> update(
      IpUnicastMulticastAndScopeTypes record,
      {String id = 'default'}) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('IpUnicastMulticastAndScopePropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late IpUnicastMulticastAndScopeViewModel viewModel;

    final testRecord = IpUnicastMulticastAndScopeTypes(
      containerId: 'test-1',
      ipv6FlowLabel: 524287,
      dscp: 46,
      ipUnicastAddress: '192.168.1.1',
      ipv4UnicastAddress: '192.168.1.1',
      ipv6UnicastAddress: '2001:db8::1',
      ipMulticastAddress: '224.0.0.1',
      ipv4MulticastAddress: '224.0.0.1',
      ipv6MulticastAddress: 'ff02::1',
      scopeType: 'link-local',
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = IpUnicastMulticastAndScopeViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: IpUnicastMulticastAndScopePropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer =
          Completer<Result<IpUnicastMulticastAndScopeTypes>>();
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
        find.text('PropertyGrid (/ietf-inet-types:ip-multicast-scope)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'SCENARIO_4 shouldRenderAllTenFieldsFromFieldDescriptorSchema',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Container ID'), findsOneWidget);
      expect(find.text('IPv6 Flow Label'), findsOneWidget);
      expect(find.text('DSCP'), findsOneWidget);
      expect(find.text('IP Unicast Address'), findsOneWidget);
      expect(find.text('IPv4 Unicast Address'), findsOneWidget);
      expect(find.text('IPv6 Unicast Address'), findsOneWidget);
      expect(find.text('IP Multicast Address'), findsOneWidget);
      expect(find.text('IPv4 Multicast Address'), findsOneWidget);
      expect(find.text('IPv6 Multicast Address'), findsOneWidget);
      expect(find.text('Scope Type'), findsOneWidget);

      expect(find.text('524287'), findsOneWidget);
      expect(find.text('46'), findsOneWidget);
      expect(find.text('192.168.1.1'), findsNWidgets(2));
      expect(find.text('2001:db8::1'), findsOneWidget);
      expect(find.text('224.0.0.1'), findsNWidgets(2));
      expect(find.text('ff02::1'), findsOneWidget);
      expect(find.text('link-local'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5a shouldRenderEditableTextFieldForFieldsWithValueWriter',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(10));
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

      final updatedRecord = IpUnicastMulticastAndScopeTypes(
        containerId: 'test-1',
        ipv6FlowLabel: 100,
        dscp: 10,
        ipUnicastAddress: '10.0.0.254',
        ipv4UnicastAddress: '10.0.0.254',
        scopeType: 'global',
      );
      repo.saveResult = Result.success(updatedRecord);

      await viewModel.save(updatedRecord, recordId: 'test-1');
      await tester.pumpAndSettle();

      expect(find.text('10.0.0.254'), findsNWidgets(2));
      expect(find.text('global'), findsOneWidget);
    });
  });
}
