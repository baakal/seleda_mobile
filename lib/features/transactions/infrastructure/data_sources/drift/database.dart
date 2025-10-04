import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:seleda_finance/features/transactions/infrastructure/repositories/transaction_seed.dart';
import 'package:seleda_finance/features/transactions/infrastructure/data_sources/drift/transaction_dao.dart';

part 'database.g.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get dateEpochMs => integer()();
  TextColumn get type => text()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DataClassName('AttachmentData')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  List<String> get customConstraints => ['FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE'];
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'seleda_finance.sqlite'));
    return NativeDatabase.createInBackground(dbFile);
  });
}

@DriftDatabase(tables: [Transactions, Attachments], daos: [TransactionDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({bool enableSeed = true})
      : _enableSeed = enableSeed,
        super(_openConnection());
  AppDatabase.forTesting(QueryExecutor executor)
      : _enableSeed = false,
        super(executor);

  final bool _enableSeed;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          if (kDebugMode && _enableSeed) {
            await transactionSeed(this);
          }
        },
      );
}
