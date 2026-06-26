class TaskItem {
  final int? id;
  final String title;
  final String description;
  final String deadline;
  final int status;

  const TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });

  bool get isCompleted => status == 1;

  factory TaskItem.fromMap(Map<String, Object?> map) {
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      deadline: map['deadline'] as String? ?? '',
      status: map['status'] as int? ?? 0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline,
      'status': status,
    };
  }
}
