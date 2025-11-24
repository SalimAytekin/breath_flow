import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

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
        'Nefes Hatırlatmaları',
        channelDescription: 'Günlük nefes egzersizi hatırlatmaları',
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
        'Nefes Egzersizi Hatırlatması',
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
        'Uyku Verisi Hatırlatmaları',
        channelDescription: 'Sabah uyku verisi girme hatırlatmaları',
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
        'Uyku Verisi Hatırlatması',
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
    String title = 'Breathe Flow Test',
    String body = 'Bildirim sistemi çalışıyor! 🎉',
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
        'Test Bildirimleri',
        channelDescription: 'Test amaçlı bildirimler',
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
        'body': 'Bugün 5 dakikanı nefesine ayır 🌬️',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Rahatla ve yenilenmek için nefes egzersizi yap 🧘',
        'action': 'nefes_egzersizi',
      },
      {
        'body': '5 dakika nefes egzersizi yaparak güne başla ☀️',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Zihnini sakinleştirmek için nefes al 🫁',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Stresi atmak için nefes egzersizi yap 💨',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Odaklanmak için 5 dakika nefes al 🎯',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Bedeni ve zihni dengelemek için nefes egzersizi yap ⚖️',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Bugünkü nefes egzersizi hatırlatması 🧘‍♀️',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Huzurlu bir gün için nefes egzersizi yap ✨',
        'action': 'nefes_egzersizi',
      },
      {
        'body': 'Enerjini toplamak için nefes al ⚡',
        'action': 'nefes_egzersizi',
      },
    ];
  }

  /// Uyku hatırlatma mesajları (Sabah - uyku verisi girme)
  List<Map<String, String>> _getSleepMessages() {
    return [
      {
        'body': 'Dün kaçta yatıp kalktın? Uyku verilerini gir 📝',
        'action': 'uyku_verisi_gir',
      },
      {
        'body': 'Sabah uyku günlüğünü doldurmayı unutma 😴',
        'action': 'uyku_verisi_gir',
      },
      {
        'body': 'Gecenin nasıldı? Uyku verilerini kaydet 🌙',
        'action': 'uyku_verisi_gir',
      },
      {
        'body': 'Uyku kaliteni ve rüyalarını not al 💭',
        'action': 'uyku_verisi_gir',
      },
      {
        'body': 'Dün nasıl uyudun? Hadi kaydet 🌟',
        'action': 'uyku_verisi_gir',
      },
      {
        'body': 'Uyku günlüğünü doldurarak analiz oluştur 📊',
        'action': 'uyku_verisi_gir',
      },
    ];
  }

  /// Gece uyku hatırlatma mesajları (Yatmadan önce)
  List<Map<String, String>> _getBedtimeMessages() {
    return [
      {
        'body': 'İyi geceler! Huzurlu bir uyku dileriz 🌙',
        'action': 'iyi_geceler',
      },
      {
        'body': 'Rahatlamak için uyku sesleri dinle 😴',
        'action': 'uyku_sesi',
      },
      {
        'body': 'Düzenli uyku saatine geçiş zamanı! 🌟',
        'action': 'uyku_rutu',
      },
    ];
  }

  /// Ses dinleme hatırlatmaları (gece için)
  List<Map<String, String>> _getSoundMessages() {
    return [
      {
        'body': 'Yatmadan önce sakinleştirici sesler dinle 🎵',
        'action': 'ses_dinle',
      },
      {
        'body': 'Uykuya dalmana yardımcı olacak sesler var 🌊',
        'action': 'ses_dinle',
      },
      {
        'body': 'Rahatlamak için doğa seslerini dinle 🏞️',
        'action': 'ses_dinle',
      },
    ];
  }
}

