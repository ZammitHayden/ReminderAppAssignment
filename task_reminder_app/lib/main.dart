import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'providers/task_provider.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';
import 'service/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase services 
  await Firebase.initializeApp();

  // Initialize local notification service. For TaskProvider is accessible throughout the app
  await NotificationService.instance.init();

  // Wrap the app with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

//stateless widget since does not manage change.
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder App',
      theme: ThemeData(primarySwatch: Colors.blue),

      //automatically logs screen transitions to Firebase Analytics.
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: _analytics),
      ],

      home: TaskListScreen(),
      routes: {'/add': (_) => AddTaskScreen()},
    );
  }
}
