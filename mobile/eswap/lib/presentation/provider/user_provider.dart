import 'package:flutter/widgets.dart';

class UserSessionProvider extends ChangeNotifier {
  int unreadNotificationNumber = 0;
  int unreadMessageNumber = 0;
  String? addPostName;

  void updateAddPostName(String value) {
    addPostName = value;
    notifyListeners();
  }

  void deleteAddPostName() {
    addPostName = null;
    notifyListeners();
  }

  void updateUnreadNotificationNumber(int value) {
    unreadNotificationNumber = value;
    notifyListeners();
  }

  void updateUnreadMessageNumber(int value) {
    unreadMessageNumber = value;
    notifyListeners();
  }

  void minusUnreadMessageNumber(int value) {
    print("MINUS $value");
    unreadMessageNumber -= value;
    notifyListeners();
  }

  void plusUnreadMessageNumber(int value) {
    print("PLUS $value");
    unreadMessageNumber += value;
    notifyListeners();
  }
}
