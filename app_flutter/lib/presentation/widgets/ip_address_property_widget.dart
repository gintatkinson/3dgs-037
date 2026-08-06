import 'package:app_flutter/domain/models/ip_address_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/ip_address_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-020/IpAddressPropertyWidget]
///
/// Property panel widget for displaying and editing IP address data types
/// defined in ietf-inet-types (RFC 6021).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to an [IpAddressViewModel] via [ListenableBuilder] for
/// reactive state rendering.
class IpAddressPropertyWidget extends StatelessWidget {
  /// Creates an [IpAddressPropertyWidget] bound to [viewModel].
  const IpAddressPropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final IpAddressViewModel viewModel;

  static const String _headerText = 'PropertyGrid (/ietf-inet-types:ip-address)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'ipAddressTypes',
    displayName: _headerText,
    iconName: 'dns',
    fields: [
      FieldDescriptor(
        key: kFieldContainerId,
        label: 'Container ID',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).containerId,
        valueWriter: (model, value) =>
            IpAddressTypes(containerId: value, ipVersion: (model as IpAddressTypes).ipVersion),
      ),
      FieldDescriptor(
        key: kFieldIpVersion,
        label: 'IP Version',
        type: 'string',
        valueResolver: (model) => '${(model as IpAddressTypes).ipVersion}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            final m = model as IpAddressTypes;
            return IpAddressTypes(containerId: m.containerId, ipVersion: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldIpAddress,
        label: 'IP Address',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipAddress ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipAddress: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpv4Address,
        label: 'IPv4 Address',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipv4Address ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipv4Address: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpv6Address,
        label: 'IPv6 Address',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipv6Address ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipv6Address: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpPrefix,
        label: 'IP Prefix',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipPrefix ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipPrefix: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpv4Prefix,
        label: 'IPv4 Prefix',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipv4Prefix ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipv4Prefix: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpv6Prefix,
        label: 'IPv6 Prefix',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipv6Prefix ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipv6Prefix: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpAddressNoZone,
        label: 'IP Address (No Zone)',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipAddressNoZone ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipAddressNoZone: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpv4AddressNoZone,
        label: 'IPv4 Address (No Zone)',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipv4AddressNoZone ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipv4AddressNoZone: value);
        },
      ),
      FieldDescriptor(
        key: kFieldIpv6AddressNoZone,
        label: 'IPv6 Address (No Zone)',
        type: 'string',
        valueResolver: (model) => (model as IpAddressTypes).ipv6AddressNoZone ?? '-',
        valueWriter: (model, value) {
          final m = model as IpAddressTypes;
          return IpAddressTypes(containerId: m.containerId, ipVersion: m.ipVersion, ipv6AddressNoZone: value);
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
