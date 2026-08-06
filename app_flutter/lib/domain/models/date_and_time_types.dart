import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-003/ParsedDateTime]
///
/// Parsed representation of an RFC 3339 / RFC 9557 date-and-time string,
/// decomposing the ISO 8601 value into its calendar components, optional
/// fractional seconds, timezone offset, and leap-second flag.
@immutable
class ParsedDateTime {
  /// Creates a [ParsedDateTime] with all required calendar fields and
  /// optional fractional-second, timezone, and leap-second metadata.
  const ParsedDateTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    this.fractionalSecond,
    this.timezoneOffset,
    this.timezoneIsZ,
    this.isLeapSecond,
  });

  /// Gregorian calendar year (must be non-negative per RFC 3339).
  final int year;

  /// Month of year, 1–12.
  final int month;

  /// Day of month, 1–31 (validated against calendar).
  final int day;

  /// Hour, 0–23.
  final int hour;

  /// Minute, 0–59.
  final int minute;

  /// Second, 0–59, or 60 for leap seconds.
  final int second;

  /// Fractional-second portion parsed from the decimal suffix, or null.
  final double? fractionalSecond;

  /// Timezone offset string (e.g. '+08:00', 'Z'), or null.
  final String? timezoneOffset;

  /// Whether the offset suffix was 'Z' (UTC, unknown local reference).
  final bool? timezoneIsZ;

  /// Whether [second] is 60, indicating a leap-second interval.
  final bool? isLeapSecond;

  /// Creates a copy of this [ParsedDateTime] with the given fields replaced.
  ParsedDateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    double? fractionalSecond,
    String? timezoneOffset,
    bool? timezoneIsZ,
    bool? isLeapSecond,
  }) {
    return ParsedDateTime(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      fractionalSecond: fractionalSecond ?? this.fractionalSecond,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      timezoneIsZ: timezoneIsZ ?? this.timezoneIsZ,
      isLeapSecond: isLeapSecond ?? this.isLeapSecond,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParsedDateTime &&
        other.year == year &&
        other.month == month &&
        other.day == day &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second &&
        other.fractionalSecond == fractionalSecond &&
        other.timezoneOffset == timezoneOffset &&
        other.timezoneIsZ == timezoneIsZ &&
        other.isLeapSecond == isLeapSecond;
  }

  @override
  int get hashCode => Object.hash(
        year,
        month,
        day,
        hour,
        minute,
        second,
        fractionalSecond,
        timezoneOffset,
        timezoneIsZ,
        isLeapSecond,
      );
}

const String kFieldDateAndTime = 'dateAndTime';
const String kFieldDate = 'date';
const String kFieldDateNoZone = 'dateNoZone';
const String kFieldTime = 'time';
const String kFieldTimeNoZone = 'timeNoZone';
const String kFieldHours32 = 'hours32';
const String kFieldMinutes32 = 'minutes32';
const String kFieldSeconds32 = 'seconds32';
const String kFieldCentiseconds32 = 'centiseconds32';
const String kFieldMilliseconds32 = 'milliseconds32';
const String kFieldMicroseconds32 = 'microseconds32';
const String kFieldMicroseconds64 = 'microseconds64';
const String kFieldNanoseconds32 = 'nanoseconds32';
const String kFieldNanoseconds64 = 'nanoseconds64';
const String kFieldTimeticks = 'timeticks';
const String kFieldTimestamp = 'timestamp';

/// Realises: [Feat-003/DateAndTimeTypes]
///
/// Domain model representing all 16 date and time typedefs defined in
/// ietf-yang-types (RFC 9911): date-and-time, date, date-no-zone, time,
/// time-no-zone, hours32..nanoseconds64, timeticks, and timestamp.
///
/// String-based types hold the raw ISO 8601 / RFC 3339 / RFC 9557 string.
/// Integer-based duration types hold the signed value with validation
/// constrained to the int32 or int64 range defined by the YANG typedef.
/// Timeticks and timestamp are unsigned 32-bit values modulo 2^32.
@immutable
class DateAndTimeTypes {
  /// Modulus for 32-bit unsigned arithmetic (2^32).
  static const int kModUint32 = 4294967296;

  /// Maximum value for 32-bit unsigned integer (2^32 - 1).
  static const int kMaxUint32 = 4294967295;

  /// Minimum value for signed 32-bit integer.
  static const int kMinInt32 = -2147483648;

  /// Maximum value for signed 32-bit integer.
  static const int kMaxInt32 = 2147483647;

  /// Minimum value for signed 64-bit integer.
  static const int kMinInt64 = -9223372036854775808;

  /// Maximum value for signed 64-bit integer.
  static const int kMaxInt64 = 9223372036854775807;

  /// Unique identifier for the container instance.
  final String containerId;

  /// RFC 3339 / RFC 9557 date-and-time string value.
  final String dateAndTime;

  /// Calendar date value with optional timezone offset.
  final String date;

  /// Calendar date value strictly without timezone offset.
  final String dateNoZone;

  /// Recurring daily time value with optional timezone offset.
  final String time;

  /// Recurring daily time value strictly without timezone offset.
  final String timeNoZone;

  /// Duration measured in hours (signed 32-bit).
  final int hours32;

  /// Duration measured in minutes (signed 32-bit).
  final int minutes32;

  /// Duration measured in seconds (signed 32-bit).
  final int seconds32;

  /// Duration measured in centiseconds (10^-2 s, signed 32-bit).
  final int centiseconds32;

  /// Duration measured in milliseconds (10^-3 s, signed 32-bit).
  final int milliseconds32;

  /// Duration measured in microseconds (10^-6 s, signed 32-bit).
  final int microseconds32;

  /// Duration measured in microseconds (10^-6 s, signed 64-bit).
  final int microseconds64;

  /// Duration measured in nanoseconds (10^-9 s, signed 32-bit).
  final int nanoseconds32;

  /// Duration measured in nanoseconds (10^-9 s, signed 64-bit).
  final int nanoseconds64;

  /// Non-negative 32-bit counter in hundredths of seconds, modulo 2^32.
  final int timeticks;

  /// Value of the associated timeticks node at event occurrence.
  final int timestamp;

  /// Creates a new [DateAndTimeTypes] instance with all 16 fields.
  const DateAndTimeTypes({
    required this.containerId,
    required this.dateAndTime,
    required this.date,
    required this.dateNoZone,
    required this.time,
    required this.timeNoZone,
    required this.hours32,
    required this.minutes32,
    required this.seconds32,
    required this.centiseconds32,
    required this.milliseconds32,
    required this.microseconds32,
    required this.microseconds64,
    required this.nanoseconds32,
    required this.nanoseconds64,
    required this.timeticks,
    required this.timestamp,
  });

  /// Creates a copy of this [DateAndTimeTypes] with the given fields replaced.
  DateAndTimeTypes copyWith({
    String? containerId,
    String? dateAndTime,
    String? date,
    String? dateNoZone,
    String? time,
    String? timeNoZone,
    int? hours32,
    int? minutes32,
    int? seconds32,
    int? centiseconds32,
    int? milliseconds32,
    int? microseconds32,
    int? microseconds64,
    int? nanoseconds32,
    int? nanoseconds64,
    int? timeticks,
    int? timestamp,
  }) {
    return DateAndTimeTypes(
      containerId: containerId ?? this.containerId,
      dateAndTime: dateAndTime ?? this.dateAndTime,
      date: date ?? this.date,
      dateNoZone: dateNoZone ?? this.dateNoZone,
      time: time ?? this.time,
      timeNoZone: timeNoZone ?? this.timeNoZone,
      hours32: hours32 ?? this.hours32,
      minutes32: minutes32 ?? this.minutes32,
      seconds32: seconds32 ?? this.seconds32,
      centiseconds32: centiseconds32 ?? this.centiseconds32,
      milliseconds32: milliseconds32 ?? this.milliseconds32,
      microseconds32: microseconds32 ?? this.microseconds32,
      microseconds64: microseconds64 ?? this.microseconds64,
      nanoseconds32: nanoseconds32 ?? this.nanoseconds32,
      nanoseconds64: nanoseconds64 ?? this.nanoseconds64,
      timeticks: timeticks ?? this.timeticks,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateAndTimeTypes &&
        other.containerId == containerId &&
        other.dateAndTime == dateAndTime &&
        other.date == date &&
        other.dateNoZone == dateNoZone &&
        other.time == time &&
        other.timeNoZone == timeNoZone &&
        other.hours32 == hours32 &&
        other.minutes32 == minutes32 &&
        other.seconds32 == seconds32 &&
        other.centiseconds32 == centiseconds32 &&
        other.milliseconds32 == milliseconds32 &&
        other.microseconds32 == microseconds32 &&
        other.microseconds64 == microseconds64 &&
        other.nanoseconds32 == nanoseconds32 &&
        other.nanoseconds64 == nanoseconds64 &&
        other.timeticks == timeticks &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        dateAndTime,
        date,
        dateNoZone,
        time,
        timeNoZone,
        hours32,
        minutes32,
        seconds32,
        centiseconds32,
        milliseconds32,
        microseconds32,
        microseconds64,
        nanoseconds32,
        nanoseconds64,
        timeticks,
        timestamp,
      );

  static final RegExp _dateTimeRegex = RegExp(
    r'^[0-9]{4}-(1[0-2]|0[1-9])-(0[1-9]|[1-2][0-9]|3[0-1])'
    r'T(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)'
    r'(\.[0-9]+)?'
    r'(Z|[\+\-]((1[0-3]|0[0-9]):([0-5][0-9])|14:00))?$',
  );

  static final RegExp _dateRegex = RegExp(
    r'^[0-9]{4}-(1[0-2]|0[1-9])-(0[1-9]|[1-2][0-9]|3[0-1])'
    r'(Z|[\+\-]((1[0-3]|0[0-9]):([0-5][0-9])|14:00))?$',
  );

  static final RegExp _dateNoZoneRegex = RegExp(
    r'^[0-9]{4}-(1[0-2]|0[1-9])-(0[1-9]|[1-2][0-9]|3[0-1])$',
  );

  static final RegExp _timeRegex = RegExp(
    r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)'
    r'(\.[0-9]+)?'
    r'(Z|[\+\-]((1[0-3]|0[0-9]):([0-5][0-9])|14:00))?$',
  );

  static final RegExp _timeNoZoneRegex = RegExp(
    r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)'
    r'(\.[0-9]+)?$',
  );

  static final RegExp _tzBoundaryRegex = RegExp(
    r'^[\+\-]((1[0-3]|0[0-9]):([0-5][0-9])|14:00)$',
  );

  static final RegExp _tzNeg14Regex = RegExp(r'^-14:00$');

  static final RegExp _tzExtractRegex = RegExp(
    r'(Z|[\+\-]((1[0-3]|0[0-9]):([0-5][0-9])|14:00))$',
  );

  /// Validates a date-and-time string against RFC 3339 / RFC 9557 profile.
  ///
  /// Checks regex format, leap-second semantics, timezone boundary
  /// [-13:59, +14:00], negative year prohibition, and calendar validity.
  /// Returns [Success] with the value or [Failure] with a domain error.
  static Result<String> validateDateAndTime(String value) {
    if (!_dateTimeRegex.hasMatch(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'dateAndTime',
          value: value,
          pattern: _dateTimeRegex.pattern,
        ),
      );
    }
    if (_hasNegativeYear(value)) {
      return Result.failure(
        const SchemaFieldPatternError(
          fieldName: 'dateAndTime',
          value: '',
          pattern: 'negative year prohibited',
        ),
      );
    }
    if (!_isValidCalendarDate(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'dateAndTime',
          value: value,
          pattern: 'valid calendar date required',
        ),
      );
    }
    final tz = _tzExtractRegex.firstMatch(value)?.group(0);
    if (tz != null && tz != 'Z') {
      if (_tzNeg14Regex.hasMatch(tz)) {
        return Result.failure(
          SchemaFieldPatternError(
            fieldName: 'dateAndTime',
            value: value,
            pattern: 'timezone range [-13:59, +14:00]',
          ),
        );
      }
      if (!_tzBoundaryRegex.hasMatch(tz)) {
        return Result.failure(
          SchemaFieldPatternError(
            fieldName: 'dateAndTime',
            value: value,
            pattern: 'timezone range [-13:59, +14:00]',
          ),
        );
      }
    }
    return Result.success(value);
  }

  /// Validates a date string with optional timezone offset.
  ///
  /// Checks regex format, calendar validity, and negative year prohibition.
  /// Returns [Success] with the value or [Failure] with a domain error.
  static Result<String> validateDate(String value) {
    if (!_dateRegex.hasMatch(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'date',
          value: value,
          pattern: _dateRegex.pattern,
        ),
      );
    }
    if (_hasNegativeYear(value)) {
      return Result.failure(
        const SchemaFieldPatternError(
          fieldName: 'date',
          value: '',
          pattern: 'negative year prohibited',
        ),
      );
    }
    if (!_isValidCalendarDate(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'date',
          value: value,
          pattern: 'valid calendar date required',
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a date string strictly without timezone offset.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldPatternError] when the format is invalid.
  static Result<String> validateDateNoZone(String value) {
    if (!_dateNoZoneRegex.hasMatch(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'dateNoZone',
          value: value,
          pattern: _dateNoZoneRegex.pattern,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a time string with optional timezone offset.
  ///
  /// Supports leap second (second value 60) and fractional seconds.
  /// Checks timezone boundary compliance.
  /// Returns [Success] with the value or [Failure] with a domain error.
  static Result<String> validateTime(String value) {
    if (!_timeRegex.hasMatch(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'time',
          value: value,
          pattern: _timeRegex.pattern,
        ),
      );
    }
    final tz = _tzExtractRegex.firstMatch(value)?.group(0);
    if (tz != null && tz != 'Z') {
      if (_tzNeg14Regex.hasMatch(tz)) {
        return Result.failure(
          SchemaFieldPatternError(
            fieldName: 'time',
            value: value,
            pattern: 'timezone range [-13:59, +14:00]',
          ),
        );
      }
      if (!_tzBoundaryRegex.hasMatch(tz)) {
        return Result.failure(
          SchemaFieldPatternError(
            fieldName: 'time',
            value: value,
            pattern: 'timezone range [-13:59, +14:00]',
          ),
        );
      }
    }
    return Result.success(value);
  }

  /// Validates a time string strictly without timezone offset.
  ///
  /// Supports leap second (second value 60) and fractional seconds.
  /// Returns [Success] with the value or [Failure] with a domain error.
  static Result<String> validateTimeNoZone(String value) {
    if (!_timeNoZoneRegex.hasMatch(value)) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'timeNoZone',
          value: value,
          pattern: _timeNoZoneRegex.pattern,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates an hours32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateHours32(int value) {
    return _validateInt32Range('hours32', value);
  }

  /// Validates a minutes32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateMinutes32(int value) {
    return _validateInt32Range('minutes32', value);
  }

  /// Validates a seconds32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateSeconds32(int value) {
    return _validateInt32Range('seconds32', value);
  }

  /// Validates a centiseconds32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateCentiseconds32(int value) {
    return _validateInt32Range('centiseconds32', value);
  }

  /// Validates a milliseconds32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateMilliseconds32(int value) {
    return _validateInt32Range('milliseconds32', value);
  }

  /// Validates a microseconds32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateMicroseconds32(int value) {
    return _validateInt32Range('microseconds32', value);
  }

  /// Validates a microseconds64 signed duration value within int64 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateMicroseconds64(int value) {
    if (value < kMinInt64 || value > kMaxInt64) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'microseconds64',
          value: value,
          min: kMinInt64,
          max: kMaxInt64,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a nanoseconds32 signed duration value within int32 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateNanoseconds32(int value) {
    return _validateInt32Range('nanoseconds32', value);
  }

  /// Validates a nanoseconds64 signed duration value within int64 range.
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateNanoseconds64(int value) {
    if (value < kMinInt64 || value > kMaxInt64) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'nanoseconds64',
          value: value,
          min: kMinInt64,
          max: kMaxInt64,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a timeticks unsigned 32-bit value within [0, 2^32-1].
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateTimeticks(int value) {
    if (value < 0 || value > kMaxUint32) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'timeticks',
          value: value,
          min: 0,
          max: kMaxUint32,
        ),
      );
    }
    return Result.success(value);
  }

  /// Validates a timestamp unsigned 32-bit value within [0, 2^32-1].
  ///
  /// Returns [Success] with the value or [Failure] with a
  /// [SchemaFieldRangeError].
  static Result<int> validateTimestamp(int value) {
    if (value < 0 || value > kMaxUint32) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: 'timestamp',
          value: value,
          min: 0,
          max: kMaxUint32,
        ),
      );
    }
    return Result.success(value);
  }

  /// Returns true if [offset] is a valid timezone offset string.
  ///
  /// Accepts 'Z' and offsets in the range [-13:59, +14:00] inclusive.
  /// Rejects '-14:00' which is outside the allowed range.
  static bool isValidTimezoneOffset(String offset) {
    if (offset == 'Z') return true;
    if (_tzNeg14Regex.hasMatch(offset)) return false;
    return _tzBoundaryRegex.hasMatch(offset);
  }

  /// Returns true if [value] has a known local time zone reference point
  /// per RFC 9557 § 2. Returns false for 'Z' suffix (unknown reference).
  static bool hasKnownTimezoneReference(String value) {
    if (value.endsWith('Z')) return false;
    return true;
  }

  /// Applies modulo 2^32 arithmetic to [ticks].
  ///
  /// Returns [ticks] mod kModUint32, handling timeticks wrap-around per
  /// RFC 9911 / SMIv2 TimeTicks semantics.
  static int wrapTimeticks(int ticks) {
    return ticks % kModUint32;
  }

  /// Evaluates a timestamp value relative to the current timeticks.
  ///
  /// If [eventTicks] is less than [currentTimeticks], the event is
  /// considered to have occurred before the last timeticks wrap-around
  /// reset and the function returns 0. Otherwise returns [eventTicks].
  /// Implements SMIv2 TimeStamp reset semantics (RFC 2579).
  static int evaluateTimestampReset(int eventTicks, int currentTimeticks) {
    if (eventTicks < currentTimeticks) return 0;
    return eventTicks;
  }

  /// Parses an RFC 3339 / RFC 9557 date-and-time string into its
  /// structured calendar and timezone components.
  ///
  /// Returns [Success] with a [ParsedDateTime] on successful parse,
  /// or [Failure] when the string fails format or calendar validation.
  static Result<ParsedDateTime> parseDateAndTime(String value) {
    final valid = validateDateAndTime(value);
    if (valid.isFailure) {
      return Result.failure((valid as Failure<String>).error);
    }

    final match = _parseRegex.firstMatch(value);
    if (match == null) {
      return Result.failure(
        SchemaFieldPatternError(
          fieldName: 'dateAndTime',
          value: value,
          pattern: _parseRegex.pattern,
        ),
      );
    }

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);

    double? fractionalSecond;
    if (match.group(8) != null) {
      final fracStr = match.group(8)!;
      fractionalSecond = double.tryParse('0.$fracStr');
    }

    String? timezoneOffset;
    bool? timezoneIsZ;
    final tzGroup = match.group(9);
    if (tzGroup != null) {
      if (tzGroup == 'Z') {
        timezoneOffset = 'Z';
        timezoneIsZ = true;
      } else {
        timezoneOffset = tzGroup;
        timezoneIsZ = false;
      }
    }

    final isLeapSecond = second == 60;

    return Result.success(ParsedDateTime(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      fractionalSecond: fractionalSecond,
      timezoneOffset: timezoneOffset,
      timezoneIsZ: timezoneIsZ,
      isLeapSecond: isLeapSecond,
    ));
  }

  static Result<int> _validateInt32Range(String fieldName, int value) {
    if (value < kMinInt32 || value > kMaxInt32) {
      return Result.failure(
        SchemaFieldRangeError(
          fieldName: fieldName,
          value: value,
          min: kMinInt32,
          max: kMaxInt32,
        ),
      );
    }
    return Result.success(value);
  }

  static bool _hasNegativeYear(String value) {
    if (value.isEmpty) return false;
    return value.startsWith('-');
  }

  static bool _isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  static final _dateExtractRegex = RegExp(r'^([0-9]{4})-([0-9]{2})-([0-9]{2})');

  static bool _isValidCalendarDate(String dateStr) {
    final match = _dateExtractRegex.firstMatch(dateStr);
    if (match == null) return false;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    final daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    int maxDay = daysInMonth[month];
    if (month == 2 && _isLeapYear(year)) maxDay = 29;
    return day <= maxDay;
  }

  static final _parseRegex = RegExp(
    r'^([0-9]{4})-'
    r'(1[0-2]|0[1-9])-'
    r'(0[1-9]|[1-2][0-9]|3[0-1])'
    r'T'
    r'(0[0-9]|1[0-9]|2[0-3]):'
    r'([0-5][0-9]):'
    r'([0-5][0-9]|60)'
    r'(\.([0-9]+))?'
    r'(Z|[\+\-]((1[0-3]|0[0-9]):([0-5][0-9])|14:00))?$',
  );
}
