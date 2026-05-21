enum TransactionBucket { life, buffer, vault, bills, income, extra }

enum TransactionType {
  eatingOut,
  groceries,
  shopping,
  transport,
  utilities,
  entertainment,
  health,
  income,
  fund,
  extra,
}

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final String description;
  final String? receiver;
  final TransactionType type;
  final TransactionBucket bucket;
  final bool isAutoCategorizied;
  final bool isPending;

  const Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    this.receiver,
    required this.type,
    required this.bucket,
    this.isAutoCategorizied = true,
    this.isPending = false,
  });

  bool get isExpense => amount < 0;
  bool get isIncome => amount > 0;
}
