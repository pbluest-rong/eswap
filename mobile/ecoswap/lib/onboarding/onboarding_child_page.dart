import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/components/bt.dart';
import 'package:ecoswap/components/text_2.dart';
import 'package:ecoswap/components/text_4.dart';
import 'package:ecoswap/utils/enums/onboarding_page_position.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildSkipButton(),
                _buildImage(),
                _buildPageControl(),
                _buildTitleAndContent(),
                _buildNextAndPrevButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      alignment: AlignmentDirectional.centerStart,
      child: Text4(
          textKey: "skip".tr(),
          onTap: () {
            skipOnPressed();
          }),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      onBoardingPagePosition.onboardingPageImage(),
      height: 296,
      width: 271,
      fit: BoxFit.contain,
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
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(56)),
          ),
          // 2
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            height: 4,
            width: 26,
            decoration: BoxDecoration(
                color: onBoardingPagePosition == OnBoardingPagePosition.page2
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(56)),
          ),
          // 3
          Container(
            height: 4,
            width: 26,
            decoration: BoxDecoration(
                color: onBoardingPagePosition == OnBoardingPagePosition.page3
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(56)),
          )
        ],
      ),
    );
  }

  Widget _buildTitleAndContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            onBoardingPagePosition.onboardingPageTitle(),
            style: TextStyle(
                fontFamily: "Lato", fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 42,
          ),
          Text(
            onBoardingPagePosition.onboardingPageContent(),
            style: TextStyle(fontFamily: "Lato", fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextAndPrevButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24).copyWith(top: 107),
      child: Row(
        children: [
          Text4(
              textKey: "back".tr(),
              onTap: () {
                backOnPressed.call();
              }),
          Spacer(),
          Button1(
              textKey: onBoardingPagePosition == OnBoardingPagePosition.page3
                  ? "get_start".tr()
                  : "next".tr(),
              onPressed: () {
                nextOnPressed.call();
                //Cach 2: nextOnPressed();
              }),
        ],
      ),
    );
  }
}
