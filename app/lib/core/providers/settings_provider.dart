import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  bool get smsNotifications => _smsNotifications;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _emailNotifications = prefs.getBool('email_notifications') ?? true;
    _pushNotifications = prefs.getBool('push_notifications') ?? true;
    _smsNotifications = prefs.getBool('sms_notifications') ?? false;
    notifyListeners();
  }

  Future<void> toggleEmailNotifications(bool value) async {
    _emailNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', value);
  }

  Future<void> togglePushNotifications(bool value) async {
    _pushNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
  }

  Future<void> toggleSmsNotifications(bool value) async {
    _smsNotifications = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sms_notifications', value);
  }
}
