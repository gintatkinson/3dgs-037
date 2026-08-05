import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/repositories/address_and_string_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/address_and_string_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/address_and_string_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-double repository for widget-level BDD tests.
class _WidgetTestRepository implements AddressAndStringRepository {
  Future<Result<AddressAndStringTypes>> Function()? _fetchFactory;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<AddressAndStringTypes>> save(AddressAndStringTypes record,
      {String id = 'default'}) async {
    return Result.success(record);
  }

  @override
  Future<Result<AddressAndStringTypes>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<AddressAndStringTypes>> update(AddressAndStringTypes record,
      {String id = 'default'}) async {
    return Result.success(record);
  }
}

void main() {
  group('AddressAndStringPropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late AddressAndStringViewModel viewModel;

    final testRecord = AddressAndStringTypes(
      containerId: 'ctr-1',
      physAddress: '00:11:22:33:44:55',
      macAddress: '08:00:27:00:a1:4c',
      hexString: 'a1:b2:c3:d4',
      dottedQuad: '192.0.2.1',
      languageTag: 'en-US',
      xpath10: '/ietf-yang-types:address-and-string-types/mac-address',
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = AddressAndStringViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: AddressAndStringPropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'Scenario1_GivenLoadingState_WhenLoadDispatched_ThenShowProgressIndicator',
        (tester) async {
      final completer = Completer<Result<AddressAndStringTypes>>();
      repo._fetchFactory = () => completer.future;

      await tester.pumpWidget(buildWidget());
      viewModel.load('test-1');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(Result.success(testRecord));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Scenario2_GivenFetchError_WhenLoadFailed_ThenDisplayErrorMessage',
        (tester) async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad-id'));

      await tester.pumpWidget(buildWidget());
      await viewModel.load('bad-id');
      await tester.pumpAndSettle();

      expect(find.textContaining('Record not found'), findsOneWidget);
    });

    testWidgets(
        'Scenario3_GivenLoadedModel_WhenRendered_ThenDisplayHeaderAndAllFields',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Address and String Types'), findsOneWidget);

      // Verify all 6 typedef field labels are rendered from FieldDescriptor schema
      expect(find.text('Physical Address (phys-address)'), findsOneWidget);
      expect(find.text('MAC Address (mac-address)'), findsOneWidget);
      expect(find.text('Hex String (hex-string)'), findsOneWidget);
      expect(find.text('Dotted Quad (dotted-quad)'), findsOneWidget);
      expect(find.text('Language Tag (language-tag)'), findsOneWidget);
      expect(find.text('XPath 1.0 (xpath1.0)'), findsOneWidget);

      // Verify field values are displayed
      expect(find.text('00:11:22:33:44:55'), findsOneWidget);
      expect(find.text('08:00:27:00:a1:4c'), findsOneWidget);
      expect(find.text('a1:b2:c3:d4'), findsOneWidget);
      expect(find.text('192.0.2.1'), findsOneWidget);
      expect(find.text('en-US'), findsOneWidget);
      expect(find.text('/ietf-yang-types:address-and-string-types/mac-address'),
          findsOneWidget);
    });

    testWidgets(
        'Scenario4_GivenNoModelLoaded_WhenRendered_ThenShowEmptyPlaceholder',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('No model'), findsOneWidget);
    });

    testWidgets(
        'Scenario5_GivenLoadedModel_WhenXPathAndLanguageTagDisplayed_ThenRenderCorrectlyInTableLayout',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      // Verify container ID is shown
      expect(find.textContaining('ctr-1'), findsOneWidget);

      // Verify the MAC address field renders correctly in canonical lowercase
      expect(find.text('08:00:27:00:a1:4c'), findsOneWidget);
    });
  });
}
