import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/provider/user_provider.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/views/admin/admin_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_email_page.dart';
import 'package:eswap/presentation/views/main_page.dart';
import 'package:eswap/presentation/views/signup/signup_name_page.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

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
      String url = ApiEndpoints.login_url;

      try {
        String usernameEmailPhoneNumber = emailController.text;
        final RegExp phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
        if (phoneRegex.hasMatch(emailController.text)) {
          usernameEmailPhoneNumber =
              "+84${emailController.text.startsWith('0') ? emailController.text.substring(1) : emailController.text}";
        }
        final response = await dio.post(
          url,
          data: {
            "usernameEmailPhoneNumber": usernameEmailPhoneNumber,
            "password": passwordController.text,
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
          }),
        );

        if (response.statusCode == 200 && response.data["success"] == true) {
          // Lấy FCM token mới
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            UserSession userSession = UserSession(
                accessToken: response.data["data"]["accessToken"],
                refreshToken: response.data["data"]["refreshToken"],
                userId: response.data["data"]["userId"],
                firstName: response.data["data"]["firstName"],
                lastName: response.data["data"]["lastName"],
                educationInstitutionId: response.data["data"]
                    ["educationInstitutionId"],
                educationInstitutionName: response.data["data"]
                    ["educationInstitutionName"],
                role: response.data["data"]["role"],
                fcmToken: fcmToken,
                username: response.data["data"]["username"],
                avatarUrl: response.data["data"]["avatarUrl"]);
            await userSession.save();

            int unreadNotificationNumber =
                response.data["data"]["unreadNotificationNumber"];
            if (unreadNotificationNumber != null &&
                unreadNotificationNumber > 0) {
              Provider.of<UserSessionProvider>(context, listen: false)
                  .updateUnreadNotificationNumber(unreadNotificationNumber);
            }
            int unreadMessageNumber =
                response.data["data"]["unreadMessageNumber"];
            if (unreadMessageNumber != null && unreadMessageNumber > 0) {
              Provider.of<UserSessionProvider>(context, listen: false)
                  .updateUnreadMessageNumber(unreadMessageNumber);
            }
            // Gửi FCM token lên server
            url = ApiEndpoints.saveFcmToken_url;
            await dio
                .post(
              url,
              queryParameters: {"fcmToken": fcmToken},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  "Accept-Language": context.locale.languageCode,
                  "Authorization": "Bearer ${userSession!.accessToken}",
                },
              ),
            )
                .catchError((error) {
              print("Lỗi khi gửi FCM Token: $error");
            });
            if (userSession.role == "ADMIN") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()),
                (Route<dynamic> route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
                (Route<dynamic> route) => false,
              );
            }
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
                  ClipOval(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 100,
                      height: 100,
                      fit: BoxFit.fill,
                    ),
                  ),
                  // Text(
                  //   "login_title".tr(),
                  //   style: textTheme.headlineLarge,
                  // ),
                  SizedBox(
                    height: 40,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Email, số điện thoại ${"or".tr()} username",
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotpwEmailPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.transparent,
                        child: Text(
                          "forgot_your_password".tr(),
                          style: textTheme.labelLarge,
                        ),
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
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      text: "signup".tr(),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpNamePage()));
                        },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
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
