import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const lightPrimary = Color(0xFF1F41BB);
  static const lightSecondary = Color(0xFF03DAC5);
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightText = Color(0xFF333333);
  static const lightError = Color(0xFFB00020);

  // Dark Theme Colors
  static const darkPrimary = Color(0xFFBB86FC);
  static const darkSecondary = Color(0xFF03DAC5);
  static const darkBackground = Color(0xFF121212);
  static const darkText = Color(0xFFE0E0E0);
  static const darkError = Color(0xFFCF6679);
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  colorScheme: ColorScheme.light(
    primary: AppColors.lightPrimary,
  ),
  fontFamily: "Lato",
  textTheme: TextTheme(
      bodyLarge: TextStyle(fontFamily: "Lato"),
      bodyMedium: TextStyle(fontFamily: "Lato"),
      bodySmall: TextStyle(fontFamily: "Lato"),
      labelMedium: TextStyle(color: Color(0xFF1F41BB))),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1F41BB),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      foregroundColor: Colors.white,
      textStyle: TextStyle(
          fontSize: 18, fontFamily: "Lato"),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      side: BorderSide(
        color: AppColors.lightPrimary,
        width: 2,
      ),
      foregroundColor: AppColors.lightPrimary,
      // Text color
      textStyle:  TextStyle(
        fontSize: 18,
        fontFamily: "Lato",
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    filled: true,
    fillColor: const Color(0xFFF1F4FF),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: "Lato",
  // Đặt font chung
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontFamily: "Lato"),
    bodyMedium: TextStyle(fontFamily: "Lato"),
    bodySmall: TextStyle(fontFamily: "Lato"),
  ),
  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all<Color>(Colors.red),
    thumbColor: MaterialStateProperty.all<Color>(Colors.green),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      padding: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      textStyle: TextStyle(fontFamily: "Lato"), // Áp dụng font cho button
    ),
  ),
);
