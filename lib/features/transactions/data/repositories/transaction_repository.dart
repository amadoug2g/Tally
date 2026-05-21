import '../datasources/categorizer.dart';
import '../datasources/saltedge_datasource.dart';
import '../../domain/entities/transaction.dart';

class TransactionRepository {
  final SaltEdgeDataSource _ds;
  final TransactionCategorizer _categorizer;

  TransactionRepository(this._ds, this._categorizer);

  // ─── Public API ──────────────────────────────────────────────────────────────

  Future<List<Transaction>> fetchMonthlyTransactions() async {
    final accountId = await _ds.getStoredAccountId();
    if (accountId == null) {
      throw Exception('Non connecté. Lance la connexion Salt Edge.');
    }
    final now = DateTime.now();
    final txs = await _ds.getTransactions(
      accountId,
      dateFrom: DateTime(now.year, now.month, 1),
    );
    return _parseTransactions(txs);
  }

  Future<double?> fetchBalance() async {
    final connectionId = await _ds.getStoredConnectionId();
    if (connectionId == null) return null;
    try {
      return await _ds.getBalance(connectionId);
    } catch (_) {
      return null;
    }
  }

  // ─── Parsing ──────────────────────────────────────────────────────────────────

  List<Transaction> _parseTransactions(List<dynamic> raw) {
    final txs = raw.map<Transaction?>((item) {
      try {
        return _mapOne(item as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<Transaction>().toList();

    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }

  Transaction _mapOne(Map<String, dynamic> raw) {
    // Salt Edge: negative = expense, positive = income — same as our convention
    final amount = (raw['amount'] as num?)?.toDouble() ?? 0.0;

    final isPending = (raw['status'] as String?) == 'pending';

    final extra = raw['extra'] as Map<String, dynamic>?;
    final payee = extra?['payee'] as String?;
    final description = payee ?? raw['description'] as String? ?? 'Transaction';

    final date =
        DateTime.tryParse(raw['made_on'] as String? ?? '') ?? DateTime.now();

    final id = raw['id']?.toString() ??
        '${date.millisecondsSinceEpoch}_${amount.toStringAsFixed(0)}';

    final type = _categorizer.categorizeType(payee, description);
    final bucket = _categorizer.categorizeBucket(type, amount);

    return Transaction(
      id: id,
      date: date,
      amount: amount,
      description: description,
      receiver: payee,
      type: type,
      bucket: bucket,
      isPending: isPending,
    );
  }

  double? _parseBalance(Map<String, dynamic> data) {
    final accounts = (data['data'] as List<dynamic>?) ?? [];
    if (accounts.isEmpty) return null;
    final account = accounts.first as Map<String, dynamic>;
    return (account['balance'] as num?)?.toDouble();
  }
}
