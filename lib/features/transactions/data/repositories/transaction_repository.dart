import '../datasources/categorizer.dart';
import '../datasources/plaid_datasource.dart';
import '../../domain/entities/transaction.dart';

class TransactionRepository {
  final PlaidDataSource _ds;
  final TransactionCategorizer _categorizer;

  TransactionRepository(this._ds, this._categorizer);

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Fetches all transactions for the current calendar month.
  Future<List<Transaction>> fetchMonthlyTransactions() async {
    final creds = await _requireCredentials();
    final now = DateTime.now();
    final dateFrom = DateTime(now.year, now.month, 1);

    final data = await _ds.getTransactions(
      creds.clientId,
      creds.secret,
      creds.accessToken,
      dateFrom: dateFrom,
    );
    return _parseTransactions(data);
  }

  /// Returns the available balance of the first account, or null on failure.
  Future<double?> fetchBalance() async {
    final accessToken = await _ds.getStoredAccessToken();
    final clientId = await _ds.getStoredClientId();
    final secret = await _ds.getStoredSecret();
    if (accessToken == null || clientId == null || secret == null) return null;

    try {
      final data = await _ds.getBalance(clientId, secret, accessToken);
      return _parseBalance(data);
    } catch (_) {
      return null;
    }
  }

  // ─── Parsing ──────────────────────────────────────────────────────────────────

  List<Transaction> _parseTransactions(Map<String, dynamic> data) {
    final txList =
        (data['transactions'] as List<dynamic>?) ?? <dynamic>[];

    final txs = txList.map<Transaction?>((raw) {
      try {
        return _mapOne(raw as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<Transaction>().toList();

    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }

  Transaction _mapOne(Map<String, dynamic> raw) {
    final isPending = raw['pending'] as bool? ?? false;

    // Plaid: positive = expense, negative = income → flip to match our convention
    final plaidAmount = (raw['amount'] as num?)?.toDouble() ?? 0.0;
    final amount = -plaidAmount;

    final merchant = raw['merchant_name'] as String?;
    final name = raw['name'] as String?;
    final description = merchant ?? name ?? 'Transaction';

    final date =
        DateTime.tryParse(raw['date'] as String? ?? '') ?? DateTime.now();
    final id = raw['transaction_id'] as String? ??
        '${date.millisecondsSinceEpoch}_${plaidAmount.toStringAsFixed(0)}';

    final type = _categorizer.categorizeType(merchant, description);
    final bucket = _categorizer.categorizeBucket(type, amount);

    return Transaction(
      id: id,
      date: date,
      amount: amount,
      description: description,
      receiver: merchant ?? name,
      type: type,
      bucket: bucket,
      isPending: isPending,
    );
  }

  double? _parseBalance(Map<String, dynamic> data) {
    final accounts = (data['accounts'] as List<dynamic>?) ?? <dynamic>[];
    if (accounts.isEmpty) return null;

    // Pick the first account with a non-null available balance
    for (final account in accounts) {
      final balances =
          (account as Map<String, dynamic>)['balances'] as Map<String, dynamic>?;
      if (balances == null) continue;
      final available = (balances['available'] as num?)?.toDouble();
      if (available != null) return available;
      final current = (balances['current'] as num?)?.toDouble();
      if (current != null) return current;
    }
    return null;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Future<({String clientId, String secret, String accessToken})>
      _requireCredentials() async {
    final clientId = await _ds.getStoredClientId();
    final secret = await _ds.getStoredSecret();
    final token = await _ds.getStoredAccessToken();
    if (clientId == null || secret == null || token == null) {
      throw Exception('Non connecté. Lance la connexion Plaid.');
    }
    return (clientId: clientId, secret: secret, accessToken: token);
  }
}
