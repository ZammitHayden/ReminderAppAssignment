import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:firebase_analytics/firebase_analytics.dart';

// handles all local notification logic such as initialization, showing notifications, scheduling, and cancelling reminders.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Plugin used to display and schedule local notifications.
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Firebase Analytics instance to track notification-related events.
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Android notification channel definition.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'task_channel',
    'Task Notifications',
    description: 'Notifications for task updates',
    importance: Importance.high,
  );

  // Initializes notification services.
  Future<void> init() async {
    // Load timezone database.
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Malta'));

    // Android-specific initialization settings.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Platform initialization settings.
    const initSettings = InitializationSettings(android: androidInit);
    
    // Initialize the notification plugin.
    await _plugin.initialize(initSettings);

    // Get Android-specific implementation of the plugin.
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Create the notification channel
    await androidPlugin?.createNotificationChannel(_channel);
    // Request necessary permissions 
    await androidPlugin?.requestNotificationsPermission();
    // Request alarm permission
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // Shows an immediate notification when a task is added.
  Future<void> showTaskAdded(String title) async {

    // Log analytics event for notification display.
    await _analytics.logEvent(
      name: 'local_notification_shown',
      parameters: {
        'type': 'task_added',
      },
    );

    // Notification Appearance.
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    // Platform-independent notification details
    const details = NotificationDetails(android: androidDetails);

    // Display the notification immediately.
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Task added',
      title.isEmpty ? 'New task created' : title,
      details,
    );
  }

// Schedules a reminder notification for a specific task.
 Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime dueDate,
  }) async {
    // notification configuration.
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    // Schedule notification using timezone-aware
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
