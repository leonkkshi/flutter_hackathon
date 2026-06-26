import 'package:flutter_hackathon/feature/application/service/interfaces/i_task_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/task_item.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_task_repository.dart';

class TaskServiceImpl implements ITaskService {
  final ITaskRepository _taskRepository;

  TaskServiceImpl(this._taskRepository);

  @override
  Future<List<TaskItem>> getTasks() {
    return _taskRepository.getTasks();
  }
}
