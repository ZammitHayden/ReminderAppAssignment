import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/task.dart';
import '../service/notification_service.dart';


class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // Firebase Analytics instance to track actions e.g add tasks events
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Method to add a new task
  void addTask(String title, {DateTime? dueDate}) {

      // Generate a unique ID for the task using timestamp
      // Masking to ensure it's a positive integer
      final id = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;

      final task = Task(id: id, title: title, reminderDate: dueDate);
      _tasks.add(task);

      // Notify all listeners (UI widgets) that the state has changed.
      notifyListeners();

      // Log the task addition event to Firebase Analytics
      _analytics.logEvent(
        name: 'task_added',
        parameters: {
          'has_due_date': dueDate != null,
          'title_length': title.length,
        },
      );

      // Show a notification confirming the task addition
      NotificationService.instance.showTaskAdded(title);

      // Schedule a reminder notification if a due date is provided
      if (dueDate != null && dueDate.isAfter(DateTime.now())) {
        NotificationService.instance.scheduleTaskReminder(
          id: task.id,
          title: task.title,
          dueDate: dueDate,
        );
      }
    }

  // Method to toggle the completion status of a task
  void toggleTask(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners();
    
    if (_tasks[index].isCompleted) {
        NotificationService.instance.cancelReminder(_tasks[index].id);
    }
  }
}
