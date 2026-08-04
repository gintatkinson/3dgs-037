import 'package:flutter/material.dart';
import 'package:app_flutter/presentation/viewmodels/counter_and_gauge_viewmodel.dart';

/// Realises: [Feat-001/CounterAndGaugePropertyWidget]
///
/// Presentation layer widget displaying dynamic PropertyGrid items for 32-bit and 64-bit counter and gauge numeric types.
/// Consumes [CounterAndGaugeViewModel] via [ListenableBuilder] to re-render UI on state change.
class CounterAndGaugePropertyWidget extends StatelessWidget {
  /// Creates a [CounterAndGaugePropertyWidget] instance with injected [CounterAndGaugeViewModel].
  const CounterAndGaugePropertyWidget({
    super.key,
    required this.viewModel,
  });

  /// View model managing presentation state and user actions for counter and gauge types.
  final CounterAndGaugeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              key: Key('loading_indicator'),
            ),
          );
        }

        final model = viewModel.model;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (viewModel.errorMessage != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    viewModel.errorMessage!,
                    key: const Key('error_message'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
              const Text(
                'PropertyGrid (/yang:counter-and-gauge-types)',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      // counter32
                      _PropertyRow(
                        title: 'counter32',
                        valueWidget: Text(
                          '${model.counter32}',
                          key: const Key('counter32_value'),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        actions: <Widget>[
                          ElevatedButton.icon(
                            key: const Key('increment_counter32_button'),
                            onPressed: () => viewModel.incrementCounter32(1),
                            icon: const Icon(Icons.add),
                            label: const Text('+1'),
                          ),
                        ],
                      ),
                      const Divider(),

                      // zeroBasedCounter32
                      _PropertyRow(
                        title: 'zeroBasedCounter32',
                        valueWidget: Text(
                          '${model.zeroBasedCounter32}',
                          key: const Key('zero_based_counter32_value'),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      const Divider(),

                      // counter64
                      _PropertyRow(
                        title: 'counter64',
                        valueWidget: Text(
                          '${model.counter64}',
                          key: const Key('counter64_value'),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        actions: <Widget>[
                          ElevatedButton.icon(
                            key: const Key('increment_counter64_button'),
                            onPressed: () => viewModel.incrementCounter64(BigInt.one),
                            icon: const Icon(Icons.add),
                            label: const Text('+1'),
                          ),
                        ],
                      ),
                      const Divider(),

                      // zeroBasedCounter64
                      _PropertyRow(
                        title: 'zeroBasedCounter64',
                        valueWidget: Text(
                          '${model.zeroBasedCounter64}',
                          key: const Key('zero_based_counter64_value'),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      const Divider(),

                      // gauge32
                      _PropertyRow(
                        title: 'gauge32',
                        valueWidget: Text(
                          '${model.gauge32}',
                          key: const Key('gauge32_value'),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        actions: <Widget>[
                          IconButton(
                            key: const Key('decrement_gauge32_button'),
                            onPressed: () => viewModel.updateGauge32(-10),
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: '-10',
                          ),
                          IconButton(
                            key: const Key('increment_gauge32_button'),
                            onPressed: () => viewModel.updateGauge32(10),
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: '+10',
                          ),
                        ],
                      ),
                      const Divider(),

                      // gauge64
                      _PropertyRow(
                        title: 'gauge64',
                        valueWidget: Text(
                          '${model.gauge64}',
                          key: const Key('gauge64_value'),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        actions: <Widget>[
                          IconButton(
                            key: const Key('decrement_gauge64_button'),
                            onPressed: () => viewModel.updateGauge64(BigInt.from(-100)),
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: '-100',
                          ),
                          IconButton(
                            key: const Key('increment_gauge64_button'),
                            onPressed: () => viewModel.updateGauge64(BigInt.from(100)),
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: '+100',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper row layout widget for displaying property key, value, and action buttons.
class _PropertyRow extends StatelessWidget {
  /// Creates a [_PropertyRow] with [title], [valueWidget], and optional [actions].
  const _PropertyRow({
    required this.title,
    required this.valueWidget,
    this.actions = const <Widget>[],
  });

  /// Property name/label displayed on the left side.
  final String title;

  /// Widget displaying property value.
  final Widget valueWidget;

  /// Optional action buttons on the right side.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: valueWidget,
          ),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
        ],
      ),
    );
  }
}
