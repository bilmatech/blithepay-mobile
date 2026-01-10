import '../models/school_model.dart';

abstract class SchoolsRepository {
  Future<List<SchoolModel>> getSchools();
  Future<List<SchoolModel>> searchSchools(String query);
  Future<SchoolModel> getSchoolDetails(String schoolId);
  Future<void> addSchool(String code, String name);
  Future<void> updateSchool(String schoolId, String code, String name);
  Future<void> deleteSchool(String schoolId);
}

class SchoolsRepositoryImpl implements SchoolsRepository {
  @override
  Future<List<SchoolModel>> getSchools() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      SchoolModel(
        id: '1',
        name: 'Ijesha International Nursery & Primary School',
        code: '8yuy5e3e46',
      ),
      SchoolModel(
        id: '2',
        name: 'Pascal Nursery & Primary School',
        code: 'pascal123',
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
      code: '8yuy5e3e46',
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
