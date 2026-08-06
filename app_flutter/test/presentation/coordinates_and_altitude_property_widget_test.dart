import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/repositories/coordinates_and_altitude_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/coordinates_and_altitude_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/coordinates_and_altitude_property_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetTestRepository implements CoordinatesAndAltitudeRepository {
  Future<Result<GeoLocation>> Function()? _fetchFactory;
  Result<GeoLocation>? saveResult;
  Result<GeoLocation>? updateResult;

  @override
  Future<Result<void>> initDatabase() async => const Result.success(null);

  @override
  Future<Result<GeoLocation>> save(
    GeoLocation record, {
    String id = 'default',
  }) async {
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<GeoLocation>> fetch({String id = 'default'}) async {
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<GeoLocation>> update(
    GeoLocation record, {
    String id = 'default',
  }) async {
    return updateResult ?? Result.success(record);
  }
}

void main() {
  group('CoordinatesAndAltitudePropertyWidget BDD', () {
    late _WidgetTestRepository repo;
    late CoordinatesAndAltitudeViewModel viewModel;

    const testRecord = GeoLocation(
      containerId: 'test-1',
      timestamp: '2026-08-04T12:00:00Z',
      validUntil: '2026-08-04T18:00:00Z',
      ellipsoid: EllipsoidalCoordinates(
        latitude: 37.7749,
        longitude: -122.4194,
        height: 15.5,
      ),
    );

    setUp(() {
      repo = _WidgetTestRepository();
      viewModel = CoordinatesAndAltitudeViewModel(repo);
    });

    tearDown(() {
      viewModel.dispose();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CoordinatesAndAltitudePropertyWidget(viewModel: viewModel),
        ),
      );
    }

    testWidgets(
        'SCENARIO_1 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      final completer = Completer<Result<GeoLocation>>();
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
        find.text('PropertyGrid (/ietf-geo-location:coordinates)'),
        findsOneWidget,
      );
    });

    testWidgets(
        'SCENARIO_4 shouldRenderEllipsoidalFieldsWithCorrectValues',
        (tester) async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-1');
      await tester.pumpAndSettle();

      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Valid Until'), findsOneWidget);
      expect(find.text('Latitude'), findsOneWidget);
      expect(find.text('Longitude'), findsOneWidget);
      expect(find.text('Height (m)'), findsOneWidget);
      expect(find.text('X (m)'), findsOneWidget);
      expect(find.text('Y (m)'), findsOneWidget);
      expect(find.text('Z (m)'), findsOneWidget);

      expect(find.text('2026-08-04T12:00:00Z'), findsOneWidget);
      expect(find.text('2026-08-04T18:00:00Z'), findsOneWidget);
      expect(find.text('37.7749'), findsOneWidget);
      expect(find.text('-122.4194'), findsOneWidget);
      expect(find.text('15.5'), findsOneWidget);
    });

    testWidgets(
        'SCENARIO_5 shouldShowCartesianFieldsWhenCartesianBranchActive',
        (tester) async {
      const cartesianRecord = GeoLocation(
        containerId: 'test-cart',
        cartesian: CartesianCoordinates(
          x: -2696667.123456,
          y: -4294025.654321,
          z: 3887802.987654,
        ),
      );
      repo._fetchFactory = () async => Result.success(cartesianRecord);

      await tester.pumpWidget(buildWidget());
      await viewModel.load('test-cart');
      await tester.pumpAndSettle();

      expect(find.text('-2696667.123456'), findsOneWidget);
      expect(find.text('-4294025.654321'), findsOneWidget);
      expect(find.text('3887802.987654'), findsOneWidget);

      expect(find.text('-'), findsNWidgets(5));
    });
  });
}
