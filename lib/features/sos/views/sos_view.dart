import 'package:flutter/material.dart';

import '../models/emergency_type.dart';
import '../viewmodels/sos_view_model.dart';

class SosView extends StatefulWidget {
  const SosView({
    required this.viewModel,
    required this.onSubmitted,
    super.key,
  });

  final SosViewModel viewModel;
  final VoidCallback onSubmitted;

  @override
  State<SosView> createState() => _SosViewState();
}

class _SosViewState extends State<SosView> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _confirmSubmission() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send emergency alert?'),
          content: Text(
            'Emergency type: ${widget.viewModel.selectedType!.name}\n\n'
            'SSD personnel will receive this incident immediately.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD71920),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('SEND SOS'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    final success = await widget.viewModel.submit(_detailsController.text);
    if (!mounted || !success) return;

    _detailsController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert submitted to SSD.'),
        backgroundColor: Color(0xFF006B2D),
      ),
    );
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            children: [
              const Text(
                'Send an Emergency Alert',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill in the details below to send your emergency.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF5E655F)),
              ),
              const SizedBox(height: 26),
              if (widget.viewModel.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE1E1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.viewModel.errorMessage!,
                    style: const TextStyle(color: Color(0xFFB42318)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<EmergencyType>(
                initialValue: widget.viewModel.selectedType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Emergency Type',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                hint: const Text('Select Emergency Type'),
                items: widget.viewModel.emergencyTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      ),
                    )
                    .toList(),
                onChanged: widget.viewModel.isSubmitting
                    ? null
                    : widget.viewModel.selectEmergencyType,
                validator: (value) =>
                    value == null ? 'Emergency type is required.' : null,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD6DAD6)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Location capture will be connected in the GPS module.',
                            style: TextStyle(
                              color: Color(0xFF656B66),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                enabled: !widget.viewModel.isSubmitting,
                minLines: 4,
                maxLines: 6,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  hintText: 'Enter additional details...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD71920),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                ),
                onPressed: widget.viewModel.isSubmitting
                    ? null
                    : _confirmSubmission,
                child: widget.viewModel.isSubmitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SEND SOS',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
