import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_provider.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_reset_page.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:eswap/presentation/views/signup/signup_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VerifyEmailPage extends StatefulWidget {
  bool isAccountSettingScreen;

  VerifyEmailPage({super.key, this.isAccountSettingScreen = false});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  int remainingSeconds = 0;
  Timer? countdownTimer;
  List<String> otpValues = List.filled(6, '');

  String getOtpCode() {
    return otpValues.join();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final minutes =
        Provider.of<ForgotPwProvider>(context, listen: false).otpMinutes;
    if (remainingSeconds == 0) {
      remainingSeconds = minutes * 60;
      startCountdown();
    }
  }

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  int resendCooldown = 120;
  Timer? resendTimer;
  bool canResend = true;

  void startResendCooldown() {
    resendTimer?.cancel();
    resendCooldown = 120;
    setState(() {});

    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (resendCooldown > 0) {
            resendCooldown--;
          } else {
            timer.cancel();
            canResend = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> resend() async {
    if (!mounted || !canResend) return;
    bool confirmResend = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(""),
          content: Text("confirm_send_otp".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("resend".tr()),
            ),
          ],
        );
      },
    );

    if (confirmResend != true) return;

    setState(() {
      canResend = false;
      startResendCooldown();
    });

    final dio = Dio();
    final url = ApiEndpoints.requireForgotPw_url;
    final emailPhoneNumber =
        Provider.of<ForgotPwProvider>(context, listen: false).emailPhoneNumber;
    final forgotProvider =
        Provider.of<ForgotPwProvider>(context, listen: false);

    try {
      if (forgotProvider.isPhoneNumber) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: emailPhoneNumber,
          timeout: const Duration(seconds: 120),
          forceResendingToken: forgotProvider.resendToken,
          // Thêm dòng này
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (!mounted) return;
            LoadingOverlay.hide();
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            String? idToken = await userCredential.user!.getIdToken();
            forgotProvider.updateFirebaseToken(idToken!);
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;
            LoadingOverlay.hide();
            showNotificationDialog(context, e.message ?? "Lỗi xác thực");
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;
            LoadingOverlay.hide();
            forgotProvider.updateSavedVerificationId(verificationId);
            forgotProvider.updateResendToken(resendToken);
            forgotProvider.updateOTPMinutes(2);
            setState(() {
              remainingSeconds = 2 * 60;
              startCountdown();
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (!mounted) return;
            LoadingOverlay.hide();
          },
        );
      } else {
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
          Provider.of<ForgotPwProvider>(context, listen: false)
              .updateOTPMinutes(minutes);
          setState(() {
            remainingSeconds = minutes * 60;
            startCountdown();
          });
        } else {
          showNotificationDialog(context, response.data["message"]);
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        showNotificationDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
      } else {
        showNotificationDialog(context, "network_error".tr());
      }
    }
  }

  Future<void> verifyForgotPw() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final otp = getOtpCode();
    if (otp.isEmpty) {
      showNotificationDialog(context, "alert_null_value".tr(args: ["OTP"]));
      return;
    }

    final dio = Dio();
    final forgotProvider =
        Provider.of<ForgotPwProvider>(context, listen: false);
    final emailPhoneNumber =
        Provider.of<ForgotPwProvider>(context, listen: false).emailPhoneNumber;
    try {
      if (forgotProvider.isPhoneNumber) {
        final url = ApiEndpoints.verifyForgotpw_url;
        final verificationId =
            Provider.of<ForgotPwProvider>(context, listen: false)
                .savedVerificationId;
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: getOtpCode(),
        );
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        String? idToken = await userCredential.user!.getIdToken();
        Provider.of<ForgotPwProvider>(context, listen: false)
            .updateFirebaseToken(idToken!);
        final response = await dio.post(
          url,
          data: {"emailPhoneNumber": emailPhoneNumber, "otp": otp},
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          ),
        );
        if (response.statusCode == 200 && response.data["success"] == true) {
          if (mounted) {
            final token = response.data["data"]["accessToken"];
            Provider.of<ForgotPwProvider>(context, listen: false)
                .updateToken(token);
            print(token);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(
                        isAccountSettingScreen: widget.isAccountSettingScreen,
                      )),
            );
          }
        } else {
          showNotificationDialog(context, response.data["message"]);
        }
      } else {
        final url = ApiEndpoints.verifyForgotpw_url;
        final response = await dio.post(
          url,
          data: {"emailPhoneNumber": emailPhoneNumber, "otp": otp},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
          }),
        );
        if (response.statusCode == 200 && response.data["success"] == true) {
          if (mounted) {
            final token = response.data["data"]["accessToken"];
            Provider.of<ForgotPwProvider>(context, listen: false)
                .updateToken(token);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPasswordPage()),
            );
          }
        } else {
          showNotificationDialog(context, response.data["message"]);
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

  @override
  Widget build(BuildContext context) {
    final usernameEmailPhoneNumber =
        Provider.of<ForgotPwProvider>(context, listen: false).emailPhoneNumber;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Provider.of<SignupProvider>(context, listen: true).isPhoneNumber
            ? Text("signup_verify_title".tr(args: ["phone_number".tr()]))
            : Text("signup_verify_title".tr(args: ["email".tr()]),
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
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 24),
                      children: [
                        Provider.of<SignupProvider>(context, listen: true)
                                .isPhoneNumber
                            ? TextSpan(
                                text: "signup_verify_desc_head"
                                    .tr(args: ["phone_number".tr()]))
                            : TextSpan(
                                text: "signup_verify_desc_head"
                                    .tr(args: ["email".tr()])),
                        TextSpan(
                          text: " $usernameEmailPhoneNumber. ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "signup_verify_desc_tail".tr(),
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  _buildCodeInputAll(context),
                  SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        TextSpan(text: "resend_question".tr()),
                        if (canResend)
                          TextSpan(
                            text: " ${"resend".tr()}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => resend(),
                          )
                        else
                          TextSpan(
                            text: " (${resendCooldown}s)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                        TextSpan(text: "expires_in".tr()),
                        TextSpan(
                          text: " $formattedTime",
                          style: TextStyle(
                              color: const Color(0xFF1F41BB),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 32),
                    child: ElevatedButton(
                      onPressed: () {
                        verifyForgotPw();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F41BB),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4))),
                      child: Text(
                        "next".tr(),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Lato",
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInputAll(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Form(
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children:
              List.generate(6, (index) => _buildCodeInput(context, index)),
        ),
      ),
    );
  }

  Widget _buildCodeInput(BuildContext context, int index) {
    return SizedBox(
      height: 48,
      width: 42,
      child: TextFormField(
        onChanged: (value) {
          if (value.length == 1) {
            // Nếu người dùng nhập số
            setState(() {
              otpValues[index] = value; // Lưu số vào danh sách
            });
            if (index < 5) {
              FocusScope.of(context).nextFocus(); // Chuyển sang ô tiếp theo
            } else {
              FocusScope.of(context)
                  .unfocus(); // Nếu nhập ô cuối cùng thì bỏ focus
            }
          } else if (value.isEmpty) {
            // Nếu người dùng xóa số
            setState(() {
              otpValues[index] = ''; // Xóa giá trị trong ô hiện tại
            });
            if (index > 0) {
              FocusScope.of(context).previousFocus(); // Quay lại ô trước đó
            }
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
