import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/enum_model.dart';
import 'package:eswap/model/notification_model.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/views/chat/chat_list_page.dart';
import 'package:eswap/presentation/views/home/home_page.dart';
import 'package:eswap/presentation/views/notification/notification_page.dart';
import 'package:eswap/presentation/views/post/standalone_post.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/auth_interceptor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    final prefs = await SharedPreferences.getInstance();
    print("FCM Token: $fcmToken");
    await prefs.setString("fcmToken", fcmToken!);
    await initPushNotifications();
  }

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("handle 0");
        handleMessageOpenedApp(message);
      }
    });

    // Handle notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("handle 1");
      handleMessageOpenedApp(message);
    });

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      print("handle 2");
      handleMessage(message);
    });
  }

  void handleMessageOpenedApp(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      Map<String, dynamic> parsedData = json.decode(message.data['data']);
      NotificationModel notification = NotificationModel.fromJson(parsedData);
      handleNavigate(notification);
    }

    if (message.notification != null) {
      print('Notification body: ${message.notification!.body}');
    }
  }

  void handleMessage(RemoteMessage message) {
    if (message.notification != null) {
      LocalNotifications.showSimpleNotification(
        title: message.notification!.title ?? "New Notification",
        body: message.notification!.body ?? "",
        payload: message.data.toString(),
      );
    }
  }

  void handleNavigate(NotificationModel notification) {
    NotificationCategory? category =
        notificationCategoryFromString(notification.category);

    if (category != null) {
      final NotificationService _notificationService = NotificationService();
      switch (category) {
        case NotificationCategory.NEW_FOLLOW:
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => DetailUserPage(userId: notification.senderId!)),
          );
          break;
        case NotificationCategory.NEW_LIKE:
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => StandalonePost(postId: notification.postId!)),
          );
          break;
        case NotificationCategory.NEW_POST_FOLLOWER:
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => DetailUserPage(userId: notification.senderId!)),
          );
          break;
        case NotificationCategory.NEW_NOTICE:
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => NotificationPage()),
          );
          break;
        case NotificationCategory.NEW_MESSAGE:
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => ChatList()),
          );
          break;
        default:
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => HomePage()),
          );
          break;
      }
      if (!notification.read) {
        _notificationService.markAsRead(notification.id);
      }
    }
  }

  NotificationCategory? notificationCategoryFromString(String value) {
    try {
      return NotificationCategory.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  Future<PageResponse<NotificationModel>> fetchNotifications(
      int page, int size, BuildContext context) async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      dio.interceptors.add(AuthInterceptor(dio, prefs));
      final accessToken = prefs.getString('accessToken');

      final response = await dio.get(
        ApiEndpoints.getNotifications,
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        }),
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        return PageResponse<NotificationModel>.fromJson(
          responseData,
          (json) => NotificationModel.fromJson(json),
        );
      } else {
        showErrorDialog(context, response.data["message"]);
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        showErrorDialog(
            context, e.response?.data["message"] ?? "general_error".tr());
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        showErrorDialog(context, "network_error".tr());
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("Failed to load post: ${e.toString()}");
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final dio = Dio();
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.get("accessToken");
      dio
          .put(
            "${ApiEndpoints.markAsReadNotification}/$notificationId",
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $accessToken"
              },
            ),
          )
          .catchError((error) => print("follow error"));
    } catch (e) {
      print("markAsRead error: ${e.toString()}");
    }
  }
}

class LocalNotifications {
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Create notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    // Initialize plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => NotificationPage()),
        );
        // if (details.payload != null) {}
      },
    );

    // Create the channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
