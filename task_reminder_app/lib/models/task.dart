class Task {
  final int id;
  String title;
  bool isCompleted;
  DateTime? reminderDate;

  Task({required this.id, required this.title, this.isCompleted = false, this.reminderDate});
}
