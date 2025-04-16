import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/core/validation/validators.dart';
import 'package:eswap/presentation/views/signup/signup_password_page.dart';
import 'package:eswap/presentation/views/signup/signup_provider.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:eswap/presentation/widgets/phone_number.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eswap/presentation/views/login/login_page.dart';
import 'package:provider/provider.dart';

class SignUpEmailPhoneNumberPage extends StatefulWidget {
  SignUpEmailPhoneNumberPage({super.key});

  @override
  State<SignUpEmailPhoneNumberPage> createState() =>
      _SignUpEmailPhoneNumberPageState();
}

class _SignUpEmailPhoneNumberPageState
    extends State<SignUpEmailPhoneNumberPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> checkExistUser() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final provider = Provider.of<SignupProvider>(context, listen: false);
    _phoneController.text.trim();
    final inputValue = provider.isPhoneNumber
        ? "+84${_phoneController.text.startsWith('0') ? _phoneController.text.substring(1) : _phoneController.text}"
        : _emailController.text.trim();
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
          showErrorDialog(
              context,
              "error_exist".tr(args: [
                provider.isPhoneNumber ? "phone_number".tr() : "email".tr()
              ]));
        } else {
          Provider.of<SignupProvider>(context, listen: false)
              .updateEmailPhoneNumber(inputValue);
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
                        Provider.of<SignupProvider>(context, listen: true)
                                .isPhoneNumber
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "signup_question_5_phone".tr(),
                                    style: textTheme.headlineMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "signup_question_5_phone_desc".tr(),
                                    style: textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "signup_question_5_email".tr(),
                                    style: textTheme.headlineMedium!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "signup_question_5_email_desc".tr(),
                                    style: textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                        SizedBox(height: 24),
                        Provider.of<SignupProvider>(context, listen: true)
                                .isPhoneNumber
                            ? PhoneNumber(controller: _phoneController)
                            : TextFormField(
                                decoration: InputDecoration(
                                  labelText: "email".tr(),
                                ),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: ValidationUtils.validateEmail,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                        SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                checkExistUser();
                              }
                            },
                            child: Text("next".tr()),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Consumer<SignupProvider>(
                          builder: (context, signupProvider, child) {
                            return TextButton(
                              onPressed: () {
                                signupProvider.updateIsPhoneNumber(
                                    !signupProvider.isPhoneNumber);
                              },
                              child: Text(
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                signupProvider.isPhoneNumber
                                    ? "Đăng ký bằng email"
                                    : "Đăng ký bằng số điện thoại",
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
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
