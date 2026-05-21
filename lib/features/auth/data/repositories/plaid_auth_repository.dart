import '../../../transactions/data/datasources/plaid_datasource.dart';

class PlaidAuthRepository {
  final PlaidDataSource _ds;

  PlaidAuthRepository(this._ds);

  Future<String> createLinkToken(String clientId, String secret) async {
    await _ds.storeCredentials(clientId, secret);
    return _ds.createLinkToken(clientId, secret);
  }

  Future<void> exchangePublicToken(String publicToken) async {
    final clientId = await _ds.getStoredClientId();
    final secret = await _ds.getStoredSecret();
    if (clientId == null || secret == null) {
      throw Exception('Credentials manquants.');
    }
    await _ds.exchangePublicToken(clientId, secret, publicToken);
  }

  Future<bool> isConnected() async {
    final token = await _ds.getStoredAccessToken();
    return token != null;
  }
}
