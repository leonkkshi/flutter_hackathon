import 'package:flutter/foundation.dart';
import 'package:flutter_hackathon/feature/application/service/interfaces/i_task_service.dart';
import 'package:flutter_hackathon/feature/domain/entities/task_item.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskViewModel extends ChangeNotifier {
  final ITaskService _taskService;

  TaskViewModel(this._taskService);

  TaskStatus _status = TaskStatus.initial;
  List<TaskItem> _tasks = [];
  String? _errorMessage;

  TaskStatus get status => _status;
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TaskStatus.loading;

  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.status == 1).length;
  int get pendingTasks => _tasks.where((task) => task.status == 0).length;

  Future<void> loadTasks() async {
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks();
      _status = TaskStatus.success;
    } catch (_) {
      _status = TaskStatus.failure;
      _errorMessage = 'Could not load tasks. Please try again.';
    }

    notifyListeners();
  }
}
