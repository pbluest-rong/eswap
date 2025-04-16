import 'package:eswap/model/enum_model.dart';

class SimpleUser {
  final int id;
  String username;
  String firstname;
  String lastname;
  String? avatarUrl;
  String educationInstitutionName;
  String followStatus;

  SimpleUser(
      {required this.id,
      required this.username,
      required this.firstname,
      required this.lastname,
      this.avatarUrl,
      required this.educationInstitutionName,
      required this.followStatus});

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
        id: json['id'],
        username: json['username'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        avatarUrl: json['avatarUrl'],
        educationInstitutionName: json['educationInstitutionName'],
        followStatus: json['followStatus']);
  }
}
