import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/common/components.dart';
import 'package:eswap/common/uitls.dart';
import 'package:eswap/enums/server_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/pages/forgotpw/forgotpw_email_page.dart';
import 'package:eswap/pages/main_page.dart';
import 'package:eswap/pages/signup/signup_name_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context);

      final dio = Dio();
      const url = ServerInfo.login_url;
      try {
        final response = await dio.post(
          url,
          data: {
            "email": emailController.text,
            "password": passwordController.text,
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
          }),
        );

        if (response.statusCode == 200 && response.data["success"] == true) {
          final token = response.data["data"]["token"];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("token", token);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } else {
          showErrorDialog(context, response.data["message"]);
        }
      } on DioException catch (e) {
        if (e.response != null) {
          showErrorDialog(
              context, e.response?.data["message"] ?? "general_error".tr());
        } else {
          showErrorDialog(context, "network_error".tr());
        }
      } finally {
        LoadingOverlay.hide();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AppBody(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: 100,
                  ),
                  Text(
                    "login_title".tr(),
                    style: textTheme.headlineLarge,
                  ),
                  SizedBox(height: 40,),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "email".tr(),
                    ),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  AppPasswordTextField(
                    labelText: "pw".tr(),
                    controller: passwordController,
                    validatePassword: false,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.labelLarge,
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
                    margin: EdgeInsets.symmetric(vertical: 30),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      child: Text("login".tr()),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  ),
                  SizedBox(height: 15,),
                  Text(
                    "or_continue_with".tr(),
                    style: textTheme.labelLarge,
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
                      SizedBox(width: 10),
                      _buildSocialButton(
                          Image.asset("assets/images/facebook.png",
                              width: 30),
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
