import 'package:flutter/material.dart';
import 'package:eswap/pages/onboarding/onboarding_child_page.dart';
import 'package:eswap/pages/splash/splash_page.dart';
import 'package:eswap/enums/onboarding_page_position.dart';
import 'package:eswap/pages/welcome/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final _pageControler = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: PageView(
          controller: _pageControler,
          children: [
            OnboardingChildPage(
              onBoardingPagePosition: OnBoardingPagePosition.page1,
              nextOnPressed: () {
                _pageControler.jumpToPage(1);
              },
              backOnPressed: () {
                _resetOnboardingCompleted();
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const SplashPage()));
              },
              skipOnPressed: () {
                _goToWelcomePage();
              },
            ),
            OnboardingChildPage(
              onBoardingPagePosition: OnBoardingPagePosition.page2,
              nextOnPressed: () {
                _pageControler.jumpToPage(2);
              },
              backOnPressed: () {
                _pageControler.jumpToPage(0);
              },
              skipOnPressed: () {
                _goToWelcomePage();
              },
            ),
            OnboardingChildPage(
              onBoardingPagePosition: OnBoardingPagePosition.page3,
              nextOnPressed: () {
                _goToWelcomePage();
              },
              backOnPressed: () {
                _pageControler.jumpToPage(1);
              },
              skipOnPressed: () {
                _goToWelcomePage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToWelcomePage() {
    _markOnboardingCompleted();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const WelcomePage(isFirstTimeInstallApp: true,)));
  }

  Future<void> _markOnboardingCompleted() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final result = prefs.setBool("kOnBoardingCompleted", true);
    } catch (e) {
      return;
    }
  }
  Future<void> _resetOnboardingCompleted() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final result = prefs.setBool("kOnBoardingCompleted", false);
    } catch (e) {
      return;
    }
  }
}
