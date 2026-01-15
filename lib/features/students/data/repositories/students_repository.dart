import '../models/student_model.dart';

abstract class StudentsRepository {
  Future<List<StudentModel>> getLinkedStudents();
  Future<StudentModel> getStudentDetails(String studentId);
  Future<void> linkStudent(String studentId);
  Future<void> verifyGuardian(String phoneNumber, String otp);
}

class StudentsRepositoryImpl implements StudentsRepository {
  @override
  Future<List<StudentModel>> getLinkedStudents() async {
    // Mock implementation
    await Future.delayed(const Duration(seconds: 1));
    return [
      StudentModel(
        id: '1',
        name: 'Adebayo Oluwaferanmi',
        studentId: '7ytf5675dm',
        class_: 'Primary 3',
        school: 'Seaman International Nursery & Primary School',
        feeStatus: 'Pending',
        amountDue: 300000,
      ),
      StudentModel(
        id: '2',
        name: 'Emma Oluwatayo',
        studentId: '7ytf3475dm',
        class_: 'Primary 4',
        school: 'Seaman International Nursery & Primary School',
        feeStatus: 'Pending',
        amountDue: 100000,
      ),
    ];
  }

  @override
  Future<StudentModel> getStudentDetails(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
    return StudentModel(
      id: studentId,
      name: 'Adebayo Oluwaferanmi',
      studentId: '7ytf5675dm',
      class_: 'Primary 3',
      school: 'Seaman International Nursery & Primary School',
      feeStatus: 'Pending',
      amountDue: 300000,
    );
  }

  @override
  Future<void> linkStudent(String studentId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> verifyGuardian(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
