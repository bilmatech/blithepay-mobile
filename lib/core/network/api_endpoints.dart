class ApiEndpoints {
  static const String _baseAuth = '/auth';

  // Auth Endpoints
  static const String signup = '$_baseAuth/create_guardian_account';
  static const String login = '$_baseAuth/authorize';
  static const String forgotPassword = '$_baseAuth/forgot_password';
  static const String verifyOtp = '$_baseAuth/verify_account';
  static const String verifyForgotPasswordCode =
      '$_baseAuth/verify_forgot_password_code';

  static const String resendOtp = '$_baseAuth/resend_verification_code';
  static const String resendForgotPasswordCode =
      '$_baseAuth/resend_forgot_password_code';

  static const String resetPassword = '$_baseAuth/reset_password';
  static const String verifyPin = '$_baseAuth/verify_app_pin';

  static const String refreshToken = '$_baseAuth/refresh';
  static const String logout = '$_baseAuth/logout';

  //
  static const String setupPin = '/accounts/set_app_pin';

  //wallet
  static const String wallet = '/wallet';

  //Portal
  static const String getportals = '/portals/live';
  static String getportalById(String id) => '/portals/$id';
  static String updateportal(String id) => '/portals/$id';
  static String deleteportal(String id) => '/portals/$id';

  // linked Profile
  static const String postLinkedProfile = '/linked_profiles';
  static const String getLinkedProfile = '/linked_profiles';
  static const String verifyLinkedProfile = '/linked_profiles/verify';
  static String getLinkedProfileById(String id) => '/linked_profiles/$id';
  static String deleteLinkedProfile(String id) => '/linked_profiles/$id';

  // Students
  static const String students = '/students';
  static String studentDetail(String id) => '$students/$id';

  static const String synToken = '/notification/sync_token';

  //wallet tramsaction
  static const String getWalletTransaction = '/wallet/transactions';

  // Fees
  static String getfeesById(String id) => '/fees/$id';

  static const String fees = '/fees';
  static const String feeBalance = '$fees/balance';
  static const String getFeeTransaction = '/fee/transactions';

  static const String getinvoices = '/invoices';
  static String getinvoicesById(String id) => '/invoices/$id';
  static const String paywithWallet = '/invoices/pay_with_wallet';

  // Payments
  static const String payments = '/payments';
  static const String createPayment = '$payments/create';

  //transactions
  static String getStudentTransaction(String id) => '/transactions/student/$id';

  // Receipts
  static const String receipts = '/receipts';
}
