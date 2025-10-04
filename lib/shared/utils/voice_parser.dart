import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';
import 'package:seleda_finance/features/transactions/domain/value_objects/transaction_type.dart';

class VoiceParseResult {
  VoiceParseResult({this.amount, required this.type});

  final Money? amount;
  final TransactionType type;
}

VoiceParseResult parseVoiceInput(String input) {
  final normalized = input.toLowerCase();
  final isIncome = ['income', 'salary', 'received'].any(normalized.contains);
  final type = isIncome ? TransactionType.income : TransactionType.expense;
  final match = RegExp(r'(\d+[\.,]?\d{0,2})').firstMatch(normalized);
  if (match == null) {
    return VoiceParseResult(amount: null, type: type);
  }
  final raw = match.group(0)!.replaceAll(',', '.');
  final sanitized = raw.replaceAll(RegExp('[^0-9\.]'), '');
  final parsed = double.tryParse(sanitized);
  if (parsed == null) {
    return VoiceParseResult(amount: null, type: type);
  }
  final cents = (parsed * 100).round();
  return VoiceParseResult(amount: Money.fromCents(cents), type: type);
}
