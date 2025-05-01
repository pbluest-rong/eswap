import 'package:flutter/widgets.dart';

class AppInfoProvider extends ChangeNotifier {
  bool localNotificationEnable = true;

  void disableLocalNotificationEnable() {
    localNotificationEnable = false;
    notifyListeners();
  }

  void enableLocalNotificationEnable() {
    localNotificationEnable = true;
    notifyListeners();
  }
}
