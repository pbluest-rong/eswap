import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Text1 extends StatelessWidget {
  final String textKey;

  const Text1({Key? key, required this.textKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
        textKey,
        style: const TextStyle(
          color: Color(0xFF1F41BB),
          fontFamily: "Lato",
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      );
  }
}
