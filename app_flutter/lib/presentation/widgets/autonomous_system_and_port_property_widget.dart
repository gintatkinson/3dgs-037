import 'package:app_flutter/domain/models/autonomous_system_and_port_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/autonomous_system_and_port_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-022/AutonomousSystemAndPortPropertyWidget]
///
/// Property panel widget for displaying and editing Autonomous System and
/// port number data types defined in ietf-inet-types (RFC 6021).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to an [AutonomousSystemAndPortViewModel] via [ListenableBuilder]
/// for reactive state rendering.
class AutonomousSystemAndPortPropertyWidget extends StatelessWidget {
  /// Creates an [AutonomousSystemAndPortPropertyWidget] bound to [viewModel].
  const AutonomousSystemAndPortPropertyWidget(
      {super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final AutonomousSystemAndPortViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-inet-types:as-number)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'autonomousSystemAndPortTypes',
    displayName: _headerText,
    iconName: 'dns',
    fields: [
      FieldDescriptor(
        key: kFieldContainerId,
        label: 'Container ID',
        type: 'string',
        valueResolver: (model) =>
            (model as AutonomousSystemAndPortTypes).containerId,
        valueWriter: (model, value) => AutonomousSystemAndPortTypes(
          containerId: value,
          asNumber: (model as AutonomousSystemAndPortTypes).asNumber,
          portNumber: model.portNumber,
        ),
      ),
      FieldDescriptor(
        key: kFieldAsNumber,
        label: 'AS Number',
        type: 'int',
        minValue: 0,
        maxValue: 4294967295,
        valueResolver: (model) =>
            '${(model as AutonomousSystemAndPortTypes).asNumber}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            final m = model as AutonomousSystemAndPortTypes;
            return AutonomousSystemAndPortTypes(
              containerId: m.containerId,
              asNumber: parsed,
              portNumber: m.portNumber,
            );
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldPortNumber,
        label: 'Port Number',
        type: 'int',
        minValue: 0,
        maxValue: 65535,
        valueResolver: (model) =>
            '${(model as AutonomousSystemAndPortTypes).portNumber}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            final m = model as AutonomousSystemAndPortTypes;
            return AutonomousSystemAndPortTypes(
              containerId: m.containerId,
              asNumber: m.asNumber,
              portNumber: parsed,
            );
          }
          return model;
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
