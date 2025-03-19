import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("error".tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Hiển thị loading overlay (CẦN `context`)
  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withOpacity(0.5),
            dismissible: false, // Ngăn chặn người dùng thao tác
          ),
          Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Colors.blue,
              size: 50,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  /// Ẩn loading overlay
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class ValidationUtils {
  static String? validateEmpty(String? value) {
    if (value!.trim().isNotEmpty) {
      return "alert_null_value".tr();
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "alert_null_value".tr(args: ["${"first_name".tr()}, ${"lastname".tr()}"]);
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
    if(!emailRegex.hasMatch(email)){
      return 'invalid_email'.tr();
    }
    return null;
  }
}
