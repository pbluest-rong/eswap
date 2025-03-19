import 'package:flutter/material.dart';

class ForgotPwProvider extends ChangeNotifier {
  String email = "";
  String newPassword = "";
  String otp = "";
  int otpMinutes = 0;

  void updateEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void updatePassword(String newPassword) {
    this.newPassword = newPassword;
    notifyListeners();
  }

  void updateOTP(String otp) {
    this.otp = otp;
    notifyListeners();
  }

  void updateOTPMinutes(int otpMinutes) {
    this.otpMinutes = otpMinutes;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'newPassword': newPassword,
      'otp': otp,
    };
  }
}
