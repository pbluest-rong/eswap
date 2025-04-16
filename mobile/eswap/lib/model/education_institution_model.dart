import 'package:eswap/model/province_model.dart';

class EducationInstitution {
  final int id;
  final String? code;
  final String name;
  final String address;

  EducationInstitution(
      {required this.id,
      required this.code,
      required this.name,
      required this.address});

  factory EducationInstitution.fromJson(Map<String, dynamic> json) {
    return EducationInstitution(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      address: json['address'],
    );
  }
}

enum InstitutionType { HIGH_SCHOOL, COLLEGE, UNIVERSITY }
