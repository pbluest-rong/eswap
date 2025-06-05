import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/core/validation/validators.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_provider.dart';
import 'package:eswap/presentation/views/forgotpw/vefify_email_page.dart';

class ForgotpwEmailPage extends StatefulWidget {
  bool isAccountSettingScreen;

  ForgotpwEmailPage({super.key, this.isAccountSettingScreen = false});

  @override
  State<ForgotpwEmailPage> createState() => _ForgotpwEmailPageState();
}

class _ForgotpwEmailPageState extends State<ForgotpwEmailPage> {
  // Controllers and keys
  final TextEditingController emailPhoneNumerController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Validation methods
  bool _validateEmail(String? email) {
    if (email!.trim().isEmpty) {
      return false;
    }
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Main business logic methods
  Future<void> requireForgotPw() async {
    if (_validateEmail(emailPhoneNumerController.text)) {
      Provider.of<ForgotPwProvider>(context, listen: false)
          .updateIsPhoneNumber(false);
      requireForgotWithEmail();
    } else {
      Provider.of<ForgotPwProvider>(context, listen: false)
          .updateIsPhoneNumber(true);
      checkExistUser();
    }
  }

  Future<void> checkExistUser() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final provider = Provider.of<ForgotPwProvider>(context, listen: false);
    emailPhoneNumerController.text.trim();
    final inputValue = provider.isPhoneNumber
        ? "+84${emailPhoneNumerController.text.startsWith('0') ? emailPhoneNumerController.text.substring(1) : emailPhoneNumerController.text}"
        : emailPhoneNumerController.text.trim();
    if (!_formKey.currentState!.validate()) return;

    final dio = Dio();
    final url = ApiEndpoints.checkExist_url;
    try {
      final response = await dio.post(
        url,
        queryParameters: {
          "usernameEmailPhoneNumber": inputValue,
        },
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );
      if (response.statusCode == 200 && response.data["success"] == true) {
        final bool isExist = response.data["data"]["isExist"];
        if (isExist) {
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateEmailPhoneNumber(inputValue);
          requireForgotWithPhoneNumber();
        } else {
          showNotificationDialog(
              context,
              "error_not_found".tr(args: [
                provider.isPhoneNumber ? "phone_number".tr() : "email".tr()
              ]));
        }
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

  Future<void> requireForgotWithEmail() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final dio = Dio();
    final url = ApiEndpoints.requireForgotPw_url;
    final emailPhoneNumber = emailPhoneNumerController.text.trim();

    try {
      final response = await dio.post(
        url,
        queryParameters: {"emailPhoneNumber": emailPhoneNumber},
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
          context
              .read<ForgotPwProvider>()
              .updateEmailPhoneNumber(emailPhoneNumber);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyEmailPage(
                      isAccountSettingScreen: widget.isAccountSettingScreen,
                    )),
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

  Future<void> requireForgotWithPhoneNumber() async {
    if (!mounted) return;
    LoadingOverlay.show(context);
    try {
      emailPhoneNumerController.text.trim();
      final inputValue =
          "+84${emailPhoneNumerController.text.startsWith('0') ? emailPhoneNumerController.text.substring(1) : emailPhoneNumerController.text}";
      final phoneNumber = inputValue;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          String? idToken = await userCredential.user!.getIdToken();
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateFirebaseToken(idToken!);
        },
        verificationFailed: (FirebaseAuthException e) {
          showNotificationDialog(context, e.message ?? "Lỗi xác thực");
        },
        codeSent: (String verificationId, int? resendToken) {
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateSavedVerificationId(verificationId);
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateResendToken(resendToken);
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateOTPMinutes(2);

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyEmailPage(
                      isAccountSettingScreen: widget.isAccountSettingScreen,
                    )),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Xử lý khi hết thời gian chờ
        },
      );
    } catch (e) {
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
                          labelText: "Email hoặc số điện thoại",
                        ),
                        validator: ValidationUtils.validateEmpty,
                        controller: emailPhoneNumerController,
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
