import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/DemoNotification.dart';
import 'package:eswap/firebase/firebase_api.dart';
import 'package:eswap/pages/forgotpw/forgotpw_provider.dart';
import 'package:eswap/pages/init_page.dart';
import 'package:eswap/pages/login/login_page.dart';
import 'package:eswap/pages/signup/signup_gender_page.dart';
import 'package:eswap/pages/signup/signup_provider.dart';
import 'package:eswap/theme/theme_constant.dart';
import 'package:eswap/theme/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();

  runApp(EasyLocalization(
    supportedLocales: [Locale("vi"), Locale("en")],
    path: "assets/translations",
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForgotPwProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
      ],
      child: MyApp(),
    ),
  ));
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
      navigatorKey: navigatorKey,
      routes: {
        DemoNotification.route: (context) => const DemoNotification(),
      },
      debugShowCheckedModeBanner: false,
      title: "eswap",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      home: Scaffold(
        body: SafeArea(child: DemoNotification()),
      ),
    );
  }
}
