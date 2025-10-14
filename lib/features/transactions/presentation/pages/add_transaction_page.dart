import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/presentation/controllers/add_edit_transaction_controller.dart';
import 'package:seleda_finance/features/transactions/presentation/style.dart';

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

// Top-level keypad button widget
class _KeypadButton extends StatelessWidget {
  final String label;
  final void Function(String) onTap;
  final IconData? icon;
  const _KeypadButton({Key? key, required this.label, required this.onTap, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 60,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => onTap(label),
          child: icon != null ? Icon(icon) : Text(label, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  void _onKeypadTap(String value) {
    final current = _amountController.text;
    if (value == 'C') {
      _amountController.clear();
      ref.read(addTransactionControllerProvider.notifier).setAmount('');
      return;
    }
    if (value == '<') {
      if (current.isNotEmpty) {
        final newText = current.substring(0, current.length - 1);
        _amountController.text = newText;
        ref.read(addTransactionControllerProvider.notifier).setAmount(newText);
      }
      return;
    }
    // Only allow one decimal point
    if (value == '.' && current.contains('.')) return;
    // Limit to 2 decimal places
    if (current.contains('.') && value != '.' && current.split('.').last.length >= 2) return;
    final newText = current + value;
    // Remove leading zeros unless immediately followed by a decimal point
    String displayText = newText;
    if (displayText.startsWith('0') && displayText.length > 1 && displayText[1] != '.') {
      displayText = displayText.replaceFirst(RegExp(r'^0+'), '');
    }
    _amountController.text = displayText;
    ref.read(addTransactionControllerProvider.notifier).setAmount(displayText);
  }
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
      // Convert cents to double string with up to 6 decimals, then trim
      String formatted = (next.amount.cents / 100).toStringAsFixed(6);
      // Trim trailing zeros
      if (formatted.contains('.')) {
        while (formatted.endsWith('0')) {
          formatted = formatted.substring(0, formatted.length - 1);
        }
        if (formatted.endsWith('.')) {
          formatted = formatted.substring(0, formatted.length - 1);
        }
      }
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
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top: Expense/Income switch
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TxStyles.spaceLg),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.income, label: Text('Income')),
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ],
                selected: {state.type},
                onSelectionChanged: (selection) {
                  notifier.setType(selection.first);
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Centered, large amount
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: TxStyles.spaceXl),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 220,
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  style: TxStyles.largeAmount(context),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    labelText: null,
                                    hintText: '0',
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  // Disable direct editing
                                  readOnly: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: TxStyles.spaceMd),
                            // Keypad
                            SizedBox(
                              width: 260,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeypadButton(label: '1', onTap: _onKeypadTap),
                                      _KeypadButton(label: '2', onTap: _onKeypadTap),
                                      _KeypadButton(label: '3', onTap: _onKeypadTap),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeypadButton(label: '4', onTap: _onKeypadTap),
                                      _KeypadButton(label: '5', onTap: _onKeypadTap),
                                      _KeypadButton(label: '6', onTap: _onKeypadTap),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeypadButton(label: '7', onTap: _onKeypadTap),
                                      _KeypadButton(label: '8', onTap: _onKeypadTap),
                                      _KeypadButton(label: '9', onTap: _onKeypadTap),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _KeypadButton(label: '.', onTap: _onKeypadTap),
                                      _KeypadButton(label: '0', onTap: _onKeypadTap),
                                      _KeypadButton(label: '<', onTap: _onKeypadTap, icon: Icons.backspace),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _KeypadButton(label: 'C', onTap: _onKeypadTap, icon: Icons.clear),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

// ...existing code...
                    // Notes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TxStyles.spaceXl, vertical: TxStyles.spaceSm),
                      child: TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: notifier.setNote,
                        minLines: 2,
                        maxLines: 4,
                      ),
                    ),
                    // Category
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TxStyles.spaceXl, vertical: TxStyles.spaceSm),
                      child: TextField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: notifier.setCategory,
                      ),
                    ),
                    // Attachments and Date row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TxStyles.spaceXl, vertical: TxStyles.spaceSm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Capture receipt/attachment button
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Show options for camera/gallery
                              showModalBottomSheet<void>(
                                context: context,
                                builder: (ctx) => Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_camera),
                                      title: const Text('Capture Receipt'),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        notifier.addAttachment(ImageSource.camera);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Pick from Gallery'),
                                      onTap: () {
                                        Navigator.pop(ctx);
                                        notifier.addAttachment(ImageSource.gallery);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Capture receipt or attachment'),
                          ),
                          // Date change button
                          OutlinedButton.icon(
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
                            icon: const Icon(Icons.calendar_today),
                            label: Text(dateLabel),
                          ),
                        ],
                      ),
                    ),
                    // Show attachments chips if any
                    if (state.attachments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: TxStyles.spaceXl, vertical: TxStyles.spaceSm),
                        child: Wrap(
                          spacing: TxStyles.spaceSm,
                          children: state.attachments
                              .map(
                                (attachment) => Chip(
                                  label: Text(attachment.filePath.split('/').last),
                                  onDeleted: () => notifier.removeAttachment(attachment),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Save button at the bottom
            Padding(
              padding: const EdgeInsets.all(TxStyles.spaceXl),
              child: SizedBox(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: state.isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
