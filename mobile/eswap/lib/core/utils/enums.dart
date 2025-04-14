import 'package:easy_localization/easy_localization.dart';

class ServerInfo {
  static const String PROTOCOL = "http";
  static const String HOST = "192.168.1.23";
  static const String PORT = "8080";
  static const String CONTEXT_PATH = "/api/v1/";

  static const String _baseUrl =
      PROTOCOL + "://" + HOST + ":" + PORT + CONTEXT_PATH;

  // wss://192.168.1.38:8080/api/v1/ws
  static const String ws_url =
      "ws://" + HOST + ":" + PORT + CONTEXT_PATH + "ws";

  static const String login_url = _baseUrl + "auth/login";
  static const String refresh_url = _baseUrl + "auth/refresh-token";
  static const String requireActivate_url =
      _baseUrl + "auth/require-activate";
  static const String register_email_url = _baseUrl + "auth/register-email";
  static const String register_phone_url = _baseUrl + "auth/register-phone";
  static const String requireForgotPw_url = _baseUrl + "auth/require-forgotpw";
  static const String verifyForgotpw_url = _baseUrl + "auth/verify-forgotpw";
  static const String forgotpw_url = _baseUrl + "auth/forgotpw";

  static const String getProvinces_url = _baseUrl + "institutions";
  static const String checkExist_url = _baseUrl + "auth/check-exist";

  static const String saveFcmToken_url = _baseUrl + "fcm/save-token";
  static const String getPostsByEducationInstitution_url = _baseUrl + "posts/education-institutions";
  static const String getPostsOfFollowing = _baseUrl + "posts/following";
  static const String getExplorePosts = _baseUrl + "posts";
  static const String getPostsByProvince = _baseUrl + "posts/province";
  static const String getCategories = _baseUrl + "categories";
  static const String getBrandsByCategory = _baseUrl + "categories/brands";
}

enum OnBoardingPagePosition { page1, page2, page3 }

extension OnboardingPagePosition on OnBoardingPagePosition {
  String onboardingPageImage() {
    switch (this) {
      case OnBoardingPagePosition.page1:
        return "assets/images/onboarding_1.png";
      case OnBoardingPagePosition.page2:
        return "assets/images/onboarding_2.png";
      case OnBoardingPagePosition.page3:
        return "assets/images/onboarding_3.png";
    }
  }

  String onboardingPageTitle() {
    switch (this) {
      case OnBoardingPagePosition.page1:
        return "onboarding_1_title".tr();
      case OnBoardingPagePosition.page2:
        return "onboarding_2_title".tr();
      case OnBoardingPagePosition.page3:
        return "onboarding_3_title".tr();
    }
  }

  String onboardingPageContent() {
    switch (this) {
      case OnBoardingPagePosition.page1:
        return "onboarding_1_content".tr();
      case OnBoardingPagePosition.page2:
        return "onboarding_2_content".tr();
      case OnBoardingPagePosition.page3:
        return "onboarding_3_content".tr();
    }
  }
}
