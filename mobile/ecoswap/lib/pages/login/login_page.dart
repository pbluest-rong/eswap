import 'package:easy_localization/easy_localization.dart';
import 'package:ecoswap/common/buttons.dart';
import 'package:ecoswap/common/textfields.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ecoswap/pages/forgotpw/forgotpw_email_page.dart';
import 'package:ecoswap/pages/main_page.dart';
import 'package:ecoswap/pages/signup/signup_name_page.dart';

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
                  Text(
                    "login_title".tr(),
                  ),
                  Text(
                    "login_desc".tr(),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 40, right: 12, bottom: 60, left: 12),
                    child: Column(
                      children: [
                        AppTextField(
                          label: "email".tr(),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 24),
                        AppPasswordTextField(
                          labelText: "pw".tr(),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(
                              text: "forgot_your_password".tr(),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotpwEmailPage()));
                                },
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 32),
                            width: double.infinity,
                            child: AppButtonPrimary(
                                textKey: "login".tr(),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainPage()));
                                })),
                        RichText(
                          text: TextSpan(
                            text: "signup".tr(),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SignUpNamePage()));
                              },
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    "or_continue_with".tr(),
                  ),
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
