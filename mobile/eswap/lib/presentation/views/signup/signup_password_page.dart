import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/presentation/views/signup/signup_provider.dart';
import 'package:eswap/presentation/views/signup/signup_verify_otp_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> requireActivate() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final dio = Dio();
    final url = ApiEndpoints.requireActivate_url;
    final languageCode = context.locale.languageCode;
    final emailPhoneNumber =
        Provider.of<SignupProvider>(context, listen: false).emailPhoneNumber;

    try {
      if (Provider.of<SignupProvider>(context, listen: false).isPhoneNumber) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: emailPhoneNumber,
          timeout: const Duration(seconds: 120),
          verificationCompleted: (PhoneAuthCredential credential) async {
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            String? idToken = await userCredential.user!.getIdToken();
            Provider.of<SignupProvider>(context, listen: false)
                .updateFirebaseToken(idToken!);
          },
          verificationFailed: (FirebaseAuthException e) {
            showNotificationDialog(context, e.message ?? "Lỗi xác thực");
          },
          codeSent: (String verificationId, int? resendToken) {
            Provider.of<SignupProvider>(context, listen: false)
                .updateSavedVerificationId(verificationId);
            Provider.of<SignupProvider>(context, listen: false)
                .updateResendToken(resendToken);
            Provider.of<SignupProvider>(context, listen: false).updateOTPMinutes(2);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupVerifyOTPPage()),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Xử lý khi hết thời gian chờ
          },
        );
      } else {
        final response = await dio.post(
          url,
          queryParameters: {"emailPhoneNumber": emailPhoneNumber},
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept-Language": languageCode,
            },
            validateStatus: (status) {
              return status != null;
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
              MaterialPageRoute(builder: (context) => SignupVerifyOTPPage()),
            );
          }
        } else {
          showNotificationDialog(context, response.data["message"]);
        }
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
    TextTheme textTheme = Theme.of(context).textTheme;
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
                              style: textTheme.headlineMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
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
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<SignupProvider>(context,
                                      listen: false)
                                  .updatePassword(
                                      confirmPasswordController.text);
                              requireActivate();
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