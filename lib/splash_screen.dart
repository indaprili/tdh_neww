import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, OnboardingPage.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ganti dengan logo dari assets
              Image.asset(
                'assets/logo.png', // Ganti dengan path yang sesuai
                width: 223, // Atur ukuran gambar sesuai kebutuhan
                height: 187,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
