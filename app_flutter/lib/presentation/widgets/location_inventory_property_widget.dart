import 'package:app_flutter/domain/models/location_inventory_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/location_inventory_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-047/LocationInventoryPropertyWidget]
///
/// Property panel widget for displaying and editing location inventory
/// data defined in ietf-ni-location.yang § locations/location.
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [LocationInventoryViewModel] via [ListenableBuilder]
/// for reactive state rendering.
class LocationInventoryPropertyWidget extends StatelessWidget {
  /// Creates a [LocationInventoryPropertyWidget] bound to [viewModel].
  const LocationInventoryPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final LocationInventoryViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-ni-location:locations/location)';

  TypeDescriptor get _typeDescriptor => TypeDescriptor(
        typeName: 'location',
        displayName: _headerText,
        iconName: 'location_on',
        fields: [
          FieldDescriptor(
            key: kFieldLocationId,
            label: 'Location ID',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).id,
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: value,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldUuid,
            label: 'UUID',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).uuid ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: value.isEmpty ? null : value,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldName,
            label: 'Name',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).name ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: value.isEmpty ? null : value,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldAlias,
            label: 'Alias',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).alias ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: value.isEmpty ? null : value,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldDescription,
            label: 'Description',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).description ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: value.isEmpty ? null : value,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldType,
            label: 'Type',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).type ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: value.isEmpty ? null : value,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldParent,
            label: 'Parent Location',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).parent ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: value.isEmpty ? null : value,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldTimestamp,
            label: 'Timestamp',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).timestamp ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: value.isEmpty ? null : value,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldValidUntil,
            label: 'Valid Until',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).validUntil ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: value.isEmpty ? null : value,
                physicalAddress: m.physicalAddress,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldAddress,
            label: 'Street Address',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).physicalAddress?.address ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newAddr = PhysicalAddress(
                address: value.isEmpty ? null : value,
                postalCode: m.physicalAddress?.postalCode,
                state: m.physicalAddress?.state,
                city: m.physicalAddress?.city,
                countryCode: m.physicalAddress?.countryCode,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: newAddr,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldPostalCode,
            label: 'Postal Code',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).physicalAddress?.postalCode ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newAddr = PhysicalAddress(
                address: m.physicalAddress?.address,
                postalCode: value.isEmpty ? null : value,
                state: m.physicalAddress?.state,
                city: m.physicalAddress?.city,
                countryCode: m.physicalAddress?.countryCode,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: newAddr,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldState,
            label: 'State',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).physicalAddress?.state ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newAddr = PhysicalAddress(
                address: m.physicalAddress?.address,
                postalCode: m.physicalAddress?.postalCode,
                state: value.isEmpty ? null : value,
                city: m.physicalAddress?.city,
                countryCode: m.physicalAddress?.countryCode,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: newAddr,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldCity,
            label: 'City',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).physicalAddress?.city ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newAddr = PhysicalAddress(
                address: m.physicalAddress?.address,
                postalCode: m.physicalAddress?.postalCode,
                state: m.physicalAddress?.state,
                city: value.isEmpty ? null : value,
                countryCode: m.physicalAddress?.countryCode,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: newAddr,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldCountryCode,
            label: 'Country Code',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).physicalAddress?.countryCode ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newAddr = PhysicalAddress(
                address: m.physicalAddress?.address,
                postalCode: m.physicalAddress?.postalCode,
                state: m.physicalAddress?.state,
                city: m.physicalAddress?.city,
                countryCode: value.isEmpty ? null : value,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: newAddr,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldBuilding,
            label: 'Building',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).buildingPosition?.building ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newBp = BuildingPosition(
                building: value.isEmpty ? null : value,
                floor: m.buildingPosition?.floor,
                room: m.buildingPosition?.room,
                roomBuildingPosition: m.buildingPosition?.roomBuildingPosition,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                buildingPosition: newBp,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldFloor,
            label: 'Floor',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).buildingPosition?.floor ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newBp = BuildingPosition(
                building: m.buildingPosition?.building,
                floor: value.isEmpty ? null : value,
                room: m.buildingPosition?.room,
                roomBuildingPosition: m.buildingPosition?.roomBuildingPosition,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                buildingPosition: newBp,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldRoom,
            label: 'Room',
            type: 'string',
            valueResolver: (model) =>
                (model as Location).buildingPosition?.room ?? '-',
            valueWriter: (model, value) {
              final m = model as Location;
              final newBp = BuildingPosition(
                building: m.buildingPosition?.building,
                floor: m.buildingPosition?.floor,
                room: value.isEmpty ? null : value,
                roomBuildingPosition: m.buildingPosition?.roomBuildingPosition,
              );
              final newLoc = Location(
                containerId: m.containerId,
                id: m.id,
                uuid: m.uuid,
                name: m.name,
                alias: m.alias,
                description: m.description,
                type: m.type,
                parent: m.parent,
                timestamp: m.timestamp,
                validUntil: m.validUntil,
                physicalAddress: m.physicalAddress,
                buildingPosition: newBp,
                containedChassis: m.containedChassis,
              );
              viewModel.update(newLoc, recordId: m.containerId);
              return newLoc;
            },
          ),
          FieldDescriptor(
            key: kFieldRoomBuildingPosition,
            label: 'Room Building Position',
            type: 'string',
            valueResolver: (model) {
              final m = model as Location;
              final bp = m.buildingPosition;
              if (bp == null) return '-';
              return formatRoomBuildingPosition(
                bp.building ?? '',
                bp.floor ?? '',
                bp.room ?? '',
              );
            },
          ),
          FieldDescriptor(
            key: kFieldContainedChassis,
            label: 'Contained Chassis',
            type: 'string',
            valueResolver: (model) {
              final m = model as Location;
              if (m.containedChassis.isEmpty) return '-';
              return m.containedChassis
                  .map((c) => '${c.chassisId} (${c.neRef ?? '-'})')
                  .join(', ');
            },
          ),
        ],
        childTypes: const [],
        relatedTypes: const [],
        parentTypes: const [],
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade100,
            child: Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final model = viewModel.model;
        if (model == null) {
          return const SizedBox.shrink();
        }

        final descriptor = _typeDescriptor;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  descriptor.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...descriptor.fields.map((field) {
                  return _PropertyRow(field: field, model: model);
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({required this.field, required this.model});

  final FieldDescriptor field;
  final dynamic model;

  @override
  Widget build(BuildContext context) {
    final valueText = field.valueResolver?.call(model) ?? '-';
    final isEditable = field.valueWriter != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                field.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 1,
              child: isEditable
                  ? TextField(
                      controller: TextEditingController(text: valueText),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyLarge,
                      onChanged: (value) {
                        field.valueWriter!.call(model, value);
                      },
                    )
                  : Text(
                      valueText,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.end,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
