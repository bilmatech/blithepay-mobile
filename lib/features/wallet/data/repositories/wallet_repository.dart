import 'package:blithepay/core/storage/hive_service.dart';
import 'package:blithepay/features/wallet/data/models/wallet_model.dart';
import 'package:blithepay/features/wallet/data/models/wallet_transaction_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

abstract class WalletRepositoryInterface {
  Future<WalletModel> getWallet();
  Future<PaginatedTransactionModel> getWalletTransaction({
    int page = 1,
    int limit = 20,
  });
}

class WalletRepository implements WalletRepositoryInterface {
  final DioClient _dioClient;

  WalletRepository({required DioClient dioClient}) : _dioClient = dioClient;

  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  final HiveService hive = HiveService();

  @override
  Future<WalletModel> getWallet() async {
    return WalletModel.fromJson(
      (await _dioClient.get(ApiEndpoints.wallet)).data['data'],
    );
  }

  @override
  Future<PaginatedTransactionModel> getWalletTransaction({
    int page = 1,
    int limit = 20,
  }) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getWalletTransaction}?page=$page&limit=$limit',
    );
    final mainData = response.data['data'];
    final List<dynamic> walletJson = mainData['data'];
    final metadata = mainData['metadata'];

    final wallet = walletJson
        .map((json) => WalletTransactionModel.fromJson(json))
        .toList();

    return PaginatedTransactionModel(
      transactions: wallet,
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }
}
