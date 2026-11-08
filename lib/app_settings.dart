import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  static const Color forestGreen = Color(0xFF245C3A);
  static const Color leafGreen = Color(0xFF4F8A50);
  static const Color lightGreen = Color(0xFFE8F1E5);

  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString('theme_mode') ?? 'light';
    final savedLanguage = prefs.getString('language') ?? 'en';

    themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    locale.value = Locale(savedLanguage);
  }

  static Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'theme_mode',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  static Future<void> setLanguage(String language) async {
    locale.value = Locale(language);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language', language);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAF4),
      colorScheme: ColorScheme.fromSeed(
        seedColor: forestGreen,
        brightness: Brightness.light,
        primary: forestGreen,
        secondary: leafGreen,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAF4),
        foregroundColor: forestGreen,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: lightGreen,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF14251B),
      colorScheme: ColorScheme.fromSeed(
        seedColor: leafGreen,
        brightness: Brightness.dark,
        primary: const Color(0xFF8BC995),
        secondary: const Color(0xFF9CCF91),
        surface: const Color(0xFF20382A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF14251B),
        foregroundColor: Color(0xFFB9E2BD),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF20382A),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF20382A),
        indicatorColor: Color(0xFF345A3D),
      ),
    );
  }
}
