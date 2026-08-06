import 'dart:io';

import 'package:app_flutter/data/repositories/sqlite_ip_address_repository.dart';
import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SqliteIpAddressRepository', () {
    late Database db;
    late SqliteIpAddressRepository repo;

    setUp(() async {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      repo = SqliteIpAddressRepository(db);
      await repo.initDatabase();
    });

    tearDown(() async {
      await db.close();
    });

    final testRecord = IpAddressTypes(
      containerId: 'test-1',
      ipVersion: 1,
      ipAddress: '192.168.1.1',
      ipv4Address: '192.168.1.1',
      ipv6Address: '2001:db8::1',
      ipPrefix: '192.168.1.0/24',
      ipv4Prefix: '192.168.1.0/24',
      ipv6Prefix: '2001:db8::/64',
      ipAddressNoZone: '10.0.0.1',
      ipv4AddressNoZone: '10.0.0.1',
      ipv6AddressNoZone: 'fe80::1',
    );

    test('shouldSaveAndFetchRecord', () async {
      final saveResult = await repo.save(testRecord, id: 'test-1');
      expect(saveResult.isSuccess, isTrue);
      final saved = (saveResult as Success<IpAddressTypes>).value;
      expect(saved, equals(testRecord));

      final fetchResult = await repo.fetch(id: 'test-1');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<IpAddressTypes>).value;
      expect(fetched, equals(testRecord));
    });

    test('shouldUpdateRecord', () async {
      await repo.save(testRecord, id: 'test-2');

      final updated = IpAddressTypes(
        containerId: 'test-2',
        ipVersion: 2,
        ipv6Address: '::1',
        ipAddressNoZone: '::1',
        ipv6AddressNoZone: '::1',
        ipAddress: '::1',
      );
      final updateResult = await repo.update(updated, id: 'test-2');
      expect(updateResult.isSuccess, isTrue);
      expect((updateResult as Success<IpAddressTypes>).value.ipVersion,
          equals(2));

      final fetchResult = await repo.fetch(id: 'test-2');
      expect(fetchResult.isSuccess, isTrue);
      final fetched2 = (fetchResult as Success<IpAddressTypes>).value;
      expect(fetched2.ipVersion, equals(2));
      expect(fetched2.ipv6Address, equals('::1'));
    });

    test(
        'shouldReturnInstanceNotFoundErrorWhenFetchingNonexistentRecord',
        () async {
      final result = await repo.fetch(id: 'nonexistent');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<IpAddressTypes>).error;
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
          (fetchResult as Success<IpAddressTypes>).value, equals(testRecord));
    });

    test('shouldRoundtripNullableFieldsCorrectly', () async {
      final sparseRecord = IpAddressTypes(
        containerId: 'sparse',
        ipVersion: 0,
        ipAddress: '127.0.0.1',
      );
      await repo.save(sparseRecord, id: 'sparse');
      final fetchResult = await repo.fetch(id: 'sparse');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = (fetchResult as Success<IpAddressTypes>).value;
      expect(fetched.ipAddress, equals('127.0.0.1'));
      expect(fetched.ipv4Address, isNull);
      expect(fetched.ipv6Address, isNull);
    });
  });
}
