import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

class GoCardlessDataSource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  GoCardlessDataSource({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.gocardlessBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _storage = storage ?? const FlutterSecureStorage();

  // ─── Token management ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAccessToken(
      String secretId, String secretKey) async {
    final response = await _dio.post('/token/new/', data: {
      'secret_id': secretId,
      'secret_key': secretKey,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    final response = await _dio.post('/token/refresh/', data: {
      'refresh': refreshToken,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> storeTokens(String access, String refresh) async {
    await _storage.write(
        key: AppConstants.keyGocardlessAccessToken, value: access);
    await _storage.write(
        key: AppConstants.keyGocardlessRefreshToken, value: refresh);
  }

  Future<void> storeAccessToken(String access) =>
      _storage.write(key: AppConstants.keyGocardlessAccessToken, value: access);

  Future<String?> getStoredAccessToken() =>
      _storage.read(key: AppConstants.keyGocardlessAccessToken);

  Future<String?> getStoredRefreshToken() =>
      _storage.read(key: AppConstants.keyGocardlessRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.keyGocardlessAccessToken);
    await _storage.delete(key: AppConstants.keyGocardlessRefreshToken);
  }

  // ─── Requisition / account ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> createRequisition(
      String accessToken, String institutionId) async {
    final response = await _dio.post(
      '/requisitions/',
      data: {
        'redirect': 'tally://auth/callback',
        'institution_id': institutionId,
        'reference': 'tally-${DateTime.now().millisecondsSinceEpoch}',
        'user_language': 'FR',
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAccounts(
      String accessToken, String requisitionId) async {
    final response = await _dio.get(
      '/requisitions/$requisitionId/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data['accounts'] as List<dynamic>;
  }

  Future<String?> getStoredAccountId() =>
      _storage.read(key: AppConstants.keyAccountId);
  Future<void> storeAccountId(String id) =>
      _storage.write(key: AppConstants.keyAccountId, value: id);

  Future<String?> getStoredRequisitionId() =>
      _storage.read(key: AppConstants.keyRequisitionId);
  Future<void> storeRequisitionId(String id) =>
      _storage.write(key: AppConstants.keyRequisitionId, value: id);

  Future<void> clearAll() => _storage.deleteAll();

  // ─── Transactions & balances ─────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactions(
    String accessToken,
    String accountId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final params = <String, String>{};
    if (dateFrom != null) {
      params['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    }
    if (dateTo != null) {
      params['date_to'] = dateTo.toIso8601String().substring(0, 10);
    }
    final response = await _dio.get(
      '/accounts/$accountId/transactions/',
      queryParameters: params.isNotEmpty ? params : null,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBalances(
      String accessToken, String accountId) async {
    final response = await _dio.get(
      '/accounts/$accountId/balances/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAccountDetails(
      String accessToken, String accountId) async {
    final response = await _dio.get(
      '/accounts/$accountId/details/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }
}
