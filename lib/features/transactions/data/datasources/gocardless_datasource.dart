import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

class GoCardlessDataSource {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  GoCardlessDataSource({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.gocardlessBaseUrl)),
        _storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> getAccessToken(String secretId, String secretKey) async {
    final response = await _dio.post('/token/new/', data: {
      'secret_id': secretId,
      'secret_key': secretKey,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createRequisition(String accessToken, String institutionId) async {
    final redirectUri = 'tally://auth/callback';
    final response = await _dio.post(
      '/requisitions/',
      data: {
        'redirect': redirectUri,
        'institution_id': institutionId,
        'reference': 'tally-${DateTime.now().millisecondsSinceEpoch}',
        'user_language': 'FR',
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getAccounts(String accessToken, String requisitionId) async {
    final response = await _dio.get(
      '/requisitions/$requisitionId/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data['accounts'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getAccountDetails(String accessToken, String accountId) async {
    final response = await _dio.get(
      '/accounts/$accountId/details/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTransactions(
    String accessToken,
    String accountId, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final params = <String, String>{};
    if (dateFrom != null) params['date_from'] = dateFrom.toIso8601String().substring(0, 10);
    if (dateTo != null) params['date_to'] = dateTo.toIso8601String().substring(0, 10);

    final response = await _dio.get(
      '/accounts/$accountId/transactions/',
      queryParameters: params,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBalances(String accessToken, String accountId) async {
    final response = await _dio.get(
      '/accounts/$accountId/balances/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<String?> getStoredAccessToken() => _storage.read(key: AppConstants.keyGocardlessAccessToken);
  Future<void> storeTokens(String access, String refresh) async {
    await _storage.write(key: AppConstants.keyGocardlessAccessToken, value: access);
    await _storage.write(key: AppConstants.keyGocardlessRefreshToken, value: refresh);
  }

  Future<String?> getStoredAccountId() => _storage.read(key: AppConstants.keyAccountId);
  Future<void> storeAccountId(String id) => _storage.write(key: AppConstants.keyAccountId, value: id);

  Future<String?> getStoredRequisitionId() => _storage.read(key: AppConstants.keyRequisitionId);
  Future<void> storeRequisitionId(String id) => _storage.write(key: AppConstants.keyRequisitionId, value: id);
}
