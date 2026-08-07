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

      expect(find.byType(TextField), findsNWidgets(17));

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

      expect(find.byType(TextField), findsNWidgets(17));
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_9 — Render BuildingPosition fields
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_9 shouldRenderBuildingPositionFields',
        (tester) async {
      const bp = BuildingPosition(
        building: 'B',
        floor: '3',
        room: '302',
        roomBuildingPosition: 'B/3/302',
      );
      final locationWithBP = Location(
        containerId: 'test-bp',
        id: 'loc-with-bp',
        buildingPosition: bp,
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationWithBP, id: 'test-bp');
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
        await harness.viewModel.load('test-bp');
      });
      await pumpSettle(tester);

      expect(find.text('Building'), findsOneWidget);
      expect(find.text('Floor'), findsOneWidget);
      expect(find.text('Room'), findsOneWidget);
      expect(find.text('Room Building Position'), findsOneWidget);

      expect(find.text('B'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('302'), findsOneWidget);
      expect(find.text('B, 3, 302'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_10 — Null BuildingPosition renders '-'
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_10 shouldRenderDashForNullBuildingPosition',
        (tester) async {
      final locationNullBP = Location(
        containerId: 'test-null-bp',
        id: 'loc-null-bp',
        physicalAddress: const PhysicalAddress(
          city: 'Austin',
        ),
        buildingPosition: null,
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationNullBP, id: 'test-null-bp');
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
        await harness.viewModel.load('test-null-bp');
      });
      await pumpSettle(tester);

      expect(find.text('Building'), findsOneWidget);
      expect(find.text('Floor'), findsOneWidget);
      expect(find.text('Room'), findsOneWidget);
      expect(find.text('Room Building Position'), findsOneWidget);

      final allTextFields = tester.widgetList<TextField>(
        find.byType(TextField),
      );
      final fieldTexts =
          allTextFields.map((tf) => tf.controller?.text ?? '').toList();
      expect(fieldTexts.where((t) => t == '-').length, greaterThanOrEqualTo(3));
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_11 — Read-only roomBuildingPosition computed field
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_11 shouldRenderReadOnlyRoomBuildingPosition',
        (tester) async {
      const bp = BuildingPosition(
        building: 'West',
        floor: '2',
        room: '201-A',
        roomBuildingPosition: 'should-not-appear',
      );
      final locationWithBP = Location(
        containerId: 'test-bp-ro',
        id: 'loc-ro',
        buildingPosition: bp,
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationWithBP, id: 'test-bp-ro');
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
        await harness.viewModel.load('test-bp-ro');
      });
      await pumpSettle(tester);

      expect(find.text('West, 2, 201-A'), findsOneWidget);
      expect(find.text('should-not-appear'), findsNothing);
      expect(find.text('Room Building Position'), findsOneWidget);

      final allTextFields = tester.widgetList<TextField>(
        find.byType(TextField),
      );
      final textFieldValues =
          allTextFields.map((tf) => tf.controller?.text ?? '').toSet();
      expect(textFieldValues.contains('West, 2, 201-A'), isFalse);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_12 — Edit building field propagates to roomBuildingPosition
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_12 shouldEditBuildingFieldAndPropagateToComputedField',
        (tester) async {
      const bp = BuildingPosition(
        building: 'Alpha',
        floor: '1',
        room: 'R01',
      );
      final locationWithBP = Location(
        containerId: 'test-edit-bp',
        id: 'loc-edit-bp',
        buildingPosition: bp,
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationWithBP, id: 'test-edit-bp');
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
        await harness.viewModel.load('test-edit-bp');
      });
      await pumpSettle(tester);

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Alpha, 1, R01'), findsOneWidget);

      final updatedBp = BuildingPosition(
        building: 'Bravo',
        floor: '1',
        room: 'R01',
      );
      final updatedLoc = Location(
        containerId: 'test-edit-bp',
        id: 'loc-edit-bp',
        buildingPosition: updatedBp,
      );

      await tester.runAsync(() async {
        await harness.viewModel.update(updatedLoc, recordId: 'test-edit-bp');
      });
      await pumpSettle(tester);

      expect(find.text('Bravo'), findsOneWidget);
      expect(find.text('Bravo, 1, R01'), findsOneWidget);
      expect(find.text('Alpha, 1, R01'), findsNothing);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_13 — Persistence integration round-trip
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_13 shouldPreserveBuildingPositionOnPersistenceRoundTrip',
        (tester) async {
      const bp = BuildingPosition(
        building: 'TowerA',
        floor: '7',
        room: '700',
        roomBuildingPosition: 'TowerA/7/700',
      );
      final locationWithBP = Location(
        containerId: 'test-roundtrip',
        id: 'loc-roundtrip',
        name: 'Roundtrip Location',
        buildingPosition: bp,
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.viewModel.save(locationWithBP, recordId: 'test-roundtrip');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );
      await pumpSettle(tester);

      expect(find.text('TowerA'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('700'), findsOneWidget);
      expect(find.text('TowerA, 7, 700'), findsOneWidget);

      await tester.runAsync(() async {
        await harness.viewModel.load('nonexistent');
      });
      await pumpSettle(tester);

      await tester.runAsync(() async {
        await harness.viewModel.load('test-roundtrip');
      });
      await pumpSettle(tester);

      expect(find.text('Building'), findsOneWidget);
      expect(find.text('Floor'), findsOneWidget);
      expect(find.text('Room'), findsOneWidget);
      expect(find.text('Room Building Position'), findsOneWidget);

      expect(find.text('TowerA'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('700'), findsOneWidget);
      expect(find.text('TowerA, 7, 700'), findsOneWidget);
    });

    // ---------------------------------------------------------------------------
    // SCENARIO_14 — BuildingPosition preserved when editing non-BP field (Name)
    // ---------------------------------------------------------------------------
    testWidgets(
        'BDD_SCENARIO_14 shouldPreserveBuildingPositionWhenEditingNonBPField',
        (tester) async {
      const bp = BuildingPosition(
        building: 'B',
        floor: '3',
        room: '302',
      );
      final locationWithBP = Location(
        containerId: 'test-regression-bp',
        id: 'loc-regression-bp',
        name: 'Original Name',
        buildingPosition: bp,
      );

      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(locationWithBP, id: 'test-regression-bp');
        await harness.viewModel.load('test-regression-bp');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationInventoryPropertyWidget(
                viewModel: harness.viewModel),
          ),
        ),
      );
      await pumpSettle(tester);

      expect(harness.viewModel.model?.buildingPosition?.building, equals('B'));

      final widget = tester.widget<LocationInventoryPropertyWidget>(
        find.byType(LocationInventoryPropertyWidget),
      );
      final descriptor = widget.typeDescriptor;
      final nameField =
          descriptor.fields.firstWhere((f) => f.key == kFieldName);
      final currentModel = harness.viewModel.model!;

      await tester.runAsync(() async {
        final result = nameField.valueWriter!.call(currentModel, 'Updated Name');
        final updated = result as Location;

        expect(
          updated.buildingPosition?.building,
          equals('B'),
          reason:
              'BuildingPosition should be preserved after editing non-BP field',
        );
      });
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
