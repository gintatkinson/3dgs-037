import 'package:app_flutter/domain/models/address_and_string_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/address_and_string_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-004/AddressAndStringPropertyWidget]
///
/// Property panel widget for displaying address and string type fields
/// defined in ietf-yang-types (RFC 9911).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to an [AddressAndStringViewModel] via [ListenableBuilder] for
/// reactive state rendering.
class AddressAndStringPropertyWidget extends StatelessWidget {
  /// Creates an [AddressAndStringPropertyWidget] bound to [viewModel].
  const AddressAndStringPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final AddressAndStringViewModel viewModel;

  static const String _headerText = 'Address and String Types';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'addressAndStringTypes',
    displayName: _headerText,
    iconName: 'dns',
    fields: [
      const FieldDescriptor(
        key: 'physAddress',
        label: 'Physical Address (phys-address)',
        type: 'string',
        pattern: r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$',
      ),
      const FieldDescriptor(
        key: 'macAddress',
        label: 'MAC Address (mac-address)',
        type: 'string',
        pattern: r'^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$',
      ),
      const FieldDescriptor(
        key: 'hexString',
        label: 'Hex String (hex-string)',
        type: 'string',
        pattern: r'^([0-9a-fA-F]{2}(:[0-9a-fA-F]{2})*)?$',
      ),
      const FieldDescriptor(
        key: 'dottedQuad',
        label: 'Dotted Quad (dotted-quad)',
        type: 'string',
      ),
      const FieldDescriptor(
        key: 'languageTag',
        label: 'Language Tag (language-tag)',
        type: 'string',
      ),
      const FieldDescriptor(
        key: 'xpath10',
        label: 'XPath 1.0 (xpath1.0)',
        type: 'string',
      ),
    ],
    childTypes: const [],
    relatedTypes: const [],
    parentTypes: const [],
  );

  static String _formatValue(
      FieldDescriptor field, AddressAndStringTypes model) {
    return switch (field.key) {
      'physAddress' => model.physAddress,
      'macAddress' => model.macAddress,
      'hexString' => model.hexString,
      'dottedQuad' => model.dottedQuad,
      'languageTag' => model.languageTag,
      'xpath10' => model.xpath10,
      _ => '-',
    };
  }

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
          return const Center(
            child: Text('No model loaded'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _typeDescriptor.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Container: ${model.containerId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _typeDescriptor.fields.length,
                  itemBuilder: (context, index) {
                    final field = _typeDescriptor.fields[index];
                    final value = _formatValue(field, model);
                    return _PropertyRow(
                      field: field,
                      value: value,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single property row rendered from a [FieldDescriptor].
///
/// Displays the field label and current value in a read-only card layout.
class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.field,
    required this.value,
  });

  final FieldDescriptor field;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(field.label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              flex: 1,
              child: Text(value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                  textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
