enum TransactionType { income, expense;

  String get name => switch (this) {
        TransactionType.income => 'income',
        TransactionType.expense => 'expense',
      };

  static TransactionType fromName(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
