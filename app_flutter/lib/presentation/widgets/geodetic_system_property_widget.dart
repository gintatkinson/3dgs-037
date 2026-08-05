import 'package:app_flutter/domain/models/geodetic_system_and_accuracy_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/geodetic_system_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-035/GeodeticSystemPropertyWidget]
///
/// Property panel widget for displaying and editing geodetic system
/// data defined in ietf-geo-location (RFC 9179 § reference-frame/geodetic-system).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [GeodeticSystemViewModel] via [ListenableBuilder]
/// for reactive state rendering.
class GeodeticSystemPropertyWidget extends StatelessWidget {
  /// Creates a [GeodeticSystemPropertyWidget] bound to [viewModel].
  const GeodeticSystemPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final GeodeticSystemViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-geo-location:geodetic-system)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'geodeticSystem',
    displayName: _headerText,
    iconName: 'public',
    fields: [
      FieldDescriptor(
        key: kFieldGeodeticDatum,
        label: 'Geodetic Datum',
        type: 'string',
        valueResolver: (model) =>
            (model as GeodeticSystem).geodeticDatum,
        valueWriter: (model, value) {
          final m = model as GeodeticSystem;
          return GeodeticSystem(
            containerId: m.containerId,
            geodeticDatum: value,
            coordAccuracy: m.coordAccuracy,
            heightAccuracy: m.heightAccuracy,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldCoordAccuracy,
        label: 'Coordinate Accuracy',
        type: 'string',
        valueResolver: (model) =>
            '${(model as GeodeticSystem).coordAccuracy ?? '-'}',
        valueWriter: (model, value) {
          final m = model as GeodeticSystem;
          final parsed = double.tryParse(value);
          return GeodeticSystem(
            containerId: m.containerId,
            geodeticDatum: m.geodeticDatum,
            coordAccuracy: parsed,
            heightAccuracy: m.heightAccuracy,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldHeightAccuracy,
        label: 'Height Accuracy (m)',
        type: 'string',
        valueResolver: (model) =>
            '${(model as GeodeticSystem).heightAccuracy ?? '-'}',
        valueWriter: (model, value) {
          final m = model as GeodeticSystem;
          final parsed = double.tryParse(value);
          return GeodeticSystem(
            containerId: m.containerId,
            geodeticDatum: m.geodeticDatum,
            coordAccuracy: m.coordAccuracy,
            heightAccuracy: parsed,
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
