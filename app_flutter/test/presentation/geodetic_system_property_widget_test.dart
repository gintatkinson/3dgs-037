import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_system_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/geodetic_system_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/geodetic_system_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetTestRepository implements GeodeticSystemRepository {
  Future<Result<GeodeticSystem>> Function()? _fetchFactory;
  Result<GeodeticSystem>? saveResult;
  Result<GeodeticSystem>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<GeodeticSystem>> save(
    GeodeticSystem record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<GeodeticSystem>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<GeodeticSystem>> update(
    GeodeticSystem record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('GeodeticSystemPropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late GeodeticSystemViewModel viewModel;

    const testRecord = GeodeticSystem(
      containerId: 'test-1',
      geodeticDatum: 'wgs-84',
      coordAccuracy: 0.000005,
      heightAccuracy: 0.050000,
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = GeodeticSystemViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: GeodeticSystemPropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<GeodeticSystem>>();
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
        find.text('PropertyGrid (/ietf-geo-location:geodetic-system)'),
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

      expect(find.text('Geodetic Datum'), findsOneWidget);
      expect(find.text('Coordinate Accuracy'), findsOneWidget);
      expect(find.text('Height Accuracy (m)'), findsOneWidget);

      expect(find.text('wgs-84'), findsOneWidget);
      expect(find.text('0.000005'), findsOneWidget);
      expect(find.text('0.05'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5 shouldRenderEditableTextFieldsAndAcceptTyping',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'nad83');
      await tester.pumpAndSettle();

      expect(find.text('nad83'), findsOneWidget);
    });
  });
}
