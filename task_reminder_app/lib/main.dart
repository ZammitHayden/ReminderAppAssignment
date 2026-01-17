import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/task_provider.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ,
      routes: {'/add': (_) => },
    );
  }
}
