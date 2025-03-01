import 'package:flutter/material.dart';
import 'package:ecoswap/splash/splash_page.dart';
import 'package:ecoswap/welcome/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  Future<void> _checkAppState(BuildContext context) async {
    if (await _isOnboardingCompleted()) {
      // welcome page
      if (!context.mounted) {
        return;
      }
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => WelcomePage(
                    isFirstTimeInstallApp: false,
                  )));
    } else {
      if (!context.mounted) {
        return;
      }
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => SplashPage()));
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
