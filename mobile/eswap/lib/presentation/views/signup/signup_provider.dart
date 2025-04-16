import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  String? firstname;
  String? lastname;
  String? dob;
  int? educationInstitutionId;
  bool? gender;
  String? emailPhoneNumber;
  String? password;
  String? otp;
  int otpMinutes = 0;
  bool isPhoneNumber = false;
  String? savedVerificationId;
  String? firebaseToken;
  int? resendToken;

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

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'educationInstitutionId': educationInstitutionId,
      'dob': dob,
      'gender': gender,
      'emailPhoneNumber': emailPhoneNumber,
      'password': password,
      'otp': otp
    };
  }

  void updateFirstName(String firstname) {
    this.firstname = firstname;
    notifyListeners();
  }

  void updateLastName(String lastname) {
    this.lastname = lastname;
    notifyListeners();
  }

  void updateEducationInstitutionId(int educationInstitutionId) {
    this.educationInstitutionId = educationInstitutionId;
    notifyListeners();
  }

  void updateDob(String dob) {
    this.dob = dob;
    notifyListeners();
  }

  void updateGender(bool? gender) {
    this.gender = gender;
    notifyListeners();
  }

  void updateEmailPhoneNumber(String emailPhoneNumber) {
    this.emailPhoneNumber = emailPhoneNumber;
    notifyListeners();
  }

  void updateIsPhoneNumber(bool value) {
    isPhoneNumber = value;
    notifyListeners();
  }

  void updatePassword(String password) {
    this.password = password;
    notifyListeners();
  }

  void updateOtp(String otp) {
    this.otp = otp;
    notifyListeners();
  }
}
