import 'package:blithepay/core/network/api_endpoints.dart';
import 'package:blithepay/core/network/dio_client.dart';

import '../models/school_model.dart';

abstract class SchoolsRepository {
  Future<PaginatedSchoolPortal> getSchoolPortal({int page = 1, int limit = 20});
  Future<List<SchoolModel>> getSchools();
  Future<List<SchoolModel>> searchSchools(String query);
  Future<SchoolModel> getSchoolDetails(String schoolId);
  Future<void> addSchool(String code, String name);
  Future<void> updateSchool(String schoolId, String code, String name);
  Future<void> deleteSchool(String schoolId);
}

class SchoolsRepositoryImpl implements SchoolsRepository {
  final DioClient _dioClient;

  SchoolsRepositoryImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<PaginatedSchoolPortal> getSchoolPortal({
    int page = 1,
    int limit = 20,
  }) async {
    var response = await _dioClient.get(
      '${ApiEndpoints.getportals}?page=$page&limit=$limit',
    );
    final mainData = response.data['data'];
    final List<dynamic> portalJson = mainData['data'];
    final metadata = mainData['metadata'];

    final schoolPortal = portalJson
        .map((json) => SchoolModel.fromJson(json))
        .toList();

    return PaginatedSchoolPortal(
      school: schoolPortal,
      currentPage: metadata['page'],
      totalPages: metadata['totalPages'],
      nextPage: metadata['nextPage'],
    );
  }

  @override
  Future<List<SchoolModel>> getSchools() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      SchoolModel(
        id: '1',
        name: 'Ijesha International Nursery & Primary School',
        schoolCode: '',
        displayName: '',
        // code: '8yuy5e3e46',
      ),
      SchoolModel(
        id: '2',
        name: 'Pascal Nursery & Primary School',
        //  code: 'pascal123',
        schoolCode: '',
        displayName: '',
      ),
    ];
  }

  @override
  Future<List<SchoolModel>> searchSchools(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return getSchools().then(
      (schools) => schools
          .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
          .toList(),
    );
  }

  @override
  Future<SchoolModel> getSchoolDetails(String schoolId) async {
    await Future.delayed(const Duration(seconds: 1));
    return SchoolModel(
      id: schoolId,
      name: 'Ijesha International Nursery & Primary School',
      // code: '8yuy5e3e46',
      schoolCode: '',
      displayName: '',
    );
  }

  @override
  Future<void> addSchool(String code, String name) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateSchool(String schoolId, String code, String name) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> deleteSchool(String schoolId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
