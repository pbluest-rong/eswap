import 'package:eswap/main.dart';
import 'package:eswap/pages/notification/notification_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmToken", fcmToken!);
    initPushNotifications();
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // Xử lý thông báo khi ứng dụng được mở từ trạng thái bị đóng hoàn toàn
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // Xử lý khi người dùng nhấn vào thông báo để mở ứng dụng (background hoặc terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // Xử lý thông báo khi ứng dụng đang chạy ở chế độ nền (background)
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // Xử lý thông báo khi ứng dụng đang mở (foreground)
    FirebaseMessaging.onMessage.listen(handleMessage);
  }

  /// Xử lý khi nhận được thông báo (foreground, background hoặc từ trạng thái bị đóng)
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState
        ?.pushNamed(NotificationPage.route, arguments: message);
  }

  /// Xử lý thông báo khi ứng dụng ở chế độ nền hoặc bị đóng (background mode)
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }
}
