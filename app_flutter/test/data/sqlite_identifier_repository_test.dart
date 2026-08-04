import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/repositories/identifier_repository.dart';
import 'package:app_flutter/data/repositories/sqlite_identifier_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late IdentifierRepository repository;

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE identifier_types (
          container_id TEXT PRIMARY KEY,
          object_identifier TEXT NOT NULL,
          object_identifier_128 TEXT NOT NULL,
          uuid TEXT NOT NULL,
          yang_identifier TEXT NOT NULL
        )
      ''');
    });
    repository = SqliteIdentifierRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SqliteIdentifierRepository Tests', () {
    test('saves and fetches IdentifierTypes record', () async {
      const record = IdentifierTypes(
        containerId: 'id-001',
        objectIdentifier: '1.3.6.1.4.1',
        objectIdentifier128: '1.3.6.1.4.1.100',
        uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
        yangIdentifier: 'interfaces',
      );

      final saveResult = await repository.save(record);
      expect(saveResult.isSuccess, isTrue);

      final fetchResult = await repository.fetch('id-001');
      expect(fetchResult.isSuccess, isTrue);
      final fetched = fetchResult.valueOrNull!;
      expect(fetched.containerId, equals('id-001'));
      expect(fetched.objectIdentifier, equals('1.3.6.1.4.1'));
      expect(fetched.objectIdentifier128, equals('1.3.6.1.4.1.100'));
      expect(fetched.uuid, equals('f81d4fae-7dec-11d0-a765-00a0c91e6bf6'));
      expect(fetched.yangIdentifier, equals('interfaces'));
    });

    test('updates existing IdentifierTypes record in SQLite', () async {
      const initial = IdentifierTypes(
        containerId: 'id-001',
        objectIdentifier: '1.3.6.1.4.1',
        objectIdentifier128: '1.3.6.1.4.1.100',
        uuid: 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
        yangIdentifier: 'interfaces',
      );
      await repository.save(initial);

      const updated = IdentifierTypes(
        containerId: 'id-001',
        objectIdentifier: '2.999.1',
        objectIdentifier128: '2.999.1.200',
        uuid: 'a0b1c2d3-e4f5-6a7b-8c9d-0e1f2a3b4c5d',
        yangIdentifier: 'xml-element',
      );
      final updateResult = await repository.update(updated);
      expect(updateResult.isSuccess, isTrue);

      final fetchResult = await repository.fetch('id-001');
      expect(fetchResult.isSuccess, isTrue);
      expect(fetchResult.valueOrNull!.yangIdentifier, equals('xml-element'));
      expect(fetchResult.valueOrNull!.objectIdentifier, equals('2.999.1'));
    });
  });
}
