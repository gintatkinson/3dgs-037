import 'dart:async';

import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/repositories/domain_name_and_host_repository.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:app_flutter/presentation/viewmodels/domain_name_and_host_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestRepository implements DomainNameAndHostRepository {
  final List<String> calls = [];
  Future<Result<DomainNameAndHostTypes>> Function()? _fetchFactory;
  Result<DomainNameAndHostTypes>? saveResult;
  Result<DomainNameAndHostTypes>? updateResult;
  Result<void>? initResult;

  @override
  Future<Result<void>> initDatabase() async {
    calls.add('initDatabase');
    return initResult ?? const Result.success(null);
  }

  @override
  Future<Result<DomainNameAndHostTypes>> save(
      DomainNameAndHostTypes record,
      {String id = 'default'}) async {
    calls.add('save:$id');
    return saveResult ?? Result.success(record);
  }

  @override
  Future<Result<DomainNameAndHostTypes>> fetch({String id = 'default'}) async {
    calls.add('fetch:$id');
    if (_fetchFactory != null) return _fetchFactory!();
    return Result.failure(InstanceNotFoundError(instanceId: id));
  }

  @override
  Future<Result<DomainNameAndHostTypes>> update(
      DomainNameAndHostTypes record,
      {String id = 'default'}) async {
    calls.add('update:$id');
    return updateResult ?? Result.success(record);
  }
}

void main() {
  late _TestRepository repo;
  late DomainNameAndHostViewModel viewModel;

  const testRecord = DomainNameAndHostTypes(
    containerId: 'test',
    domainName: 'example.com',
    host: '192.0.2.1',
    uri: 'https://example.com',
  );

  setUp(() {
    repo = _TestRepository();
    viewModel = DomainNameAndHostViewModel(repo);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('DomainNameAndHostViewModel', () {
    test('should_expose_loading_state_during_load', () async {
      final completer = Completer<Result<DomainNameAndHostTypes>>();
      repo._fetchFactory = () => completer.future;

      final future = viewModel.load('test-1');
      await Future.microtask(() {});
      expect(viewModel.isLoading, isTrue);

      completer.complete(Result.success(testRecord));
      await future;
      expect(viewModel.isLoading, isFalse);
    });

    test('should_emit_model_after_successful_load', () async {
      repo._fetchFactory = () async => Result.success(testRecord);

      await viewModel.load('test-1');

      expect(viewModel.model, equals(testRecord));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('should_emit_error_message_on_load_failure', () async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'missing'));

      await viewModel.load('missing');

      expect(viewModel.model, isNull);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, contains('missing'));
    });

    test('should_save_new_record', () async {
      await viewModel.save(testRecord, recordId: 'new-1');

      expect(repo.calls, contains('save:new-1'));
      expect(viewModel.model, equals(testRecord));
      expect(viewModel.errorMessage, isNull);
    });

    test('should_update_existing_record', () async {
      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('test-1');

      const updated = DomainNameAndHostTypes(
        containerId: 'test-1',
        domainName: 'updated.org',
        host: '2001:db8::1',
        uri: 'https://updated.org',
      );
      repo.updateResult = Result.success(updated);

      await viewModel.update(updated, recordId: 'test-1');

      expect(repo.calls, contains('update:test-1'));
      expect(viewModel.model?.domainName, equals('updated.org'));
      expect(viewModel.model?.host, equals('2001:db8::1'));
    });

    test('should_clear_error_message_on_recovery', () async {
      repo._fetchFactory = () async =>
          Result.failure(InstanceNotFoundError(instanceId: 'bad'));
      await viewModel.load('bad');
      expect(viewModel.errorMessage, isNotNull);

      repo._fetchFactory = () async => Result.success(testRecord);
      await viewModel.load('good');
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.model, isNotNull);
    });
  });
}
