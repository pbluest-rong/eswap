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
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("accessToken");
      if(accessToken==null){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WelcomePage(
                  isFirstTimeInstallApp: false,
                )));
      }else{
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
              (Route<dynamic> route) => false,
        );
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
