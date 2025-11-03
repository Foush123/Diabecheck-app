import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      });

    // Create the notification channel
    const androidChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Reminder notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Request notifications permission on Android 13+
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }
  
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime whenLocal,
  }) async {
    await init();
    final tz.TZDateTime scheduleDate = tz.TZDateTime.from(whenLocal, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          enableLights: true,
          enableVibration: true,
          playSound: true,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.reminder,
          fullScreenIntent: true,
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: 'Diabecheck Reminder',
            htmlFormatSummaryText: true,
          ),
          channelShowBadge: true,
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
      ),
      // Use inexact scheduling to avoid exact alarm permission requirement
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }
}
