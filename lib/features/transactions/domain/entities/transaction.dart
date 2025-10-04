import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';
import 'package:seleda_finance/features/transactions/domain/entities/attachment.dart';

class Transaction {
  Transaction({
    required this.id,
    required this.dateEpochMs,
    required this.type,
    required Money amount,
    this.category,
    this.note,
    List<Attachment>? attachments,
  })  : assert(amount.cents >= 0, 'Amount must be non-negative'),
        amount = amount,
        attachments = List.unmodifiable(attachments ?? <Attachment>[]);

  final String id;
  final int dateEpochMs;
  final TransactionType type;
  final Money amount;
  final String? category;
  final String? note;
  final List<Attachment> attachments;

  Transaction copyWith({
    int? dateEpochMs,
    TransactionType? type,
    Money? amount,
    String? category,
    String? note,
    List<Attachment>? attachments,
  }) {
    return Transaction(
      id: id,
      dateEpochMs: dateEpochMs ?? this.dateEpochMs,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      attachments: attachments ?? this.attachments,
    );
  }
}
