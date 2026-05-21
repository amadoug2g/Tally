import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

class SaltEdgeDataSource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  SaltEdgeDataSource({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.saltEdgeBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _storage = storage ?? const FlutterSecureStorage();

  // ─── Credentials ──────────────────────────────────────────────────────────

  Future<void> storeCredentials(String appId, String secret) async {
    await _storage.write(key: AppConstants.keySaltEdgeAppId, value: appId);
    await _storage.write(key: AppConstants.keySaltEdgeSecret, value: secret);
  }

  Future<String?> getStoredAppId() =>
      _storage.read(key: AppConstants.keySaltEdgeAppId);
  Future<String?> getStoredSecret() =>
      _storage.read(key: AppConstants.keySaltEdgeSecret);
  Future<String?> getStoredCustomerId() =>
      _storage.read(key: AppConstants.keySaltEdgeCustomerId);
  Future<String?> getStoredConnectionId() =>
      _storage.read(key: AppConstants.keySaltEdgeConnectionId);
  Future<String?> getStoredAccountId() =>
      _storage.read(key: AppConstants.keySaltEdgeAccountId);

  Future<void> storeCustomerId(String id) =>
      _storage.write(key: AppConstants.keySaltEdgeCustomerId, value: id);
  Future<void> storeConnectionId(String id) =>
      _storage.write(key: AppConstants.keySaltEdgeConnectionId, value: id);
  Future<void> storeAccountId(String id) =>
      _storage.write(key: AppConstants.keySaltEdgeAccountId, value: id);

  Future<void> clearAll() => _storage.deleteAll();

  // ─── Auth headers ──────────────────────────────────────────────────────────

  Future<Options> _authOptions() async {
    final appId = await getStoredAppId();
    final secret = await getStoredSecret();
    return Options(headers: {
      'App-id': appId!,
      'Secret': secret!,
      'Content-Type': 'application/json',
    });
  }

  // ─── Customer ──────────────────────────────────────────────────────────────

  Future<String> createCustomer(String identifier) async {
    final opts = await _authOptions();
    final response = await _dio.post(
      '/customers',
      data: {'data': {'identifier': identifier}},
      options: opts,
    );
    final id = (response.data['data'] as Map<String, dynamic>)['id'].toString();
    await storeCustomerId(id);
    return id;
  }

  // ─── Connect session ───────────────────────────────────────────────────────

  Future<String> createConnectSession(String customerId) async {
    final opts = await _authOptions();
    final fromDate = DateTime.now().subtract(const Duration(days: 90));
    final response = await _dio.post(
      '/connect_sessions/create',
      data: {
        'data': {
          'customer_id': customerId,
          'consent': {
            'from_date': fromDate.toIso8601String().substring(0, 10),
            'fetching_scopes': ['accounts', 'transactions'],
          },
          'attempt': {
            'return_to': 'tally://auth/callback',
            'show_consent_confirmation': false,
          },
        },
      },
      options: opts,
    );
    return (response.data['data'] as Map<String, dynamic>)['connect_url']
        as String;
  }

  // ─── Accounts ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getAccounts(String connectionId) async {
    final opts = await _authOptions();
    final response = await _dio.get(
      '/accounts',
      queryParameters: {'connection_id': connectionId},
      options: opts,
    );
    return (response.data['data'] as List<dynamic>?) ?? [];
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getTransactions(
    String accountId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final opts = await _authOptions();
    final now = DateTime.now();
    final params = <String, String>{
      'account_id': accountId,
      'from_date':
          (dateFrom ?? DateTime(now.year, now.month, 1)).toIso8601String().substring(0, 10),
      'to_date': (dateTo ?? now).toIso8601String().substring(0, 10),
    };

    final List<dynamic> all = [];
    String? nextId;

    do {
      if (nextId != null) params['from_id'] = nextId;
      final response = await _dio.get(
        '/transactions',
        queryParameters: params,
        options: opts,
      );
      final data = (response.data['data'] as List<dynamic>?) ?? [];
      all.addAll(data);
      nextId = (response.data['meta'] as Map<String, dynamic>?)?['next_id']
          ?.toString();
    } while (nextId != null && nextId.isNotEmpty);

    return all;
  }

  // ─── Balance ───────────────────────────────────────────────────────────────

  Future<double?> getBalance(String connectionId) async {
    final accounts = await getAccounts(connectionId);
    if (accounts.isEmpty) return null;

    // Prefer main EUR checking account
    final account = accounts.firstWhere(
      (a) =>
          (a as Map<String, dynamic>)['currency_code'] == 'EUR' &&
          ['account', 'checking'].contains(a['nature']),
      orElse: () => accounts.first,
    ) as Map<String, dynamic>;

    return (account['balance'] as num?)?.toDouble();
  }
}
