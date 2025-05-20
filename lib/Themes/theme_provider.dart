import 'package:chatty_app/Themes/Dark_Mode.dart';
import 'package:chatty_app/Themes/Light_Mode.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightmode;
  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;
  set ThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightmode) {
      _themeData = darkMode;
    } else {
      _themeData = lightmode;
    }
  }
}
