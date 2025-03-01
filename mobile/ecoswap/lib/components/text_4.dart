import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Text4 extends StatelessWidget {
  final String textKey;
  final VoidCallback onTap;
  final TextStyle textStyle;

  const Text4({
    Key? key,
    required this.textKey,
    required this.onTap,
    this.textStyle = const TextStyle(
      color: Colors.black38,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: textKey.tr(),
        style: textStyle,
        recognizer: TapGestureRecognizer()..onTap = onTap,
      ),
    );
  }
}
