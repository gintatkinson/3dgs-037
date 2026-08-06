import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_velocity_repository.dart';
import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/presentation/viewmodels/velocity_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/velocity_property_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Velocity;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> pumpSettle(WidgetTester tester) async {
  for (int i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

class _VelocityTestHarness {
  late Database db;
  late SqliteVelocityRepository repo;
  late VelocityViewModel viewModel;

  Future<void> init() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    repo = SqliteVelocityRepository(db);
    await repo.initDatabase();
    viewModel = VelocityViewModel(repo);
  }

  Future<void> dispose() async {
    viewModel.dispose();
    await db.close();
  }
}

void main() {
  group('VelocityPropertyWidget BDD', () {
    late _VelocityTestHarness harness;

    const testRecord = Velocity(
      containerId: 'test-1',
      vNorth: 3.0,
      vEast: 4.0,
      vUp: 0.5,
    );

    setUp(() {
      harness = _VelocityTestHarness();
    });

    tearDown(() async {
      await harness.dispose();
    });

    testWidgets(
        'BDD_SCENARIO_1 shouldDisplayCorrectSpeedAndHeadingAndEditableReadOnlyFields',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testRecord, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('5.0'), findsOneWidget);
      expect(find.textContaining('0.927295'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('SCENARIO_2 shouldDisplayVNorthValueFromViewModel',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testRecord, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('v-north (m/s)'), findsOneWidget);
      expect(find.text('3.0'), findsOneWidget);
    });

    testWidgets('SCENARIO_3 shouldDisplaySpeedComputedFromVNorthAndVEast',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testRecord, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('Speed (m/s)'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
    });

    testWidgets('SCENARIO_4 shouldDisplayHeadingComputedFromVNorthAndVEast',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testRecord, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('Heading (rad)'), findsOneWidget);
      expect(find.textContaining('0.927295'), findsOneWidget);
    });

    testWidgets('SCENARIO_5 shouldShowLoadingIndicatorWhenViewModelIsLoading',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        harness.viewModel.load('test-1');
      });
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SCENARIO_6 shouldRenderEditableTextFieldsForVelocityComponents',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testRecord, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('v-north (m/s)'), findsOneWidget);
      expect(find.text('v-east (m/s)'), findsOneWidget);
      expect(find.text('v-up (m/s)'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets(
        'SCENARIO_7 shouldRenderReadOnlyTextForDerivedSpeedAndHeading',
        (tester) async {
      await tester.runAsync(() async {
        await harness.init();
        await harness.repo.save(testRecord, id: 'test-1');
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VelocityPropertyWidget(viewModel: harness.viewModel),
          ),
        ),
      );

      await tester.runAsync(() async {
        await harness.viewModel.load('test-1');
      });
      await pumpSettle(tester);

      expect(find.text('Speed (m/s)'), findsOneWidget);
      expect(find.text('Heading (rad)'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(3));

      final allTextFields = tester.widgetList<TextField>(
        find.byType(TextField),
      );
      for (final tf in allTextFields) {
        expect(tf.controller?.text, isNot(contains('5.0')));
        expect(tf.controller?.text, isNot(contains('0.927295')));
      }
    });
  });
}
