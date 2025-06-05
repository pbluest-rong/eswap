import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/admin/admin_page.dart';
import 'package:eswap/presentation/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:eswap/presentation/views/splash/splash_page.dart';
import 'package:eswap/presentation/views/welcome/welcome_page.dart';
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
}
