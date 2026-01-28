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
  // Students
  static const String students = '/students';
  static String studentDetail(String id) => '$students/$id';
  
  // Fees
  static const String fees = '/fees';
  static const String feeBalance = '$fees/balance';
  
  // Payments
  static const String payments = '/payments';
  static const String createPayment = '$payments/create';
  
  // Receipts
  static const String receipts = '/receipts';
}
