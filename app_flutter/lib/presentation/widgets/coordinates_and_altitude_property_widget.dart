import 'package:app_flutter/domain/models/coordinates_and_altitude_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/coordinates_and_altitude_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-036/CoordinatesAndAltitudePropertyWidget]
///
/// Property panel widget for displaying and editing geographic coordinate
/// and altitude data defined in ietf-geo-location (RFC 9179 § geo-location).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [CoordinatesAndAltitudeViewModel] via [ListenableBuilder]
/// for reactive state rendering.
class CoordinatesAndAltitudePropertyWidget extends StatelessWidget {
  /// Creates a [CoordinatesAndAltitudePropertyWidget] bound to [viewModel].
  const CoordinatesAndAltitudePropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final CoordinatesAndAltitudeViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-geo-location:coordinates)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'geoLocation',
    displayName: _headerText,
    iconName: 'public',
    fields: [
      FieldDescriptor(
        key: kFieldTimestamp,
        label: 'Timestamp',
        type: 'string',
        valueResolver: (model) =>
            (model as GeoLocation).timestamp ?? '-',
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          return GeoLocation(
            containerId: m.containerId,
            timestamp: value.isEmpty ? null : value,
            validUntil: m.validUntil,
            ellipsoid: m.ellipsoid,
            cartesian: m.cartesian,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldValidUntil,
        label: 'Valid Until',
        type: 'string',
        valueResolver: (model) =>
            (model as GeoLocation).validUntil ?? '-',
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: value.isEmpty ? null : value,
            ellipsoid: m.ellipsoid,
            cartesian: m.cartesian,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldLatitude,
        label: 'Latitude',
        type: 'string',
        valueResolver: (model) {
          final m = model as GeoLocation;
          if (m.ellipsoid != null) return '${m.ellipsoid!.latitude}';
          return '-';
        },
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          final parsed = double.tryParse(value);
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: m.validUntil,
            ellipsoid: EllipsoidalCoordinates(
              latitude: parsed ?? (m.ellipsoid?.latitude ?? 0.0),
              longitude: m.ellipsoid?.longitude ?? 0.0,
              height: m.ellipsoid?.height,
            ),
            cartesian: m.cartesian,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldLongitude,
        label: 'Longitude',
        type: 'string',
        valueResolver: (model) {
          final m = model as GeoLocation;
          if (m.ellipsoid != null) return '${m.ellipsoid!.longitude}';
          return '-';
        },
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          final parsed = double.tryParse(value);
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: m.validUntil,
            ellipsoid: EllipsoidalCoordinates(
              latitude: m.ellipsoid?.latitude ?? 0.0,
              longitude: parsed ?? (m.ellipsoid?.longitude ?? 0.0),
              height: m.ellipsoid?.height,
            ),
            cartesian: m.cartesian,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldHeight,
        label: 'Height (m)',
        type: 'string',
        valueResolver: (model) {
          final m = model as GeoLocation;
          if (m.ellipsoid != null) return '${m.ellipsoid!.height ?? '-'}';
          return '-';
        },
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          final parsed = double.tryParse(value);
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: m.validUntil,
            ellipsoid: EllipsoidalCoordinates(
              latitude: m.ellipsoid?.latitude ?? 0.0,
              longitude: m.ellipsoid?.longitude ?? 0.0,
              height: parsed,
            ),
            cartesian: m.cartesian,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldCartesianX,
        label: 'X (m)',
        type: 'string',
        valueResolver: (model) {
          final m = model as GeoLocation;
          if (m.cartesian != null) return '${m.cartesian!.x}';
          return '-';
        },
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          final parsed = double.tryParse(value);
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: m.validUntil,
            ellipsoid: m.ellipsoid,
            cartesian: CartesianCoordinates(
              x: parsed ?? (m.cartesian?.x ?? 0.0),
              y: m.cartesian?.y ?? 0.0,
              z: m.cartesian?.z ?? 0.0,
            ),
          );
        },
      ),
      FieldDescriptor(
        key: kFieldCartesianY,
        label: 'Y (m)',
        type: 'string',
        valueResolver: (model) {
          final m = model as GeoLocation;
          if (m.cartesian != null) return '${m.cartesian!.y}';
          return '-';
        },
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          final parsed = double.tryParse(value);
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: m.validUntil,
            ellipsoid: m.ellipsoid,
            cartesian: CartesianCoordinates(
              x: m.cartesian?.x ?? 0.0,
              y: parsed ?? (m.cartesian?.y ?? 0.0),
              z: m.cartesian?.z ?? 0.0,
            ),
          );
        },
      ),
      FieldDescriptor(
        key: kFieldCartesianZ,
        label: 'Z (m)',
        type: 'string',
        valueResolver: (model) {
          final m = model as GeoLocation;
          if (m.cartesian != null) return '${m.cartesian!.z}';
          return '-';
        },
        valueWriter: (model, value) {
          final m = model as GeoLocation;
          final parsed = double.tryParse(value);
          return GeoLocation(
            containerId: m.containerId,
            timestamp: m.timestamp,
            validUntil: m.validUntil,
            ellipsoid: m.ellipsoid,
            cartesian: CartesianCoordinates(
              x: m.cartesian?.x ?? 0.0,
              y: m.cartesian?.y ?? 0.0,
              z: parsed ?? (m.cartesian?.z ?? 0.0),
            ),
          );
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

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _typeDescriptor.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ..._typeDescriptor.fields.map((field) {
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
