import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static UserSession? _cached;

  String accessToken;
  String refreshToken;
  int userId;
  String firstName;
  String lastName;
  int educationInstitutionId;
  String educationInstitutionName;
  String role;
  String fcmToken;
  String username;
  String? avatarUrl;

  UserSession(
      {required this.accessToken,
      required this.refreshToken,
      required this.userId,
      required this.firstName,
      required this.lastName,
      required this.educationInstitutionId,
      required this.educationInstitutionName,
      required this.role,
      required this.fcmToken,
      required this.username,
      this.avatarUrl});

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'educationInstitutionId': educationInstitutionId,
        'educationInstitutionName': educationInstitutionName,
        'role': role,
        'fcmToken': fcmToken,
        'avatarUrl': avatarUrl,
        'username': username
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      educationInstitutionId: json['educationInstitutionId'],
      educationInstitutionName: json['educationInstitutionName'],
      role: json['role'],
      fcmToken: json['fcmToken'],
      avatarUrl: json['avatarUrl'],
      username: json['username']);

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userSession', jsonEncode(toJson()));
    _cached = this;
  }

  static Future<UserSession?> load() async {
    if (_cached != null) return _cached;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('userSession');
    if (jsonString != null) {
      _cached = UserSession.fromJson(jsonDecode(jsonString));
    }
    return _cached;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userSession');
    _cached = null;
  }
}
