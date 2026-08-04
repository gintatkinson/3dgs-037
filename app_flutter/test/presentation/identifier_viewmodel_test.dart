import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/presentation/viewmodels/identifier_viewmodel.dart';

class MockIdentifierRepository implements IdentifierRepository {
  IdentifierTypes? record;
  bool shouldFail = false;

  @override
  Future<Result<IdentifierTypes>> fetch(String containerId) async {
    if (shouldFail) return const Failure('FETCH_ERROR', 'Mock failure');
    if (record == null) return const Failure('NOT_FOUND', 'Not found');
    return Success(record!);
  }

  @override
  Future<Result<void>> save(IdentifierTypes newRecord) async {
    if (shouldFail) return const Failure('SAVE_ERROR', 'Mock failure');
    record = newRecord;
    return const Success(null);
  }

  @override
  Future<Result<void>> update(IdentifierTypes newRecord) async {
    return save(newRecord);
  }
}

void main() {
  late MockIdentifierRepository repository;
  late IdentifierViewModel viewModel;

  setUp(() {
    repository = MockIdentifierRepository();
    viewModel = IdentifierViewModel(repository);
  });

  group('IdentifierViewModel Tests', () {
    test('loads record from repository', () async {
      repository.record = const IdentifierTypes(
        containerId: 'id-001',
        objectIdentifier: '1.3.6.1.4.1',
        objectIdentifier128: '1.3.6.1.4.1.100',
        uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
        yangIdentifier: 'interfaces',
      );

      await viewModel.load('id-001');

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.model, isNotNull);
      expect(viewModel.model!.objectIdentifier, equals('1.3.6.1.4.1'));
    });

    test('updates objectIdentifier when valid', () async {
      await viewModel.load('id-001');

      final result = await viewModel.updateObjectIdentifier('2.999.1');
      expect(result.isSuccess, isTrue);
      expect(viewModel.model!.objectIdentifier, equals('2.999.1'));
    });

    test('updates and normalizes UUID to canonical lowercase', () async {
      await viewModel.load('id-001');

      const upperUuid = 'F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6';
      final result = await viewModel.updateUuid(upperUuid);
      expect(result.isSuccess, isTrue);
      expect(viewModel.model!.uuid, equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
    });

    test('rejects invalid YANG identifier without mutating state', () async {
      await viewModel.load('id-001');

      final result = await viewModel.updateYangIdentifier('123-invalid');
      expect(result.isFailure, isTrue);
      expect(result.errorCodeOrNull, equals('INVALID_YANG_IDENTIFIER_START'));
      expect(viewModel.model!.yangIdentifier, equals('interfaces'));
    });
  });
}
