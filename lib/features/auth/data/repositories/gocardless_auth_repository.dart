import '../../../transactions/data/datasources/gocardless_datasource.dart';

class GoCardlessAuthRepository {
  final GoCardlessDataSource _ds;

  GoCardlessAuthRepository(this._ds);

  Future<({String accessToken, String refreshToken})> authenticate(
    String secretId,
    String secretKey,
  ) async {
    final data = await _ds.getAccessToken(secretId, secretKey);
    final access = data['access'] as String;
    final refresh = data['refresh'] as String;
    await _ds.storeTokens(access, refresh);
    return (accessToken: access, refreshToken: refresh);
  }

  Future<String> createRequisitionLink(String accessToken, String institutionId) async {
    final data = await _ds.createRequisition(accessToken, institutionId);
    final requisitionId = data['id'] as String;
    final link = data['link'] as String;
    await _ds.storeRequisitionId(requisitionId);
    return link;
  }

  Future<String?> getLinkedAccountId(String accessToken, String requisitionId) async {
    final accounts = await _ds.getAccounts(accessToken, requisitionId);
    if (accounts.isEmpty) return null;
    final accountId = accounts.first as String;
    await _ds.storeAccountId(accountId);
    return accountId;
  }

  Future<String?> getStoredAccessToken() => _ds.getStoredAccessToken();
  Future<String?> getStoredAccountId() => _ds.getStoredAccountId();
  Future<String?> getStoredRequisitionId() => _ds.getStoredRequisitionId();

  Future<bool> isConnected() async {
    final token = await _ds.getStoredAccessToken();
    final account = await _ds.getStoredAccountId();
    return token != null && account != null;
  }
}
