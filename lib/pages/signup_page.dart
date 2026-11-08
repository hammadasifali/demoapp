import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main_shell.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const Color forestGreen = Color(0xFF245C3A);
  static const Color leafGreen = Color(0xFF4F8A50);
  static const Color lightGreen = Color(0xFFE8F1E5);
  static const Color cream = Color(0xFFFAFAF4);
  static const Color textDark = Color(0xFF26382A);

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final err = await ApiService.signup(
        _name.text.trim(),
        _email.text.trim(),
        _pass.text,
      );

      if (!mounted) return;

      setState(() => _loading = false);

      if (err == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
          (_) => false,
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

  Widget _buildField({
    required String title,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: textDark),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: _inputDecoration(
            label: label,
            icon: icon,
            suffix: suffix,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirmPass.dispose();
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
              // Botanical header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 30),
                decoration: const BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(38),
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: forestGreen,
                        ),
                      ),
                    ),

                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 95,
                          height: 95,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        ClipOval(
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.eco_rounded,
                              size: 55,
                              color: forestGreen,
                            ),
                          ),
                        ),
                        const Positioned(
                          right: -5,
                          top: 0,
                          child: Icon(Icons.spa, color: leafGreen, size: 28),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Join Our Green World',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: forestGreen,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create an account and grow with us.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF607764), fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Signup form
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 30, 26, 25),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Fill in your details to get started.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),

                      const SizedBox(height: 25),

                      _buildField(
                        title: 'Full Name',
                        controller: _name,
                        label: 'Enter your name',
                        icon: Icons.person_outline,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter your name'
                            : null,
                      ),

                      const SizedBox(height: 19),

                      _buildField(
                        title: 'Email Address',
                        controller: _email,
                        label: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null ||
                                !RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(v.trim()))
                            ? 'Enter a valid email'
                            : null,
                      ),

                      const SizedBox(height: 19),

                      _buildField(
                        title: 'Password',
                        controller: _pass,
                        label: 'Create password',
                        icon: Icons.lock_outline,
                        obscure: _hidePassword,
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: leafGreen,
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Minimum 6 characters'
                            : null,
                      ),

                      const SizedBox(height: 19),

                      _buildField(
                        title: 'Confirm Password',
                        controller: _confirmPass,
                        label: 'Confirm your password',
                        icon: Icons.verified_user_outlined,
                        obscure: _hideConfirmPassword,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          ),
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: leafGreen,
                          ),
                        ),
                        validator: (v) =>
                            v != _pass.text ? 'Passwords do not match' : null,
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: forestGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: forestGreen.withOpacity(
                              0.5,
                            ),
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
                                    Icon(Icons.eco_outlined),
                                    SizedBox(width: 10),
                                    Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          '🌱  Start your journey towards a greener life.',
                          textAlign: TextAlign.center,
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
