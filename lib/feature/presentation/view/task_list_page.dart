import 'package:flutter/material.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/task_view_model.dart';
import 'package:provider/provider.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = context.watch<TaskViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Task List')),
      body: RefreshIndicator(
        onRefresh: taskViewModel.loadTasks,
        child: _buildBody(taskViewModel),
      ),
    );
  }

  Widget _buildBody(TaskViewModel taskViewModel) {
    if (taskViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (taskViewModel.status == TaskStatus.failure) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.error_outline, size: 56),
          const SizedBox(height: 16),
          Text(
            taskViewModel.errorMessage ?? 'Could not load tasks.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (taskViewModel.tasks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 96),
          Icon(Icons.checklist_outlined, size: 64),
          SizedBox(height: 16),
          Text(
            'No tasks yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Tasks saved in SQLite will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: taskViewModel.tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = taskViewModel.tasks[index];

        return Card(
          child: ListTile(
            leading: Icon(
              task.isCompleted
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              color: task.isCompleted ? Colors.green : Colors.orange,
            ),
            title: Text(task.title),
            subtitle: Text('${task.description}\nDeadline: ${task.deadline}'),
            isThreeLine: true,
            trailing: Text(task.isCompleted ? 'Completed' : 'Pending'),
          ),
        );
      },
    );
  }
}
