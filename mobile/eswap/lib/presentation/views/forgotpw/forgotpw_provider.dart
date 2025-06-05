import 'package:flutter/material.dart';

class ForgotPwProvider extends ChangeNotifier {
  String emailPhoneNumber = "";
  String newPassword = "";
  String token = "";
  int otpMinutes = 0;
  bool isPhoneNumber = false;
  String? savedVerificationId;
  String? firebaseToken;
  int? resendToken;

  void updateIsPhoneNumber(bool value) {
    isPhoneNumber = value;
    notifyListeners();
  }

  void updateResendToken(int? token) {
    this.resendToken = token;
    notifyListeners();
  }

  void updateOTPMinutes(int otpMinutes) {
    this.otpMinutes = otpMinutes;
    notifyListeners();
  }

  void updateFirebaseToken(String firebaseToken) {
    this.firebaseToken = firebaseToken;
    notifyListeners();
  }

  void updateSavedVerificationId(String savedVerificationId) {
    this.savedVerificationId = savedVerificationId;
    notifyListeners();
  }

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

  Map<String, dynamic> toJsonForChangePw() {
    return {'token': token, 'newPassword': newPassword};
  }
}
