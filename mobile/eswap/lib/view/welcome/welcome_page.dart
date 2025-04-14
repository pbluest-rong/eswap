import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/widgets/password_tf.dart';
import 'package:flutter/material.dart';
import 'package:eswap/view/login/login_page.dart';
import 'package:eswap/view/signup/signup_name_page.dart';

class WelcomePage extends StatelessWidget {
  final bool isFirstTimeInstallApp;

  const WelcomePage({super.key, required this.isFirstTimeInstallApp});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: AppBody(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/welcome.png",
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        "welcome_title".tr(),
                        style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 42,
                      ),
                      Text(
                        "welcome_desc".tr(),
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16, bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpNamePage()),
                        );
                      },
                      child: Text(
                        "signup".tr(),
                        style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text("login".tr()),
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
