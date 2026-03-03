


// class LivePortalSchoolModel {
//   final String id;
//   final String schoolCode;
//   final String name;
//   final String logo;
//   final String state;
//   final String city;
//   final String lga;
//   final String displayName;

//   const LivePortalSchoolModel({
//     required this.id,
//     required this.schoolCode,
//     required this.name,
//     required this.logo,
//     required this.state,
//     required this.city,
//     required this.lga,
//     required this.displayName,
//   });

//   factory LivePortalSchoolModel.fromJson(Map<String, dynamic> json) {
//     return LivePortalSchoolModel(
//       id: json['id'] ?? '',
//       schoolCode: json['schoolCode'] ?? '',
//       name: json['name'] ?? '',
//       logo: json['logo'] ?? '',
//       state: json['state'] ?? '',
//       city: json['city'] ?? '',
//       lga: json['lga'] ?? '',
//       displayName: json['displayName'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'schoolCode': schoolCode,
//       'name': name,
//       'logo': logo,
//       'state': state,
//       'city': city,
//       'lga': lga,
//       'displayName': displayName,
//     };
//   }

//   LivePortalSchoolModel copyWith({
//     String? id,
//     String? schoolCode,
//     String? name,
//     String? logo,
//     String? state,
//     String? city,
//     String? lga,
//     String? displayName,
//   }) {
//     return LivePortalSchoolModel(
//       id: id ?? this.id,
//       schoolCode: schoolCode ?? this.schoolCode,
//       name: name ?? this.name,
//       logo: logo ?? this.logo,
//       state: state ?? this.state,
//       city: city ?? this.city,
//       lga: lga ?? this.lga,
//       displayName: displayName ?? this.displayName,
//     );
//   }
// }
