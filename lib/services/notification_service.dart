import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_strings.dart';

/// 🔔 Notification Service
/// Nefes hatırlatmaları ve önemli bildirimler için lokal bildirim yönetimi
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Bildirim servisini başlatır
  Future<void> initialize() async {
    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      final result = await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result == false) {
        throw Exception('Notification initialization failed');
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      _isInitialized = false;
    }
  }

  /// Notification tap handler
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  /// İzin isteme (Android 13+ için)
  Future<bool> requestPermissions() async {
    try {
      // Android 13+ için bildirim izni
      if (await Permission.notification.isGranted) {
        return true;
      }

      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Bildirimlerin açık olup olmadığını kontrol et
  Future<bool> checkNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        return await Permission.notification.isGranted;
      }
      // iOS için zaten initializasyonda izin istiyoruz
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Tekrarlayan nefes egzersizi hatırlatması (öğleden sonra/akşam)
  Future<void> scheduleDailyBreathingReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_isInitialized || !_notificationsEnabled) {
        return;
      }

      // İzin kontrolü
      if (!await checkNotificationsEnabled()) {
        return;
      }

      // Android channel için high importance
      const androidDetails = AndroidNotificationDetails(
        'breathing_reminders',
        AppStrings.notifChannelBreathing,
        channelDescription: AppStrings.notifChannelBreathingDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      // iOS details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Her gün aynı saatte tetiklenecek
      final scheduledDate = tz.TZDateTime(
        tz.local,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );

      // Random motivasyon mesajları
      final messages = _getBreathingMessages();
      final randomMessage = messages[DateTime.now().millisecond % messages.length];

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        AppStrings.notifBreathingTitle,
        randomMessage['body']!,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      // Sabah uyku verisi girme hatırlatması (ID: 1)
      await scheduleDailySleepReminder(
        hour: 8,
        minute: 0,
      );
    } catch (e) {
      // Error scheduling reminder
    }
  }

  /// Sabah uyku verisi girme hatırlatması
  Future<void> scheduleDailySleepReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      if (!_isInitialized || !_notificationsEnabled) {
        return;
      }

      // İzin kontrolü
      if (!await checkNotificationsEnabled()) {
        return;
      }

      // Android channel için high importance
      const androidDetails = AndroidNotificationDetails(
        'sleep_data_reminders',
        AppStrings.notifChannelSleep,
        channelDescription: AppStrings.notifChannelSleepDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      // iOS details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Her gün aynı saatte tetiklenecek (sabah)
      final scheduledDate = tz.TZDateTime(
        tz.local,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );

      // Random uyku verisi mesajları
      final messages = _getSleepMessages();
      final randomMessage = messages[DateTime.now().millisecond % messages.length];

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        1, // ID: 1 (farklı ID)
        AppStrings.notifSleepTitle,
        randomMessage['body']!,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // Error scheduling sleep reminder
    }
  }

  /// Hatırlatmayı iptal et
  Future<void> cancelReminder(int notificationId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(notificationId);
    } catch (e) {
      // Error cancelling reminder
    }
  }

  /// Tüm hatırlatmaları iptal et
  Future<void> cancelAllReminders() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      // Error cancelling all reminders
    }
  }

  /// Bildirimleri aç/kapat
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    
    if (!enabled) {
      cancelAllReminders();
    }
  }

  /// Test bildirimi gönder
  Future<void> showTestNotification({
    String title = AppStrings.notifTestTitle,
    String body = AppStrings.notifTestBody,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // İzin kontrolü
      final hasPermission = await checkNotificationsEnabled();
      
      if (!hasPermission) {
        final granted = await requestPermissions();
        if (!granted) {
          return;
        }
      }

      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        AppStrings.notifChannelTest,
        channelDescription: AppStrings.notifChannelTestDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        999,
        title,
        body,
        details,
      );
    } catch (e, stackTrace) {
      // Error showing test notification
    }
  }

  /// Nefes egzersizi hatırlatma mesajları
  List<Map<String, String>> _getBreathingMessages() {
    return [
      {
        'body': AppStrings.notifBreathing1,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing2,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing3,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing4,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing5,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing6,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing7,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing8,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing9,
        'action': 'nefes_egzersizi',
      },
      {
        'body': AppStrings.notifBreathing10,
        'action': 'nefes_egzersizi',
      },
    ];
  }

  /// Uyku hatırlatma mesajları (Sabah - uyku verisi girme)
  List<Map<String, String>> _getSleepMessages() {
    return [
      {
        'body': AppStrings.notifSleep1,
        'action': 'uyku_verisi_gir',
      },
      {
        'body': AppStrings.notifSleep2,
        'action': 'uyku_verisi_gir',
      },
      {
        'body': AppStrings.notifSleep3,
        'action': 'uyku_verisi_gir',
      },
      {
        'body': AppStrings.notifSleep4,
        'action': 'uyku_verisi_gir',
      },
      {
        'body': AppStrings.notifSleep5,
        'action': 'uyku_verisi_gir',
      },
      {
        'body': AppStrings.notifSleep6,
        'action': 'uyku_verisi_gir',
      },
    ];
  }

  /// Gece uyku hatırlatma mesajları (Yatmadan önce)
  List<Map<String, String>> _getBedtimeMessages() {
    return [
      {
        'body': AppStrings.notifBedtime1,
        'action': 'iyi_geceler',
      },
      {
        'body': AppStrings.notifBedtime2,
        'action': 'uyku_sesi',
      },
      {
        'body': AppStrings.notifBedtime3,
        'action': 'uyku_rutu',
      },
    ];
  }

  /// Ses dinleme hatırlatmaları (gece için)
  List<Map<String, String>> _getSoundMessages() {
    return [
      {
        'body': AppStrings.notifSound1,
        'action': 'ses_dinle',
      },
      {
        'body': AppStrings.notifSound2,
        'action': 'ses_dinle',
      },
      {
        'body': AppStrings.notifSound3,
        'action': 'ses_dinle',
      },
    ];
  }
}

