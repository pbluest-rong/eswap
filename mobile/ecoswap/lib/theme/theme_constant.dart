
import 'package:flutter/material.dart';

const COLOR_PRIMARY = Color(0xFF1F41BB);
const COLOR_ACCENT = Colors.orange;

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: COLOR_PRIMARY,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: COLOR_ACCENT,
  ),
);


ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
);