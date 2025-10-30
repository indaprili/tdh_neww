import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/signup';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _emailPhone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pushReplacementNamed(context, HomePage.routeName);
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

          // Header (logo + title + subtitle) — style sama LoginPage
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
                    Text('Create your account', style: _titleBold28(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      'Start organizing your day and building habits!',
                      textAlign: TextAlign.center,
                      style: _body14Regular(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Panel putih
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: whitePanelHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _FieldLabel('Email or Phone Number'),
                      _LabeledTextField(
                        controller: _emailPhone,
                        hint: 'Enter your email or phone number',
                        prefixAssetPath: 'assets/Email.png',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email, AutofillHints.username],
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      const _FieldLabel('Set Password'),
                      _LabeledTextField(
                        controller: _password,
                        hint: 'Create a password',
                        prefixAssetPath: 'assets/Password.png',
                        obscure: _obscure1,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        enableSuggestions: false,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _obscure1 = !_obscure1),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                      ),
                      const SizedBox(height: 12),

                      const _FieldLabel('Confirm Password'),
                      _LabeledTextField(
                        controller: _confirm,
                        hint: 'Re-type password',
                        prefixAssetPath: 'assets/Password.png',
                        obscure: _obscure2,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        enableSuggestions: false,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                        ),
                        validator: (v) => v != _password.text ? 'Passwords do not match' : null,
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _submit,
                          child: Text('Sign Up', style: _body14Regular(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: _label12Medium(color: Colors.black87)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text('Log in', style: _label12Semi(color: blue)),
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

// ===== Gradient (sama LoginPage)
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

// ===== Label kecil
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }
}

// ===== TextField dengan prefix icon dari asset (seragam dengan LoginPage)
class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefixAssetPath;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool? enableSuggestions;

  const _LabeledTextField({
    required this.controller,
    required this.hint,
    this.prefixAssetPath,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.enableSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      enableSuggestions: enableSuggestions ?? true,
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

/// ======= TextStyle helpers (Inter) – sama persis dengan LoginPage =======
TextStyle _titleBold28({Color? color}) =>
    GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: color);

TextStyle _body14Regular({Color? color}) =>
    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color);

TextStyle _label12Medium({Color? color}) =>
    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color);

TextStyle _label12Semi({Color? color}) =>
    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color);
