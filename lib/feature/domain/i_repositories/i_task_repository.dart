import 'package:flutter_hackathon/feature/domain/entities/task_item.dart';

abstract interface class ITaskRepository {
  Future<List<TaskItem>> getTasks();
}
