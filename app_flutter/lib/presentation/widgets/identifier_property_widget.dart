import 'package:flutter/material.dart';
import '../viewmodels/identifier_viewmodel.dart';

/// Presentation widget displaying [IdentifierViewModel] properties inside PropertyGrid.
///
/// Realises: [Feat-002/IdentifierPropertyWidget]
class IdentifierPropertyWidget extends StatefulWidget {
  /// Active ViewModel instance.
  final IdentifierViewModel viewModel;

  /// Creates an [IdentifierPropertyWidget] bound to [viewModel].
  const IdentifierPropertyWidget({
    super.key,
    required this.viewModel,
  });

  @override
  State<IdentifierPropertyWidget> createState() => _IdentifierPropertyWidgetState();
}

class _IdentifierPropertyWidgetState extends State<IdentifierPropertyWidget> {
  late TextEditingController _oidController;
  late TextEditingController _oid128Controller;
  late TextEditingController _uuidController;
  late TextEditingController _yangIdController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _initControllers() {
    final model = widget.viewModel.model;
    _oidController = TextEditingController(text: model?.objectIdentifier ?? '');
    _oid128Controller = TextEditingController(text: model?.objectIdentifier128 ?? '');
    _uuidController = TextEditingController(text: model?.uuid ?? '');
    _yangIdController = TextEditingController(text: model?.yangIdentifier ?? '');
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    final model = widget.viewModel.model;
    if (model == null) return;

    if (_oidController.text != model.objectIdentifier) {
      _oidController.text = model.objectIdentifier;
    }
    if (_oid128Controller.text != model.objectIdentifier128) {
      _oid128Controller.text = model.objectIdentifier128;
    }
    if (_uuidController.text != model.uuid) {
      _uuidController.text = model.uuid;
    }
    if (_yangIdController.text != model.yangIdentifier) {
      _yangIdController.text = model.yangIdentifier;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _oidController.dispose();
    _oid128Controller.dispose();
    _uuidController.dispose();
    _yangIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.viewModel.model;
    if (widget.viewModel.isLoading || model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ietf-yang-types: Identifier Data Types',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (widget.viewModel.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red.withOpacity(0.2),
              child: Text(
                widget.viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Object Identifier (OID)
          const Text('Object Identifier (OID)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _oidController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. 1.3.6.1.4.1',
            ),
            onSubmitted: (val) async {
              await widget.viewModel.updateObjectIdentifier(val);
            },
          ),
          const SizedBox(height: 16),

          // Object Identifier 128
          const Text('Object Identifier (128 sub-identifiers limit)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _oid128Controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. 1.3.6.1.4.1.100',
            ),
            onSubmitted: (val) async {
              await widget.viewModel.updateObjectIdentifier128(val);
            },
          ),
          const SizedBox(height: 16),

          // UUID (RFC 9562)
          const Text('UUID (RFC 9562)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _uuidController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. f81d4fae-7dec-11d0-a765-00a0c91e6bf6',
            ),
            onSubmitted: (val) async {
              await widget.viewModel.updateUuid(val);
            },
          ),
          const SizedBox(height: 16),

          // YANG Identifier
          const Text('YANG Identifier', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextField(
            controller: _yangIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. interfaces',
            ),
            onSubmitted: (val) async {
              await widget.viewModel.updateYangIdentifier(val);
            },
          ),
        ],
      ),
    );
  }
}
