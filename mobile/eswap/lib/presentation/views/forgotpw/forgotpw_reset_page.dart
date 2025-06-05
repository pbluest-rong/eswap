import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/views/setting/settings_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_provider.dart';
import 'package:eswap/presentation/views/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  bool isAccountSettingScreen;

  ResetPasswordPage({super.key, this.isAccountSettingScreen = false});

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
      final url = ApiEndpoints.forgotpw_url;

      try {
        final response = await dio.post(
          url,
          data: Provider.of<ForgotPwProvider>(context, listen: false)
              .toJsonForChangePw(),
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
          }),
        );
        if (response.statusCode == 200 && response.data["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${response.data['message']}")),
          );
          if (widget.isAccountSettingScreen) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } else {
          showNotificationDialog(context, response.data["message"]);
        }
      } on DioException catch (e) {
        if (e.response != null) {
          showNotificationDialog(
              context, e.response?.data["message"] ?? "general_error".tr());
        } else {
          showNotificationDialog(context, "network_error".tr());
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
                            child: Text("submit".tr()),
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
