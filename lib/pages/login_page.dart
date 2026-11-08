import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main_shell.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  bool _loading = false;
  bool _hide = true;

  // Botanical color palette
  static const Color forestGreen = Color(0xFF245C3A);
  static const Color leafGreen = Color(0xFF4F8A50);
  static const Color lightGreen = Color(0xFFE8F1E5);
  static const Color cream = Color(0xFFFAFAF4);
  static const Color textDark = Color(0xFF26382A);

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final err = await ApiService.login(_email.text.trim(), _pass.text);

      if (!mounted) return;

      setState(() => _loading = false);

      if (err == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: leafGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE8D9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: leafGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top botanical section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 38),
                decoration: const BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // App logo
                    Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: forestGreen.withOpacity(0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.eco_rounded,
                            size: 55,
                            color: forestGreen,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Grow Green',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: forestGreen,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your plants, your garden, your journey.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF607764)),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.spa, color: leafGreen, size: 17),
                        SizedBox(width: 8),
                        Text(
                          'Nurture Nature',
                          style: TextStyle(
                            color: forestGreen,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Login form
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 35, 26, 24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Sign in to take care of your plants.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          label: 'Enter your email',
                          icon: Icons.email_outlined,
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _pass,
                        obscureText: _hide,
                        decoration: _inputDecoration(
                          label: 'Enter your password',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _hide
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: leafGreen,
                            ),
                            onPressed: () {
                              setState(() => _hide = !_hide);
                            },
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Minimum 6 characters'
                            : null,
                      ),

                      const SizedBox(height: 30),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: forestGreen,
                            disabledBackgroundColor: forestGreen.withOpacity(
                              0.5,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.eco_outlined, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Signup navigation
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: forestGreen,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Center(
                        child: Text(
                          '🌱  Every plant deserves a little care.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF829482),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
