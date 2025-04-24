import 'package:dio/dio.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/views/login/login_page.dart';
import 'package:eswap/service/auth_interceptor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void loginByTokenAccess(BuildContext context) async {
  final dio = Dio();
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString("accessToken");
  dio.interceptors.add(AuthInterceptor(dio, prefs));
  try {
    final response = await dio.post(
      ApiEndpoints.auto_login_url,
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      }),
    );

    if (response.statusCode == 200 && response.data["success"] == true) {
      final educationInstitutionId =
      response.data["data"]["educationInstitutionId"];
      final educationInstitutionName =
      response.data["data"]["educationInstitutionName"];
      final role = response.data["data"]["role"];

      await prefs.setInt("educationInstitutionId", educationInstitutionId);
      await prefs.setString("educationInstitutionName", educationInstitutionName);
    }
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await prefs.setString("fcmToken", fcmToken);
      // Gửi FCM token lên server
      final url = ApiEndpoints.saveFcmToken_url;
      await dio
          .post(
        url,
        queryParameters: {"fcmToken": fcmToken},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
        ),
      )
          .catchError((error) {
        print("Lỗi khi gửi FCM Token: $error");
      });
    }
  } catch (e) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }
}
