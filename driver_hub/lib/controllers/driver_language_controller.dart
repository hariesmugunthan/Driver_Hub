import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLanguageController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadLanguage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? savedLanguage = preferences.getString('driver_language');

    if (savedLanguage == 'ta') {
      _locale = const Locale('ta');
    } else {
      _locale = const Locale('en');
    }

    notifyListeners();
  }

  Future<void> changeLanguage(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'ta') {
      return;
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString('driver_language', locale.languageCode);

    _locale = locale;
//predefined method

    notifyListeners();
  }
}