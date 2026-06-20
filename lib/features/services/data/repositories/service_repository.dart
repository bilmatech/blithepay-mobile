import 'package:blithepay/core/network/api_endpoints.dart';
import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/features/services/data/models/service_model.dart';
import 'package:blithepay/features/services/data/models/service_purchase_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ServiceRepository {
  Future<String> verifyPin(String pin);
  Future<List<ServiceModel>> getServices();
  Future<List<ServiceProviderModel>> getServiceProviders(String serviceId);
  Future<List<ServiceProviderModel>> getCableProviders(String serviceId);
  Future<List<ServiceProductModel>> getProviderProducts(String providerId);
  Future<List<ServiceProductModel>> getCableProviderProducts(String providerId);

  Future<Map<String, dynamic>> verifyMeter({
    required String serviceId,
    required String meterNumber,
    required String providerId,
  });
  Future<Map<String, dynamic>> verifySmartCard({
    required String provider,
    required String smartcardNumber,
  });
  Future<ServiceTransactionModel> purchaseAirtime({
    required String serviceId,
    required String recipient,
    required String providerId,
    required int amountKobo,
    required String challengeToken,
  });
  Future<ServiceTransactionModel> purchaseInternet({
    required String serviceId,
    required String recipient,
    required String providerId,
    required String bundleCode,
    required int amountKobo,
    required String challengeToken,
  });
  Future<ServiceTransactionModel> purchaseUtility({
    required String serviceId,
    required String meterNumber,
    // required String providerId,
    required int amountKobo,
    required String meterType,
    required String challengeToken,
  });
  Future<ServiceTransactionModel> subscribeCableTv({
    required String provider,
    required String smartcardNumber,
    // required String packageName,
    required int amountKobo,
    required String pin,
    required String bundleCode,
    required String challengeToken,
  });
}

class ServiceRepositoryImpl implements ServiceRepository {
  final DioClient _dioClient;

  ServiceRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  var secureStorage = const FlutterSecureStorage();

  @override
  Future<List<ServiceModel>> getServices() async {
    final response = await _dioClient.get(ApiEndpoints.services);
    final data = response.data['data']['data'];
    final services = (data as List<dynamic>?)
        ?.map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return services ?? [];
  }

  @override
  Future<List<ServiceProviderModel>> getServiceProviders(
    String serviceId,
  ) async {
    final response = await _dioClient.get(ApiEndpoints.getProviders(serviceId));
    final data = response.data['data']['data'];
    final providers = (data as List<dynamic>?)
        ?.map(
          (json) => ServiceProviderModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    return providers ?? [];
  }

  @override
  Future<List<ServiceProductModel>> getProviderProducts(
    String providerId,
  ) async {
    final response = await _dioClient.get(
      ApiEndpoints.getProductsById(providerId),
    );
    final data = response.data['data']['data'];
    final products = (data as List<dynamic>?)
        ?.map(
          (json) => ServiceProductModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    return products ?? [];
  }

  @override
  Future<Map<String, dynamic>> verifyMeter({
    required String serviceId,
    required String meterNumber,
    required String providerId,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifyMeter,
      data: {
        // 'serviceId': serviceId,
        'meterNumber': meterNumber,
        'serviceCategoryId': providerId,
      },
    );
    return _responseData(response);
  }

  @override
  Future<Map<String, dynamic>> verifySmartCard({
    required String provider,
    required String smartcardNumber,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifySmartCard,
      data: {'serviceCategoryId': provider, 'smartCardNumber': smartcardNumber},
    );
    return _responseData(response);
  }

  @override
  Future<ServiceTransactionModel> purchaseAirtime({
    required String serviceId,
    required String recipient,
    required String providerId,
    required int amountKobo,
    required String challengeToken, // Accept the token cleanly here
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.purchaseAirtime,
      data: {
        'serviceCategoryId': providerId,
        'phoneNumber': recipient,
        //'providerId': providerId,
        'amount': (amountKobo / 100).toStringAsFixed(2),
        'idempotencyKey':
            '${DateTime.now().millisecondsSinceEpoch}', // Add idempotency key to prevent duplicate transactions
      },
      options: Options(headers: {'X-PIN-CHALLENGE': challengeToken}),
    );
    return ServiceTransactionModel.fromJson(response.data['data']);
  }

  @override
  Future<ServiceTransactionModel> purchaseInternet({
    required String serviceId,
    required String recipient,
    required String providerId,
    required String bundleCode,
    required int amountKobo,
    required String challengeToken,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.purchaseInternet,
      data: {
        'serviceCategoryId': providerId,
        'phoneNumber': recipient,
        // 'providerId': providerId,
        'bundleCode': bundleCode,
        'amount': (amountKobo / 100).toStringAsFixed(2),
        'idempotencyKey': '${DateTime.now().millisecondsSinceEpoch}',
      },
      options: Options(headers: {'X-PIN-CHALLENGE': challengeToken}),
    );
    return ServiceTransactionModel.fromJson(response.data['data']);
  }

  @override
  Future<ServiceTransactionModel> purchaseUtility({
    required String serviceId,
    required String meterNumber,
    // required String providerId,
    required int amountKobo,
    required String meterType,
    required String challengeToken,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.purchaseUtility,
      data: {
        'serviceCategoryId': serviceId,
        'meterNumber': meterNumber,
        // 'providerId': providerId,
        'amount': (amountKobo / 100).toStringAsFixed(2),
        'meterType': meterType,
        'idempotencyKey': '${DateTime.now().millisecondsSinceEpoch}',
      },
      options: Options(headers: {'X-PIN-CHALLENGE': challengeToken}),
    );
    return ServiceTransactionModel.fromJson(response.data['data']);
  }

  @override
  Future<ServiceTransactionModel> subscribeCableTv({
    required String provider,
    required String smartcardNumber,
    // required String packageName,
    required int amountKobo,
    required String pin,
    required String bundleCode,
    required String challengeToken,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.subscribeCableTv,
      data: {
        'serviceCategoryId': provider,
        'smartcardNumber': smartcardNumber,
        // 'packageName': packageName,
        "bundleCode": bundleCode,
        'amount': (amountKobo / 100).toStringAsFixed(2),
        'idempotencyKey': '${DateTime.now().millisecondsSinceEpoch}',
      },
      options: Options(headers: {'X-PIN-CHALLENGE': challengeToken}),
    );
    return ServiceTransactionModel.fromJson(response.data['data']);
  }

  Map<String, dynamic> _responseData(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'data': data};
  }

  @override
  Future<String> verifyPin(String pin) async {
    final response = await _dioClient.post(
      ApiEndpoints.verifyPin,
      data: {"pin": pin},
    );

    if (response.data != null && response.data['status'] == true) {
      final token = response.data['data']?['XPinChallengeToken']?['token'];
      if (token != null) {
        // We still write it to storage as a fallback/for other views
        await secureStorage.write(key: 'xPinChallengeToken', value: token);
        return token; // Return it directly to avoid native storage read lag
      }
      throw Exception('Challenge token not found in verification response');
    } else {
      final message = response.data?['message'] ?? 'Invalid PIN';
      throw Exception(message);
    }
  }

  @override
  Future<List<ServiceProviderModel>> getCableProviders(String serviceId) async {
    final response = await _dioClient.get(ApiEndpoints.getProviders(serviceId));
    final data = response.data['data'];
    final providers = (data as List<dynamic>?)
        ?.map(
          (json) => ServiceProviderModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    return providers ?? [];
  }

  @override
  Future<List<ServiceProductModel>> getCableProviderProducts(
    String providerId,
  ) async {
    final response = await _dioClient.get(
      ApiEndpoints.getProductsById(providerId),
    );
    final data = response.data['data'];
    final products = (data as List<dynamic>?)
        ?.map(
          (json) => ServiceProductModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    return products ?? [];
  }
}
