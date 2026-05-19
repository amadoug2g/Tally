import 'package:dio/dio.dart';
import '../datasources/categorizer.dart';
import '../datasources/gocardless_datasource.dart';
import '../../domain/entities/transaction.dart';

class TransactionRepository {
  final GoCardlessDataSource _ds;
  final TransactionCategorizer _categorizer;

  TransactionRepository(this._ds, this._categorizer);

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Fetches all booked transactions for the current calendar month.
  Future<List<Transaction>> fetchMonthlyTransactions() async {
    final token = await _requireToken();
    final accountId = await _requireAccountId();
    final now = DateTime.now();
    final dateFrom = DateTime(now.year, now.month, 1);

    return _fetchWithRefresh(
      () => _ds.getTransactions(token, accountId, dateFrom: dateFrom),
      _parseTransactions,
    );
  }

  /// Returns the current interim-available balance in EUR, or null on failure.
  Future<double?> fetchBalance() async {
    final token = await _ds.getStoredAccessToken();
    final accountId = await _ds.getStoredAccountId();
    if (token == null || accountId == null) return null;

    try {
      final data = await _ds.getBalances(token, accountId);
      return _parseBalance(data);
    } catch (_) {
      return null;
    }
  }

  // ─── Token refresh ────────────────────────────────────────────────────────────

  /// Wraps an API call; on 401 it refreshes the access token and retries once.
  Future<T> _fetchWithRefresh<T>(
    Future<Map<String, dynamic>> Function() call,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      return parse(await call());
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) rethrow;

      final newToken = await _doRefresh();
      final accountId = await _requireAccountId();
      final now = DateTime.now();
      final dateFrom = DateTime(now.year, now.month, 1);

      // Rebuild the call with the fresh token
      final data = await _ds.getTransactions(newToken, accountId,
          dateFrom: dateFrom);
      return parse(data);
    }
  }

  Future<String> _doRefresh() async {
    final refresh = await _ds.getStoredRefreshToken();
    if (refresh == null) {
      throw Exception('Session expirée. Reconnecte-toi à Revolut.');
    }
    final data = await _ds.refreshAccessToken(refresh);
    final newAccess = data['access'] as String;
    await _ds.storeAccessToken(newAccess);
    return newAccess;
  }

  // ─── Parsing ──────────────────────────────────────────────────────────────────

  List<Transaction> _parseTransactions(Map<String, dynamic> data) {
    final booked =
        (data['transactions']?['booked'] as List<dynamic>?) ?? <dynamic>[];

    final txs = booked.map<Transaction?>((raw) {
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
    final amountStr =
        (raw['transactionAmount'] as Map<String, dynamic>?)?['amount']
                as String? ??
            '0';
    final amount = double.tryParse(amountStr) ?? 0.0;

    final creditor = raw['creditorName'] as String?;
    final debtor = raw['debtorName'] as String?;
    final receiver = creditor ?? debtor;

    // Revolut returns multiple description fields; pick the most informative one
    final description = _pickDescription(raw, receiver);

    final date =
        DateTime.tryParse(raw['bookingDate'] as String? ?? '') ?? DateTime.now();

    final type = _categorizer.categorizeType(receiver, description);
    final bucket = _categorizer.categorizeBucket(type, amount);

    return Transaction(
      id: raw['transactionId'] as String? ??
          '${date.millisecondsSinceEpoch}_${amount.toStringAsFixed(0)}',
      date: date,
      amount: amount,
      description: description,
      receiver: receiver,
      type: type,
      bucket: bucket,
    );
  }

  String _pickDescription(Map<String, dynamic> raw, String? receiver) {
    // Prefer structured remittance, fallback to unstructured, then receiver, then generic
    final structured =
        raw['remittanceInformationStructured'] as String?;
    final unstructured =
        raw['remittanceInformationUnstructured'] as String?;
    final additional = raw['additionalInformation'] as String?;

    final candidate =
        structured ?? unstructured ?? additional ?? receiver ?? 'Transaction';
    return candidate.trim().isEmpty ? (receiver ?? 'Transaction') : candidate;
  }

  double? _parseBalance(Map<String, dynamic> data) {
    final balances = (data['balances'] as List<dynamic>?) ?? <dynamic>[];
    if (balances.isEmpty) return null;

    // Prefer interimAvailable, then closingBooked
    final preferred = balances.firstWhere(
      (b) => (b as Map<String, dynamic>)['balanceType'] == 'interimAvailable',
      orElse: () => balances.firstWhere(
        (b) => (b as Map<String, dynamic>)['balanceType'] == 'closingBooked',
        orElse: () => balances.first,
      ),
    ) as Map<String, dynamic>;

    final amountStr = (preferred['balanceAmount']
        as Map<String, dynamic>?)?['amount'] as String?;
    return amountStr != null ? double.tryParse(amountStr) : null;
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Future<String> _requireToken() async {
    final token = await _ds.getStoredAccessToken();
    if (token == null) throw Exception('Non connecté. Lance la connexion Revolut.');
    return token;
  }

  Future<String> _requireAccountId() async {
    final id = await _ds.getStoredAccountId();
    if (id == null) throw Exception('Aucun compte lié. Reconnecte Revolut.');
    return id;
  }
}
