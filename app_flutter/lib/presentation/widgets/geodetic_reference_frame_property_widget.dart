import 'package:app_flutter/domain/models/geodetic_reference_frame_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/geodetic_reference_frame_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-034/GeodeticReferenceFramePropertyWidget]
///
/// Property panel widget for displaying and editing geodetic reference
/// frame data defined in ietf-geo-location (RFC 9179 § reference-frame).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [GeodeticReferenceFrameViewModel] via [ListenableBuilder]
/// for reactive state rendering.
class GeodeticReferenceFramePropertyWidget extends StatelessWidget {
  /// Creates a [GeodeticReferenceFramePropertyWidget] bound to [viewModel].
  const GeodeticReferenceFramePropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final GeodeticReferenceFrameViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-geo-location:reference-frame)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'geodeticReferenceFrame',
    displayName: _headerText,
    iconName: 'public',
    fields: [
      FieldDescriptor(
        key: kFieldAstronomicalBody,
        label: 'Astronomical Body',
        type: 'string',
        valueResolver: (model) =>
            (model as GeodeticReferenceFrame).astronomicalBody,
        valueWriter: (model, value) {
          final m = model as GeodeticReferenceFrame;
          return GeodeticReferenceFrame(
            containerId: m.containerId,
            astronomicalBody: value,
            alternateSystem: m.alternateSystem,
            alternateSystems: m.alternateSystems,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldAlternateSystem,
        label: 'Alternate System',
        type: 'string',
        valueResolver: (model) =>
            (model as GeodeticReferenceFrame).alternateSystem ?? '-',
        valueWriter: (model, value) {
          final m = model as GeodeticReferenceFrame;
          return GeodeticReferenceFrame(
            containerId: m.containerId,
            astronomicalBody: m.astronomicalBody,
            alternateSystem: value,
            alternateSystems: m.alternateSystems,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldAlternateSystems,
        label: 'Alternate Systems Feature',
        type: 'string',
        valueResolver: (model) =>
            '${(model as GeodeticReferenceFrame).alternateSystems}',
        valueWriter: (model, value) {
          final m = model as GeodeticReferenceFrame;
          final enabled = value.toLowerCase() == 'true';
          return GeodeticReferenceFrame(
            containerId: m.containerId,
            astronomicalBody: m.astronomicalBody,
            alternateSystem: m.alternateSystem,
            alternateSystems: enabled,
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
