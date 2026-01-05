import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  Locale _locale = const Locale('en');

  bool get emailNotifications => _emailNotifications;
  bool get pushNotifications => _pushNotifications;
  bool get smsNotifications => _smsNotifications;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _emailNotifications = prefs.getBool('email_notifications') ?? true;
    _pushNotifications = prefs.getBool('push_notifications') ?? true;
    _smsNotifications = prefs.getBool('sms_notifications') ?? false;
    final languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
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

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}
