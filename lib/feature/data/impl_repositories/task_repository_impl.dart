import 'package:flutter_hackathon/feature/data/datasource/task_local_data_source.dart';
import 'package:flutter_hackathon/feature/domain/entities/task_item.dart';
import 'package:flutter_hackathon/feature/domain/i_repositories/i_task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl({required TaskLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<List<TaskItem>> getTasks() {
    return _localDataSource.getTasks();
  }
}
