import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_location_inventory_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/location_inventory_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/location_inventory_property_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> pumpSettle(WidgetTester tester) async {
  for (int i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _LocationInventoryTestHarness {
  late Database db;
  late SqliteLocationInventoryRepository repo;
  late LocationInventoryViewModel viewModel;

  Future<void> init() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    repo = SqliteLocationInventoryRepository(db);
    await repo.initDatabase();
    viewModel = LocationInventoryViewModel(repo);
  }

  Future<void> dispose() async {
    viewModel.dispose();
    await db.close();
  }
}

void main() {
  group('LocationInventoryPropertyWidget BDD', () {
    late _LocationInventoryTestHarness harness;

    final testLocation = Location(
      containerId: 'test-1',
      id: 'loc-site-sfo-01',
      uuid: '550e8400-e29b-41d4-a716-446655440000',
      name: 'SFO Site',
      alias: 'sfo-site',
      description: 'San Francisco data center site',
      type: 'site',
      parent: null,
      timestamp: '2026-01-15T10:30:00Z',
      validUntil: '2027-01-15T10:30:00Z',
      physicalAddress: const PhysicalAddress(
        address: '500 Howard Street',
        postalCode: '94105',
        state: 'CA',
        city: 'San Francisco',
        countryCode: 'US',
      ),
      containedChassis: const [],
    );

    setUp(() {
      harness = _LocationInventoryTestHarness();
    });

    tearDown(() async {
      await harness.dispose();
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_1: should display location with physical address fields
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_1 shouldDisplayLocationWithPhysicalAddressFields',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testLocation, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('PropertyGrid (/ietf-ni-location:locations/location)'),
          findsOneWidget);

      expect(find.text('loc-site-sfo-01'), findsOneWidget);
      expect(find.text('500 Howard Street'), findsOneWidget);
      expect(find.text('US'), findsOneWidget);
      expect(find.text('San Francisco'), findsOneWidget);

      expect(find.text('Location ID'), findsOneWidget);
      expect(find.text('UUID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alias'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Parent Location'), findsOneWidget);
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Valid Until'), findsOneWidget);
      expect(find.text('Street Address'), findsOneWidget);
      expect(find.text('Postal Code'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Country Code'), findsOneWidget);
      expect(find.text('Contained Chassis'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_2: should render country code validation error
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_2 shouldRenderCountryCodeValidationError',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
      });

      final result = validateCountryCode('USA');
      expect(result.isFailure, isTrue);
      final failure = result as Failure<String>;
      expect(failure.error is CountryCodeValidationError, isTrue);
      expect(
          failure.error.toString().toLowerCase(),
          contains('countrycodevalidationerror'));
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_3: should display hierarchical parent reference
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_3 shouldDisplayHierarchicalParentReference',
        (tester) async {
      final parentLocation = Location(
        containerId: 'parent-1',
        id: 'loc-site-sfo-parent',
        name: 'Parent Site',
      );

      final childLocation = Location(
        containerId: 'child-1',
        id: 'loc-site-sfo-child',
        name: 'Child Site',
        parent: 'loc-site-sfo-parent',
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(parentLocation, id: 'parent-1');
        await harness.repo.save(childLocation, id: 'child-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('child-1');
      });
      await pumpSettle(tester);

      expect(find.text('loc-site-sfo-parent'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_4: should render contained chassis list entries
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_4 shouldRenderContainedChassisListEntries',
        (tester) async {
      final locationWithChassis = Location(
        containerId: 'test-chassis',
        id: 'loc-with-chassis',
        physicalAddress: const PhysicalAddress(
          city: 'San Jose',
        ),
        containedChassis: const [
          ContainedChassis(
            chassisId: 101,
            neRef: '/nwi:network-inventory/network-elements/ne-101',
          ),
        ],
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationWithChassis, id: 'test-chassis');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-chassis');
      });
      await pumpSettle(tester);

      expect(find.textContaining('101'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_5: should display loading indicator when ViewModel is loading
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_5 shouldDisplayLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        harness.viewModel.load('test-1');
      });
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_6: should render editable TextFields for location metadata
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_6 shouldRenderEditableTextFieldsForLocationMetadata',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testLocation, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.byType(TextField), findsNWidgets(14));

      expect(find.text('Location ID'), findsOneWidget);
      expect(find.text('UUID'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alias'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Type'), findsOneWidget);
      expect(find.text('Parent Location'), findsOneWidget);
      expect(find.text('Timestamp'), findsOneWidget);
      expect(find.text('Valid Until'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_7: should render editable TextFields for physical address fields
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_7 shouldRenderEditableTextFieldsForPhysicalAddressFields',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testLocation, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('Street Address'), findsOneWidget);
      expect(find.text('Postal Code'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Country Code'), findsOneWidget);

      expect(find.byType(TextField), findsNWidgets(14));
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_8: should render read-only chassis list
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_8 shouldRenderReadOnlyChassisList',
        (tester) async {
      final locationWithChassis = Location(
        containerId: 'test-chassis-ro',
        id: 'loc-readonly-chassis',
        physicalAddress: const PhysicalAddress(
          city: 'San Jose',
        ),
        containedChassis: const [
          ContainedChassis(
            chassisId: 101,
            neRef: '/nwi:network-inventory/network-elements/ne-101',
          ),
          ContainedChassis(
            chassisId: 202,
            neRef: '/nwi:network-inventory/network-elements/ne-202',
          ),
        ],
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationWithChassis, id: 'test-chassis-ro');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-chassis-ro');
      });
      await pumpSettle(tester);

      expect(find.text('Contained Chassis'), findsOneWidget);

      final allTextFields = tester.widgetList<TextField>(
        find.byType(TextField),
      );
      final chassisTextControllers = <String>{};
      for (final tf in allTextFields) {
        chassisTextControllers.add(tf.controller?.text ?? '');
      }
      final hasChassisInTextField = chassisTextControllers.any(
        (t) => t.contains('101') || t.contains('202'),
      );
      expect(hasChassisInTextField, isFalse);
    });
  });
}
