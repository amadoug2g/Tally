import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

class PlaidDataSource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  PlaidDataSource({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.plaidBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _storage = storage ?? const FlutterSecureStorage();

  // ─── Credentials ──────────────────────────────────────────────────────────

  Future<void> storeCredentials(String clientId, String secret) async {
    await _storage.write(key: AppConstants.keyPlaidClientId, value: clientId);
    await _storage.write(key: AppConstants.keyPlaidSecret, value: secret);
  }

  Future<String?> getStoredClientId() =>
      _storage.read(key: AppConstants.keyPlaidClientId);

  Future<String?> getStoredSecret() =>
      _storage.read(key: AppConstants.keyPlaidSecret);

  // ─── Link token ────────────────────────────────────────────────────────────

  Future<String> createLinkToken(String clientId, String secret) async {
    final response = await _dio.post(
      '/link/token/create',
      data: {
        'client_id': clientId,
        'secret': secret,
        'client_name': 'Tally',
        'user': {'client_user_id': 'tally-user'},
        'products': ['transactions'],
        'country_codes': ['FR', 'GB'],
        'language': 'fr',
      },
    );
    return response.data['link_token'] as String;
  }

  // ─── Token exchange ────────────────────────────────────────────────────────

  Future<void> exchangePublicToken(
      String clientId, String secret, String publicToken) async {
    final response = await _dio.post(
      '/item/public_token/exchange',
      data: {
        'client_id': clientId,
        'secret': secret,
        'public_token': publicToken,
      },
    );
    final accessToken = response.data['access_token'] as String;
    final itemId = response.data['item_id'] as String;
    await _storage.write(
        key: AppConstants.keyPlaidAccessToken, value: accessToken);
    await _storage.write(key: AppConstants.keyPlaidItemId, value: itemId);
  }

  Future<String?> getStoredAccessToken() =>
      _storage.read(key: AppConstants.keyPlaidAccessToken);

  Future<void> clearAll() => _storage.deleteAll();

  // ─── Transactions ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactions(
    String clientId,
    String secret,
    String accessToken, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final now = DateTime.now();
    final start = dateFrom ?? DateTime(now.year, now.month, 1);
    final end = dateTo ?? now;

    final response = await _dio.post(
      '/transactions/get',
      data: {
        'client_id': clientId,
        'secret': secret,
        'access_token': accessToken,
        'start_date': start.toIso8601String().substring(0, 10),
        'end_date': end.toIso8601String().substring(0, 10),
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // ─── Balance ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBalance(
    String clientId,
    String secret,
    String accessToken,
  ) async {
    final response = await _dio.post(
      '/accounts/balance/get',
      data: {
        'client_id': clientId,
        'secret': secret,
        'access_token': accessToken,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
