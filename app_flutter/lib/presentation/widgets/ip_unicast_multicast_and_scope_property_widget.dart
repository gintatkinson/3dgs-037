import 'package:app_flutter/domain/models/ip_unicast_multicast_and_scope_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/ip_unicast_multicast_and_scope_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-023/IpUnicastMulticastAndScopePropertyWidget]
///
/// Property panel widget for displaying and editing IP unicast, multicast,
/// flow label, DSCP, and scope data types defined in ietf-inet-types
/// (RFC 6021).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to an [IpUnicastMulticastAndScopeViewModel] via
/// [ListenableBuilder] for reactive state rendering.
class IpUnicastMulticastAndScopePropertyWidget extends StatelessWidget {
  /// Creates an [IpUnicastMulticastAndScopePropertyWidget] bound to
  /// [viewModel].
  const IpUnicastMulticastAndScopePropertyWidget(
      {super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final IpUnicastMulticastAndScopeViewModel viewModel;

  static const String _headerText =
      'PropertyGrid (/ietf-inet-types:ip-multicast-scope)';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'ipUnicastMulticastAndScopeTypes',
    displayName: _headerText,
    iconName: 'dns',
    fields: [
      FieldDescriptor(
        key: kFieldContainerId,
        label: 'Container ID',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes).containerId,
        valueWriter: (model, value) => IpUnicastMulticastAndScopeTypes(
          containerId: value,
          ipv6FlowLabel:
              (model as IpUnicastMulticastAndScopeTypes).ipv6FlowLabel,
          dscp: model.dscp,
        ),
      ),
      FieldDescriptor(
        key: kFieldIpv6FlowLabel,
        label: 'IPv6 Flow Label',
        type: 'int',
        minValue: 0,
        maxValue: 1048575,
        valueResolver: (model) =>
            '${(model as IpUnicastMulticastAndScopeTypes).ipv6FlowLabel}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            final m = model as IpUnicastMulticastAndScopeTypes;
            return IpUnicastMulticastAndScopeTypes(
              containerId: m.containerId,
              ipv6FlowLabel: parsed,
              dscp: m.dscp,
            );
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldDscp,
        label: 'DSCP',
        type: 'int',
        minValue: 0,
        maxValue: 63,
        valueResolver: (model) =>
            '${(model as IpUnicastMulticastAndScopeTypes).dscp}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            final m = model as IpUnicastMulticastAndScopeTypes;
            return IpUnicastMulticastAndScopeTypes(
              containerId: m.containerId,
              ipv6FlowLabel: m.ipv6FlowLabel,
              dscp: parsed,
            );
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldIpUnicastAddress,
        label: 'IP Unicast Address',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes).ipUnicastAddress ??
            '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            ipUnicastAddress: value,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldIpv4UnicastAddress,
        label: 'IPv4 Unicast Address',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes).ipv4UnicastAddress ??
            '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            ipv4UnicastAddress: value,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldIpv6UnicastAddress,
        label: 'IPv6 Unicast Address',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes).ipv6UnicastAddress ??
            '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            ipv6UnicastAddress: value,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldIpMulticastAddress,
        label: 'IP Multicast Address',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes).ipMulticastAddress ??
            '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            ipMulticastAddress: value,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldIpv4MulticastAddress,
        label: 'IPv4 Multicast Address',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes)
                    .ipv4MulticastAddress ??
                '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            ipv4MulticastAddress: value,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldIpv6MulticastAddress,
        label: 'IPv6 Multicast Address',
        type: 'string',
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes)
                    .ipv6MulticastAddress ??
                '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            ipv6MulticastAddress: value,
          );
        },
      ),
      FieldDescriptor(
        key: kFieldScopeType,
        label: 'Scope Type',
        type: 'enum',
        enumOptions: [
          'interface-local',
          'link-local',
          'admin-local',
          'site-local',
          'organization-local',
          'global',
        ],
        valueResolver: (model) =>
            (model as IpUnicastMulticastAndScopeTypes).scopeType ?? '-',
        valueWriter: (model, value) {
          final m = model as IpUnicastMulticastAndScopeTypes;
          return IpUnicastMulticastAndScopeTypes(
            containerId: m.containerId,
            ipv6FlowLabel: m.ipv6FlowLabel,
            dscp: m.dscp,
            scopeType: value,
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
