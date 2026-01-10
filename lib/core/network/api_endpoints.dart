class ApiEndpoints {
  static const String _baseAuth = '/auth';
  
  // Auth Endpoints
  static const String signup = '$_baseAuth/signup';
  static const String login = '$_baseAuth/login';
  static const String forgotPassword = '$_baseAuth/forgot-password';
  static const String verifyOtp = '$_baseAuth/verify-otp';
  static const String resetPassword = '$_baseAuth/reset-password';
  static const String refreshToken = '$_baseAuth/refresh-token';
  static const String logout = '$_baseAuth/logout';
  
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
