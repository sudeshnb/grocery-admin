import 'package:flutter/cupertino.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';

class SettingsModel with ChangeNotifier {
  final AuthBase auth;

  final Database database;

  SettingsModel({required this.auth, required this.database});

  String get email => auth.email ?? "";

  String get displayName => (auth.displayName == null || auth.displayName == '')
      ? "Admin"
      : auth.displayName!;

  String? get profileImage => auth.profileImage;

  Future<void> signOut() async {
    ///Remove notification token
    await database.setData({}, 'admin/notifications');
    await auth.signOut();
  }

  void updateWidget() {
    notifyListeners();
  }
}
