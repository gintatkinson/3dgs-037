import 'package:app_flutter/domain/models/domain_name_and_host_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/domain_name_and_host_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-021/DomainNameAndHostPropertyWidget]
///
/// Property panel widget for displaying and editing domain name and host
/// data types defined in ietf-inet-types (RFC 6021):
/// domain-name, host, uri.
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [DomainNameAndHostViewModel] via [ListenableBuilder] for
/// reactive state rendering.
class DomainNameAndHostPropertyWidget extends StatelessWidget {
  /// Creates a [DomainNameAndHostPropertyWidget] bound to [viewModel].
  const DomainNameAndHostPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final DomainNameAndHostViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-inet-types:domain-name)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'domainNameAndHostTypes',
    displayName: _headerText,
    iconName: 'language',
    fields: [
      FieldDescriptor(
        key: kFieldContainerId,
        label: 'Container ID',
        type: 'string',
        valueResolver: (model) =>
            (model as DomainNameAndHostTypes).containerId,
        valueWriter: (model, value) => DomainNameAndHostTypes(
          containerId: value,
          domainName: (model as DomainNameAndHostTypes).domainName,
          host: model.host,
          uri: model.uri,
        ),
      ),
      FieldDescriptor(
        key: kFieldDomainName,
        label: 'Domain Name',
        type: 'string',
        valueResolver: (model) =>
            (model as DomainNameAndHostTypes).domainName,
        valueWriter: (model, value) {
          final m = model as DomainNameAndHostTypes;
          return DomainNameAndHostTypes(
            containerId: m.containerId,
            domainName: value,
            host: m.host,
            uri: m.uri,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldHost,
        label: 'Host',
        type: 'string',
        valueResolver: (model) => (model as DomainNameAndHostTypes).host,
        valueWriter: (model, value) {
          final m = model as DomainNameAndHostTypes;
          return DomainNameAndHostTypes(
            containerId: m.containerId,
            domainName: m.domainName,
            host: value,
            uri: m.uri,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldUri,
        label: 'URI',
        type: 'string',
        valueResolver: (model) => (model as DomainNameAndHostTypes).uri,
        valueWriter: (model, value) {
          final m = model as DomainNameAndHostTypes;
          return DomainNameAndHostTypes(
            containerId: m.containerId,
            domainName: m.domainName,
            host: m.host,
            uri: value,
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
