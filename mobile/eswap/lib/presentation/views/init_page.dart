import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/provider/user_provider.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/admin/admin_page.dart';
import 'package:eswap/presentation/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:eswap/presentation/views/splash/splash_page.dart';
import 'package:eswap/presentation/views/welcome/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  Future<void> _checkAppState(BuildContext context) async {
    if (await _isOnboardingCompleted()) {
      // welcome page
      if (!context.mounted) {
        return;
      }
      final loadedUser = await UserSession.load();
      if (loadedUser == null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomePage(
                      isFirstTimeInstallApp: false,
                    )));
      } else {
        autoLogin(context);
        if (loadedUser.role == "ADMIN") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } else {
      if (!context.mounted) {
        return;
      }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashPage()));
    }
  }

  Future<bool> _isOnboardingCompleted() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final result = prefs.getBool("kOnBoardingCompleted");
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAppState(context);
    return const SizedBox.shrink();
  }

  Future<void> autoLogin(BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;

      final userSession = await UserSession.load();

      final dio = Dio();
      final response = await dio.post(ApiEndpoints.auto_login_url,
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final userSession = await UserSession.load();
        UserSession newUserSession = UserSession(
            accessToken: responseData["accessToken"],
            refreshToken: responseData["refreshToken"],
            userId: responseData["userId"],
            firstName: responseData["firstName"],
            lastName: responseData["lastName"],
            educationInstitutionId: responseData["educationInstitutionId"],
            educationInstitutionName: responseData["educationInstitutionName"],
            role: responseData["role"],
            fcmToken: userSession!.fcmToken,
            username: responseData["username"],
            avatarUrl: responseData["avatarUrl"]);
        await newUserSession.save();

        int unreadNotificationNumber = responseData["unreadNotificationNumber"];
        if (unreadNotificationNumber > 0) {
          Provider.of<UserSessionProvider>(context, listen: false)
              .updateUnreadNotificationNumber(unreadNotificationNumber);
        }
        int unreadMessageNumber = responseData["unreadMessageNumber"];
        if (unreadMessageNumber > 0) {
          Provider.of<UserSessionProvider>(context, listen: false)
              .updateUnreadMessageNumber(unreadMessageNumber);
        }
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("general_error".tr());
    }
  }
}
