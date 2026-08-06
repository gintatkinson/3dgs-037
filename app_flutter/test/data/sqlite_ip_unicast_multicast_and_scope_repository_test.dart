import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_ip_unicast_multicast_and_scope_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteIpUnicastMulticastAndScopeRepository', () {
    late Database db;
    late SqliteIpUnicastMulticastAndScopeRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteIpUnicastMulticastAndScopeRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = IpUnicastMulticastAndScopeTypes(
      containerId: 'test-1',
      ipv6FlowLabel: 524287,
      dscp: 46,
      ipUnicastAddress: '192.168.1.1',
      ipv4UnicastAddress: '192.168.1.1',
      ipv6UnicastAddress: '2001:db8::1',
      ipMulticastAddress: '224.0.0.1',
      ipv4MulticastAddress: '224.0.0.1',
      ipv6MulticastAddress: 'ff02::1',
      scopeType: 'link-local',
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved =
          (saveResult as Success<IpUnicastMulticastAndScopeTypes>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<IpUnicastMulticastAndScopeTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      const updated = IpUnicastMulticastAndScopeTypes(
        containerId: 'test-2',
        ipv6FlowLabel: 100,
        dscp: 10,
        ipv6MulticastAddress: 'ff0e::1',
        scopeType: 'global',
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      final resultVal =
          (updateResult as Success<IpUnicastMulticastAndScopeTypes>).value;
      expect(resultVal.dscp, equals(10));

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<IpUnicastMulticastAndScopeTypes>).value;
      expect(fetched.dscp, equals(10));
      expect(fetched.ipv6MulticastAddress, equals('ff0e::1'));
    });

    test('shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error =
          (result as Failure<IpUnicastMulticastAndScopeTypes>).error;
      expect(error, isA<InstanceNotFoundError>());
      expect(
          (error as InstanceNotFoundError).instanceId, equals('nonexistent'));
    });

    test('shouldUseDefaultIdWhenNotSpecified', () async {
      final saveResult = await repo.save(testRecord);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repo.fetch();
      expect(fetchResult.isSuccess, isTrue);
      expect(
        (fetchResult as Success<IpUnicastMulticastAndScopeTypes>).value,
        equals(testRecord),
      );
    });

    test('shouldRoundtripNullableFieldsCorrectly', () async {
      const sparseRecord = IpUnicastMulticastAndScopeTypes(
        containerId: 'sparse',
        ipv6FlowLabel: 42,
        dscp: 0,
        ipv6MulticastAddress: 'ff02::1',
      );
      await repo.save(sparseRecord, id: 'sparse');
      final fetchResult = await repo.fetch(id: 'sparse');
      expect(fetchResult.isSuccess, isTrue);
      final fetched =
          (fetchResult as Success<IpUnicastMulticastAndScopeTypes>).value;
      expect(fetched.ipv6FlowLabel, equals(42));
      expect(fetched.ipv4UnicastAddress, isNull);
      expect(fetched.ipv6UnicastAddress, isNull);
    });
  });
}
