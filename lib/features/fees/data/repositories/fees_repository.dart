import 'package:dio/dio.dart';
import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/core/network/api_endpoints.dart';
import 'package:blithepay/core/network/idempotency_key_factory.dart';
import 'package:blithepay/features/fees/data/models/fee_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:blithepay/features/fees/data/models/payment_data.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/schools/data/models/linked_student_model.dart';
import 'package:blithepay/features/students/data/models/fee_transaction_model.dart';

abstract class FeesRepository {
  Future<Fee> getFeesById(String feeId, String studentCode);
  Future<bool> verifyPin(String pin);
  Future<WalletPaymentData> payWithWallet(String invoiceId, List<String> feeItemIds);
  Future<PaymentLink> initializeInvoicePayment(String invoiceId, List<String> feeItemIds);
  Future<LinkedStudentModel> linkStudent(String studentId, String studentCode);
  Future<void> unlinkStudent(String studentId, String studentCode);
  Future<void> verifyGuardian(String phoneNumber, String otp);
  Future<PaginatedFeeTransactionModel> getWalletTransaction({int page = 1, int limit = 20});
  Future<PaginatedInvoiceModel> getInvoices(String studentId, {int page = 1, int limit = 20});
}

class FeesRepositoryImpl implements FeesRepository {
  final DioClient _dioClient;

  FeesRepositoryImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<Fee> getFeesById(String feeId, String studentCode) async {
    final response = await _dioClient.get(
      ApiEndpoints.getfeesById(feeId),
      options: Options(headers: {'X-App-Id': studentCode}),
    );

    return Fee.fromJson(response.data['data']);
  }

  var secureStorage = const FlutterSecureStorage();

  @override
  Future<bool> verifyPin(String pin) async {
    final response = await _dioClient.post(ApiEndpoints.verifyPin, data: {"pin": pin});

    if (response.data != null && response.data['status'] == true) {
      final token = response.data['data']?['XPinChallengeToken']?['token'];
      if (token != null) {
        await secureStorage.write(key: 'xPinChallengeToken', value: token);
      }
      return true;
    } else {
      // Throw with backend message if available, fallback to 'Invalid PIN'
      final message = response.data?['message'] ?? 'Invalid PIN';
      throw Exception(message);
    }
  }

  @override
  Future<WalletPaymentData> payWithWallet(String invoiceId, List<String> feeItemIds) async {
    final token = await secureStorage.read(key: 'xPinChallengeToken');
    final idempotencyKey = IdempotencyKeyFactory.getOrCreateKey(invoiceId, feeItemIds);

    try {
      final response = await _dioClient.post(
        ApiEndpoints.paywithWallet,
        data: {
          "invoiceId": invoiceId,
          "feeItemIds": feeItemIds,
          "idempotencyKey": idempotencyKey,
        },
        options: Options(headers: {'X-PIN-CHALLENGE': token ?? ''}),
      );
      // Clear key upon successful completion
      IdempotencyKeyFactory.clearKey(invoiceId, feeItemIds);
      return WalletPaymentData.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LinkedStudentModel> linkStudent(String studentId, String studentCode) async {
    var response = await _dioClient.post(
      ApiEndpoints.postLinkedProfile,
      data: {'studentId': studentId},
      options: Options(headers: {'X-App-Id': studentCode}),
    );
    return LinkedStudentModel.fromJson(response.data['data']);
  }

  @override
  Future<void> unlinkStudent(String studentId, String studentCode) async {
    await _dioClient.delete(
      ApiEndpoints.deleteLinkedProfile(studentId),
      options: Options(headers: {'X-App-Id': studentCode}),
    );
  }

  @override
  Future<void> verifyGuardian(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<PaginatedFeeTransactionModel> getWalletTransaction({int page = 1, int limit = 20}) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getFeeTransaction}?page=$page&limit=$limit',
    );
    final mainData = response.data['data'];
    final List<dynamic> walletJson = mainData['data'];
    final metadata = mainData['metadata'];

    final wallet = walletJson.map((json) => FeeTransactionModel.fromJson(json)).toList();

    return PaginatedFeeTransactionModel(
      transactions: wallet,
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }

  @override
  Future<PaginatedInvoiceModel> getInvoices(
    String studentId, {
    int page = 1,
    int limit = 20,
  }) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getinvoices}?page=$page&limit=$limit',
      queryParameters: {"studentId": studentId},
    );
    final mainData = response.data['data'] ?? {};
    final invoiceJson = (mainData['data'] as List<dynamic>?) ?? [];
    final metadata = mainData['metadata'] ?? {};

    final invoices = invoiceJson.map((json) => InvoiceModel.fromJson(json)).toList();

    return PaginatedInvoiceModel(
      invoices: invoices,
      currentPage: metadata['page'] ?? 1,
      totalPages: metadata['totalPages'] ?? 1,
      nextPage: metadata['nextPage'],
    );
  }

  @override
  Future<PaymentLink> initializeInvoicePayment(String invoiceId, List<String> feeItemIds) async {
    final idempotencyKey = IdempotencyKeyFactory.getOrCreateKey(invoiceId, feeItemIds);

    try {
      final response = await _dioClient.post(
        ApiEndpoints.paywithPAystack,
        data: {
          "invoiceId": invoiceId,
          "feeItemIds": feeItemIds,
          "idempotencyKey": idempotencyKey,
        },
      );

      IdempotencyKeyFactory.clearKey(invoiceId, feeItemIds);
      return PaymentLink.fromJson(response.data['data']['paymentLink']);
    } catch (e) {
      rethrow;
    }
  }
}
