import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:seleda_finance/app/di.dart';
import 'package:seleda_finance/core/error/failure.dart';
import 'package:seleda_finance/core/result.dart';
import 'package:seleda_finance/shared/formatters/money_formatter.dart';
import 'package:seleda_finance/shared/utils/voice_parser.dart';
import 'package:seleda_finance/features/transactions/application/dto/transaction_input_dto.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/external/image/image_picker_adapter.dart';

class AttachmentFormEntry {
  const AttachmentFormEntry({this.id, required this.filePath, required this.mimeType});

  final String? id;
  final String filePath;
  final String mimeType;
}

class AddEditTransactionState {
  AddEditTransactionState({
    required this.type,
    required this.amount,
    required this.date,
    required this.category,
    required this.note,
    required this.attachments,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final TransactionType type;
  final Money amount;
  final DateTime date;
  final String category;
  final String note;
  final List<AttachmentFormEntry> attachments;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  AddEditTransactionState copyWith({
    TransactionType? type,
    Money? amount,
    DateTime? date,
    String? category,
    String? note,
    List<AttachmentFormEntry>? attachments,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return AddEditTransactionState(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      attachments: attachments ?? this.attachments,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

final addTransactionControllerProvider = StateNotifierProvider.autoDispose<AddEditTransactionController, AddEditTransactionState>((ref) {
  return AddEditTransactionController(ref);
});

class AddEditTransactionController extends StateNotifier<AddEditTransactionState> {
  AddEditTransactionController(this._ref)
      : super(
          AddEditTransactionState(
            type: TransactionType.expense,
            amount: Money.zero(),
            date: DateTime.now(),
            category: '',
            note: '',
            attachments: const <AttachmentFormEntry>[],
          ),
        );

  final Ref _ref;

  void loadDefaults(TransactionType defaultType, {Money? amount, String? note}) {
    state = state.copyWith(
      type: defaultType,
      amount: amount ?? state.amount,
      note: note ?? state.note,
    );
  }

  void applyVoice(String transcript) {
    final result = parseVoiceInput(transcript);
    state = state.copyWith(
      type: result.type,
      amount: result.amount ?? state.amount,
      note: transcript,
    );
  }

  void setType(TransactionType type) {
    state = state.copyWith(type: type);
  }

  void setAmount(String value) {
    final normalized = value.replaceAll(',', '').trim();
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      state = state.copyWith(amount: Money.zero());
      return;
    }
    state = state.copyWith(amount: Money.fromCents((parsed * 100).round()));
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<void> addAttachment(ImageSource source) async {
    final picker = _ref.read(imagePickerAdapterProvider);
    final result = await picker.pickImage(source);
    if (result == null) {
      return;
    }
    state = state.copyWith(
      attachments: [
        ...state.attachments,
        AttachmentFormEntry(filePath: result.filePath, mimeType: result.mimeType),
      ],
    );
  }

  void removeAttachment(AttachmentFormEntry entry) {
    state = state.copyWith(
      attachments: state.attachments.where((e) => e.filePath != entry.filePath).toList(),
    );
  }

  Future<Result<void, AppFailure>> submit() async {
    if (state.amount.cents <= 0) {
      final failure = AppFailure('Amount must be greater than zero');
      state = state.copyWith(errorMessage: failure.message, successMessage: null);
      return Failure(failure);
    }
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);
    final dto = TransactionInputDto(
      type: state.type,
      amount: state.amount,
      dateEpochMs: state.date.millisecondsSinceEpoch,
      category: state.category.isEmpty ? null : state.category,
      note: state.note.isEmpty ? null : state.note,
      attachments: state.attachments
          .map(
            (entry) => AttachmentInputDto(
              filePath: entry.filePath,
              mimeType: entry.mimeType,
            ),
          )
          .toList(),
    );
    final useCase = _ref.read(addTransactionUseCaseProvider);
    final result = await useCase(dto);
    return result.fold(
      (success) {
        final savedAmount = formatMoney(state.amount, type: state.type);
        state = state.copyWith(
          isSaving: false,
          successMessage: 'Saved $savedAmount',
          attachments: const <AttachmentFormEntry>[],
          amount: Money.zero(),
          note: '',
          category: '',
        );
        return const Success(null);
      },
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return Failure(failure);
      },
    );
  }
}
