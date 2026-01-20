import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:firebase_analytics/firebase_analytics.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'task_channel',
    'Task Notifications',
    description: 'Notifications for task updates',
    importance: Importance.high,
  );

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Malta'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    
    await _plugin.initialize(initSettings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> showTaskAdded(String title) async {
    await _analytics.logEvent(
      name: 'local_notification_shown',
      parameters: {
        'type': 'task_added',
      },
    );

    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Task added',
      title.isEmpty ? 'New task created' : title,
      details,
    );
  }

 Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime dueDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id, 
      'Task reminder',
      'Reminder For: $title',
      tz.TZDateTime.from(dueDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }
}
