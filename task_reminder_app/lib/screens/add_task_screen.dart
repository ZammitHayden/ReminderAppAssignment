import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

// Stateful widget for adding a new task since it involves user interaction
class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {

  // used to read and manage text input
  final _titleController = TextEditingController();
  DateTime? _dueDate;

  // date picker followed by a time picker
  Future<void> _pickDueDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (date == null) return; //cancels data picker

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return; // cancels the time picker

    // Update the state with the selected date and time.
    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 12),

            // ListTile displays due date information.
            // Shows different text depending on whether a date is selected.
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dueDate == null
                  ? 'No due time set'
                  : 'Due: ${_dueDate!.toLocal()}'),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: _pickDueDateTime,
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
               // Ensure the task title is not empty.
                if (_titleController.text.isNotEmpty) {
                  Provider.of<TaskProvider>(context, listen: false).addTask(
                    _titleController.text,
                    dueDate: _dueDate,
                  );
                  // Navigate back to the previous screen
                  Navigator.pop(context);
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
