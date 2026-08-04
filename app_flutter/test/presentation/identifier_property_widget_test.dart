import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/presentation/viewmodels/identifier_viewmodel.dart';
import 'package:app_flutter/presentation/widgets/identifier_property_widget.dart';

class FakeIdentifierRepository implements IdentifierRepository {
  IdentifierTypes record = const IdentifierTypes(
    containerId: 'id-001',
    objectIdentifier: '1.3.6.1.4.1',
    objectIdentifier128: '1.3.6.1.4.1.100',
    uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
    yangIdentifier: 'interfaces',
  );

  @override
  Future<Result<IdentifierTypes>> fetch(String containerId) async {
    return Success(record);
  }

  @override
  Future<Result<void>> save(IdentifierTypes newRecord) async {
    record = newRecord;
    return const Success(null);
  }

  @override
  Future<Result<void>> update(IdentifierTypes newRecord) async {
    return save(newRecord);
  }
}

void main() {
  late FakeIdentifierRepository repository;
  late IdentifierViewModel viewModel;

  setUp(() async {
    repository = FakeIdentifierRepository();
    viewModel = IdentifierViewModel(repository);
    await viewModel.load('id-001');
  });

  group('IdentifierPropertyWidget BDD User Story Widget Tests', () {
    testWidgets('Renders identifier fields in PropertyGrid layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifierPropertyWidget(viewModel: viewModel),
          ),
        ),
      );

      expect(find.text('Object Identifier (OID)'), findsOneWidget);
      expect(find.text('1.3.6.1.4.1'), findsOneWidget);
      expect(find.text('UUID (RFC 9562)'), findsOneWidget);
      expect(find.text('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'), findsOneWidget);
      expect(find.text('YANG Identifier'), findsOneWidget);
      expect(find.text('interfaces'), findsOneWidget);
    });

    testWidgets('BDD Flow: User edits OID -> ViewModel Action -> State Change -> LUI Render', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifierPropertyWidget(viewModel: viewModel),
          ),
        ),
      );

      // Tap on OID text field and enter valid OID
      final oidFinder = find.widgetWithText(TextField, '1.3.6.1.4.1');
      expect(oidFinder, findsOneWidget);

      await tester.enterText(oidFinder, '2.999.1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert ViewModel state changed
      expect(viewModel.model!.objectIdentifier, equals('2.999.1'));
      expect(repository.record.objectIdentifier, equals('2.999.1'));
    });

    testWidgets('BDD Flow: User enters uppercase UUID -> ViewModel normalizes to canonical lowercase in LUI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IdentifierPropertyWidget(viewModel: viewModel),
          ),
        ),
      );

      final uuidFinder = find.widgetWithText(TextField, 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6');
      expect(uuidFinder, findsOneWidget);

      const upperUuid = 'F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6';
      await tester.enterText(uuidFinder, upperUuid);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert normalized canonical lowercase rendered
      expect(viewModel.model!.uuid, equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
    });
  });
}
