import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/dialogs/dialog.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:eswap/core/utils/validation.dart';
import 'package:eswap/pages/signup/signup_password_page.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:eswap/widgets/loading_overlay.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:provider/provider.dart';

class SignUpEmailPage extends StatefulWidget {
  SignUpEmailPage({super.key});

  @override
  State<SignUpEmailPage> createState() => _SignUpEmailPageState();
}

class _SignUpEmailPageState extends State<SignUpEmailPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> checkExistEmail() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final dio = Dio();
    const url = ServerInfo.checkExistEmail_url;
    try {
      final response = await dio.post(
        url,
        queryParameters: {
          "email": emailController.text,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      if (response.statusCode == 200 && response.data["success"] == true) {
        final bool isExistEmail = response.data["data"]["isExistEmail"];
        if (isExistEmail) {
          showErrorDialog(context, "error_email_exist".tr());
        } else {
          Provider.of<SignupProvider>(context, listen: false)
              .updateEmail(emailController.text.trim());
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignupPasswordPage()));
        }
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
                              "signup_question_5".tr(),
                              style: _textTheme.headlineLarge,
                            ),
                            Text(
                              "signup_question_5_desc".tr(),
                              style: _textTheme.headlineSmall,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "email".tr(),
                          ),
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: ValidationUtils.validateEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                checkExistEmail();
                              }
                            },
                            child: Text("next".tr()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    text: "signup_bottom".tr(),
                    style: TextStyle(
                      color: const Color(0xFF1F41BB),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                  ),
                ),
              ),
            ]),
          ),
        ));
  }
}
