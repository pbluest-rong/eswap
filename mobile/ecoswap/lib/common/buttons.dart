import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppButtonPrimary  extends StatelessWidget {
  final String textKey;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;
  final TextStyle textStyle;

  const AppButtonPrimary ({
    Key? key,
    required this.textKey,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF1F41BB),
    this.padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    this.borderRadius = 4.0,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: "Lato",
      color: Colors.white,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        textKey.tr(),
        style: textStyle,
      ),
    );
  }
}
