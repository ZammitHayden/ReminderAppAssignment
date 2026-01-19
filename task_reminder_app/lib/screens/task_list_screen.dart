import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Reminder')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return ListView.builder(
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Checkbox(
                  value: taskProvider.tasks[index].isCompleted,
                  onChanged: (_) => taskProvider.toggleTask(index),
                ),
                title: Text(
                  taskProvider.tasks[index].title,
                  style: TextStyle(
                    decoration: taskProvider.tasks[index].isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: taskProvider.tasks[index].reminderDate == null
                ? null
                : Text('Reminder: ${taskProvider.tasks[index].reminderDate}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: Icon(Icons.add),
      ),
    );
  }
}
