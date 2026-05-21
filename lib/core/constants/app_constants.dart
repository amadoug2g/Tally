class AppConstants {
  static const String appName = 'Tally';

  // Plaid API
  static const String plaidBaseUrl = 'https://sandbox.plaid.com';

  // Bucket names
  static const String bucketLife = 'Life';
  static const String bucketBuffer = 'Buffer';
  static const String bucketVault = 'Vault';
  static const String bucketBills = 'Bills';

  // Storage keys
  static const String keyPlaidClientId = 'plaid_client_id';
  static const String keyPlaidSecret = 'plaid_secret';
  static const String keyPlaidAccessToken = 'plaid_access_token';
  static const String keyPlaidItemId = 'plaid_item_id';
  static const String keyBucketConfig = 'bucket_config';
}
