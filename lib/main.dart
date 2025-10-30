import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'calender_page.dart';
import 'stats_page.dart';
import 'profile_page.dart';
import 'app_theme.dart';

void main() {
  final controller = AppThemeController(); // <- controller global
  runApp(AppTheme(                         // <- bungkus seluruh app
    controller: controller,
    child: TodoHabitApp(controller: controller),
  ));
}

class TodoHabitApp extends StatelessWidget {
  final AppThemeController controller;
  const TodoHabitApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ToDoHabit',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED)),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2F80ED),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          themeMode: controller.mode, // <- sinkron sama switch Dark Mode
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            OnboardingPage.routeName: (_) => const OnboardingPage(),
            LoginPage.routeName: (_) => const LoginPage(),
            SignUpPage.routeName: (_) => const SignUpPage(),
            HomePage.routeName: (_) => const HomePage(),
            CalendarPage.routeName: (_) => const CalendarPage(),
            StatsPage.routeName: (_) => const StatsPage(),
            ProfilePage.routeName: (_) => const ProfilePage(),
          },
        );
      },
    );
  }
}
