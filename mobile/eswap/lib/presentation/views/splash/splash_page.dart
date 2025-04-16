import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:eswap/presentation/views/onboarding/onboarding_page_view.dart';
import 'package:eswap/presentation/views/welcome/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
      //
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill,
                  ),
                ),
                _buildButtonSwitchLanguage(context),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OnboardingPageView()));
                    },
                    child: Text("next".tr())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSwitchLanguage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.only(bottom: 24, top: 12),
      child: TextButton(
        onPressed: () {
          final currentLocale = context.locale.toString();
          if (currentLocale == "en") {
            context.setLocale(const Locale("vi"));
          } else {
            context.setLocale(const Locale("en"));
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa
          children: [
            Text(
              "language".tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.sync_alt,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
