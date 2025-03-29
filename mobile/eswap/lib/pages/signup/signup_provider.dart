import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  String? firstname;
  String? lastname;
  String? dob;
  int? educationInstitutionId;
  bool? gender;
  String? usernameEmailPhoneNumber;
  String? password;
  String? otp;
  int otpMinutes = 0;

  void updateOTPMinutes(int otpMinutes) {
    this.otpMinutes = otpMinutes;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'educationInstitutionId': educationInstitutionId,
      'dob': dob,
      'gender': gender,
      'usernameEmailPhoneNumber': usernameEmailPhoneNumber,
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

  void updateUsernameEmailPhoneNumber(String usernameEmailPhoneNumber) {
    this.usernameEmailPhoneNumber = usernameEmailPhoneNumber;
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
