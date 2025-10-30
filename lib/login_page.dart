import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2F80ED);
    final size = MediaQuery.of(context).size;
    final whitePanelHeight = size.height * 0.62;

    return Scaffold(
      body: Stack(
        children: [
          const _GradientBG(),

          // Header (logo + title + subtitle)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logowhite.png', width: 77.33, height: 80),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome back!',
                      style: _titleBold28(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log in to continue tracking your tasks and habits',
                      textAlign: TextAlign.center,
                      style: _body14Regular(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // White panel (full width, rounded at the top)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: whitePanelHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, -4)),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email field
                      const _FieldLabel('Email'),
                      _LabeledTextField(
                        controller: _email,
                        hint: 'Enter your email',
                        prefixAssetPath: 'assets/Email.png',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 12),

                      // Password field
                      const _FieldLabel('Password'),
                      _LabeledTextField(
                        controller: _password,
                        hint: 'Enter your password',
                        prefixAssetPath: 'assets/Password.png',
                        obscure: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Minimum 6 characters required' : null,
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? false),
                          ),
                          Text('Remember me', style: _label12Medium()),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              foregroundColor: blue,
                            ),
                            child: Text('Forgot Password?', style: _label12Semi()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Login button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _submit,
                          child: Text('Log In', style: _body14Regular(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Center(child: Text('Or login with', style: _body14Regular(color: Colors.black87))),
                      const SizedBox(height: 10),

                      // Social login buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          _SocialBtn(assetPath: 'assets/google.png',    fallbackIcon: Icons.g_mobiledata),
                          SizedBox(width: 12),
                          _SocialBtn(assetPath: 'assets/apple.png',     fallbackIcon: Icons.apple),
                          SizedBox(width: 12),
                          _SocialBtn(assetPath: 'assets/Facebook.png',  fallbackIcon: Icons.facebook_rounded),
                          SizedBox(width: 12),
                          _SocialBtn(assetPath: 'assets/mobile.png',    fallbackIcon: Icons.phone_iphone_rounded),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: _label12Medium(color: Colors.black87)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, SignUpPage.routeName),
                            child: Text('Sign Up', style: _label12Semi(color: blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBG extends StatelessWidget {
  const _GradientBG();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF04E09F), Color(0xFF2F80ED), Color(0xFF04E09F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefixAssetPath;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _LabeledTextField({
    required this.controller,
    required this.hint,
    this.prefixAssetPath,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: _body14Regular(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _body14Regular(color: Colors.black38),
        prefixIcon: prefixAssetPath != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(prefixAssetPath!, width: 20, height: 20, filterQuality: FilterQuality.high),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String assetPath;
  final IconData fallbackIcon;
  const _SocialBtn({required this.assetPath, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    final child = Image.asset(
      assetPath,
      width: 20,
      height: 20,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Icon(fallbackIcon, size: 22),
    );
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Container(
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: child,
      ),
    );
  }
}

/// ======= TextStyle helpers (Inter) =======
TextStyle _titleBold28({Color? color}) =>
    GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: color);

TextStyle _body14Regular({Color? color}) =>
    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color);

TextStyle _label12Medium({Color? color}) =>
    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color);

TextStyle _label12Semi({Color? color}) =>
    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color);
