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

  await Firebase.initializeApp();

  await NotificationService.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder App',
      theme: ThemeData(primarySwatch: Colors.blue),

      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: _analytics),
      ],

      home: TaskListScreen(),
      routes: {'/add': (_) => AddTaskScreen()},
    );
  }
}
