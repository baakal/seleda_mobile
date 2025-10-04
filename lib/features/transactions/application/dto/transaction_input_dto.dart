import 'package:seleda_finance/features/transactions/domain/entities/attachment.dart' as domain;
import 'package:seleda_finance/features/transactions/domain/entities/transaction.dart' as domain;
import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

class TransactionInputDto {
  TransactionInputDto({
    this.id,
    required this.type,
    required this.amount,
    required this.dateEpochMs,
    this.category,
    this.note,
    List<AttachmentInputDto>? attachments,
  }) : attachments = attachments ?? <AttachmentInputDto>[];

  final String? id;
  final TransactionType type;
  final Money amount;
  final int dateEpochMs;
  final String? category;
  final String? note;
  final List<AttachmentInputDto> attachments;

  domain.Transaction toDomain({required String Function() idGenerator}) {
    final transactionId = id ?? idGenerator();
    return domain.Transaction(
      id: transactionId,
      dateEpochMs: dateEpochMs,
      type: type,
      amount: amount,
      category: category,
      note: note,
      attachments: attachments
          .map(
            (a) => domain.Attachment(
              id: a.id ?? idGenerator(),
              transactionId: transactionId,
              filePath: a.filePath,
              mimeType: a.mimeType,
            ),
          )
          .toList(),
    );
  }
}

class AttachmentInputDto {
  const AttachmentInputDto({
    this.id,
    required this.filePath,
    required this.mimeType,
  });

  final String? id;
  final String filePath;
  final String mimeType;
}
