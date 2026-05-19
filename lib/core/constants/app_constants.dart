class AppConstants {
  static const String appName = 'Tally';

  // GoCardless (Nordigen) API
  static const String gocardlessBaseUrl = 'https://bankaccountdata.gocardless.com/api/v2';
  static const String revoltInstitutionId = 'REVOLUT_REVOGB21';

  // Bucket names
  static const String bucketLife = 'Life';
  static const String bucketBuffer = 'Buffer';
  static const String bucketVault = 'Vault';
  static const String bucketBills = 'Bills';

  // Storage keys
  static const String keyGocardlessAccessToken = 'gc_access_token';
  static const String keyGocardlessRefreshToken = 'gc_refresh_token';
  static const String keyRequisitionId = 'gc_requisition_id';
  static const String keyAccountId = 'gc_account_id';
  static const String keyBucketConfig = 'bucket_config';
}
