import 'package:app_flutter/domain/models/counter_and_gauge_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/counter_and_gauge_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-001/CounterAndGaugePropertyWidget]
///
/// Property panel widget for displaying and editing counter and gauge
/// numeric types defined in ietf-yang-types (RFC 9911).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [CounterAndGaugeViewModel] via [ListenableBuilder] for
/// reactive state rendering.
class CounterAndGaugePropertyWidget extends StatelessWidget {
  /// Creates a [CounterAndGaugePropertyWidget] bound to [viewModel].
  const CounterAndGaugePropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations.
  final CounterAndGaugeViewModel viewModel;

  static const String _headerText = 'Counter and Gauge Types';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'counterAndGaugeTypes',
    displayName: _headerText,
    iconName: 'speed',
    fields: [
      FieldDescriptor(
        key: kFieldCounter32,
        label: 'Counter32',
        type: 'int',
        minValue: 0,
        maxValue: CounterAndGaugeTypes.kMaxUint32,
        valueResolver: (model) => '${(model as CounterAndGaugeTypes).counter32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as CounterAndGaugeTypes).copyWith(counter32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldZeroBasedCounter32,
        label: 'Zero Based Counter32',
        type: 'int',
        minValue: 0,
        maxValue: CounterAndGaugeTypes.kMaxUint32,
        valueResolver: (model) => '${(model as CounterAndGaugeTypes).zeroBasedCounter32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as CounterAndGaugeTypes)
                .copyWith(zeroBasedCounter32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldCounter64,
        label: 'Counter64',
        type: 'int',
        minValue: 0,
        valueResolver: (model) => '${(model as CounterAndGaugeTypes).counter64}',
        valueWriter: (model, value) {
          final parsed = BigInt.tryParse(value);
          if (parsed != null) {
            return (model as CounterAndGaugeTypes).copyWith(counter64: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldZeroBasedCounter64,
        label: 'Zero Based Counter64',
        type: 'int',
        minValue: 0,
        valueResolver: (model) =>
            '${(model as CounterAndGaugeTypes).zeroBasedCounter64}',
        valueWriter: (model, value) {
          final parsed = BigInt.tryParse(value);
          if (parsed != null) {
            return (model as CounterAndGaugeTypes)
                .copyWith(zeroBasedCounter64: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldGauge32,
        label: 'Gauge32',
        type: 'int',
        minValue: 0,
        maxValue: CounterAndGaugeTypes.kMaxUint32,
        valueResolver: (model) => '${(model as CounterAndGaugeTypes).gauge32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as CounterAndGaugeTypes).copyWith(gauge32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldGauge64,
        label: 'Gauge64',
        type: 'int',
        minValue: 0,
        valueResolver: (model) => '${(model as CounterAndGaugeTypes).gauge64}',
        valueWriter: (model, value) {
          final parsed = BigInt.tryParse(value);
          if (parsed != null) {
            return (model as CounterAndGaugeTypes).copyWith(gauge64: parsed);
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
                    return _PropertyRow(
                      field: field,
                      model: model,
                      viewModel: viewModel,
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
/// Displays the field label and current value, with increment/decrement
/// buttons for counter and gauge operations.
class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.field,
    required this.model,
    required this.viewModel,
  });

  final FieldDescriptor field;
  final CounterAndGaugeTypes model;
  final CounterAndGaugeViewModel viewModel;

  static const int _step = 5;

  Widget? _buildButton() {
    switch (field.key) {
      case kFieldCounter32:
      case kFieldZeroBasedCounter32:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: ValueKey('inc_${field.key}'),
              icon: const Icon(Icons.add),
              onPressed: () => viewModel.incrementCounter32(_step),
              tooltip: '+$_step',
            ),
          ],
        );
      case kFieldCounter64:
      case kFieldZeroBasedCounter64:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: ValueKey('inc_${field.key}'),
              icon: const Icon(Icons.add),
              onPressed: () =>
                  viewModel.incrementCounter64(BigInt.from(_step)),
              tooltip: '+$_step',
            ),
          ],
        );
      case kFieldGauge32:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: ValueKey('dec_${field.key}'),
              icon: const Icon(Icons.remove),
              onPressed: () => viewModel.updateGauge32(-_step),
              tooltip: '-$_step',
            ),
            IconButton(
              key: ValueKey('inc_${field.key}'),
              icon: const Icon(Icons.add),
              onPressed: () => viewModel.updateGauge32(_step),
              tooltip: '+$_step',
            ),
          ],
        );
      case kFieldGauge64:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: ValueKey('dec_${field.key}'),
              icon: const Icon(Icons.remove),
              onPressed: () =>
                  viewModel.updateGauge64(BigInt.from(-_step)),
              tooltip: '-$_step',
            ),
            IconButton(
              key: ValueKey('inc_${field.key}'),
              icon: const Icon(Icons.add),
              onPressed: () =>
                  viewModel.updateGauge64(BigInt.from(_step)),
              tooltip: '+$_step',
            ),
          ],
        );
      default:
        return null;
    }
  }

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
                  : Text(valueText,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.end),
            ),
            if (_buildButton() != null) _buildButton()!,
          ],
        ),
      ),
    );
  }
}
