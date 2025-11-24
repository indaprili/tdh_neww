import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'todo_item.dart';

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// ✅ 1. Inisialisasi
  Future<void> ensureInitialized() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      debugPrint('[NotificationService] Error setting timezone: $e');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[NotificationService] Notification clicked: ${details.payload}');
      },
    );

    _initialized = true;
    debugPrint('[NotificationService] Initialized');
  }

  /// ✅ 2. Request Permission
  Future<void> requestPermission() async {
    await ensureInitialized();
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  /// ✅ 3. Jadwal Reminder (MODE AMAN / INEXACT)
  Future<void> scheduleReminder(TodoItem item) async {
    await ensureInitialized();

    if (item.id == null || item.dueDate == null) return;
    if (item.done) return;

    final DateTime now = DateTime.now();
    final DateTime due = item.dueDate!;

    // Mundur 5 menit sebelum deadline
    DateTime scheduledTime = due.subtract(const Duration(minutes: 5));

    if (scheduledTime.isBefore(now)) {
      if (due.isAfter(now)) {
        scheduledTime = now.add(const Duration(seconds: 5));
      } else {
        return; // Udah lewat jauh, skip
      }
    }

    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    debugPrint('[NotificationService] Schedule ID:${item.id} at $tzScheduled');

    // ID Channel Baru (_v5) biar fresh
    const androidDetails = AndroidNotificationDetails(
      'todo_channel_v5', 
      'Todo Reminders V5',
      channelDescription: 'Reminder for tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        item.id!,
        item.isHabit ? 'Habit Reminder 🌿' : 'Task Reminder 📌',
        'Jangan lupa: ${item.title}',
        tzScheduled,
        notifDetails,
        
        // 🔥 KUNCI ANTI-CRASH: Pakai inexactAllowWhileIdle
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error scheduling: $e');
    }
  }

  /// 🔔 4. Debug Instan (LANGSUNG MUNCUL TANPA JADWAL)
  /// Ini yang bikin error tadi, sekarang udah diganti pakai .show()
  Future<void> scheduleDebugNotification() async {
    await ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'debug_channel_v5', // ID Baru
      'Debug Instant V5',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    debugPrint('[NotificationService] Coba tampilkan notif SEKARANG...');

    // Pakai .show() -> Langsung tampil detik ini juga, gak butuh izin alarm.
    try {
      await _plugin.show(
        888, 
        'Halo Inda! 👋', 
        'Tes Notifikasi Berhasil! (Tanpa Error)', 
        notifDetails,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error debug notif: $e');
    }
  }

  /// ❌ Cancel Notif
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}