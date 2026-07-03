import 'package:blithepay/core/network/api_endpoints.dart';
import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/student_transaction_model.dart';

abstract class TransactionRepository {
  Future<PaginatedStudentTransactionModel> getStudentTransaction({
    int page,
    int limit,
    String studentId,
  });

  Future<InvoiceModel> getStudentTransactionById(String studentId);
}

class StudentsRepositoryImpl implements TransactionRepository {
  final DioClient _dioClient;

  StudentsRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<PaginatedStudentTransactionModel> getStudentTransaction({
    int page = 1,
    int limit = 20,
    String studentId = '',
  }) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getStudentTransaction(studentId)}?page=$page&limit=$limit',
    );
    final mainData = response.data['data'];
    final List<dynamic> transactionsJson = mainData['data'];
    final metadata = mainData['metadata'];

    final transactions = transactionsJson
        .map((json) => StudentTransactionModel.fromJson(json))
        .toList();

    return PaginatedStudentTransactionModel(
      transactions: transactions,
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }

  @override
  Future<InvoiceModel> getStudentTransactionById(String studentId) async {
    var response = await _dioClient.get(
      ApiEndpoints.getinvoicesById(studentId),
    );
    return InvoiceModel.fromJson(response.data['data']);
  }
}
