import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/dialogs/dialog.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:eswap/core/utils/validation.dart';
import 'package:eswap/widgets/loading_overlay.dart';
import 'package:eswap/widgets/password_tf.dart';
import 'package:eswap/pages/forgotpw/forgotpw_provider.dart';
import 'package:flutter/material.dart';
import 'package:eswap/pages/forgotpw/vefify_email_page.dart';
import 'package:provider/provider.dart';

class ForgotpwEmailPage extends StatefulWidget {
  ForgotpwEmailPage({super.key});

  @override
  State<ForgotpwEmailPage> createState() => _ForgotpwEmailPageState();
}

class _ForgotpwEmailPageState extends State<ForgotpwEmailPage> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> requireForgotPw() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final dio = Dio();
    const url = ServerInfo.requireForgotPw_url;
    final email = emailController.text.trim();

    try {
      final response = await dio.post(
        url,
        queryParameters: {"email": email},
        options: Options(headers: {
          "Content-Type": "application/json",
          "Accept-Language": context.locale.languageCode,
        }),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        final minutes = response.data["data"]["minutes"];
        if (mounted) {
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateOTPMinutes(minutes);
          context.read<ForgotPwProvider>().updateEmail(email);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyEmailPage()),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("forgot_pw_title".tr(),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AppBody(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "forgot_pw_desc".tr(),
                              style: textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "email".tr(),
                        ),
                        validator: ValidationUtils.validateEmail,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 32),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              requireForgotPw();
                            }
                          },
                          child: Text("send".tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
