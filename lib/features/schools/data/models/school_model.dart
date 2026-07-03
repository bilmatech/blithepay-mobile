class PaginatedSchoolPortal {
  final List<SchoolModel> school;
  final int currentPage;
  final int totalPages;
  final int? nextPage;

  PaginatedSchoolPortal({
    required this.school,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
  });
}

class SchoolModel {
  final String id;
  final String schoolCode;
  final String name;
  final String? displayName;
  final String? logo;

  SchoolModel({
    required this.id,
    required this.schoolCode,
    required this.name,
    this.displayName,
    this.logo,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'],
      schoolCode: json['schoolCode'],
      name: json['name'],
      displayName: json['displayName'] as String?,
      logo: json['logo'] as String?,
    );
  }
}
