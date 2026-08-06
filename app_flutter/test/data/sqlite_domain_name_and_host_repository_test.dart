import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_domain_name_and_host_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteDomainNameAndHostRepository', () {
    late Database db;
    late SqliteDomainNameAndHostRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteDomainNameAndHostRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = DomainNameAndHostTypes(
      containerId: 'test-1',
      domainName: 'example.com',
      host: '192.0.2.1',
      uri: 'https://example.com/path?q=1#section',
    );

    test('should_save_and_fetch_record', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<DomainNameAndHostTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('should_update_record', () async {
      await repo.save(testRecord, id: 'test-2');

      final updated = DomainNameAndHostTypes(
        containerId: 'test-2',
        domainName: 'updated.org',
        host: '2001:db8::1',
        uri: 'https://updated.org',
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<DomainNameAndHostTypes>).value;
      expect(fetched.domainName, equals('updated.org'));
      expect(fetched.host, equals('2001:db8::1'));
      expect(fetched.uri, equals('https://updated.org'));
    });

    test(
        'should_return_InstanceNotFoundError_when_fetching_nonexistent_record',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error =
          (result as Failure<DomainNameAndHostTypes>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('should_use_default_id_when_not_specified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect((fetchResult as Success<DomainNameAndHostTypes>).value,
          equals(testRecord));
    });

    test('should_roundtrip_nullable_fields_correctly', () async {
      const sparseRecord =
          DomainNameAndHostTypes(domainName: 'localhost');
      await repo.save(sparseRecord, id: 'sparse');
      final fetchResult = await repo.fetch(id: 'sparse');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<DomainNameAndHostTypes>).value;
      expect(fetched.domainName, equals('localhost'));
      expect(fetched.host, '');
      expect(fetched.uri, '');
    });

    test('should_fail_to_update_nonexistent_record', () async {
      final result = await repo.update(testRecord, id: 'ghost');
      expect(result.isFailure, isTrue);
      expect(
          (result as Failure<DomainNameAndHostTypes>).error,
          isA<InstanceNotFoundError>());
    });
  });
}
