import 'package:eswap/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();

  factory ThemeManager() => _instance;

  ThemeManager._internal() {
    _loadThemeMode();
  }

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    _saveThemeMode(mode);
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
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
