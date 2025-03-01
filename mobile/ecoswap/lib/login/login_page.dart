import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/components/text_4.dart';
import 'package:ecoswap/components/bt.dart';
import 'package:ecoswap/components/text_2.dart';
import 'package:ecoswap/components/pwf.dart';
import 'package:ecoswap/components/tf_1.dart';
import 'package:ecoswap/components/text_3.dart';
import 'package:ecoswap/components/text_1.dart';
import 'package:ecoswap/forgotpw/forgotpw_email_page.dart';
import 'package:ecoswap/main_page.dart';
import 'package:ecoswap/signup/signup_name_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text1(textKey: "login_title".tr()),
                  Text2(textKey: "login_desc".tr()),
                  Container(
                    margin: EdgeInsets.only(
                        top: 40, right: 12, bottom: 60, left: 12),
                    child: Column(
                      children: [
                        TextField1(
                          label: "email".tr(),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 24),
                        PasswordField(labelText: "pw".tr(),),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text3(
                            textKey: "forgot_your_password",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotpwEmailPage()));
                            },
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 32),
                            width: double.infinity,
                            child: Button1(
                                textKey: "login".tr(),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainPage()));
                                })),
                        Text4(
                            textKey: "signup".tr(),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpNamePage()));
                            })
                      ],
                    ),
                  ),
                  Text3(textKey: "or_continue_with".tr(), onTap: () {}),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                          Image.asset(
                            "assets/images/google.png",
                            width: 30,
                          ),
                          () {}),
                      SizedBox(width: 16),
                      _buildSocialButton(
                          Image.asset("assets/images/facebook.png", width: 30),
                          () {}),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(Image icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: icon,
        ),
      ),
    );
  }
}
