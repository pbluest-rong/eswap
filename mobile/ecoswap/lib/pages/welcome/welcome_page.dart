import 'package:easy_localization/easy_localization.dart';
import 'package:ecoswap/common/buttons.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/pages/login/login_page.dart';
import 'package:ecoswap/pages/signup/signup_name_page.dart';

class WelcomePage extends StatelessWidget {
  final bool isFirstTimeInstallApp;

  const WelcomePage({super.key, required this.isFirstTimeInstallApp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            // Đổi từ SingleChildScrollView sang Column
            children: [
              Expanded(
                // Giúp tránh lỗi overflow
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/welcome.png",
                        width: 363,
                        height: 370,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        "welcome_title".tr(),
                      ),
                      Text(
                        "welcome_desc".tr(),
                      ),
                      SizedBox(height: 20),
                      // Thêm khoảng trống thay vì Spacer()
                    ],
                  ),
                ),
              ),
              // Khu vực nút bấm cố định ở cuối màn hình
              Container(
                margin: EdgeInsets.only(top: 16, bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButtonPrimary(
                      textKey: "login".tr(),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                    ),
                    SizedBox(width: 32),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpNamePage()));
                      },
                      child: Text(
                        "signup".tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Lato",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
