// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

/// Controller buat toggle dark/light
class AppThemeController extends ChangeNotifier {
  bool _isDark;
  AppThemeController({bool isDark = false}) : _isDark = isDark;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void setDark(bool value) {
    if (value == _isDark) return;
    _isDark = value;
    notifyListeners();
  }
}

/// InheritedNotifier yang nge-expose controller ke widget tree
class AppTheme extends InheritedNotifier<AppThemeController> {
  const AppTheme({
    super.key,
    required AppThemeController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  /// Panggil ini di mana pun: final ctrl = AppTheme.of(context);
  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(scope != null, 'AppTheme.of(context) dipanggil tanpa AppTheme di atasnya.');
    return scope!.notifier!;
  }
}
