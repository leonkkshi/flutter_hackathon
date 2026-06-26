import 'package:flutter/material.dart';
import 'package:flutter_hackathon/app/routes/app_route.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/login_view_model.dart';
import 'package:flutter_hackathon/feature/presentation/viewmodel/task_view_model.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
    });
  }

  Future<void> _openTaskList() async {
    await Navigator.pushNamed(context, AppRoutes.taskList);
    if (!mounted) {
      return;
    }
    await context.read<TaskViewModel>().loadTasks();
  }

  Future<void> _logout() async {
    await context.read<LoginViewModel>().logout();
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = context.watch<TaskViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Task Manager'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: taskViewModel.loadTasks,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Welcome to Student Task Manager App',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your study tasks and progress.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (taskViewModel.status == TaskStatus.failure)
              _ErrorCard(
                message: taskViewModel.errorMessage ?? 'Could not load tasks.',
                onRetry: taskViewModel.loadTasks,
              )
            else ...[
              if (taskViewModel.isLoading) const LinearProgressIndicator(),
              if (taskViewModel.isLoading) const SizedBox(height: 16),
              _StatsGrid(taskViewModel: taskViewModel),
              if (!taskViewModel.isLoading && taskViewModel.totalTasks == 0)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: _EmptyTaskHint(),
                ),
            ],
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _openTaskList,
              icon: const Icon(Icons.checklist_outlined),
              label: const Text('Go to Task List'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final TaskViewModel taskViewModel;

  const _StatsGrid({required this.taskViewModel});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final cards = [
          _StatCard(
            label: 'Total Tasks',
            value: taskViewModel.totalTasks,
            icon: Icons.assignment_outlined,
            color: Colors.blue,
          ),
          _StatCard(
            label: 'Completed Tasks',
            value: taskViewModel.completedTasks,
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _StatCard(
            label: 'Pending Tasks',
            value: taskViewModel.pendingTasks,
            icon: Icons.pending_actions_outlined,
            color: Colors.orange,
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              for (final card in cards) ...[
                Expanded(child: card),
                if (card != cards.last) const SizedBox(width: 12),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (final card in cards) ...[
              card,
              if (card != cards.last) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    '$value',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTaskHint extends StatelessWidget {
  const _EmptyTaskHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'No tasks have been saved yet. Once tasks are added, this dashboard will update from SQLite data.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
