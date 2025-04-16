import 'package:flutter/material.dart';

class ForgotPwProvider extends ChangeNotifier {
  String emailPhoneNumber = "";
  String newPassword = "";
  String token = "";
  int otpMinutes = 0;

  void updateEmailPhoneNumber(String emailPhoneNumber) {
    this.emailPhoneNumber = emailPhoneNumber;
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
