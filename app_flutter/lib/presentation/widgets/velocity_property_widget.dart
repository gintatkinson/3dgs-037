import 'package:app_flutter/domain/models/velocity_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/velocity_viewmodel.dart';
import 'package:flutter/material.dart' hide Velocity;

/// Realises: [Feat-037/VelocityPropertyWidget]
///
/// Property panel widget for displaying and editing velocity
/// data defined in ietf-geo-location (RFC 9179 § geo-location/velocity).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [VelocityViewModel] via [ListenableBuilder]
/// for reactive state rendering.
class VelocityPropertyWidget extends StatelessWidget {
  /// Creates a [VelocityPropertyWidget] bound to [viewModel].
  const VelocityPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final VelocityViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-geo-location:velocity)';

  TypeDescriptor get _typeDescriptor => TypeDescriptor(
        typeName: 'velocity',
        displayName: _headerText,
        iconName: 'speed',
        fields: [
          FieldDescriptor(
            key: kFieldVNorth,
            label: 'v-north (m/s)',
            type: 'string',
            valueResolver: (model) =>
                '${(model as Velocity).vNorth ?? '-'}',
            valueWriter: (model, value) {
              final m = model as Velocity;
              final parsed = double.tryParse(value);
              final newVelocity = Velocity(
                containerId: m.containerId,
                vNorth: parsed ?? m.vNorth,
                vEast: m.vEast,
                vUp: m.vUp,
              );
              viewModel.update(newVelocity, recordId: m.containerId);
              return newVelocity;
            },
          ),
          FieldDescriptor(
            key: kFieldVEast,
            label: 'v-east (m/s)',
            type: 'string',
            valueResolver: (model) =>
                '${(model as Velocity).vEast ?? '-'}',
            valueWriter: (model, value) {
              final m = model as Velocity;
              final parsed = double.tryParse(value);
              final newVelocity = Velocity(
                containerId: m.containerId,
                vNorth: m.vNorth,
                vEast: parsed ?? m.vEast,
                vUp: m.vUp,
              );
              viewModel.update(newVelocity, recordId: m.containerId);
              return newVelocity;
            },
          ),
          FieldDescriptor(
            key: kFieldVUp,
            label: 'v-up (m/s)',
            type: 'string',
            valueResolver: (model) =>
                '${(model as Velocity).vUp ?? '-'}',
            valueWriter: (model, value) {
              final m = model as Velocity;
              final parsed = double.tryParse(value);
              final newVelocity = Velocity(
                containerId: m.containerId,
                vNorth: m.vNorth,
                vEast: m.vEast,
                vUp: parsed ?? m.vUp,
              );
              viewModel.update(newVelocity, recordId: m.containerId);
              return newVelocity;
            },
          ),
          FieldDescriptor(
            key: kFieldSpeed,
            label: 'Speed (m/s)',
            type: 'string',
            valueResolver: (model) {
              final m = model as Velocity;
              if (m.vNorth != null && m.vEast != null) {
                final speed = calculateSpeed(m.vNorth!, m.vEast!);
                return '$speed';
              }
              return '-';
            },
          ),
          FieldDescriptor(
            key: kFieldHeading,
            label: 'Heading (rad)',
            type: 'string',
            valueResolver: (model) {
              final m = model as Velocity;
              if (m.vNorth != null && m.vEast != null) {
                final heading = calculateHeading(m.vNorth!, m.vEast!);
                return '$heading';
              }
              return '-';
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
