class Task {
  String title;
  bool isDone;

  Task({
    required this.title,
    this.isDone = false,
  });

  // Convert Task to Map (to save in SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "isDone": isDone,
    };
  }

  // Convert Map back to Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map["title"],
      isDone: map["isDone"],
    );
  }
}
