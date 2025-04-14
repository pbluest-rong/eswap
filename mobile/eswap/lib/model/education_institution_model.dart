import 'package:eswap/model/province_model.dart';

class EducationInstitution {
  final int id;
  final String? code;
  final String name;
  final Province province;
  final String address;
  final String institutionType;

  EducationInstitution(
      {required this.id,
      required this.code,
      required this.name,
      required this.province,
      required this.address,
      required this.institutionType});

  factory EducationInstitution.fromJson(Map<String, dynamic> json) {
    return EducationInstitution(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      province: Province.fromJson(json['province']),
      address: json['address'],
      institutionType: json['institutionType'],
    );
  }
}

enum InstitutionType { HIGH_SCHOOL, COLLEGE, UNIVERSITY }
