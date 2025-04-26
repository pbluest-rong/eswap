import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/theme/theme.dart';
import 'package:eswap/presentation/views/home/search_filter_sort_provider.dart';
import 'package:eswap/presentation/views/forgotpw/forgotpw_provider.dart';
import 'package:eswap/presentation/views/home/explore.dart';
import 'package:eswap/presentation/views/home/following.dart';
import 'package:eswap/presentation/views/init_page.dart';
import 'package:eswap/presentation/views/post/add_post_provider.dart';
import 'package:eswap/presentation/views/signup/signup_provider.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eswap/presentation/views/notification/notification_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

// Initialize notifications
  await LocalNotifications.init();
  final notificationService = NotificationService();
  await notificationService.initNotifications();

  runApp(EasyLocalization(
    supportedLocales: [Locale("vi"), Locale("en")],
    path: "assets/translations",
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForgotPwProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => SearchFilterSortProvider()),
        ChangeNotifierProvider(create: (_) => AddPostProvider())
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
          NotificationPage.route: (context) => const NotificationPage(),
          FollowingPage.route: (context) => const FollowingPage(),
          ExplorePage.route: (context) => const ExplorePage()
        },
        debugShowCheckedModeBanner: false,
        title: "Eswap",
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _themeManager.themeMode,
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        home: Scaffold(
          body: InitPage(),
        ));
  }
}
