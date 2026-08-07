import 'package:app_flutter/domain/domain_errors.dart';
import 'package:app_flutter/domain/result.dart';
import 'package:flutter/foundation.dart';

/// Realises: [Feat-047/Location]
///
/// Field key constants for the location inventory container fields,
/// used by [FieldDescriptor] schemas and serialisation logic.
/// Field key constant for the YANG list key identifier.
const String kFieldLocationId = 'id';
/// Field key constant for the RFC 9562 UUID.
const String kFieldUuid = 'uuid';
/// Field key constant for the human-readable location name.
const String kFieldName = 'name';
/// Field key constant for the short location alias.
const String kFieldAlias = 'alias';
/// Field key constant for the free-text description.
const String kFieldDescription = 'description';
/// Field key constant for the location type identifier.
const String kFieldType = 'type';
/// Field key constant for the parent location leafref.
const String kFieldParent = 'parent';
/// Field key constant for the last update timestamp.
const String kFieldTimestamp = 'timestamp';
/// Field key constant for the validity expiry date-time.
const String kFieldValidUntil = 'validUntil';
/// Field key constant for the postal address.
const String kFieldAddress = 'address';
/// Field key constant for the postal code.
const String kFieldPostalCode = 'postalCode';
/// Field key constant for the state, province, or region.
const String kFieldState = 'state';
/// Field key constant for the city name.
const String kFieldCity = 'city';
/// Field key constant for the ISO 3166-1 alpha-2 country code.
const String kFieldCountryCode = 'countryCode';
/// Field key constant for the building identifier.
const String kFieldBuilding = 'building';
/// Field key constant for the floor designation.
const String kFieldFloor = 'floor';
/// Field key constant for the room identifier.
const String kFieldRoom = 'room';
/// Field key constant for the formatted room-building position string.
const String kFieldRoomBuildingPosition = 'roomBuildingPosition';
/// Field key constant for the chassis identifier.
const String kFieldChassisId = 'chassisId';
/// Field key constant for the network element reference.
const String kFieldNeRef = 'neRef';
/// Field key constant for the component reference.
const String kFieldComponentRef = 'componentRef';
/// Field key constant for the contained chassis list.
const String kFieldContainedChassis = 'containedChassis';

/// Realises: [Feat-047/Location]
///
/// Domain model capturing the `location` list entry defined in the
/// `ietf-ni-location` YANG module (ietf-ni-location.yang § locations/location).
///
/// A location represents a geographic or structural position in the
/// network inventory hierarchy. Locations can be nested via the [parent]
/// leafref to form hierarchical chains such as site → building → room.
///
/// The [id] field is the YANG list key and must be non-empty and unique
/// within the locations container. The [physicalAddress] captures postal
/// mailing details, and [containedChassis] lists chassis units directly
/// deployed at this location without a rack.
///
/// Fields:
/// - [id]: The YANG list key identifier (required, non-nullable).
/// - [uuid]: Optional RFC 9562 UUID.
/// - [name]: Optional human-readable location name.
/// - [alias]: Optional short alias for the location.
/// - [description]: Optional free-text description.
/// - [type]: Optional location type identifier (e.g. site, equipment-room).
/// - [parent]: Optional leafref to another location's [id].
/// - [timestamp]: Optional RFC 3339 date-and-time of last update.
/// - [validUntil]: Optional RFC 3339 date-and-time of validity expiry.
/// - [physicalAddress]: Optional structured postal mailing address.
/// - [buildingPosition]: Optional indoor building position information.
/// - [containedChassis]: List of chassis directly deployed at this location.
@immutable
class Location {
  /// Creates a [Location] with the given fields.
  const Location({
    this.containerId = 'default',
    required this.id,
    this.uuid,
    this.name,
    this.alias,
    this.description,
    this.type,
    this.parent,
    this.timestamp,
    this.validUntil,
    this.physicalAddress,
    this.buildingPosition,
    this.containedChassis = const [],
  });

  /// Container identifier for database indexing.
  final String containerId;

  /// The YANG list key identifier for this location.
  final String id;

  /// Optional RFC 9562 universally unique identifier.
  final String? uuid;

  /// Optional human-readable name.
  final String? name;

  /// Optional short alias.
  final String? alias;

  /// Optional free-text description.
  final String? description;

  /// Optional location type (e.g. site, equipment-room, building).
  final String? type;

  /// Optional leafref to the [id] of the parent location.
  final String? parent;

  /// Optional RFC 3339 date-and-time of last update.
  final String? timestamp;

  /// Optional RFC 3339 date-and-time marking validity expiry.
  final String? validUntil;

  /// Optional structured postal mailing address.
  final PhysicalAddress? physicalAddress;

  /// Optional indoor building position information.
  final BuildingPosition? buildingPosition;

  /// Chassis units directly deployed at this location without a rack.
  final List<ContainedChassis> containedChassis;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.containerId == containerId &&
        other.id == id &&
        other.uuid == uuid &&
        other.name == name &&
        other.alias == alias &&
        other.description == description &&
        other.type == type &&
        other.parent == parent &&
        other.timestamp == timestamp &&
        other.validUntil == validUntil &&
        other.physicalAddress == physicalAddress &&
        other.buildingPosition == buildingPosition &&
        listEquals(other.containedChassis, containedChassis);
  }

  @override
  int get hashCode => Object.hash(
        containerId,
        id,
        uuid,
        name,
        alias,
        description,
        type,
        parent,
        timestamp,
        validUntil,
        physicalAddress,
        buildingPosition,
        Object.hashAll(containedChassis),
      );
}

/// Realises: [Feat-047/PhysicalAddress]
///
/// Domain model capturing the `physical-address` grouping defined in the
/// `ietf-ni-location` YANG module (ietf-ni-location.yang §
/// physical-address).
///
/// Represents a structured postal mailing address with fields for street
/// address, postal code, city, state/region, and ISO 3166-1 alpha-2
/// country code.
///
/// Fields:
/// - [address]: Optional street address (number and street).
/// - [postalCode]: Optional postal code.
/// - [state]: Optional state, province, or region.
/// - [city]: Optional city name.
/// - [countryCode]: Optional ISO 3166-1 alpha-2 country code.
@immutable
class PhysicalAddress {
  /// Creates a [PhysicalAddress] with the given fields.
  const PhysicalAddress({
    this.address,
    this.postalCode,
    this.state,
    this.city,
    this.countryCode,
  });

  /// Optional street address (number and street).
  final String? address;

  /// Optional postal code.
  final String? postalCode;

  /// Optional state, province, or region.
  final String? state;

  /// Optional city name.
  final String? city;

  /// Optional ISO 3166-1 alpha-2 two-letter country code.
  final String? countryCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhysicalAddress &&
        other.address == address &&
        other.postalCode == postalCode &&
        other.state == state &&
        other.city == city &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode => Object.hash(
        address,
        postalCode,
        state,
        city,
        countryCode,
      );
}

/// Realises: [Feat-048/BuildingPosition]
///
/// Domain model capturing indoor building position attributes defined
/// in the `ietf-ni-location` YANG module (ietf-ni-location.yang §
/// physical-address/building, floor, room, room-building-position).
///
/// Represents fine-grained indoor location hierarchy within a facility:
/// the building structure identifier, floor level, room or suite number,
/// and a formatted compound position string.
///
/// Fields:
/// - [building]: Optional building identifier (1-64 chars).
/// - [floor]: Optional floor designation (1-64 chars).
/// - [room]: Optional room identifier (1-64 chars).
/// - [roomBuildingPosition]: Optional formatted compound position
///   string (1-128 chars).
@immutable
class BuildingPosition {
  /// Creates a [BuildingPosition] with the given fields.
  const BuildingPosition({
    this.building,
    this.floor,
    this.room,
    this.roomBuildingPosition,
  });

  /// Optional building structure identifier.
  final String? building;

  /// Optional floor or level designation.
  final String? floor;

  /// Optional room number, suite, or rack hall identifier.
  final String? room;

  /// Optional formatted compound position string combining room, floor,
  /// and building hierarchy.
  final String? roomBuildingPosition;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BuildingPosition &&
        other.building == building &&
        other.floor == floor &&
        other.room == room &&
        other.roomBuildingPosition == roomBuildingPosition;
  }

  @override
  int get hashCode => Object.hash(
        building,
        floor,
        room,
        roomBuildingPosition,
      );
}

/// Realises: [Feat-048/BuildingPosition.formatRoomBuildingPosition]
///
/// Formats building, floor, and room identifiers into a compound
/// position string. Implemented as a top-level function rather than
/// a member method to avoid coupling the formatting logic to
/// a specific BuildingPosition instance state.
///
/// Non-empty segments are joined with `", "` separator.
/// Null or empty segments are omitted gracefully.
///
/// Example: `"Building B, Floor 3, Room 302"`
String formatRoomBuildingPosition(
  String building,
  String floor,
  String room,
) {
  final parts = <String>[];
  if (building.isNotEmpty) parts.add(building);
  if (floor.isNotEmpty) parts.add(floor);
  if (room.isNotEmpty) parts.add(room);
  return parts.join(', ');
}

/// Realises: [Feat-048/validateBuildingPosition]
///
/// Validates a [BuildingPosition] instance. At least one of the four
/// fields ([building], [floor], [room], [roomBuildingPosition]) must be
/// non-null and non-empty.
///
/// Returns [Success] with the position if at least one field is populated,
/// or [Failure] with [BuildingPositionValidationError] if all fields are
/// null or empty.
Result<BuildingPosition> validateBuildingPosition(BuildingPosition bp) {
  final hasContent = (bp.building != null && bp.building!.trim().isNotEmpty) ||
      (bp.floor != null && bp.floor!.trim().isNotEmpty) ||
      (bp.room != null && bp.room!.trim().isNotEmpty) ||
      (bp.roomBuildingPosition != null && bp.roomBuildingPosition!.trim().isNotEmpty);
  if (!hasContent) {
    return Result.failure(
      BuildingPositionValidationError(
        building: bp.building,
        floor: bp.floor,
        room: bp.room,
        roomBuildingPosition: bp.roomBuildingPosition,
      ),
    );
  }
  if (bp.building != null && bp.building!.length > 64) {
    return Result.failure(BuildingPositionLengthError(field: 'building', maxLength: 64, actualLength: bp.building!.length));
  }
  if (bp.floor != null && bp.floor!.length > 64) {
    return Result.failure(BuildingPositionLengthError(field: 'floor', maxLength: 64, actualLength: bp.floor!.length));
  }
  if (bp.room != null && bp.room!.length > 64) {
    return Result.failure(BuildingPositionLengthError(field: 'room', maxLength: 64, actualLength: bp.room!.length));
  }
  if (bp.roomBuildingPosition != null && bp.roomBuildingPosition!.length > 128) {
    return Result.failure(BuildingPositionLengthError(field: 'roomBuildingPosition', maxLength: 128, actualLength: bp.roomBuildingPosition!.length));
  }
  return Result.success(bp);
}

/// Realises: [Feat-047/ContainedChassis]
///
/// Domain model capturing the `contained-chassis` list entry defined in
/// the `ietf-ni-location` YANG module (ietf-ni-location.yang §
/// locations/location/contained-chassis).
///
/// Represents a chassis unit directly deployed at a location without being
/// mounted in a rack. Each entry is keyed by [chassisId] and may carry
/// leafref pointers to the corresponding network element and its component.
///
/// Fields:
/// - [chassisId]: The YANG list key, a non-negative 32-bit integer.
/// - [neRef]: Optional leafref to the network element identifier.
/// - [componentRef]: Optional leafref to the component identifier.
@immutable
class ContainedChassis {
  /// Creates a [ContainedChassis] with the given fields.
  const ContainedChassis({
    required this.chassisId,
    this.neRef,
    this.componentRef,
  });

  /// The YANG list key, a non-negative 32-bit integer.
  final int chassisId;

  /// Optional leafref to the network element identifier.
  final String? neRef;

  /// Optional leafref to the component identifier.
  final String? componentRef;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContainedChassis &&
        other.chassisId == chassisId &&
        other.neRef == neRef &&
        other.componentRef == componentRef;
  }

  @override
  int get hashCode => Object.hash(
        chassisId,
        neRef,
        componentRef,
      );
}

/// The compiled regex matching the ISO 3166-1 alpha-2 country code
/// pattern `[A-Z]{2}` as defined in the YANG `country-code` type
/// in ietf-ni-location.yang.
final RegExp _countryCodeRegex = RegExp(r'^[A-Z]{2}$');

/// Realises: [Feat-047/validateCountryCode]
///
/// Validates a country code string against the ISO 3166-1 alpha-2 format
/// defined in ietf-ni-location.yang § physical-address/country-code.
///
/// The value must match the pattern `[A-Z]{2}` — exactly two uppercase
/// ASCII letters. Lowercase, digits, or strings of different lengths
/// are rejected.
///
/// Returns [Success] with the input code if valid, or [Failure] with
/// [CountryCodeValidationError] if the pattern does not match.
Result<String> validateCountryCode(String code) {
  if (_countryCodeRegex.hasMatch(code)) {
    return Result.success(code);
  }
  return Result.failure(CountryCodeValidationError(input: code));
}

/// Realises: [Feat-047/validateLocationId]
///
/// Validates that a location [id] string is non-empty, as required by
/// the YANG `key "id"` constraint in ietf-ni-location.yang §
/// locations/location.
///
/// Returns [Success] with the validated [id] if non-empty, or [Failure]
/// with [SchemaFieldRequiredError] if the string is empty or only
/// whitespace.
Result<String> validateLocationId(String id) {
  if (id.trim().isEmpty) {
    return Result.failure(
      SchemaFieldRequiredError(fieldName: 'id', schemaName: 'Location'),
    );
  }
  return Result.success(id);
}

/// Realises: [Feat-047/validateDuplicateChassisId]
///
/// Validates that no two [ContainedChassis] entries in [chassis] share
/// the same [chassisId] value, enforcing the YANG list key uniqueness
/// constraint in ietf-ni-location.yang § contained-chassis.
///
/// Returns [Success] with the list if all chassis-id values are unique,
/// or [Failure] with [DuplicateChassisIdError] identifying the first
/// duplicate encountered.
Result<List<ContainedChassis>> validateDuplicateChassisId(
    List<ContainedChassis> chassis) {
  final seen = <int>{};
  for (final c in chassis) {
    if (!seen.add(c.chassisId)) {
      return Result.failure(DuplicateChassisIdError(chassisId: c.chassisId));
    }
  }
  return Result.success(chassis);
}

/// Realises: [Feat-047/validateCyclicParent]
///
/// Validates that setting [parentId] as the parent of [locationId] would
/// not create a cyclic reference chain. Walks the parent tree from
/// [parentId] through [allLocations] to ensure [locationId] is never
/// encountered.
///
/// Returns [Success] with [parentId] if the reference is acyclic (or
/// [parentId] is null), or [Failure] with [CyclicParentReferenceError]
/// if a cycle is detected.
Result<String> validateCyclicParent(
  String locationId,
  String? parentId,
  List<Location> allLocations,
) {
  if (parentId == null) return Result.success('');

  if (parentId == locationId) {
    return Result.failure(
      CyclicParentReferenceError(locationId: locationId, parentId: parentId),
    );
  }

  final locationMap = <String, Location>{};
  for (final loc in allLocations) {
    locationMap[loc.id] = loc;
  }

  var current = parentId;
  final visited = <String>{};
  while (current.isNotEmpty) {
    if (current == locationId) {
      return Result.failure(
        CyclicParentReferenceError(
            locationId: locationId, parentId: parentId),
      );
    }
    if (!visited.add(current)) {
      return Result.failure(
        CyclicParentReferenceError(
            locationId: locationId, parentId: parentId),
      );
    }
    final parentLoc = locationMap[current];
    if (parentLoc == null || parentLoc.parent == null) break;
    current = parentLoc.parent!;
  }
  return Result.success(parentId);
}

/// Realises: [Feat-047/validatePhysicalAddress]
///
/// Validates a [PhysicalAddress] instance. If [PhysicalAddress.countryCode]
/// is non-null, validates it against the ISO 3166-1 alpha-2 pattern.
/// Null countryCode is allowed (the field is optional).
///
/// Returns [Success] with the address if valid, or [Failure] with
/// [CountryCodeValidationError] if the country code fails validation.
Result<PhysicalAddress> validatePhysicalAddress(PhysicalAddress addr) {
  if (addr.countryCode != null) {
    final result = validateCountryCode(addr.countryCode!);
    if (result.isFailure) {
      return Result.failure((result as Failure<String>).error);
    }
  }
  return Result.success(addr);
}

/// Realises: [Feat-047/validateLocation]
///
/// Aggregate validation for a [Location] model, running all applicable
/// checks in sequence:
///
/// 1. [validateLocationId] — ensures [Location.id] is non-empty.
/// 2. [validateCountryCode] — if [Location.physicalAddress] has a
///    non-null country code, validates it against the ISO pattern.
/// 3. [validateDuplicateChassisId] — ensures no duplicate chassis-id
///    values in [Location.containedChassis].
///
/// Returns [Success] with the model if all checks pass, or [Failure]
/// with the first-encountered domain error.
Result<Location> validateLocation(Location model) {
  final idResult = validateLocationId(model.id);
  if (idResult.isFailure) {
    return Result.failure((idResult as Failure<String>).error);
  }

  if (model.physicalAddress != null) {
    final addrResult = validatePhysicalAddress(model.physicalAddress!);
    if (addrResult.isFailure) {
      return Result.failure((addrResult as Failure<PhysicalAddress>).error);
    }
  }

  final chassisResult = validateDuplicateChassisId(model.containedChassis);
  if (chassisResult.isFailure) {
    return Result.failure(
      (chassisResult as Failure<List<ContainedChassis>>).error,
    );
  }

  return Result.success(model);
}
