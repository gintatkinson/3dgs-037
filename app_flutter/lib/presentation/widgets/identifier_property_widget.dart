import 'package:app_flutter/domain/models/identifier_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/identifier_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-002/IdentifierPropertyWidget]
///
/// Property panel widget for displaying identifier data types defined in
/// ietf-yang-types (RFC 9911): object-identifier, object-identifier-128,
/// uuid, and yang-identifier.
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to an [IdentifierViewModel] via [ListenableBuilder] for
/// reactive state rendering.
class IdentifierPropertyWidget extends StatelessWidget {
  /// Creates an [IdentifierPropertyWidget] bound to [viewModel].
  const IdentifierPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final IdentifierViewModel viewModel;

  static const String _headerText = 'Identifier Types';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'identifierTypes',
    displayName: _headerText,
    iconName: 'fingerprint',
    fields: [
      FieldDescriptor(
        key: kFieldContainerId,
        label: 'Container ID',
        type: 'string',
        valueResolver: (model) => (model as IdentifierTypes).containerId,
        valueWriter: (model, value) =>
            (model as IdentifierTypes).copyWith(containerId: value),
      ),
      FieldDescriptor(
        key: kFieldObjectIdentifier,
        label: 'Object Identifier',
        type: 'string',
        valueResolver: (model) =>
            (model as IdentifierTypes).objectIdentifier,
        valueWriter: (model, value) =>
            (model as IdentifierTypes).copyWith(objectIdentifier: value),
      ),
      FieldDescriptor(
        key: kFieldObjectIdentifier128,
        label: 'Object Identifier 128',
        type: 'string',
        valueResolver: (model) =>
            (model as IdentifierTypes).objectIdentifier128,
        valueWriter: (model, value) =>
            (model as IdentifierTypes).copyWith(objectIdentifier128: value),
      ),
      FieldDescriptor(
        key: kFieldUuid,
        label: 'UUID',
        type: 'string',
        valueResolver: (model) => (model as IdentifierTypes).uuid,
        valueWriter: (model, value) =>
            (model as IdentifierTypes).copyWith(uuid: value),
      ),
      FieldDescriptor(
        key: kFieldYangIdentifier,
        label: 'YANG Identifier',
        type: 'string',
        valueResolver: (model) => (model as IdentifierTypes).yangIdentifier,
        valueWriter: (model, value) =>
            (model as IdentifierTypes).copyWith(yangIdentifier: value),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _typeDescriptor.displayName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _typeDescriptor.fields.length,
                  itemBuilder: (context, index) {
                    final field = _typeDescriptor.fields[index];
                    return _PropertyRow(field: field, model: model);
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
/// Renders an editable TextField when the field has a valueWriter,
/// or a read-only Text widget otherwise.
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
              child: Text(field.label,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              flex: 3,
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
                  : Text(valueText,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
