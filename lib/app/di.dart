import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seleda_finance/features/transactions/application/usecases/add_transaction.dart';
import 'package:seleda_finance/features/transactions/application/usecases/compute_balance.dart';
import 'package:seleda_finance/features/transactions/application/usecases/delete_transaction.dart';
import 'package:seleda_finance/features/transactions/application/usecases/update_transaction.dart';
import 'package:seleda_finance/features/transactions/application/usecases/watch_transactions.dart';
import 'package:seleda_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:seleda_finance/features/transactions/external/image/image_picker_adapter.dart';
import 'package:seleda_finance/features/transactions/external/voice/stt_adapter.dart';
import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/database.dart';
import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/transaction_dao.dart';
import 'package:seleda_finance/features/transactions/infrastructure/repositories/transaction_repository_impl.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final transactionDaoProvider = Provider<TransactionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionDao(db);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dao = ref.watch(transactionDaoProvider);
  return TransactionRepositoryImpl(dao);
});

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return AddTransactionUseCase(repo);
});

final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return UpdateTransactionUseCase(repo);
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return DeleteTransactionUseCase(repo);
});

final watchTransactionsUseCaseProvider = Provider<WatchTransactionsUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return WatchTransactionsUseCase(repo);
});

final computeBalanceUseCaseProvider = Provider<ComputeBalanceUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return ComputeBalanceUseCase(repo);
});

final imagePickerAdapterProvider = Provider<ImagePickerAdapter>((ref) {
  return ImagePickerAdapter();
});

final speechToTextAdapterProvider = Provider<SpeechToTextAdapter>((ref) {
  return SpeechToTextAdapter();
});
