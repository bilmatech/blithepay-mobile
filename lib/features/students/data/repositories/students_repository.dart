import 'package:blithepay/core/network/api_endpoints.dart';
import 'package:blithepay/core/network/dio_client.dart';
import 'package:blithepay/features/schools/data/models/linked_student_model.dart';
import 'package:blithepay/features/students/data/models/fee_transaction_model.dart';
import 'package:blithepay/features/students/data/models/invoice_model.dart';
import 'package:blithepay/features/students/data/models/verify_student_model.dart';
import 'package:dio/dio.dart';

import '../models/student_model.dart';

abstract class StudentsRepository {
  // Future<PaginatedLivePortal> getLivePortal({int page, int limit});
  Future<PaginatedStudents> getLinkedStudents({
    int page,
    int limit,
    String studentCode,
  });

  Future<VerifiedStudentModel> getStudentDetails(String studentId);
  Future<VerifiedStudentModel> verifyStudent(
    String schoolId,
    String regNum,
    String studentCode,
  );
  Future<LinkedStudentModel> linkStudent(String studentId, String studentCode);
  Future<void> unlinkStudent(String studentId, String studentCode);
  Future<void> verifyGuardian(String phoneNumber, String otp);
  Future<PaginatedFeeTransactionModel> getWalletTransaction({
    int page = 1,
    int limit = 20,
  });
  Future<PaginatedInvoiceModel> getInvoices(
    String studentId, {
    int page = 1,
    int limit = 20,
  });
  Future<InvoiceModel> getInvoiceById(String studentId);
}

class StudentsRepositoryImpl implements StudentsRepository {
  final DioClient _dioClient;

  StudentsRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;
  // @override
  // Future<List<StudentModel>> getLinkedStudents() async {
  //   // Mock implementation
  //   await Future.delayed(const Duration(seconds: 1));
  //   return [
  //     StudentModel(
  //       id: '1',
  //       name: 'Adebayo Oluwaferanmi',
  //       studentId: '7ytf5675dm',
  //       class_: 'Primary 3',
  //       school: 'Seaman International Nursery & Primary School',
  //       feeStatus: 'Pending',
  //       amountDue: 300000,
  //     ),
  //     StudentModel(
  //       id: '2',
  //       name: 'Emma Oluwatayo',
  //       studentId: '7ytf3475dm',
  //       class_: 'Primary 4',
  //       school: 'Seaman International Nursery & Primary School',
  //       feeStatus: 'Pending',
  //       amountDue: 100000,
  //     ),
  //   ];
  // }

  // @override
  // Future<PaginatedLivePortal> getLivePortal({
  //   int page = 1,
  //   int limit = 20,
  // }) async {
  //   var response = await _dioClient.get(
  //     '${ApiEndpoints.getportals}?page=$page&limit=$limit',
  //   );
  //   final mainData = response.data['data'];
  //   final List<dynamic> portalJson = mainData['data'];
  //   final metadata = mainData['metadata'];

  //   final livePortal = portalJson
  //       .map((json) => LivePortalSchoolModel.fromJson(json))
  //       .toList();

  //   return PaginatedLivePortal(
  //     livePortal: livePortal,
  //     currentPage: metadata['page'],
  //     totalPages: metadata['totalPages'],
  //     nextPage: metadata['nextPage'],
  //   );
  // }

  @override
  Future<PaginatedStudents> getLinkedStudents({
    int page = 1,
    int limit = 20,
    String studentCode = '',
  }) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getLinkedProfile}?page=$page&limit=$limit',
      options: Options(headers: {'X-App-Id': studentCode}),
    );
    final mainData = response.data['data'];
    final List<dynamic> studentJson = mainData['data'];
    final metadata = mainData['metadata'];

    final students = studentJson
        .map((json) => VerifiedStudentModel.fromJson(json))
        .toList();

    return PaginatedStudents(
      students: students,
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }

  @override
  Future<VerifiedStudentModel> getStudentDetails(String studentId) async {
    var response = await _dioClient.get(ApiEndpoints.getportalById(studentId));
    final data = response.data['data'];
    return VerifiedStudentModel.fromJson(data);

    // await Future.delayed(const Duration(seconds: 1));
    // return StudentModel(
    //   id: studentId,
    //   name: 'Adebayo Oluwaferanmi',
    //   studentId: '7ytf5675dm',
    //   class_: 'Primary 3',
    //   school: 'Seaman International Nursery & Primary School',
    //   feeStatus: 'Pending',
    //   amountDue: 300000,
    // );
  }

  @override
  Future<VerifiedStudentModel> verifyStudent(
    String schoolId,
    String regNumber,
    String studentCode,
  ) async {
    var response = await _dioClient.get(
      ApiEndpoints.verifyLinkedProfile,
      queryParameters: {"regNumber": regNumber, 'schoolId': schoolId},
      options: Options(headers: {'X-App-Id': studentCode}),
    );
    return VerifiedStudentModel.fromJson(response.data['data']);
  }

  @override
  Future<LinkedStudentModel> linkStudent(
    String studentId,
    String studentCode,
  ) async {
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
  Future<PaginatedFeeTransactionModel> getWalletTransaction({
    int page = 1,
    int limit = 20,
  }) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getFeeTransaction}?page=$page&limit=$limit',
    );
    final mainData = response.data['data'];
    final List<dynamic> walletJson = mainData['data'];
    final metadata = mainData['metadata'];

    final wallet = walletJson
        .map((json) => FeeTransactionModel.fromJson(json))
        .toList();

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

    final invoices = invoiceJson
        .map((json) => InvoiceModel.fromJson(json))
        .toList();

    return PaginatedInvoiceModel(
      invoices: invoices,
      currentPage: metadata['page'] ?? 1,
      totalPages: metadata['totalPages'] ?? 1,
      nextPage: metadata['nextPage'],
    );
  }

  @override
  Future<InvoiceModel> getInvoiceById(String studentId) async {
    var response = await _dioClient.get(
      ApiEndpoints.getinvoicesById(studentId),
    );
    return InvoiceModel.fromJson(response.data['data']);
  }
}
