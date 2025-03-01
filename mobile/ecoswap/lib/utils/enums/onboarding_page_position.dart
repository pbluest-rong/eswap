import 'package:easy_localization/easy_localization.dart';

enum  OnBoardingPagePosition{
  page1, page2, page3
}

extension OnboardingPagePosition on OnBoardingPagePosition{
  String onboardingPageImage(){
    switch (this){
      case OnBoardingPagePosition.page1:
        return "assets/images/onboarding_1.png";
      case OnBoardingPagePosition.page2:
        return "assets/images/onboarding_2.png";
      case OnBoardingPagePosition.page3:
        return "assets/images/onboarding_3.png";
    }
  }
  String onboardingPageTitle(){
    switch (this){
      case OnBoardingPagePosition.page1:
        return "onboarding_1_title".tr();
      case OnBoardingPagePosition.page2:
        return "onboarding_2_title".tr();
      case OnBoardingPagePosition.page3:
        return "onboarding_3_title".tr();
    }
  }
  String onboardingPageContent(){
    switch (this){
      case OnBoardingPagePosition.page1:
        return "onboarding_1_content".tr();
      case OnBoardingPagePosition.page2:
        return "onboarding_2_content".tr();
      case OnBoardingPagePosition.page3:
        return "onboarding_3_content".tr();
    }
  }
}