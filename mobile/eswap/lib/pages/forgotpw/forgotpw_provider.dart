import 'package:flutter/material.dart';

class ForgotPwProvider extends ChangeNotifier {
  String email = "";
  String newPassword = "";
  String token = "";
  int otpMinutes = 0;

  void updateEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void updatePassword(String newPassword) {
    this.newPassword = newPassword;
    notifyListeners();
  }
  void updateToken(String token) {
    this.token = token;
    notifyListeners();
  }

  void updateOTPMinutes(int otpMinutes) {
    this.otpMinutes = otpMinutes;
    notifyListeners();
  }

  Map<String, dynamic> toJsonForChangePw() {
    return {
      'token': token,
      'newPassword': newPassword
    };
  }
}
