import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeModel with ChangeNotifier {
  late ThemeData theme;

  ThemeModel({required ThemeData theme}) {
    backgroundColor = theme.backgroundColor;

    if (theme.brightness == Brightness.dark) {
      secondBackgroundColor = Color(0xFF4E5D6A);
      textColor = Colors.white;
      secondTextColor = Color(0xFFA6BCD0);
    } else {
      secondBackgroundColor = Colors.white;
      textColor = Colors.black;
      secondTextColor = Color(0xFF696969);
    }

    this.theme = theme;
  }

  Future<void> setToStorage(bool isDark) async {
    GetStorage storage=GetStorage();
    await storage.write('isDark', isDark);
  }

  late Color secondBackgroundColor;
  late Color backgroundColor;
  late Color textColor;
  late Color secondTextColor;

  final Color shadowColor = Colors.black.withOpacity(0.07);
  final Color priceColor = Color(0xFFFFA700);

  final Color accentColor = Color(0xFF7BED8D);

  Future<void> updateTheme() async {
    bool isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      theme = light;
    } else {
      theme = dark;
    }

    backgroundColor = theme.backgroundColor;

    if (theme.brightness == Brightness.dark) {
      secondBackgroundColor = Color(0xFF4E5D6A);
      textColor = Colors.white;
      secondTextColor = Color(0xFFA6BCD0);
    } else {
      secondBackgroundColor = Colors.white;
      textColor = Colors.black;
      secondTextColor = Color(0xFF696969);
    }

    await setToStorage(!isDark);
    notifyListeners();
  }

  static MaterialColor _primarySwatch(int color) {
    return MaterialColor(color, {
      50: Color.fromRGBO(255, 92, 87, .1),
      100: Color.fromRGBO(255, 92, 87, .2),
      200: Color.fromRGBO(255, 92, 87, .3),
      300: Color.fromRGBO(255, 92, 87, .4),
      400: Color.fromRGBO(255, 92, 87, .5),
      500: Color.fromRGBO(255, 92, 87, .6),
      600: Color.fromRGBO(255, 92, 87, .7),
      700: Color.fromRGBO(255, 92, 87, .8),
      800: Color.fromRGBO(255, 92, 87, .9),
      900: Color.fromRGBO(255, 92, 87, 1),
    });
  }

  static MaterialColor lightSwatch = _primarySwatch(0xFF7BED8D);

  ///Light theme
  static final light = ThemeData.light().copyWith(
      brightness: Brightness.light,
      tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(width: 2.0, color:  Color(0xFF7BED8D))
        ),
      ),
      primaryColor: lightSwatch,
      primaryColorDark: lightSwatch,
      toggleableActiveColor: Color(0xFF7BED8D),
      backgroundColor: Color(0xFFf4f4f4),
      scaffoldBackgroundColor: Color(0xFFf4f4f4),
      bottomSheetTheme:
      BottomSheetThemeData(backgroundColor: Colors.transparent),
      bottomNavigationBarTheme:
      BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFf4f4f4),
          selectedItemColor:  Color(0xFF7BED8D),
          unselectedItemColor: Color(0xFFA6BCD0),
          elevation: 0
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF7BED8D),
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 34,
            color: Colors.black),
        headline2: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.black),
        headline3: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black),
        bodyText1: TextStyle(
            height: 1.1,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black),
        bodyText2: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black),
        subtitle1: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black),
        subtitle2: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: Colors.black),

      ), colorScheme: ColorScheme.fromSwatch(primarySwatch: lightSwatch).copyWith(secondary: Color(0xFF7BED8D))
  );

  ///Dark theme
  static final dark = ThemeData.dark().copyWith(


      brightness: Brightness.dark,
      primaryColor: lightSwatch,
      primaryColorDark: lightSwatch,
      toggleableActiveColor: Color(0xFF7BED8D),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF7BED8D),
      ),
      backgroundColor: Color(0xFF404E5A),
      scaffoldBackgroundColor: Color(0xFF404E5A),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF404E5A), elevation: 0,
        selectedItemColor:  Color(0xFF7BED8D),
        unselectedItemColor: Color(0xFFA6BCD0),

      ),
      textTheme: TextTheme(
        headline1: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 34,
            color: Colors.white),
        headline2: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.white),
        headline3: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.white),
        bodyText1: TextStyle(
            height: 1.1,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.white),
        bodyText2: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white),
        subtitle1: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color:Colors.white),
        subtitle2: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: Colors.white),

      ), colorScheme: ColorScheme.fromSwatch(primarySwatch: lightSwatch).copyWith(secondary: Color(0xFF7BED8D))
  );
}
