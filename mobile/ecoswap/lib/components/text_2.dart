import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Text2 extends StatelessWidget {
  final String textKey;

  const Text2({Key? key, required this.textKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      textKey,
      style: TextStyle(
          fontFamily: "Lato", fontSize: 26, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
