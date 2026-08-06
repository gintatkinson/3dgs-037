import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/repositories/geodetic_reference_frame_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/geodetic_reference_frame_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/geodetic_reference_frame_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetTestRepository implements GeodeticReferenceFrameRepository {
  Future<Result<GeodeticReferenceFrame>> Function()? _fetchFactory;
  Result<GeodeticReferenceFrame>? saveResult;
  Result<GeodeticReferenceFrame>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<GeodeticReferenceFrame>> save(
    GeodeticReferenceFrame record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<GeodeticReferenceFrame>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<GeodeticReferenceFrame>> update(
    GeodeticReferenceFrame record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('GeodeticReferenceFramePropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late GeodeticReferenceFrameViewModel viewModel;

    const testRecord = GeodeticReferenceFrame(
      containerId: 'test-1',
      astronomicalBody: 'mars',
      alternateSystem: 'wgs84-3d',
      alternateSystems: true,
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = GeodeticReferenceFrameViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body:
              GeodeticReferenceFramePropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<GeodeticReferenceFrame>>();
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
        find.text('PropertyGrid (/ietf-geo-location:reference-frame)'),
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

      expect(find.text('Astronomical Body'), findsOneWidget);
      expect(find.text('Alternate System'), findsOneWidget);
      expect(find.text('Alternate Systems Feature'), findsOneWidget);

      expect(find.text('mars'), findsOneWidget);
      expect(find.text('wgs84-3d'), findsOneWidget);
      expect(find.text('true'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5 shouldRenderEditableTextFieldAndAcceptTyping',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(3));

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'venus');
      await tester.pumpAndSettle();

      expect(find.text('venus'), findsOneWidget);
    });
  });
}
