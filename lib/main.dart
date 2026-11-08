import 'package:demoapp/app_settings.dart';
import 'package:demoapp/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppSettings.loadSettings();

  runApp(const MyApp());
}

const String kAppName = 'My App';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppSettings.locale,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,

              // Your existing app name
              title: kAppName,

              theme: AppSettings.lightTheme,
              darkTheme: AppSettings.darkTheme,
              themeMode: themeMode,

              locale: locale,
              supportedLocales: const [Locale('en'), Locale('ur')],

              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // Keep your existing home page
              home: const MainShell(),
            );
          },
        );
      },
    );
  }
}
