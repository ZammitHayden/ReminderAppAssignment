import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/task.dart';
import '../service/notification_service.dart';


class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void addTask(String title, {DateTime? dueDate}) {
      final id = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;

      final task = Task(id: id, title: title, reminderDate: dueDate);
      _tasks.add(task);
      notifyListeners();

      _analytics.logEvent(
        name: 'task_added',
        parameters: {
          'has_due_date': dueDate != null,
          'title_length': title.length,
        },
      );

      NotificationService.instance.showTaskAdded(title);

      if (dueDate != null && dueDate.isAfter(DateTime.now())) {
        NotificationService.instance.scheduleTaskReminder(
          id: task.id,
          title: task.title,
          dueDate: dueDate,
        );
      }
    }

  void toggleTask(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();

    if (_tasks[index].isCompleted) {
        NotificationService.instance.cancelReminder(_tasks[index].id);
    }
  }
}
