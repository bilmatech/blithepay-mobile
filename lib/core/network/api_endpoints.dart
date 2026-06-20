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
  static String getinvoicesByIdView(String id) => '/invoices/$id/view';
  static String getinvoicesByIdDownload(String id) => '/invoices/$id/download';

  static const String paywithWallet = '/invoices/pay_with_wallet';
  static const String paywithPAystack = '/invoices/pay_online_mobile';

  // Payments
  static const String payments = '/payments';
  static const String createPayment = '$payments/create';

  //transactions
  static String getStudentTransaction(String id) => '/transactions/student/$id';

  // Receipts
  static const String receipts = '/receipts';

  static const String accountupdate = '/accounts';

  //Service
  static const String services = '/vas';
  static String getProviders(String serviceId) => '/vas/providers/$serviceId';
  static String getProductsById(String providerId) =>
      '/vas/providers/$providerId/products';

  static const String verifyMeter = '/vas/verify-meter';
  static const String verifySmartCard = '/vas/verify-smart-card';
  static const String purchaseAirtime = '/vas/purchase-airtime';
  static const String purchaseInternet = '/vas/purchase-internet';
  static const String purchaseUtility = '/vas/purchase-utility';
  static const String subscribeCableTv = '/vas/subscribe-cabletv';
}


//  Responses 

// {
//     "status": true,
//     "message": "Services fetched successfully",
//     "data": [
//         {
//             "id": "61e985180e69308aa37a7a94",
//             "name": "Mobile Recharge",
//             "slug": "AIRTIME"
//         },
//         {
//             "id": "61e9854bbce8e444a497663e",
//             "name": "DATA PURCHASE",
//             "slug": "DATA"
//         },
//         {
//             "id": "61e9857bbce8e444a4976641",
//             "name": "CABLE TV",
//             "slug": "CABLETV"
//         },
//         {
//             "id": "61e985a3bce8e444a4976643",
//             "name": "UTILITY BILLS",
//             "slug": "UTILITY"
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "Glo 2.5GB",
//             "amount": "1000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 2.5GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 5.8GB",
//             "amount": "2000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 5.8GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 7.7GB",
//             "amount": "2500.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 7.7GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 10GB",
//             "amount": "3000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 10GB/Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "Days"
//         },
//         {
//             "name": "Glo 13.25GB",
//             "amount": "4000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 13.25GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 18.25GB",
//             "amount": "5000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 18.25GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 50GB",
//             "amount": "10000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 50GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 93GB",
//             "amount": "15000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 93GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 119GB",
//             "amount": "18000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 119GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "Glo 138GB",
//             "amount": "20000.00",
//             "duration": "Monthly",
//             "bundleCode": "Glo 138GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "GLO 29.5GB",
//             "amount": "8000.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 29.5GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "GLO 1.05GB",
//             "amount": "500.00",
//             "duration": "Weekly",
//             "bundleCode": "GLO 1.05GB/14Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "14Days"
//         },
//         {
//             "name": "GLO 350MB",
//             "amount": "200.00",
//             "duration": "Daily",
//             "bundleCode": "GLO 350MB/2Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2Days"
//         },
//         {
//             "name": "GLO 105MB",
//             "amount": "100.00",
//             "duration": "Daily",
//             "bundleCode": "GLO 105MB/1Day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1Day"
//         },
//         {
//             "name": "GLO 32MB",
//             "amount": "50.00",
//             "duration": "Daily",
//             "bundleCode": "GLO 32MB/1Day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1Day"
//         },
//         {
//             "name": "GLO 4.1GB",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 4.1GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "GLO 225GB",
//             "amount": "30000.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 225GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "GLO 300GB",
//             "amount": "36000.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 300GB/30Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30Days"
//         },
//         {
//             "name": "GLO 425GB",
//             "amount": "50000.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 425GB/90Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "90Days"
//         },
//         {
//             "name": "GLO 525GB",
//             "amount": "60000.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 525GB/90Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "90Days"
//         },
//         {
//             "name": "GLO 675GB",
//             "amount": "75000.00",
//             "duration": "Monthly",
//             "bundleCode": "GLO 675GB/120Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "120Days"
//         },
//         {
//             "name": "GLO 1024GB",
//             "amount": "100000.00",
//             "duration": "Yearly",
//             "bundleCode": "GLO 1024GB/365Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "365Days"
//         },
//         {
//             "name": "GLO 1GB",
//             "amount": "300.00",
//             "duration": "Daily",
//             "bundleCode": "GLO 1GB/1day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1day"
//         },
//         {
//             "name": "GLO 2GB",
//             "amount": "500.00",
//             "duration": "Daily",
//             "bundleCode": "GLO 2GB/2days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2days"
//         },
//         {
//             "name": "GLO 7GB",
//             "amount": "1500.00",
//             "duration": "Weekly",
//             "bundleCode": "GLO 7GB/7days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7days"
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "1GB",
//             "amount": 350,
//             "duration": "Daily",
//             "bundleCode": "18",
//             "isAmountFixed": true,
//             "formattedAmont": "N350",
//             "validity": "1day"
//         },
//         {
//             "name": "160GB",
//             "amount": 30000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N30,000",
//             "validity": "60days"
//         },
//         {
//             "name": "N100K Talk+4.5GB",
//             "amount": 20000,
//             "duration": "Monthly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N20,000",
//             "validity": "30days"
//         },
//         {
//             "name": "750MB+N500Talk",
//             "amount": 500,
//             "duration": "Weekly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N500",
//             "validity": "14days"
//         },
//         {
//             "name": "1GB+1GB YT",
//             "amount": 600,
//             "duration": "Weekly",
//             "bundleCode": "19",
//             "isAmountFixed": true,
//             "formattedAmont": "N600",
//             "validity": "7days"
//         },
//         {
//             "name": "120GB",
//             "amount": 22000,
//             "duration": "Monthly",
//             "bundleCode": "36",
//             "isAmountFixed": true,
//             "formattedAmont": "N22,000",
//             "validity": "30days"
//         },
//         {
//             "name": "1TB can share",
//             "amount": 350000,
//             "duration": "Monthly",
//             "bundleCode": "12",
//             "isAmountFixed": true,
//             "formattedAmont": "N350,000",
//             "validity": "90days"
//         },
//         {
//             "name": "2.5GB",
//             "amount": 600,
//             "duration": "Daily",
//             "bundleCode": "20",
//             "isAmountFixed": true,
//             "formattedAmont": "N600",
//             "validity": "2days"
//         },
//         {
//             "name": "100MB",
//             "amount": 100,
//             "duration": "Daily",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N100",
//             "validity": "1day"
//         },
//         {
//             "name": "N1500Talk+50MB",
//             "amount": 300,
//             "duration": "Weekly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N300",
//             "validity": "7days"
//         },
//         {
//             "name": "N2500Talk+100MB",
//             "amount": 500,
//             "duration": "Weekly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "500",
//             "validity": "7days"
//         },
//         {
//             "name": "350MB+N300Talk",
//             "amount": 300,
//             "duration": "Weekly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N300",
//             "validity": "7days"
//         },
//         {
//             "name": "350MB+350MB YT nite",
//             "amount": 350,
//             "duration": "Weekly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N350",
//             "validity": "7days"
//         },
//         {
//             "name": "5GB",
//             "amount": 1500,
//             "duration": "Weekly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N1,500",
//             "validity": "7days"
//         },
//         {
//             "name": "N5000Talk+300MB",
//             "amount": 1000,
//             "duration": "Monthly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N1000",
//             "validity": "30days"
//         },
//         {
//             "name": "N10K Talk+650MB",
//             "amount": 2000,
//             "duration": "Monthly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N2000",
//             "validity": "30days"
//         },
//         {
//             "name": "N25K Talk+1.5GB",
//             "amount": 5000,
//             "duration": "Monthly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N5000",
//             "validity": "30days"
//         },
//         {
//             "name": "N50K Talk+2.5GB",
//             "amount": 10000,
//             "duration": "Monthly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N10,000",
//             "validity": "30days"
//         },
//         {
//             "name": "N75K Talk+3.5GB",
//             "amount": 15000,
//             "duration": "Monthly",
//             "bundleCode": "24",
//             "isAmountFixed": true,
//             "formattedAmont": "N15,000",
//             "validity": "30days"
//         },
//         {
//             "name": "1.5GB+N1000Talk",
//             "amount": 1000,
//             "duration": "Monthly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N1000",
//             "validity": "30days"
//         },
//         {
//             "name": "4.5GB+N2000Talk",
//             "amount": 2000,
//             "duration": "Monthly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N2000",
//             "validity": "30days"
//         },
//         {
//             "name": "15GB+N5000Talk",
//             "amount": 5000,
//             "duration": "Monthly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N5000",
//             "validity": "30days"
//         },
//         {
//             "name": "30GB+N10K Talk",
//             "amount": 10000,
//             "duration": "Monthly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N10,000",
//             "validity": "30days"
//         },
//         {
//             "name": "50GB+N15K Talk",
//             "amount": 15000,
//             "duration": "Monthly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N15,000",
//             "validity": "30days"
//         },
//         {
//             "name": "70GB+N20K Talk",
//             "amount": 20000,
//             "duration": "Monthly",
//             "bundleCode": "25",
//             "isAmountFixed": true,
//             "formattedAmont": "N20,000",
//             "validity": "30days"
//         },
//         {
//             "name": "1.5GB+2.4GB YT nite",
//             "amount": 1200,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N1200",
//             "validity": "30days"
//         },
//         {
//             "name": "1.2GB+2GB YT",
//             "amount": 1000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N1000",
//             "validity": "30days"
//         },
//         {
//             "name": "4GB+2GB YT nite",
//             "amount": 2000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N2000",
//             "validity": "30days"
//         },
//         {
//             "name": "12GB+2GB YT nite",
//             "amount": 4000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N4000",
//             "validity": "30days"
//         },
//         {
//             "name": "20GB+2GB YT nite",
//             "amount": 5500,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "5500",
//             "validity": "30days"
//         },
//         {
//             "name": "40GB",
//             "amount": 11000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N11,000",
//             "validity": "30days"
//         },
//         {
//             "name": "3GB+2GB YT nite",
//             "amount": 1600,
//             "duration": "Monthly",
//             "bundleCode": "36",
//             "isAmountFixed": true,
//             "formattedAmont": "N1600",
//             "validity": "30days"
//         },
//         {
//             "name": "25GB+2GB YT nite",
//             "amount": 6500,
//             "duration": "Monthly",
//             "bundleCode": "36",
//             "isAmountFixed": true,
//             "formattedAmont": "N6500",
//             "validity": "30days"
//         },
//         {
//             "name": "75GB",
//             "amount": 16000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N16,000",
//             "validity": "30days"
//         },
//         {
//             "name": "25GB can share ",
//             "amount": 10000,
//             "duration": "Monthly",
//             "bundleCode": "12",
//             "isAmountFixed": true,
//             "formattedAmont": "N10,000",
//             "validity": "30days"
//         },
//         {
//             "name": "8GB+2GB YT nite",
//             "amount": 3000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N3000",
//             "validity": "30days"
//         },
//         {
//             "name": "10GB+2GB YT nite",
//             "amount": 3500,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N3500",
//             "validity": "30days"
//         },
//         {
//             "name": "165GB can share",
//             "amount": 50000,
//             "duration": "Monthly",
//             "bundleCode": "12",
//             "isAmountFixed": true,
//             "formattedAmont": "N50,000",
//             "validity": "30days"
//         },
//         {
//             "name": "360GB can share",
//             "amount": 100000,
//             "duration": "Monthly",
//             "bundleCode": "12",
//             "isAmountFixed": true,
//             "formattedAmont": "N100,000",
//             "validity": "30days"
//         },
//         {
//             "name": "200MB",
//             "amount": 200,
//             "duration": "Daily",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N200",
//             "validity": "3days"
//         },
//         {
//             "name": "100GB",
//             "amount": 20000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N20,000",
//             "validity": "60days"
//         },
//         {
//             "name": "400GB",
//             "amount": 50000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N50,000",
//             "validity": "90days"
//         },
//         {
//             "name": "600GB",
//             "amount": 75000,
//             "duration": "Monthly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N75,000",
//             "validity": "90days"
//         },
//         {
//             "name": "1TB",
//             "amount": 100000,
//             "duration": "Yearly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N100,000",
//             "validity": "365days"
//         },
//         {
//             "name": "4.5TB",
//             "amount": 450000,
//             "duration": "Yearly",
//             "bundleCode": "9",
//             "isAmountFixed": true,
//             "formattedAmont": "N450,000",
//             "validity": "365days"
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "MTN DIRECT GIFTING 90GB",
//             "amount": "25000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 90GB",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 40GB Postpaid 2-Month",
//             "amount": "9000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 40GB Postpaid 2-Month",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 200GB 2-Month Plan",
//             "amount": "50000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 200GB 2-Month Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "DIRECT GIFTING 75MB Daily Plan",
//             "amount": "75.00",
//             "duration": "Daily",
//             "bundleCode": "DIRECT GIFTING 75MB Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 2.5GB Daily Plan",
//             "amount": "750.00",
//             "duration": "Daily",
//             "bundleCode": "MTN DIRECT GIFTING 2.5GB Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 2GB 2-Day Plan",
//             "amount": "750.00",
//             "duration": "Daily",
//             "bundleCode": "MTN DIRECT GIFTING 2GB 2-Day Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 2.5GB 2-Day Plan",
//             "amount": "900.00",
//             "duration": "Daily",
//             "bundleCode": "MTN DIRECT GIFTING 2.5GB 2-Day Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 3.2GB 2-Day Plan",
//             "amount": "1000.00",
//             "duration": "Daily",
//             "bundleCode": "MTN DIRECT GIFTING 3.2GB 2-Day Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 35GB Postpaid Monthly",
//             "amount": "7000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 35GB Postpaid Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 75GB Monthly Plan",
//             "amount": "18000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 75GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 250GB Monthly Plan",
//             "amount": "55000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 250GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Bundles",
//             "amount": "3000.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Bundles",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "ThryveTalk 1500",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "ThryveTalk 1500",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "ThryveData 3000",
//             "amount": "3000.00",
//             "duration": "Monthly",
//             "bundleCode": "ThryveData 3000",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "ThryveData 1500",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "ThryveData 1500",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Ads Premium - Google",
//             "amount": "20000.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Ads Premium - Google",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Ad Mega - Google",
//             "amount": "13500.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Ad Mega - Google",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Ads Standard - Google",
//             "amount": "12000.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Ads Standard - Google",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Ad Bumper - Google",
//             "amount": "6000.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Ad Bumper - Google",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Ad Lite",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Ad Lite",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 6GB Weekly Plan",
//             "amount": "2500.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN DIRECT GIFTING 6GB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 1GB+1.5mins Daily Plan",
//             "amount": "500.00",
//             "duration": "Daily",
//             "bundleCode": "MTN DIRECT GIFTING 1GB+1.5mins Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 1GB Weekly Plan",
//             "amount": "800.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN DIRECT GIFTING 1GB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN Gifting 25GB Monthly",
//             "amount": "9000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN Gifting 25GB Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "11GB Weekly Bundle",
//             "amount": "3500.00",
//             "duration": "Weekly",
//             "bundleCode": "11GB Weekly Bundle",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN Gifting 20GB Monthly",
//             "amount": "7500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN Gifting 20GB Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 2GB+2mins Monthly Plan",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 2GB+2mins Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 2.7GB+2mins Monthly Plan",
//             "amount": "2000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 2.7GB+2mins Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN Direct Gifting 12.5GB Monthly Plan",
//             "amount": "5500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN Direct Gifting 12.5GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 7GB Monthly",
//             "amount": "3500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 7GB Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 3.5GB",
//             "amount": "2500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 3.5GB",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN DIRECT GIFTING 10GB",
//             "amount": "4500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN DIRECT GIFTING 10GB",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "1.5GB 2-Day Plan",
//             "amount": "600.00",
//             "duration": "Daily",
//             "bundleCode": "1.5GB 2-Day Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "165GB Monthly Plan",
//             "amount": "35000.00",
//             "duration": "Monthly",
//             "bundleCode": "165GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 1.5GB 2-Day Plan",
//             "amount": "600.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 1.5GB 2-Day Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "150GB 2-Month Plan",
//             "amount": "40000.00",
//             "duration": "Monthly",
//             "bundleCode": "150GB 2-Month Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "MTN GIFTING 1.2GB+1hr (YT",
//             "amount": "750.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 1.2GB+1hr (YT/IG/TT)",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "IG"
//         },
//         {
//             "name": "MTN GIFTING 150GB 2-Month Plan",
//             "amount": "40000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 150GB 2-Month Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "MTN GIFTING 1.2GB All Social Monthly",
//             "amount": "450.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 1.2GB All Social Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 230MB Daily Plan",
//             "amount": "200.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 230MB Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 11GB Weekly Plan",
//             "amount": "3500.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 11GB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 120MB Facebook Monthly",
//             "amount": "150.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 120MB Facebook Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 120MB WhatsApp Monthly",
//             "amount": "150.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 120MB WhatsApp Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 40MB Facebook Weekly",
//             "amount": "50.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 40MB Facebook Weekly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 40MB WhatsApp Weekly",
//             "amount": "50.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 40MB WhatsApp Weekly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 40MB Ayoba Weekly Plan",
//             "amount": "50.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 40MB Ayoba Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 470MB All Social Weekly",
//             "amount": "200.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 470MB All Social Weekly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 20MB Facebook Daily Plan",
//             "amount": "25.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 20MB Facebook Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 20MB WhatsApp Daily Plan",
//             "amount": "25.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 20MB WhatsApp Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 150MB TikTok Daily Plan",
//             "amount": "50.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 150MB TikTok Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 200MB All Social Daily",
//             "amount": "100.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 200MB All Social Daily",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 4 hrs YouTube Daily",
//             "amount": "250.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 4 hrs YouTube Daily",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 12 hrs YouTube 2 Days",
//             "amount": "600.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 12 hrs YouTube 2 Days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "MTN GIFTING 480GB 3-Month Plan",
//             "amount": "90000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 480GB 3-Month Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "90 Days"
//         },
//         {
//             "name": "MTN GIFTING 110MB Daily Plan",
//             "amount": "100.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 110MB Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 16.5GB+10mins Monthly",
//             "amount": "6500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 16.5GB+10mins Monthly",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 36GB Monthly Plan",
//             "amount": "11000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 36GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 165GB Monthly Plan",
//             "amount": "35000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 165GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 500MB Weekly Plan",
//             "amount": "500.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 500MB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MSME Learning Bundle",
//             "amount": "300.00",
//             "duration": "Monthly",
//             "bundleCode": "MSME Learning Bundle",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Bundles 3GB",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Bundles 3GB",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Bundles 10GB",
//             "amount": "3000.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Bundles 10GB",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Talk 500MB Plus 7500talk time",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Talk 500MB Plus 7500talk time",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "Thryve Talk 1GB Plus 15000talk time",
//             "amount": "3000.00",
//             "duration": "Monthly",
//             "bundleCode": "Thryve Talk 1GB Plus 15000talk time",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 20GB Weekly Plan",
//             "amount": "5000.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 20GB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 6.75GB Value Data Plan",
//             "amount": "3000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 6.75GB Value Data Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 1.5GB Weekly Plan",
//             "amount": "1000.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 1.5GB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 750MB+1hr (YT",
//             "amount": "450.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 750MB+1hr (YT/IG/TT)",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "IG"
//         },
//         {
//             "name": "MTN GIFTING 3.5GB Weekly Plan",
//             "amount": "1500.00",
//             "duration": "Weekly",
//             "bundleCode": "MTN GIFTING 3.5GB Weekly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "MTN GIFTING 65GB Monthly Plan",
//             "amount": "16000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 65GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 14.5GB Value Data Plan",
//             "amount": "5000.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 14.5GB Value Data Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 12.5GB Monthly Plan",
//             "amount": "5500.00",
//             "duration": "Monthly",
//             "bundleCode": "MTN GIFTING 12.5GB Monthly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "MTN GIFTING 500MB Daily Plan",
//             "amount": "350.00",
//             "duration": "Daily",
//             "bundleCode": "MTN GIFTING 500MB Daily Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "MTN GIFTING 800GB Yearly Plan",
//             "amount": "125000.00",
//             "duration": "Yearly",
//             "bundleCode": "MTN GIFTING 800GB Yearly Plan",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "365 Days"
//         },
//         {
//             "name": "110 MB 1 day",
//             "amount": "100.00",
//             "duration": "Daily",
//             "bundleCode": "110 MB 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "230 MB 1 day",
//             "amount": "200.00",
//             "duration": "Daily",
//             "bundleCode": "230 MB 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "500 MB 1 day",
//             "amount": "350.00",
//             "duration": "Daily",
//             "bundleCode": "500 MB 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "1 GB 1 day",
//             "amount": "500.00",
//             "duration": "Daily",
//             "bundleCode": "1 GB 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "2.5 GB 1 day",
//             "amount": "750.00",
//             "duration": "Daily",
//             "bundleCode": "2.5 GB 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "1.5 GB 2 days",
//             "amount": "600.00",
//             "duration": "Daily",
//             "bundleCode": "1.5 GB 2 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "2 GB 2 days",
//             "amount": "750.00",
//             "duration": "Daily",
//             "bundleCode": "2 GB 2 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "2.5 GB 2 days",
//             "amount": "900.00",
//             "duration": "Daily",
//             "bundleCode": "2.5 GB 2 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "3.2 GB 2 days",
//             "amount": "1000.00",
//             "duration": "Daily",
//             "bundleCode": "3.2 GB 2 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "2 Days"
//         },
//         {
//             "name": "500 MB 7 days",
//             "amount": "500.00",
//             "duration": "Weekly",
//             "bundleCode": "500 MB 7 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "1 GB 7 days",
//             "amount": "800.00",
//             "duration": "Weekly",
//             "bundleCode": "1 GB 7 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "7 Days"
//         },
//         {
//             "name": "2 GB 30 days",
//             "amount": "1500.00",
//             "duration": "Monthly",
//             "bundleCode": "2 GB 30 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "2.7 GB 30 days",
//             "amount": "2000.00",
//             "duration": "Monthly",
//             "bundleCode": "2.7 GB 30 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "36 GB 30 days",
//             "amount": "11000.00",
//             "duration": "Monthly",
//             "bundleCode": "36 GB 30 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "165 GB 30 days",
//             "amount": "35000.00",
//             "duration": "Monthly",
//             "bundleCode": "165 GB 30 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "30 Days"
//         },
//         {
//             "name": "90 GB 60 days",
//             "amount": "25000.00",
//             "duration": "Monthly",
//             "bundleCode": "90 GB 60 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "150 GB 60 days",
//             "amount": "40000.00",
//             "duration": "Monthly",
//             "bundleCode": "150 GB 60 days",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "60 Days"
//         },
//         {
//             "name": "20 MB Facebook 1 day",
//             "amount": "25.00",
//             "duration": "Daily",
//             "bundleCode": "20 MB Facebook 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "20 MB WhatsApp 1 day",
//             "amount": "25.00",
//             "duration": "Daily",
//             "bundleCode": "20 MB WhatsApp 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "150 MB TikTok 1 day",
//             "amount": "50.00",
//             "duration": "Daily",
//             "bundleCode": "150 MB TikTok 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "200 MB All Social 1 day",
//             "amount": "100.00",
//             "duration": "Daily",
//             "bundleCode": "200 MB All Social 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         },
//         {
//             "name": "4 hr YouTube Buffet 1 day",
//             "amount": "250.00",
//             "duration": "Daily",
//             "bundleCode": "4 hr YouTube Buffet 1 day",
//             "isAmountFixed": true,
//             "formattedAmont": null,
//             "validity": "1 Day"
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "40MB",
//             "amount": 50,
//             "duration": "Daily",
//             "bundleCode": "49.99",
//             "isAmountFixed": true,
//             "formattedAmont": "N50",
//             "validity": "1day"
//         },
//         {
//             "name": "100MB",
//             "amount": 100,
//             "duration": "Daily",
//             "bundleCode": "99",
//             "isAmountFixed": true,
//             "formattedAmont": "N100",
//             "validity": "1day"
//         },
//         {
//             "name": "200MB",
//             "amount": 200,
//             "duration": "Daily",
//             "bundleCode": "199.03",
//             "isAmountFixed": true,
//             "formattedAmont": "N200",
//             "validity": "3days"
//         },
//         {
//             "name": "350MB",
//             "amount": 350,
//             "duration": "Weekly",
//             "bundleCode": "349.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N350",
//             "validity": "7days"
//         },
//         {
//             "name": "750MB",
//             "amount": 500,
//             "duration": "Weekly",
//             "bundleCode": "499",
//             "isAmountFixed": true,
//             "formattedAmont": "N500",
//             "validity": "7days"
//         },
//         {
//             "name": "1GB",
//             "amount": 350,
//             "duration": "Daily",
//             "bundleCode": "349.03",
//             "isAmountFixed": true,
//             "formattedAmont": "N350",
//             "validity": "1day"
//         },
//         {
//             "name": "2GB",
//             "amount": 500,
//             "duration": "Daily",
//             "bundleCode": "499.03",
//             "isAmountFixed": true,
//             "formattedAmont": "N500",
//             "validity": "1day"
//         },
//         {
//             "name": "5GB",
//             "amount": 1500,
//             "duration": "Weekly",
//             "bundleCode": "1499.03",
//             "isAmountFixed": true,
//             "formattedAmont": "N1500",
//             "validity": "7days"
//         },
//         {
//             "name": "1.2GB",
//             "amount": 1000,
//             "duration": "Monthly",
//             "bundleCode": "999",
//             "isAmountFixed": true,
//             "formattedAmont": "N1000",
//             "validity": "30days"
//         },
//         {
//             "name": "1.5GB",
//             "amount": 1200,
//             "duration": "Monthly",
//             "bundleCode": "1199",
//             "isAmountFixed": true,
//             "formattedAmont": "N1200",
//             "validity": "30days"
//         },
//         {
//             "name": "3GB",
//             "amount": 1500,
//             "duration": "Monthly",
//             "bundleCode": "1499.01",
//             "isAmountFixed": true,
//             "formattedAmont": "N1500",
//             "validity": "30days"
//         },
//         {
//             "name": "4.5GB",
//             "amount": 2000,
//             "duration": "Monthly",
//             "bundleCode": "1999",
//             "isAmountFixed": true,
//             "formattedAmont": "N2000",
//             "validity": "30days"
//         },
//         {
//             "name": "6GB",
//             "amount": 2500,
//             "duration": "Monthly",
//             "bundleCode": "2499.01",
//             "isAmountFixed": true,
//             "formattedAmont": "N2500",
//             "validity": "30days"
//         },
//         {
//             "name": "10GB",
//             "amount": 3000,
//             "duration": "Monthly",
//             "bundleCode": "2999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N3000",
//             "validity": "30days"
//         },
//         {
//             "name": "15GB",
//             "amount": 4000,
//             "duration": "Monthly",
//             "bundleCode": "3999.01",
//             "isAmountFixed": true,
//             "formattedAmont": "N4000",
//             "validity": "30days"
//         },
//         {
//             "name": "18GB",
//             "amount": 5000,
//             "duration": "Monthly",
//             "bundleCode": "4999",
//             "isAmountFixed": true,
//             "formattedAmont": "N5000",
//             "validity": "30days"
//         },
//         {
//             "name": "30GB",
//             "amount": 8000,
//             "duration": "Monthly",
//             "bundleCode": "7999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N8000",
//             "validity": "30days"
//         },
//         {
//             "name": "40GB",
//             "amount": 10000,
//             "duration": "Monthly",
//             "bundleCode": "9999",
//             "isAmountFixed": true,
//             "formattedAmont": "N10,000",
//             "validity": "30days"
//         },
//         {
//             "name": "75GB",
//             "amount": 15000,
//             "duration": "Monthly",
//             "bundleCode": "14999",
//             "isAmountFixed": true,
//             "formattedAmont": "15,000",
//             "validity": "30days"
//         },
//         {
//             "name": "120GB",
//             "amount": 20000,
//             "duration": "Monthly",
//             "bundleCode": "19999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N20,000",
//             "validity": "30days"
//         },
//         {
//             "name": "240GB",
//             "amount": 30000,
//             "duration": "Monthly",
//             "bundleCode": "29999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N30,000",
//             "validity": "30days"
//         },
//         {
//             "name": "280GB",
//             "amount": 36000,
//             "duration": "Monthly",
//             "bundleCode": "35999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N36,000",
//             "validity": "30days"
//         },
//         {
//             "name": "400GB",
//             "amount": 50000,
//             "duration": "Monthly",
//             "bundleCode": "49999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N50,000",
//             "validity": "90days"
//         },
//         {
//             "name": "500GB",
//             "amount": 60000,
//             "duration": "Monthly",
//             "bundleCode": "59999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N60,000",
//             "validity": "120days"
//         },
//         {
//             "name": "1TB",
//             "amount": 100000,
//             "duration": "Yearly",
//             "bundleCode": "99999.02",
//             "isAmountFixed": true,
//             "formattedAmont": "N100,000",
//             "validity": "365days"
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "DStv Padi",
//             "amount": 3600,
//             "duration": "1 month",
//             "bundleCode": "db1",
//             "isAmountFixed": true
//         },
//         {
//             "name": "DStv Yanga",
//             "amount": 5100,
//             "duration": "1 month",
//             "bundleCode": "db2",
//             "isAmountFixed": true
//         },
//         {
//             "name": "DStv Confam",
//             "amount": 9300,
//             "duration": "1 month",
//             "bundleCode": "db3",
//             "isAmountFixed": true
//         },
//         {
//             "name": "DStv Compact",
//             "amount": 15700,
//             "duration": "1 month",
//             "bundleCode": "db4",
//             "isAmountFixed": true
//         },
//         {
//             "name": "DStv Compact Plus",
//             "amount": 25000,
//             "duration": "1 month",
//             "bundleCode": "db5",
//             "isAmountFixed": true
//         },
//         {
//             "name": "DStv Premium",
//             "amount": 37000,
//             "duration": "1 month",
//             "bundleCode": "db6",
//             "isAmountFixed": true
//         },
//         {
//             "name": "Top Up",
//             "amount": null,
//             "bundleCode": "TOP_UP",
//             "isAmountFixed": false
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "Gotv Supa+",
//             "amount": 13900,
//             "duration": "1 month",
//             "bundleCode": "gb1",
//             "isAmountFixed": true
//         },
//         {
//             "name": "Gotv Supa",
//             "amount": 9600,
//             "duration": "1 month",
//             "bundleCode": "gb2",
//             "isAmountFixed": true
//         },
//         {
//             "name": "Gotv Max",
//             "amount": 7200,
//             "duration": "1 month",
//             "bundleCode": "gb3",
//             "isAmountFixed": true
//         },
//         {
//             "name": "GOtv Jolli",
//             "amount": 4850,
//             "duration": "1 month",
//             "bundleCode": "gb4",
//             "isAmountFixed": true
//         },
//         {
//             "name": "GOtv Jinja",
//             "amount": 3300,
//             "duration": "1 month",
//             "bundleCode": "gb5",
//             "isAmountFixed": true
//         },
//         {
//             "name": "GOtv Smallie",
//             "amount": 1575,
//             "duration": "1 month",
//             "bundleCode": "gb6",
//             "isAmountFixed": true
//         },
//         {
//             "name": "GOtv Open",
//             "amount": 6600,
//             "duration": "1 one-time",
//             "bundleCode": "gb7",
//             "isAmountFixed": true
//         },
//         {
//             "name": "Top Up",
//             "amount": null,
//             "bundleCode": "TOP_UP",
//             "isAmountFixed": false
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Service provider products fetched successfully",
//     "data": [
//         {
//             "name": "StarTimes Nova (Antenna)",
//             "amount": 600,
//             "duration": "1 week",
//             "bundleCode": "sb1",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Nova (Antenna)",
//             "amount": 1900,
//             "duration": "1 month",
//             "bundleCode": "sb2",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Basic (Antenna)",
//             "amount": 1250,
//             "duration": "1 week",
//             "bundleCode": "sb3",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Basic (Antenna)",
//             "amount": 3700,
//             "duration": "1 month",
//             "bundleCode": "sb4",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Classic (Antenna)",
//             "amount": 1900,
//             "duration": "1 week",
//             "bundleCode": "sb5",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Classic (Antenna)",
//             "amount": 5500,
//             "duration": "1 month",
//             "bundleCode": "sb6",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Super (Antenna)",
//             "amount": 3000,
//             "duration": "1 week",
//             "bundleCode": "sb7",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Super (Antenna)",
//             "amount": 8800,
//             "duration": "1 month",
//             "bundleCode": "sb8",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Nova (Dish)",
//             "amount": 650,
//             "duration": "1 week",
//             "bundleCode": "sb9",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Nova (Dish)",
//             "amount": 1900,
//             "duration": "1 month",
//             "bundleCode": "sb10",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Basic (Dish)",
//             "amount": 1550,
//             "duration": "1 week",
//             "bundleCode": "sb11",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Basic (Dish)",
//             "amount": 4700,
//             "duration": "1 month",
//             "bundleCode": "sb12",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Classic (Dish)",
//             "amount": 2300,
//             "duration": "1 week",
//             "bundleCode": "sb13",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Classic (Dish)",
//             "amount": 6800,
//             "duration": "1 month",
//             "bundleCode": "sb14",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Super (Dish)",
//             "amount": 3000,
//             "duration": "1 week",
//             "bundleCode": "sb15",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Super (Dish)",
//             "amount": 9000,
//             "duration": "1 month",
//             "bundleCode": "sb16",
//             "isAmountFixed": true
//         },
//         {
//             "name": "StarTimes Chinese (Dish)",
//             "amount": 19000,
//             "duration": "1 month",
//             "bundleCode": "sb17",
//             "isAmountFixed": true
//         },
//         {
//             "name": "Top Up",
//             "amount": null,
//             "bundleCode": "TOP_UP",
//             "isAmountFixed": false
//         }
//     ]
// }

// {
//     "status": true,
//     "message": "Meter number verified successfully",
//     "data": {
//         "discoCode": "ABUJA",
//         "vendType": "PREPAID",
//         "meterNo": "45143922321",
//         "minVendAmount": 900,
//         "maxVendAmount": 10000000,
//         "outstanding": 0,
//         "debtRepayment": 0,
//         "name": "EVANS UMORU ",
//         "address": "NO 5 DASUKI STREET FO1 KUBWA HSE 204, , GBAZANGO AREA OFFICE",
//         "tariff": null,
//         "tariffClass": null,
//         "demandCategory": "NMD"
//     }
// }

// {
//     "status": true,
//     "message": "Meter number verified successfully",
//     "data": {
//         "discoCode": "IBADAN",
//         "vendType": "PREPAID",
//         "meterNo": "0159006592509",
//         "minVendAmount": 100,
//         "maxVendAmount": 200000,
//         "outstanding": 0,
//         "debtRepayment": 0,
//         "name": "Mr &mrs Makinwa Adeniran Flat 1 .",
//         "address": "23, AYEOKUN AREA MONIYA IBADAN.MONIYAIbadan OYO",
//         "tariff": "Not Available",
//         "tariffClass": "Not Available",
//         "demandCategory": "NMD"
//     }
// }

// {
//     "status": true,
//     "message": "Meter number verified successfully",
//     "data": {
//         "discoCode": "BENIN",
//         "vendType": "PREPAID",
//         "meterNo": "04266940206",
//         "minVendAmount": 500,
//         "maxVendAmount": 500000,
//         "outstanding": 0,
//         "debtRepayment": 0,
//         "name": "ADEBAYO 222 EZEKIEL",
//         "address": "OPPOSITE TENDER HEART HOSPITAL, NULL",
//         "tariff": "Not Available",
//         "tariffClass": "Not Available",
//         "demandCategory": "NMD"
//     }
// }

// {
//     "status": true,
//     "message": "Meter number verified successfully",
//     "data": {
//         "discoCode": "IKEJA",
//         "vendType": "PREPAID",
//         "meterNo": "45066657326",
//         "minVendAmount": 600,
//         "maxVendAmount": 500000,
//         "outstanding": 0,
//         "debtRepayment": 0,
//         "name": "JETHRO OMOYEMI JEDO ESQ",
//         "address": "27 OLANREWAJU ST OLD A/C AKOKA",
//         "tariff": "Not Available",
//         "tariffClass": "Not Available",
//         "demandCategory": "NMD"
//     }
// }
// {
//     "status": true,
//     "message": "Smart card verified successfully",
//     "data": {
//         "cardNumber": "7020878750",
//         "customerName": "HILLARY NDUBUISI"
//     }
// }
// {
//     "status": true,
//     "message": "Airtime purchased successfully",
//     "data": {
//         "id": "cmqjktxr1000cwvkp1kohgxta",
//         "transactionId": "cmqjktvte0008wvkp67f1m3vf",
//         "reference": "4f0429ce67f842aa89e938b98f05ec9a",
//         "status": "SUCCESS",
//         "amount": 100,
//         "commission": null,
//         "externalTransactionId": "6a33fc2d4fd1b349b16ec056",
//         "token": null,
//         "metadata": {
//             "id": "6a33fc2d4fd1b349b16ec056",
//             "amount": 100,
//             "status": "successful",
//             "clientId": "6a12e5a1c9e4150024da1720",
//             "receiver": {
//                 "number": "08142714699",
//                 "vendType": "AIRTIME",
//                 "distribution": "MTN"
//             },
//             "reference": "4f0429ce67f842aa89e938b98f05ec9a",
//             "serviceCategoryId": "61efacbcda92348f9dde5f92"
//         },
//         "phoneContactId": "cmqjktwp3000bwvkp2q98iq69",
//         "isDeleted": false,
//         "updatedAt": "2026-06-18T14:09:57.277Z",
//         "createdAt": "2026-06-18T14:09:57.277Z"
//     }
// }

// {
//     "status": true,
//     "message": "Internet data subscription was successful.",
//     "data": {
//         "id": "cmqk0nsgi0004t3kpv6cj5hy3",
//         "transactionId": "cmqk0njmg0000t3kpcy6kexm2",
//         "reference": "cb6e6ce672ee4dbe9f96a0689079bc34",
//         "status": "SUCCESS",
//         "amount": 500,
//         "commission": null,
//         "externalTransactionId": "6a34640d4fd1b349b16fe034",
//         "token": null,
//         "metadata": {
//             "id": "6a34640d4fd1b349b16fe034",
//             "amount": 500,
//             "status": "successful",
//             "clientId": "6a12e5a1c9e4150024da1720",
//             "receiver": {
//                 "number": "08142714699",
//                 "vendType": "DATA",
//                 "distribution": "MTN"
//             },
//             "reference": "cb6e6ce672ee4dbe9f96a0689079bc34",
//             "serviceCategoryId": "6502eb6e65463b201bf8065f"
//         },
//         "phoneContactId": "cmqk0nrq70003t3kpvlja84yq",
//         "isDeleted": false,
//         "updatedAt": "2026-06-18T21:33:04.338Z",
//         "createdAt": "2026-06-18T21:33:04.338Z"
//     }
// }

// {
//     "status": true,
//     "message": "Utility bill purchase was successful.",
//     "data": {
//         "id": "cmqk3oeb00003szkp3hribbfp",
//         "transactionId": "cmqk3nq4b0000szkp1n8zr5ah",
//         "reference": "727e88bc37eb4562a8c42feb1a0cde11",
//         "status": "SUCCESS",
//         "amount": 1000,
//         "commission": null,
//         "externalTransactionId": "6a3477c34fd1b349b1700717",
//         "token": "6509-1264-0377-1469-1914",
//         "tokenUnits": "4.4",
//         "metadata": {
//             "id": "6a3477c34fd1b349b1700717",
//             "amount": 1000,
//             "status": "successful",
//             "clientId": "6a12e5a1c9e4150024da1720",
//             "metaData": {
//                 "id": 200831622,
//                 "tax": 69.77,
//                 "name": "EVANS UMORU ",
//                 "disco": "ABUJA",
//                 "token": "6509-1264-0377-1469-1914",
//                 "units": 4.4,
//                 "tariff": null,
//                 "address": "NO 5 DASUKI STREET FO1 KUBWA HSE 204, , GBAZANGO AREA OFFICE",
//                 "charges": "0",
//                 "orderId": "727e88bc37eb4562a8c42feb1a0cde11",
//                 "parcels": [
//                     {
//                         "type": "TOKEN",
//                         "content": "65091264037714691914"
//                     }
//                 ],
//                 "phoneNo": null,
//                 "vendRef": "18229134335262945000",
//                 "vendTime": "2026-06-18 23:57:27",
//                 "receiptNo": "38851221",
//                 "debtAmount": 0,
//                 "vendAmount": 0,
//                 "tariffClass": null,
//                 "tariffIndex": null,
//                 "responseCode": 100,
//                 "assetProvider": "ABUJA",
//                 "debtRemaining": 0,
//                 "demandCategory": "NMD",
//                 "amountGenerated": 930.23,
//                 "responseMessage": "Request successful",
//                 "totalAmountPaid": 1000
//             },
//             "receiver": {
//                 "name": null,
//                 "number": "45143922321",
//                 "address": null,
//                 "vendType": null,
//                 "distribution": null
//             },
//             "reference": "727e88bc37eb4562a8c42feb1a0cde11",
//             "tokenValue": "4.4",
//             "utilityToken": "65091264037714691914",
//             "verificationId": null,
//             "serviceCategoryId": "61efac35da92348f9dde5f77"
//         },
//         "phoneContactId": null,
//         "isDeleted": false,
//         "updatedAt": "2026-06-18T22:57:31.500Z",
//         "createdAt": "2026-06-18T22:57:31.500Z"
//     }
// }

// {
//     "status": true,
//     "message": "Cable TV subscription was successful.",
//     "data": {
//         "id": "cmqk53o120004f5kpzec2u03y",
//         "transactionId": "cmqk5393s0001f5kp6zil2gep",
//         "reference": "e63853858d3f45d8b33822cb8179d564",
//         "status": "SUCCESS",
//         "amount": 1575,
//         "commission": null,
//         "externalTransactionId": "6a34812f4fd1b349b1701c4c",
//         "token": null,
//         "tokenUnits": null,
//         "metadata": {
//             "id": "6a34812f4fd1b349b1701c4c",
//             "amount": 1575,
//             "status": "successful",
//             "clientId": "6a12e5a1c9e4150024da1720",
//             "receiver": {
//                 "name": null,
//                 "number": "4613693905",
//                 "vendType": "",
//                 "distribution": "GOTV",
//                 "customerNumber": null
//             },
//             "reference": "e63853858d3f45d8b33822cb8179d564",
//             "serviceCategoryId": "61efad45da92348f9dde5fad"
//         },
//         "phoneContactId": null,
//         "isDeleted": false,
//         "updatedAt": "2026-06-18T23:37:23.558Z",
//         "createdAt": "2026-06-18T23:37:23.558Z"
//     }
// }