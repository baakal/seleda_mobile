import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/add_edit_transaction_controller.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({
    super.key,
    this.defaultType = TransactionType.expense,
    this.voicePrefill,
  });

  final TransactionType defaultType;
  final String? voicePrefill;

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  // No explicit listener flag needed; we attach using ref.listen inside build.

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _categoryController = TextEditingController();
    _noteController = TextEditingController();

    // Defer loading defaults until first frame to ensure context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(addTransactionControllerProvider.notifier);
      notifier.loadDefaults(widget.defaultType);
      if (widget.voicePrefill != null) {
        notifier.applyVoice(widget.voicePrefill!);
      }
    });
  }

  void _onStateChanged(AddEditTransactionState? previous, AddEditTransactionState next) {
    // Update controllers only when values actually changed to avoid loops.
    if (previous == null || previous.amount.cents != next.amount.cents) {
      final formatted = (next.amount.cents / 100).toStringAsFixed(2);
      if (_amountController.text != formatted) {
        _amountController.text = formatted;
      }
    }
    if (previous == null || previous.category != next.category) {
      if (_categoryController.text != next.category) {
        _categoryController.text = next.category;
      }
    }
    if (previous == null || previous.note != next.note) {
      if (_noteController.text != next.note) {
        _noteController.text = next.note;
      }
    }
    if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    }
    if (next.successMessage != null && next.successMessage != previous?.successMessage) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Attach listener during build (allowed) – Riverpod disposes and re-adds as needed.
    ref.listen<AddEditTransactionState>(
      addTransactionControllerProvider,
      _onStateChanged,
    );

    final state = ref.watch(addTransactionControllerProvider);
    final notifier = ref.read(addTransactionControllerProvider.notifier);
    final dateLabel = DateFormat.yMMMd().format(state.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
              ],
              selected: {state.type},
              onSelectionChanged: (selection) {
                notifier.setType(selection.first);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
              onChanged: notifier.setAmount,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(dateLabel),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    notifier.setDate(picked);
                  }
                },
              ),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: notifier.setCategory,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              onChanged: notifier.setNote,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => notifier.addAttachment(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => notifier.addAttachment(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.attachments.isEmpty)
              const Text('No attachments added.')
            else
              Wrap(
                spacing: 8,
                children: state.attachments
                    .map(
                      (attachment) => Chip(
                        label: Text(attachment.filePath.split('/').last),
                        onDeleted: () => notifier.removeAttachment(attachment),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final result = await notifier.submit();
                        result.fold(
                          (_) {},
                          (error) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          ),
                        );
                      },
                child: state.isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
