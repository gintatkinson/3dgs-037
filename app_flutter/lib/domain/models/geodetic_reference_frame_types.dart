import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-034/ReferenceFrame]
///
/// Field key constants for the geodetic reference frame container fields,
/// used by [FieldDescriptor] schemas and serialisation logic.
/// Field key constant for the astronomical body string.
const String kFieldAstronomicalBody = 'astronomicalBody';
/// Field key constant for the alternate coordinate reference system.
const String kFieldAlternateSystem = 'alternateSystem';
/// Field key constant for the alternate systems feature flag.
const String kFieldAlternateSystems = 'alternateSystems';

/// Realises: [Feat-034/ReferenceFrame]
///
/// Domain model capturing the `reference-frame` container defined in the
/// `ietf-geo-location` YANG module (RFC 9179 § reference-frame).
///
/// The reference frame establishes the spatial origin and contextual
/// interpretation for geographical coordinates and height values.
///
/// Fields:
/// - [astronomicalBody]: The IAU-defined astronomical body string.
///   Defaults to `"earth"`. Constrained to printable ASCII characters
///   matching the YANG pattern `'[ -@\\[-\\^_-~]*'`.
/// - [alternateSystem]: Optional alternate coordinate reference system
///   string. Guarded by the [alternateSystems] feature flag.
/// - [alternateSystems]: Boolean indicating whether the
///   `alternate-systems` YANG feature is enabled. When `true`,
///   [alternateSystem] can be set; when `false`, setting it produces
///   a [FeatureDisabledAlternateSystemError].
@immutable
class GeodeticReferenceFrame {
  /// Creates a [GeodeticReferenceFrame] with the given fields.
  const GeodeticReferenceFrame({
    this.containerId = 'default',
    this.astronomicalBody = 'earth',
    this.alternateSystem,
    this.alternateSystems = false,
  });

  /// Container identifier for database indexing.
  final String containerId;

  /// The IAU-defined astronomical body string (default: `"earth"`).
  final String astronomicalBody;

  /// Optional alternate coordinate reference system.
  final String? alternateSystem;

  /// Whether the `alternate-systems` YANG feature is enabled.
  final bool alternateSystems;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeodeticReferenceFrame &&
        other.containerId == containerId &&
        other.astronomicalBody == astronomicalBody &&
        other.alternateSystem == alternateSystem &&
        other.alternateSystems == alternateSystems;
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        astronomicalBody,
        alternateSystem,
        alternateSystems,
      );
}

/// The compiled regex matching the printable ASCII range (chars 32–126)
/// as described in RFC 9179 § reference-frame for astronomical-body.
///
/// Excludes control characters (0–31) and DEL (127). One or more
/// characters required since the default is `"earth"`.
final RegExp _astronomicalBodyRegex = RegExp(r'^[\x20-\x7E]+$');

/// Realises: [Feat-034/ReferenceFrame]
///
/// Validates an astronomical-body string against the YANG pattern
/// defined in RFC 9179 § reference-frame.
///
/// Accepted characters: printable ASCII in range 32–126 (space through tilde).
/// This excludes control characters (0–31) and DEL (127).
///
/// Returns [Success] with the input string if valid, or [Failure] with
/// [InvalidAstronomicalBodyError] if the pattern does not match.
Result<String> validateAstronomicalBody(String input) {
  if (_astronomicalBodyRegex.hasMatch(input)) {
    return Result.success(input);
  }
  return Result.failure(InvalidAstronomicalBodyError(input: input));
}

/// Realises: [Feat-034/ReferenceFrame]
///
/// Validates the [alternateSystem] field in the context of the
/// [alternateSystems] feature flag.
///
/// When [alternateSystems] is `true`, any non-null [alternateSystem]
/// value is accepted. When `false` and [alternateSystem] is non-null,
/// returns [Failure] with [FeatureDisabledAlternateSystemError].
/// Returns [Success] for a null [alternateSystem] regardless of the flag.
Result<String?> validateAlternateSystemWithFeature({
  required String? alternateSystem,
  required bool alternateSystems,
}) {
  if (alternateSystem != null && !alternateSystems) {
    return Result.failure(
      FeatureDisabledAlternateSystemError(value: alternateSystem),
    );
  }
  return Result.success(alternateSystem);
}

/// Realises: [Feat-034/ReferenceFrame]
///
/// Validates a complete [GeodeticReferenceFrame] instance.
///
/// Checks:
/// 1. [astronomicalBody] against the YANG printable ASCII pattern.
/// 2. [alternateSystem] presence when [alternateSystems] is disabled.
///
/// Returns [Success] with the model if all validations pass, or
/// [Failure] with the first-encountered domain error.
Result<GeodeticReferenceFrame> validateGeodeticReferenceFrame(
  GeodeticReferenceFrame model,
) {
  final bodyResult = validateAstronomicalBody(model.astronomicalBody);
  if (bodyResult.isFailure) {
    return Result.failure(
      (bodyResult as Failure<String>).error,
    );
  }

  final featureResult = validateAlternateSystemWithFeature(
    alternateSystem: model.alternateSystem,
    alternateSystems: model.alternateSystems,
  );
  if (featureResult.isFailure) {
    return Result.failure(
      (featureResult as Failure<String?>).error,
    );
  }

  return Result.success(model);
}
