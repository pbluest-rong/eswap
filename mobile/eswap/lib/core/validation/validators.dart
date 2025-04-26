import 'package:easy_localization/easy_localization.dart';

class ValidationUtils {
  static String? validateEmpty(String? value) {
    if (value!.trim().isNotEmpty) {
      return "alert_null_value".tr();
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "alert_null_value"
          .tr(args: ["${"first_name".tr()}, ${"lastname".tr()}"]);
    }
    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(value)) {
      return "name_only_letters".tr();
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email!.trim().isEmpty) {
      return 'alert_null_value'.tr(args: ["Email"]);
    }
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'invalid_email'.tr();
    }
    return null;
  }

  static String? validatePhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return 'alert_null_value'.tr(args: ["phone_number".tr()]);
    }
    final RegExp phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      return 'invalid_phone_number'.tr();
    }
    return null;
  }

  static String? validatePostEmpty(String? value, String errorTextValue) {
    if (value == null || value.trim().isEmpty) {
      return "alert_null_value".tr(args: [errorTextValue]);
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, String errorTextValue) {
    if (value == null || value.trim().isEmpty) {
      return "alert_null_value".tr(args: [errorTextValue]);
    }

    final number = double.tryParse(value);
    if (number == null) {
      return "Vui lòng nhập số hợp lệ";
    }

    if (number < 0) {
      return "Giá trị không được nhỏ hơn 0";
    }

    return null;
  }
}
