import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/core/onboarding/onboarding_page_position.dart';
import 'package:eswap/core/validation/validators.dart';
import 'package:eswap/presentation/views/login/login_page.dart';
import 'package:eswap/presentation/views/signup/signup_provider.dart';
import 'package:eswap/presentation/widgets/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignupVerifyOTPPage extends StatefulWidget {
  const SignupVerifyOTPPage({super.key});

  @override
  State<SignupVerifyOTPPage> createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<SignupVerifyOTPPage> {
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
        Provider.of<SignupProvider>(context, listen: false).otpMinutes;
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

    if (!mounted) return;
    LoadingOverlay.show(context);
    final emailPhoneNumber =
        Provider.of<SignupProvider>(context, listen: false).emailPhoneNumber;
    final signupProvider = Provider.of<SignupProvider>(context, listen: false);

    try {
      if (signupProvider.isPhoneNumber) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: emailPhoneNumber,
          timeout: const Duration(seconds: 120),
          forceResendingToken: signupProvider.resendToken,
          // Thêm dòng này
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (!mounted) return;
            LoadingOverlay.hide();
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            String? idToken = await userCredential.user!.getIdToken();
            signupProvider.updateFirebaseToken(idToken!);
          },
          verificationFailed: (FirebaseAuthException e) {
            if (!mounted) return;
            LoadingOverlay.hide();
            showNotificationDialog(context, e.message ?? "Lỗi xác thực");
          },
          codeSent: (String verificationId, int? resendToken) {
            if (!mounted) return;
            LoadingOverlay.hide();
            signupProvider.updateSavedVerificationId(verificationId);
            signupProvider.updateResendToken(resendToken); // Lưu resendToken
            signupProvider.updateOTPMinutes(2);
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
        final dio = Dio();
        final url = ApiEndpoints.requireActivate_url;
        final response = await dio.post(
          url,
          queryParameters: {"emailPhoneNumber": emailPhoneNumber},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": context.locale.languageCode,
          }),
        );
        if (!mounted) return;
        LoadingOverlay.hide();

        if (response.statusCode == 200 && response.data["success"] == true) {
          final minutes = response.data["data"]["minutes"];
          Provider.of<SignupProvider>(context, listen: false)
              .updateOTPMinutes(minutes);
          setState(() {
            remainingSeconds = minutes * 60;
            startCountdown();
          });
        } else {
          showNotificationDialog(context, response.data["message"]);
        }
      }
    } catch (e) {
      if (!mounted) return;
      LoadingOverlay.hide();
      if (e is DioException) {
        if (e.response != null) {
          showNotificationDialog(
              context, e.response?.data["message"] ?? "general_error".tr());
        } else {
          showNotificationDialog(context, "network_error".tr());
        }
      } else if (e is FirebaseAuthException) {
        showNotificationDialog(context, e.message ?? "Lỗi xác thực");
      } else {
        showNotificationDialog(context, "general_error".tr());
      }
    }
  }

  Future<void> signup() async {
    if (!mounted) return;
    LoadingOverlay.show(context);

    final dio = Dio();

    final signupProvider = Provider.of<SignupProvider>(context, listen: false);
    try {
      if (signupProvider.isPhoneNumber) {
        final url = ApiEndpoints.register_phone_url;

        final verificationId =
            Provider.of<SignupProvider>(context, listen: false)
                .savedVerificationId;
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: getOtpCode(),
        );
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        String? idToken = await userCredential.user!.getIdToken();
        Provider.of<SignupProvider>(context, listen: false)
            .updateFirebaseToken(idToken!);
        final response = await dio.post(
          url,
          data: Provider.of<SignupProvider>(context, listen: false).toJson(),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          ),
        );
        if (response.statusCode == 200 && response.data["success"] == true) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } else {
          showNotificationDialog(context, response.data["message"]);
        }
      } else {
        final url = ApiEndpoints.register_email_url;
        Provider.of<SignupProvider>(context, listen: false)
            .updateOtp(getOtpCode());
        final response = await dio.post(
          url,
          data: Provider.of<SignupProvider>(context, listen: false).toJson(),
          options: Options(headers: {"Content-Type": "application/json"}),
        );
        if (response.statusCode == 200 && response.data["success"] == true) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
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
        Provider.of<SignupProvider>(context, listen: false).emailPhoneNumber;

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 32),
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
                                text: " $usernameEmailPhoneNumber ",
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
                              signup();
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
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInputAll(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Form(
        child: Wrap(
          spacing: 8,
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
