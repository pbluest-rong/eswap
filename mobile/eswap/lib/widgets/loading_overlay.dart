import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


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
