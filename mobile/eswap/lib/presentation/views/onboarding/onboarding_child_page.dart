import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OnboardingChildPage extends StatelessWidget {
  final OnBoardingPagePosition onBoardingPagePosition;
  final VoidCallback nextOnPressed;
  final VoidCallback backOnPressed;
  final VoidCallback skipOnPressed;

  const OnboardingChildPage(
      {super.key,
      required this.onBoardingPagePosition,
      required this.nextOnPressed,
      required this.backOnPressed,
      required this.skipOnPressed});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: AppBody(
        child: Column(
          children: [
            Expanded(child:
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildSkipButton(textTheme),
                    _buildImage(),
                    _buildPageControl(),
                    _buildTitleAndContent(textTheme),
                  ],
                ),
              )
            ),
            _buildNextAndPrevButton(textTheme)
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        onPressed: () {
          skipOnPressed();
        },
        child: Text(
          "skip".tr(),
          style: textTheme.labelLarge,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      onBoardingPagePosition.onboardingPageImage(),
      height: 250,
      width: double.infinity,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _buildPageControl() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1
          Container(
            height: 4,
            width: 26,
            decoration: BoxDecoration(
                color: onBoardingPagePosition == OnBoardingPagePosition.page1
                    ? Color(0xFF1F41BB)
                    : Colors.black12,
                borderRadius: BorderRadius.circular(56)),
          ),
          // 2
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 4,
            width: 26,
            decoration: BoxDecoration(
                color: onBoardingPagePosition == OnBoardingPagePosition.page2
                    ? Color(0xFF1F41BB)
                    : Colors.black12,
                borderRadius: BorderRadius.circular(56)),
          ),
          // 3
          Container(
            height: 4,
            width: 26,
            decoration: BoxDecoration(
                color: onBoardingPagePosition == OnBoardingPagePosition.page3
                    ? Color(0xFF1F41BB)
                    : Colors.black12,
                borderRadius: BorderRadius.circular(56)),
          )
        ],
      ),
    );
  }

  Widget _buildTitleAndContent(TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            onBoardingPagePosition.onboardingPageTitle(),
            style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 42,
          ),
          Text(
            onBoardingPagePosition.onboardingPageContent(),
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextAndPrevButton(TextTheme textTheme) {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 24),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              backOnPressed.call();
            },
            child: Text(
              "back".tr(),
              style:
                  textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Spacer(),
          ElevatedButton(
              onPressed: () {
                nextOnPressed.call();
                //Cach 2: nextOnPressed();
              },
              child: Text(onBoardingPagePosition == OnBoardingPagePosition.page3
                  ? "get_start".tr()
                  : "next".tr())),
        ],
      ),
    );
  }
}
