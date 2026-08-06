import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/date_and_time_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParsedDateTime', () {
    test('should create instance with all fields', () {
      final parsed = ParsedDateTime(
        year: 2026,
        month: 8,
        day: 4,
        hour: 0,
        minute: 23,
        second: 12,
        fractionalSecond: 0.123456,
        timezoneOffset: '+08:00',
        timezoneIsZ: false,
        isLeapSecond: false,
      );
      expect(parsed.year, equals(2026));
      expect(parsed.month, equals(8));
      expect(parsed.day, equals(4));
      expect(parsed.hour, equals(0));
      expect(parsed.minute, equals(23));
      expect(parsed.second, equals(12));
      expect(parsed.fractionalSecond, equals(0.123456));
      expect(parsed.timezoneOffset, equals('+08:00'));
      expect(parsed.timezoneIsZ, isFalse);
      expect(parsed.isLeapSecond, isFalse);
    });

    test('should have value equality', () {
      final a = ParsedDateTime(
        year: 2026, month: 8, day: 4,
        hour: 0, minute: 23, second: 12,
        timezoneOffset: '+08:00',
      );
      final b = ParsedDateTime(
        year: 2026, month: 8, day: 4,
        hour: 0, minute: 23, second: 12,
        timezoneOffset: '+08:00',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should support copyWith', () {
      final original = ParsedDateTime(
        year: 2026, month: 8, day: 4,
        hour: 0, minute: 23, second: 12,
      );
      final copy = original.copyWith(day: 15, hour: 10);
      expect(copy.year, equals(2026));
      expect(copy.day, equals(15));
      expect(copy.hour, equals(10));
      expect(copy.minute, equals(23));
      expect(copy.second, equals(12));
    });

    test('should handle leap second flag', () {
      final leap = ParsedDateTime(
        year: 2023, month: 12, day: 31,
        hour: 23, minute: 59, second: 60,
        isLeapSecond: true,
      );
      expect(leap.isLeapSecond, isTrue);
      expect(leap.second, equals(60));
    });

    test('should distinguish Z from +00:00 timezone', () {
      final zTime = ParsedDateTime(
        year: 2026, month: 8, day: 4,
        hour: 0, minute: 0, second: 0,
        timezoneOffset: 'Z', timezoneIsZ: true,
      );
      final explicitUtc = ParsedDateTime(
        year: 2026, month: 8, day: 4,
        hour: 0, minute: 0, second: 0,
        timezoneOffset: '+00:00', timezoneIsZ: false,
      );
      expect(zTime, isNot(equals(explicitUtc)));
    });
  });

  group('DateAndTimeTypes Value Object', () {
    final defaultRecord = DateAndTimeTypes(
      containerId: 'default',
      dateAndTime: '2026-08-04T00:23:12+08:00',
      date: '2026-08-04',
      dateNoZone: '2026-08-04',
      time: '00:23:12+08:00',
      timeNoZone: '00:23:12',
      hours32: 100,
      minutes32: 6000,
      seconds32: 360000,
      centiseconds32: 36000000,
      milliseconds32: 360000000,
      microseconds32: 2147483000,
      microseconds64: 2400000000,
      nanoseconds32: 2000000000,
      nanoseconds64: 5000000000000,
      timeticks: 100,
      timestamp: 50,
    );

    test('should create instance with all 16 fields', () {
      expect(defaultRecord.containerId, equals('default'));
      expect(defaultRecord.dateAndTime, equals('2026-08-04T00:23:12+08:00'));
      expect(defaultRecord.date, equals('2026-08-04'));
      expect(defaultRecord.dateNoZone, equals('2026-08-04'));
      expect(defaultRecord.time, equals('00:23:12+08:00'));
      expect(defaultRecord.timeNoZone, equals('00:23:12'));
      expect(defaultRecord.hours32, equals(100));
      expect(defaultRecord.minutes32, equals(6000));
      expect(defaultRecord.seconds32, equals(360000));
      expect(defaultRecord.centiseconds32, equals(36000000));
      expect(defaultRecord.milliseconds32, equals(360000000));
      expect(defaultRecord.microseconds32, equals(2147483000));
      expect(defaultRecord.microseconds64, equals(2400000000));
      expect(defaultRecord.nanoseconds32, equals(2000000000));
      expect(defaultRecord.nanoseconds64, equals(5000000000000));
      expect(defaultRecord.timeticks, equals(100));
      expect(defaultRecord.timestamp, equals(50));
    });

    test('should have value equality', () {
      final a = DateAndTimeTypes(
        containerId: 'test',
        dateAndTime: '', date: '', dateNoZone: '',
        time: '', timeNoZone: '',
        hours32: 0, minutes32: 0, seconds32: 0,
        centiseconds32: 0, milliseconds32: 0,
        microseconds32: 0, microseconds64: 0,
        nanoseconds32: 0, nanoseconds64: 0,
        timeticks: 0, timestamp: 0,
      );
      final b = DateAndTimeTypes(
        containerId: 'test',
        dateAndTime: '', date: '', dateNoZone: '',
        time: '', timeNoZone: '',
        hours32: 0, minutes32: 0, seconds32: 0,
        centiseconds32: 0, milliseconds32: 0,
        microseconds32: 0, microseconds64: 0,
        nanoseconds32: 0, nanoseconds64: 0,
        timeticks: 0, timestamp: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should support copyWith', () {
      final copy = defaultRecord.copyWith(hours32: 500, timeticks: 200);
      expect(copy.hours32, equals(500));
      expect(copy.timeticks, equals(200));
      expect(copy.dateAndTime, equals(defaultRecord.dateAndTime));
      expect(copy.minutes32, equals(defaultRecord.minutes32));
    });

    test('constants should match spec bounds', () {
      expect(DateAndTimeTypes.kMaxUint32, equals(4294967295));
      expect(DateAndTimeTypes.kModUint32, equals(4294967296));
      expect(DateAndTimeTypes.kMinInt32, equals(-2147483648));
      expect(DateAndTimeTypes.kMaxInt32, equals(2147483647));
      expect(DateAndTimeTypes.kMinInt64, equals(-9223372036854775808));
      expect(DateAndTimeTypes.kMaxInt64, equals(9223372036854775807));
    });
  });

  group('validateDateAndTime', () {
    test('should accept valid RFC 3339 datetime with timezone', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T00:23:12.123456+08:00',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should accept datetime with Z suffix', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T00:00:00Z',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should accept datetime with +00:00', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T00:00:00+00:00',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should accept leap second 60', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2023-12-31T23:59:60Z',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should accept negative timezone offset -13:59', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:00:00-13:59',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should accept positive timezone offset +14:00', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:00:00+14:00',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should accept datetime without fractional seconds', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:00:00+08:00',
      );
      expect(result.isSuccess, isTrue);
    });

    test('should reject empty string', () {
      final result = DateAndTimeTypes.validateDateAndTime('');
      expect(result.isFailure, isTrue);
    });

    test('should reject invalid date February 30', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-02-30T12:00:00Z',
      );
      expect(result.isFailure, isTrue);
    });

    test('should reject negative year', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '-0001-01-01T00:00:00Z',
      );
      expect(result.isFailure, isTrue);
    });

    test('should reject timezone -14:00 (out of range)', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:00:00-14:00',
      );
      expect(result.isFailure, isTrue);
    });

    test('should reject timezone +14:01 (out of range)', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:00:00+14:01',
      );
      expect(result.isFailure, isTrue);
    });

    test('should reject hour 24', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T24:00:00Z',
      );
      expect(result.isFailure, isTrue);
    });

    test('should reject minute 60', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:60:00Z',
      );
      expect(result.isFailure, isTrue);
    });

    test('should reject second 61', () {
      final result = DateAndTimeTypes.validateDateAndTime(
        '2026-08-04T12:00:61Z',
      );
      expect(result.isFailure, isTrue);
    });
  });

  group('validateDate', () {
    test('should accept valid date with timezone', () {
      final result = DateAndTimeTypes.validateDate('2026-08-04+08:00');
      expect(result.isSuccess, isTrue);
    });

    test('should accept date with Z suffix', () {
      final result = DateAndTimeTypes.validateDate('2026-08-04Z');
      expect(result.isSuccess, isTrue);
    });

    test('should accept date without timezone', () {
      final result = DateAndTimeTypes.validateDate('2026-08-04');
      expect(result.isSuccess, isTrue);
    });

    test('should reject February 30', () {
      final result = DateAndTimeTypes.validateDate('2026-02-30');
      expect(result.isFailure, isTrue);
    });

    test('should reject month 13', () {
      final result = DateAndTimeTypes.validateDate('2026-13-01');
      expect(result.isFailure, isTrue);
    });

    test('should reject day 32', () {
      final result = DateAndTimeTypes.validateDate('2026-01-32');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateDateNoZone', () {
    test('should accept valid date without timezone', () {
      final result = DateAndTimeTypes.validateDateNoZone('2026-08-04');
      expect(result.isSuccess, isTrue);
    });

    test('should reject date with timezone offset', () {
      final result = DateAndTimeTypes.validateDateNoZone('2026-08-04+08:00');
      expect(result.isFailure, isTrue);
    });

    test('should reject date with Z suffix', () {
      final result = DateAndTimeTypes.validateDateNoZone('2026-08-04Z');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateTime', () {
    test('should accept valid time with timezone', () {
      final result = DateAndTimeTypes.validateTime('00:23:12+08:00');
      expect(result.isSuccess, isTrue);
    });

    test('should accept time with fractional seconds', () {
      final result = DateAndTimeTypes.validateTime('00:23:12.123456+08:00');
      expect(result.isSuccess, isTrue);
    });

    test('should accept time with Z suffix', () {
      final result = DateAndTimeTypes.validateTime('00:00:00Z');
      expect(result.isSuccess, isTrue);
    });

    test('should accept leap second 60', () {
      final result = DateAndTimeTypes.validateTime('23:59:60Z');
      expect(result.isSuccess, isTrue);
    });

    test('should reject hour 24', () {
      final result = DateAndTimeTypes.validateTime('24:00:00Z');
      expect(result.isFailure, isTrue);
    });

    test('should reject minute 60', () {
      final result = DateAndTimeTypes.validateTime('12:60:00Z');
      expect(result.isFailure, isTrue);
    });

    test('should reject second 61', () {
      final result = DateAndTimeTypes.validateTime('12:00:61Z');
      expect(result.isFailure, isTrue);
    });
  });

  group('validateTimeNoZone', () {
    test('should accept valid time without timezone', () {
      final result = DateAndTimeTypes.validateTimeNoZone('00:23:12');
      expect(result.isSuccess, isTrue);
    });

    test('should accept fractional seconds', () {
      final result = DateAndTimeTypes.validateTimeNoZone('00:23:12.123456');
      expect(result.isSuccess, isTrue);
    });

    test('should accept leap second 60', () {
      final result = DateAndTimeTypes.validateTimeNoZone('23:59:60');
      expect(result.isSuccess, isTrue);
    });

    test('should reject time with timezone', () {
      final result = DateAndTimeTypes.validateTimeNoZone('00:23:12+08:00');
      expect(result.isFailure, isTrue);
    });

    test('should reject time with Z', () {
      final result = DateAndTimeTypes.validateTimeNoZone('00:23:12Z');
      expect(result.isFailure, isTrue);
    });
  });

  group('Integer validators', () {
    group('validateHours32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateHours32(0).isSuccess, isTrue);
      });
      test('should accept max int32', () {
        expect(
          DateAndTimeTypes.validateHours32(DateAndTimeTypes.kMaxInt32).isSuccess,
          isTrue,
        );
      });
      test('should accept min int32', () {
        expect(
          DateAndTimeTypes.validateHours32(DateAndTimeTypes.kMinInt32).isSuccess,
          isTrue,
        );
      });
    });

    group('validateMinutes32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateMinutes32(0).isSuccess, isTrue);
      });
    });

    group('validateSeconds32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateSeconds32(0).isSuccess, isTrue);
      });
    });

    group('validateCentiseconds32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateCentiseconds32(0).isSuccess, isTrue);
      });
    });

    group('validateMilliseconds32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateMilliseconds32(0).isSuccess, isTrue);
      });
    });

    group('validateMicroseconds32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateMicroseconds32(0).isSuccess, isTrue);
      });
      test('should accept 2147483647 (max int32)', () {
        expect(
          DateAndTimeTypes.validateMicroseconds32(DateAndTimeTypes.kMaxInt32)
              .isSuccess,
          isTrue,
        );
      });
      test('should accept -2147483648 (min int32)', () {
        expect(
          DateAndTimeTypes.validateMicroseconds32(DateAndTimeTypes.kMinInt32)
              .isSuccess,
          isTrue,
        );
      });
    });

    group('validateMicroseconds64', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateMicroseconds64(0).isSuccess, isTrue);
      });
      test('should accept large 64-bit value', () {
        expect(
          DateAndTimeTypes.validateMicroseconds64(2400000000).isSuccess,
          isTrue,
        );
      });
    });

    group('validateNanoseconds32', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateNanoseconds32(0).isSuccess, isTrue);
      });
    });

    group('validateNanoseconds64', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateNanoseconds64(0).isSuccess, isTrue);
      });
      test('should accept large 64-bit value', () {
        expect(
          DateAndTimeTypes.validateNanoseconds64(5000000000000).isSuccess,
          isTrue,
        );
      });
      test('should accept min int64 boundary', () {
        expect(
          DateAndTimeTypes.validateNanoseconds64(DateAndTimeTypes.kMinInt64)
              .isSuccess,
          isTrue,
        );
      });
      test('should accept max int64 boundary', () {
        expect(
          DateAndTimeTypes.validateNanoseconds64(DateAndTimeTypes.kMaxInt64)
              .isSuccess,
          isTrue,
        );
      });
    });

    group('validateTimeticks', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateTimeticks(0).isSuccess, isTrue);
      });
      test('should accept 4294967295 (max timeticks)', () {
        expect(
          DateAndTimeTypes.validateTimeticks(DateAndTimeTypes.kMaxUint32)
              .isSuccess,
          isTrue,
        );
      });
      test('should reject -1', () {
        final result = DateAndTimeTypes.validateTimeticks(-1);
        expect(result.isFailure, isTrue);
      });
      test('should reject 4294967296 (overflow)', () {
        final result = DateAndTimeTypes.validateTimeticks(4294967296);
        expect(result.isFailure, isTrue);
      });
    });

    group('validateTimestamp', () {
      test('should accept 0', () {
        expect(DateAndTimeTypes.validateTimestamp(0).isSuccess, isTrue);
      });
      test('should accept max uint32', () {
        expect(
          DateAndTimeTypes.validateTimestamp(DateAndTimeTypes.kMaxUint32)
              .isSuccess,
          isTrue,
        );
      });
      test('should reject -1', () {
        final result = DateAndTimeTypes.validateTimestamp(-1);
        expect(result.isFailure, isTrue);
      });
    });
  });

  group('Timezone helpers', () {
    group('isValidTimezoneOffset', () {
      test('Z is valid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('Z'), isTrue);
      });
      test('+00:00 is valid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('+00:00'), isTrue);
      });
      test('+08:00 is valid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('+08:00'), isTrue);
      });
      test('+14:00 is valid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('+14:00'), isTrue);
      });
      test('-13:59 is valid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('-13:59'), isTrue);
      });
      test('-14:00 is invalid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('-14:00'), isFalse);
      });
      test('+15:00 is invalid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('+15:00'), isFalse);
      });
      test('+14:01 is invalid', () {
        expect(DateAndTimeTypes.isValidTimezoneOffset('+14:01'), isFalse);
      });
    });

    group('hasKnownTimezoneReference', () {
      test('+00:00 has known reference per RFC 9557', () {
        expect(
          DateAndTimeTypes.hasKnownTimezoneReference('2026-08-04T00:00:00+00:00'),
          isTrue,
        );
      });
      test('Z has unknown reference per RFC 9557', () {
        expect(
          DateAndTimeTypes.hasKnownTimezoneReference('2026-08-04T00:00:00Z'),
          isFalse,
        );
      });
      test('+08:00 has known reference', () {
        expect(
          DateAndTimeTypes.hasKnownTimezoneReference('2026-08-04T00:00:00+08:00'),
          isTrue,
        );
      });
      test('no timezone has known reference', () {
        expect(
          DateAndTimeTypes.hasKnownTimezoneReference('2026-08-04T00:00:00'),
          isTrue,
        );
      });
    });
  });

  group('Operation functions', () {
    group('wrapTimeticks', () {
      test('should return same value when under modulus', () {
        expect(DateAndTimeTypes.wrapTimeticks(100), equals(100));
      });
      test('should wrap at 2^32', () {
        expect(DateAndTimeTypes.wrapTimeticks(4294967296), equals(0));
      });
      test('should handle value just below modulus', () {
        expect(
          DateAndTimeTypes.wrapTimeticks(4294967295),
          equals(4294967295),
        );
      });
      test('should wrap overflow correctly', () {
        expect(DateAndTimeTypes.wrapTimeticks(4294967300), equals(4));
      });
      test('should handle large multiples of modulus', () {
        expect(DateAndTimeTypes.wrapTimeticks(8589934592), equals(0));
      });
    });

    group('evaluateTimestampReset', () {
      test('should return eventTicks when event after last reset', () {
        expect(
          DateAndTimeTypes.evaluateTimestampReset(100, 50),
          equals(100),
        );
      });
      test('should return 0 when event before current timeticks (wrapped)', () {
        final result = DateAndTimeTypes.evaluateTimestampReset(5, 4294967290);
        expect(result, equals(0));
      });
      test('should return eventTicks when equal timeticks', () {
        expect(
          DateAndTimeTypes.evaluateTimestampReset(50, 50),
          equals(50),
        );
      });
      test('should return 0 for exact wraparound scenario', () {
        final result = DateAndTimeTypes.evaluateTimestampReset(4, 4294967290);
        expect(result, equals(0));
      });
    });

    group('parseDateAndTime', () {
      test('should parse full datetime with fractional seconds and tz', () {
        final result = DateAndTimeTypes.parseDateAndTime(
          '2026-08-04T00:23:12.123456+08:00',
        );
        expect(result.isSuccess, isTrue);
      });

      test('should parse datetime with Z suffix', () {
        final result = DateAndTimeTypes.parseDateAndTime(
          '2026-08-04T00:00:00Z',
        );
        expect(result.isSuccess, isTrue);
      });

      test('should parse leap second date', () {
        final result = DateAndTimeTypes.parseDateAndTime(
          '2023-12-31T23:59:60Z',
        );
        expect(result.isSuccess, isTrue);
      });

      test('should reject invalid datetime', () {
        final result = DateAndTimeTypes.parseDateAndTime('not a date');
        expect(result.isFailure, isTrue);
      });
    });
  });
}
