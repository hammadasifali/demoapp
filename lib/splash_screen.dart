import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';
import 'main_shell.dart';
import 'pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..forward();

  @override
  void initState() {
    super.initState();
    _next();
  }

  Future<void> _next() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await ApiService.getToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              (token != null && token.isNotEmpty) ? const MainShell() : const LoginPage()),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: FadeTransition(
            opacity: _c,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset('assets/images/app_icon.png', width: 120),
              const SizedBox(height: 16),
              Text(kAppName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      );
}
