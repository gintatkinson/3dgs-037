import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeodeticReferenceFrame value object', () {
    test('should create instance with default astronomical body "earth"', () {
      const model = GeodeticReferenceFrame();
      expect(model.astronomicalBody, equals('earth'));
      expect(model.alternateSystem, isNull);
      expect(model.alternateSystems, isFalse);
      expect(model.containerId, equals('default'));
    });

    test('should create instance with all fields specified', () {
      const model = GeodeticReferenceFrame(
        containerId: 'test-1',
        astronomicalBody: 'mars',
        alternateSystem: 'wgs84-3d',
        alternateSystems: true,
      );
      expect(model.containerId, equals('test-1'));
      expect(model.astronomicalBody, equals('mars'));
      expect(model.alternateSystem, equals('wgs84-3d'));
      expect(model.alternateSystems, isTrue);
    });

    test('should have value equality', () {
      const a = GeodeticReferenceFrame(
        astronomicalBody: 'mars',
        alternateSystem: 'wgs84-3d',
        alternateSystems: true,
      );
      const b = GeodeticReferenceFrame(
        astronomicalBody: 'mars',
        alternateSystem: 'wgs84-3d',
        alternateSystems: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('should have inequality with different values', () {
      const a = GeodeticReferenceFrame(astronomicalBody: 'mars');
      const b = GeodeticReferenceFrame(astronomicalBody: 'earth');
      expect(a, isNot(equals(b)));
    });
  });

  group('validateAstronomicalBody', () {
    test('should accept default value "earth"', () {
      final result = validateAstronomicalBody('earth');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('earth'));
    });

    test('should accept lowercase name "mars"', () {
      final result = validateAstronomicalBody('mars');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('mars'));
    });

    test('should accept string with digits and special chars "1P/Halley"', () {
      final result = validateAstronomicalBody('1P/Halley');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('1P/Halley'));
    });

    test('should accept space-containing name', () {
      final result = validateAstronomicalBody('alpha centauri');
      expect(result.isSuccess, isTrue);
    });

    test('should reject control character (newline)', () {
      final result = validateAstronomicalBody('mars\n');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<InvalidAstronomicalBodyError>());
      final bodyError = error as InvalidAstronomicalBodyError;
      expect(bodyError.input, equals('mars\n'));
    });

    test('should reject empty string', () {
      final result = validateAstronomicalBody('');
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String>).error;
      expect(error, isA<InvalidAstronomicalBodyError>());
    });

    test('should accept all allowed printable ASCII chars except uppercase', () {
      final result = validateAstronomicalBody('mars 123 / - _ . [ ] ^');
      expect(result.isSuccess, isTrue);
    });

    test('should accept uppercase letter E in "Enceladus"', () {
      final result = validateAstronomicalBody('Enceladus');
      expect(result.isSuccess, isTrue);
      expect((result as Success<String>).value, equals('Enceladus'));
    });
  });

  group('validateAlternateSystemWithFeature', () {
    test('should accept alternateSystem when feature is enabled', () {
      final result = validateAlternateSystemWithFeature(
        alternateSystem: 'wgs84-3d',
        alternateSystems: true,
      );
      expect(result.isSuccess, isTrue);
      expect((result as Success<String?>).value, equals('wgs84-3d'));
    });

    test('should accept null alternateSystem regardless of feature flag', () {
      final result = validateAlternateSystemWithFeature(
        alternateSystem: null,
        alternateSystems: false,
      );
      expect(result.isSuccess, isTrue);
      expect((result as Success<String?>).value, isNull);
    });

    test('should reject alternateSystem when feature is disabled', () {
      final result = validateAlternateSystemWithFeature(
        alternateSystem: 'wgs84-3d',
        alternateSystems: false,
      );
      expect(result.isFailure, isTrue);
      final error = (result as Failure<String?>).error;
      expect(error, isA<FeatureDisabledAlternateSystemError>());
      final feError = error as FeatureDisabledAlternateSystemError;
      expect(feError.value, equals('wgs84-3d'));
    });
  });

  group('validateGeodeticReferenceFrame', () {
    test('should accept valid model with feature enabled', () {
      const model = GeodeticReferenceFrame(
        astronomicalBody: 'mars',
        alternateSystem: 'wgs84-3d',
        alternateSystems: true,
      );
      final result = validateGeodeticReferenceFrame(model);
      expect(result.isSuccess, isTrue);
      expect((result as Success<GeodeticReferenceFrame>).value, equals(model));
    });

    test('should accept valid model with feature disabled and no alternate',
        () {
      const model = GeodeticReferenceFrame(astronomicalBody: 'earth');
      final result = validateGeodeticReferenceFrame(model);
      expect(result.isSuccess, isTrue);
    });

    test('should reject when astronomical body is invalid', () {
      const model = GeodeticReferenceFrame(astronomicalBody: '\x00bad');
      final result = validateGeodeticReferenceFrame(model);
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<GeodeticReferenceFrame>).error,
        isA<InvalidAstronomicalBodyError>(),
      );
    });

    test('should reject when alternate system is set but feature disabled', () {
      const model = GeodeticReferenceFrame(
        astronomicalBody: 'earth',
        alternateSystem: 'invalid-here',
        alternateSystems: false,
      );
      final result = validateGeodeticReferenceFrame(model);
      expect(result.isFailure, isTrue);
      expect(
        (result as Failure<GeodeticReferenceFrame>).error,
        isA<FeatureDisabledAlternateSystemError>(),
      );
    });
  });

  group('Field key constants', () {
    test('should define kFieldAstronomicalBody', () {
      expect(kFieldAstronomicalBody, equals('astronomicalBody'));
    });

    test('should define kFieldAlternateSystem', () {
      expect(kFieldAlternateSystem, equals('alternateSystem'));
    });

    test('should define kFieldAlternateSystems', () {
      expect(kFieldAlternateSystems, equals('alternateSystems'));
    });
  });
}
