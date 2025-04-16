import 'package:flutter/foundation.dart';

class InfoProvider extends ChangeNotifier {
  int _educationInstitutionId = 0;
  String _educationInstitutionName = "";

  int get educationInstitutionId => _educationInstitutionId;
  String get educationInstitutionName => _educationInstitutionName;

  void updateEducationInstitution(int id, String name) {
    _educationInstitutionId = id;
    _educationInstitutionName = name;
    notifyListeners();
  }
}
