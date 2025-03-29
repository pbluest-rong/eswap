import 'package:flutter/material.dart';

class ForgotPwProvider extends ChangeNotifier {
  String usernameEmailPhoneNumber = "";
  String newPassword = "";
  String token = "";
  int otpMinutes = 0;

  void updateUsernameEmailPhoneNumber(String usernameEmailPhoneNumber) {
    this.usernameEmailPhoneNumber = usernameEmailPhoneNumber;
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
