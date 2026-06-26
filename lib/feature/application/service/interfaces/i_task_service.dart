import 'package:flutter_hackathon/feature/domain/entities/task_item.dart';

abstract interface class ITaskService {
  Future<List<TaskItem>> getTasks();
}
