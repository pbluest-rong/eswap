import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/dialogs/dialog.dart';
import 'package:eswap/core/utils/enums.dart';
import 'package:eswap/widgets/loading_overlay.dart';
import 'package:eswap/widgets/password_tf.dart';
import 'package:eswap/pages/forgotpw/forgotpw_provider.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      LoadingOverlay.show(context);

      Provider.of<ForgotPwProvider>(context, listen: false)
          .updatePassword(confirmPasswordController.text);

      final dio = Dio();
      const url = ServerInfo.forgotpw_url;

      try {
        final response = await dio.post(
          url,
          data: Provider.of<ForgotPwProvider>(context, listen: false).toJsonForChangePw(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
          }),
        );
        if (response.statusCode == 200 && response.data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${response.data['message']}")),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("reset_pw".tr(),
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
      body: SafeArea(
        child: Form(
          key: _formKey, // Form validation
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 24),
                        AppPasswordTextField(
                          labelText: "new_pw".tr(),
                          controller: passwordController,
                        ),
                        SizedBox(height: 24),
                        AppPasswordTextField(
                          labelText: "confirm_new_pw".tr(),
                          controller: confirmPasswordController,
                          matchController:
                              passwordController, // Kiểm tra trùng khớp
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _submitForm();
                            },
                            child: Text("login".tr()),
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
      ),
    );
  }
}
