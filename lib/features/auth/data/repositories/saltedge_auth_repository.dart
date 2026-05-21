import '../../../transactions/data/datasources/saltedge_datasource.dart';

class SaltEdgeAuthRepository {
  final SaltEdgeDataSource _ds;
  SaltEdgeAuthRepository(this._ds);

  /// Stores credentials, creates (or reuses) a customer, then creates a
  /// connect session. Returns the connect_url to open in the browser.
  Future<String> startConnect(String appId, String secret) async {
    await _ds.storeCredentials(appId, secret);

    // Reuse existing customer if we already created one
    String? customerId = await _ds.getStoredCustomerId();
    if (customerId == null) {
      customerId = await _ds.createCustomer('tally-user');
    }

    return _ds.createConnectSession(customerId);
  }

  /// Called after the OAuth deep link returns. Stores connection + account.
  Future<void> handleCallback(String connectionId) async {
    await _ds.storeConnectionId(connectionId);

    final accounts = await _ds.getAccounts(connectionId);
    if (accounts.isEmpty) throw Exception('Aucun compte trouvé.');

    // Pick the main EUR account
    final account = accounts.firstWhere(
      (a) =>
          (a as Map<String, dynamic>)['currency_code'] == 'EUR' &&
          ['account', 'checking', 'savings'].contains(a['nature']),
      orElse: () => accounts.first,
    ) as Map<String, dynamic>;

    await _ds.storeAccountId(account['id'].toString());
  }

  Future<bool> isConnected() async {
    final connectionId = await _ds.getStoredConnectionId();
    final accountId = await _ds.getStoredAccountId();
    return connectionId != null && accountId != null;
  }
}
