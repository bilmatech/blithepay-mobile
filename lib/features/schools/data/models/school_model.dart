class SchoolModel {
  final String id;
  final String name;
  final String code;
  final String? logo;
  final String? address;

  SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    this.logo,
    this.address,
  });
}
