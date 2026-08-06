import 'package:app_flutter/domain/models/date_and_time_types.dart';
import 'package:app_flutter/domain/type_descriptor.dart';
import 'package:app_flutter/presentation/viewmodels/date_and_time_viewmodel.dart';
import 'package:flutter/material.dart';

/// Realises: [Feat-003/DateAndTimePropertyWidget]
///
/// Property panel widget for displaying and editing date and time
/// types defined in ietf-yang-types (RFC 9911).
///
/// Zero-Codegen Parameter Isolation: all fields are driven at runtime
/// via a [TypeDescriptor] with [FieldDescriptor] schemas. No domain
/// attributes are hardcoded in widget build methods.
///
/// Binds to a [DateAndTimeViewModel] via [ListenableBuilder] for
/// reactive state rendering.
class DateAndTimePropertyWidget extends StatelessWidget {
  /// Creates a [DateAndTimePropertyWidget] bound to [viewModel].
  const DateAndTimePropertyWidget({super.key, required this.viewModel});

  /// The ViewModel providing state and operations for date-and-time types.
  final DateAndTimeViewModel viewModel;

  static const String _headerText = 'Date and Time Types';

  static final _typeDescriptor = TypeDescriptor(
    typeName: 'dateAndTimeTypes',
    displayName: _headerText,
    iconName: 'schedule',
    fields: [
      FieldDescriptor(
        key: kFieldDateAndTime,
        label: 'Date and Time',
        type: 'string',
        valueResolver: (model) => (model as DateAndTimeTypes).dateAndTime,
        valueWriter: (model, value) =>
            (model as DateAndTimeTypes).copyWith(dateAndTime: value),
      ),
      FieldDescriptor(
        key: kFieldDate,
        label: 'Date',
        type: 'string',
        valueResolver: (model) => (model as DateAndTimeTypes).date,
        valueWriter: (model, value) =>
            (model as DateAndTimeTypes).copyWith(date: value),
      ),
      FieldDescriptor(
        key: kFieldDateNoZone,
        label: 'Date (No Zone)',
        type: 'string',
        valueResolver: (model) => (model as DateAndTimeTypes).dateNoZone,
        valueWriter: (model, value) =>
            (model as DateAndTimeTypes).copyWith(dateNoZone: value),
      ),
      FieldDescriptor(
        key: kFieldTime,
        label: 'Time',
        type: 'string',
        valueResolver: (model) => (model as DateAndTimeTypes).time,
        valueWriter: (model, value) =>
            (model as DateAndTimeTypes).copyWith(time: value),
      ),
      FieldDescriptor(
        key: kFieldTimeNoZone,
        label: 'Time (No Zone)',
        type: 'string',
        valueResolver: (model) => (model as DateAndTimeTypes).timeNoZone,
        valueWriter: (model, value) =>
            (model as DateAndTimeTypes).copyWith(timeNoZone: value),
      ),
      FieldDescriptor(
        key: kFieldHours32,
        label: 'Hours (32-bit)',
        type: 'int',
        valueResolver: (model) => '${(model as DateAndTimeTypes).hours32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes).copyWith(hours32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldMinutes32,
        label: 'Minutes (32-bit)',
        type: 'int',
        valueResolver: (model) => '${(model as DateAndTimeTypes).minutes32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes).copyWith(minutes32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldSeconds32,
        label: 'Seconds (32-bit)',
        type: 'int',
        valueResolver: (model) => '${(model as DateAndTimeTypes).seconds32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes).copyWith(seconds32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldCentiseconds32,
        label: 'Centiseconds (32-bit)',
        type: 'int',
        valueResolver: (model) =>
            '${(model as DateAndTimeTypes).centiseconds32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes)
                .copyWith(centiseconds32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldMilliseconds32,
        label: 'Milliseconds (32-bit)',
        type: 'int',
        valueResolver: (model) =>
            '${(model as DateAndTimeTypes).milliseconds32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes)
                .copyWith(milliseconds32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldMicroseconds32,
        label: 'Microseconds (32-bit)',
        type: 'int',
        valueResolver: (model) =>
            '${(model as DateAndTimeTypes).microseconds32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes)
                .copyWith(microseconds32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldMicroseconds64,
        label: 'Microseconds (64-bit)',
        type: 'int',
        valueResolver: (model) =>
            '${(model as DateAndTimeTypes).microseconds64}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes)
                .copyWith(microseconds64: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldNanoseconds32,
        label: 'Nanoseconds (32-bit)',
        type: 'int',
        valueResolver: (model) =>
            '${(model as DateAndTimeTypes).nanoseconds32}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes)
                .copyWith(nanoseconds32: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldNanoseconds64,
        label: 'Nanoseconds (64-bit)',
        type: 'int',
        valueResolver: (model) =>
            '${(model as DateAndTimeTypes).nanoseconds64}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes)
                .copyWith(nanoseconds64: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldTimeticks,
        label: 'Timeticks',
        type: 'int',
        minValue: 0,
        maxValue: DateAndTimeTypes.kMaxUint32,
        valueResolver: (model) => '${(model as DateAndTimeTypes).timeticks}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes).copyWith(timeticks: parsed);
          }
          return model;
        },
      ),
      FieldDescriptor(
        key: kFieldTimestamp,
        label: 'Timestamp',
        type: 'int',
        minValue: 0,
        maxValue: DateAndTimeTypes.kMaxUint32,
        valueResolver: (model) => '${(model as DateAndTimeTypes).timestamp}',
        valueWriter: (model, value) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return (model as DateAndTimeTypes).copyWith(timestamp: parsed);
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
                child: SingleChildScrollView(
                  child: Column(
                    children: _typeDescriptor.fields.map((field) {
                      return _PropertyRow(field: field, model: model);
                    }).toList(),
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
          ],
        ),
      ),
    );
  }
}
