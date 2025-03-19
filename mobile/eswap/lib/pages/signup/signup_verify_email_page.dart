import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/enums/server_info.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignupVerifyEmailPage extends StatefulWidget {
  const SignupVerifyEmailPage({super.key});

  @override
  State<SignupVerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<SignupVerifyEmailPage> {
  bool isLoading = false;
  int remainingSeconds = 0; // Tổng số giây còn lại
  Timer? countdownTimer; // Bộ đếm thời gian
  List<String> otpValues = List.filled(6, '');

  String getOtpCode() {
    return otpValues.join(); // Nối tất cả giá trị lại
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final minutes = Provider.of<SignupProvider>(context, listen: false).otpMinutes;
    setState(() {
      remainingSeconds = minutes * 60; // Chuyển phút thành giây
    });
    startCountdown();
  }

  void startCountdown() {
    countdownTimer?.cancel(); // Hủy bộ đếm cũ nếu có
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

  int resendCooldown = 60;
  Timer? resendTimer;
  bool canResend = true; // Biến kiểm soát việc gửi lại OTP
  void startResendCooldown() {
    resendTimer?.cancel(); // Hủy bộ đếm cũ nếu có
    resendCooldown = 60; // Reset lại thời gian chờ
    setState(() {}); // Cập nhật UI để hiển thị thời gian đếm ngược

    resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (resendCooldown > 0) {
            resendCooldown--;
          } else {
            timer.cancel();
            canResend = true; // Cho phép gửi lại khi hết thời gian
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
          title: Text("Xác nhận"),
          content: Text("Bạn có chắc chắn muốn gửi lại mã OTP?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Gửi lại"),
            ),
          ],
        );
      },
    );

    if (confirmResend != true) return;

    setState(() {
      isLoading = true;
      canResend = false;
      startResendCooldown();
    });

    final dio = Dio();
    const url = ServerInfo.requireActivateEmail_url;
    final email = Provider.of<SignupProvider>(context, listen: false).email;

    try {
      final response = await dio.post(
        url,
        queryParameters: {"email": email},
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200) {
        final minutes = response.data["data"]["minutes"];
        Provider.of<SignupProvider>(context, listen: true)
            .updateOTPMinutes(minutes);
        remainingSeconds = minutes * 60;
        startCountdown();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Lỗi: ${response.data['message'] ?? 'Không xác định'}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> signup() async {
    if (!mounted) return; // Kiểm tra context trước khi tiếp tục

    setState(() {
      isLoading = true;
    });

    final dio = Dio();
    const url = ServerInfo.register_url;

    try {
      Provider.of<SignupProvider>(context, listen: false).updateOtp(getOtpCode());
      final response = await dio.post(
        url,
        data: Provider.of<SignupProvider>(context, listen: false).toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Lỗi: ${response.data['message'] ?? 'Không xác định'}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Provider.of<SignupProvider>(context, listen: false).email;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("signup_verify_title".tr(),
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
                              TextSpan(text: "signup_verify_desc_head".tr()),
                              TextSpan(
                                text: " $email ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "signup_verify_desc_tail".tr()),
                            ],
                          ),
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
      height: 68,
      width: 64,
      child: TextFormField(
        onChanged: (value) {
          if (value.length == 1) {
            otpValues[index] = value; // Lưu số vào danh sách
            if (index < 5) {
              FocusScope.of(context).nextFocus(); // Chuyển sang ô tiếp theo
            } else {
              FocusScope.of(context)
                  .unfocus(); // Nếu nhập ô cuối cùng thì bỏ focus
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
