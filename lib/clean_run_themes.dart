import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  //colorScheme: ColorScheme.light(),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 1,
    selectedItemColor: const Color(0xFF66b3ff),
    unselectedItemColor: const Color(0x75000000),
  ),
  appBarTheme: AppBarTheme(
    elevation: 2,
    brightness: Brightness.light,
    color: Colors.white,
    textTheme: Typography.blackCupertino,
  ),
  dividerColor: Colors.black87,
  cardTheme: CardTheme(
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.0),
      //side: BorderSide(color: Colors.grey[100], width: 1),
    ),
    margin: EdgeInsets.all(6),
    shadowColor: Colors.grey[200],
  ),
  buttonColor: Colors.white,
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(
        primary: Colors.black87,
        secondary: Colors.white,
        brightness: Brightness.dark,
        surface: Colors.black54,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        background: Colors.black,
        error: Colors.red,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.blueAccent,
        primaryVariant: Colors.black,
        secondaryVariant: Colors.white70),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      elevation: 1,
      backgroundColor: Colors.grey[850],
      selectedItemColor: const Color(0xFF66b3ff), //Color(0xFF87A2CE),
      unselectedItemColor: Colors.white70,
    ),
    appBarTheme: AppBarTheme(
      elevation: 2,
      brightness: Brightness.dark,
      color: Colors.grey[850],
      //elevation: 0.0,
      textTheme: Typography.whiteCupertino,
    ),
    snackBarTheme: SnackBarThemeData(
        actionTextColor: const Color(0xFFFF3C00),
        disabledActionTextColor: Colors.grey,
        backgroundColor: const Color(0xFF202020),
        contentTextStyle: TextStyle(color: Colors.white)),
    iconTheme: IconThemeData(color: Colors.grey[400]),
    dividerColor: Colors.white,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        //uncomment and change colors to set button colors
        //backgroundColor: Colors.indigoAccent[700],
        //splashColor: Colors.indigoAccent[200],
        ),
    buttonColor: Colors.grey[800],
    cardTheme: CardTheme(
      elevation: 2,
      color: Colors.grey[800],
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      margin: EdgeInsets.all(6),
    ));

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;
  bool darkMode = false;
  ThemeData getTheme() => _themeData;

  ThemeNotifier() {
    _themeData = lightTheme;
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    notifyListeners();
    darkMode = true;
  }

  void setLightMode() async {
    _themeData = lightTheme;
    notifyListeners();
    darkMode = false;
  }

  void switchMode() async {
    if (_themeData == lightTheme) {
      _themeData = darkTheme;
      darkMode = true;
    } else {
      _themeData = lightTheme;
      darkMode = false;
    }
    notifyListeners();
  }
}
