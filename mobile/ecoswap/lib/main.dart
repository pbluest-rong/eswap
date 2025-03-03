import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:ecoswap/common/textfields.dart';
import 'package:ecoswap/theme/themeTest.dart';
import 'package:ecoswap/theme/theme_constant.dart';
import 'package:ecoswap/theme/theme_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
      supportedLocales: [Locale("vi"), Locale("en")],
      path: "assets/translations",
      child: const MyApp()));
}

final _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "EcoSwap",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ThemeTest(),
            ),
          ),
        ),
      ),
    );
  }
}
