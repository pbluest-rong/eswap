import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Text3 extends StatelessWidget {
  final String textKey;
  final VoidCallback onTap;

  const Text3({Key? key, required this.textKey, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: textKey.tr(),
        style: const TextStyle(
          color: Color(0xFF1F41BB),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()..onTap = onTap,
      ),
    );
  }
}
