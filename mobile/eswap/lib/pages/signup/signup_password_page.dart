import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/common/components.dart';
import 'package:eswap/common/uitls.dart';
import 'package:eswap/enums/server_info.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:eswap/pages/signup/signup_verify_email_page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SignupPasswordPage extends StatefulWidget {
  SignupPasswordPage({super.key});

  @override
  State<SignupPasswordPage> createState() => _SignupPasswordPageState();
}

class _SignupPasswordPageState extends State<SignupPasswordPage> {
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> requireActivateEmail() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final dio = Dio();
    const url = ServerInfo.requireActivateEmail_url;
    final languageCode = context.locale.languageCode;
    final email = Provider.of<SignupProvider>(context, listen: false).email;

    try {
      final response = await dio.post(
        url,
        queryParameters: {"email": email},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
          },
          validateStatus: (status) {
            return status !=
                null;
          },
        ),
      );
      if (response.statusCode == 200 && response.data["success"] == true) {
        final minutes = response.data["data"]["minutes"];
        Provider.of<SignupProvider>(context, listen: false)
            .updateOTPMinutes(minutes);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignupVerifyEmailPage()),
          );
        }
      } else {
        showErrorDialog(context, response.data["message"]);
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e")),
        );
      }
    } finally {
      LoadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme _textTheme = Theme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "signup_question_6".tr(),
                              style: _textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        AppPasswordTextField(
                          labelText: "pw".tr(),
                          controller: passwordController,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        AppPasswordTextField(
                          labelText: "confirm_pw".tr(),
                          controller: confirmPasswordController,
                          matchController: passwordController,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<SignupProvider>(context,
                                      listen: false)
                                  .updatePassword(
                                      confirmPasswordController.text);
                              requireActivateEmail();
                            },
                            child: Text(
                              "next".tr(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
