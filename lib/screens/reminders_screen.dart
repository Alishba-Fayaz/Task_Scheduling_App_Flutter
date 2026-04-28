import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/task_provider.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final allTasks = provider.tasks.toList();

    // Sort tasks by date
    final incompleteTasks = allTasks
        .where((t) => !t.completed)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final overdue = _getOverdue(incompleteTasks);
    final today = _getToday(incompleteTasks);
    final upcoming = _getUpcoming(incompleteTasks);
    final completed = allTasks.where((t) => t.completed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3d2369),
        foregroundColor: Colors.white,
        title: const Text('Reminders'),
        elevation: 0,
      ),
      body: allTasks.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Stats summary row ─────────────────
                _buildStatsRow(provider),

                const SizedBox(height: 20),

                // ── Overdue ───────────────────────────
                if (overdue.isNotEmpty) ...[
                  _buildSectionHeader(
                    '🔴 Overdue',
                    '${overdue.length} task${overdue.length > 1 ? "s" : ""}',
                    Colors.red,
                  ),
                  ...overdue.map((t) => _buildReminderCard(context, t, isOverdue: true)),
                  const SizedBox(height: 16),
                ],

                // ── Due Today ─────────────────────────
                if (today.isNotEmpty) ...[
                  _buildSectionHeader(
                    '🟡 Due Today',
                    '${today.length} task${today.length > 1 ? "s" : ""}',
                    Colors.orange,
                  ),
                  ...today.map((t) => _buildReminderCard(context, t, isToday: true)),
                  const SizedBox(height: 16),
                ],

                // ── Upcoming ──────────────────────────
                if (upcoming.isNotEmpty) ...[
                  _buildSectionHeader(
                    '🟢 Upcoming',
                    '${upcoming.length} task${upcoming.length > 1 ? "s" : ""}',
                    Colors.green,
                  ),
                  ...upcoming.map((t) => _buildReminderCard(context, t)),
                  const SizedBox(height: 16),
                ],

                // ── Completed ─────────────────────────
                if (completed.isNotEmpty) ...[
                  _buildSectionHeader(
                    '✅ Completed',
                    '${completed.length} done',
                    Colors.grey,
                  ),
                  ...completed.map((t) => _buildReminderCard(context, t, isDone: true)),
                ],
              ],
            ),
    );
  }

  // ── Helpers: date bucketing ──────────────────────────
  String _todayStr() => DateTime.now().toIso8601String().split('T')[0];

  List<Task> _getOverdue(List<Task> tasks) {
    final today = _todayStr();
    return tasks.where((t) => t.date.compareTo(today) < 0).toList();
  }

  List<Task> _getToday(List<Task> tasks) {
    final today = _todayStr();
    return tasks.where((t) => t.date == today).toList();
  }

  List<Task> _getUpcoming(List<Task> tasks) {
    final today = _todayStr();
    return tasks.where((t) => t.date.compareTo(today) > 0).toList();
  }

  // ── Stats row ────────────────────────────────────────
  Widget _buildStatsRow(TaskProvider provider) {
    return Row(
      children: [
        _statCard('Total', '${provider.taskCount}', Colors.blue),
        const SizedBox(width: 10),
        _statCard('Active', '${provider.incompleteCount}', Colors.orange),
        const SizedBox(width: 10),
        _statCard('Done', '${provider.completedCount}', Colors.green),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────
  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reminder card ─────────────────────────────────────
  Widget _buildReminderCard(
    BuildContext context,
    Task task, {
    bool isOverdue = false,
    bool isToday = false,
    bool isDone = false,
  }) {
    Color borderColor = Colors.transparent;
    if (isOverdue) borderColor = Colors.red.shade300;
    if (isToday) borderColor = Colors.orange.shade300;

    final daysText = _getDaysText(task.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      elevation: isDone ? 0 : 2,
      color: isDone ? Colors.grey.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Priority color bar
            Container(
              width: 5,
              height: 50,
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.grey.shade300
                    : task.priority.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),

            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : Colors.black87,
                    ),
                  ),
                  if (task.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: isOverdue ? Colors.red : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey.shade500,
                          fontWeight: isOverdue ? FontWeight.bold : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        daysText,
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverdue
                              ? Colors.red
                              : isToday
                                  ? Colors.orange
                                  : Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Complete toggle button
            if (!isDone)
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                color: Colors.green,
                onPressed: () =>
                    context.read<TaskProvider>().toggleComplete(task.id),
              )
            else
              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.grey,
                onPressed: () =>
                    context.read<TaskProvider>().toggleComplete(task.id),
              ),
          ],
        ),
      ),
    );
  }

  String _getDaysText(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDay = DateTime(date.year, date.month, date.day);
      final diff = taskDay.difference(today).inDays;

      if (diff == 0) return 'Today!';
      if (diff == 1) return 'Tomorrow';
      if (diff == -1) return '1 day ago';
      if (diff > 1) return 'In $diff days';
      return '${diff.abs()} days ago';
    } catch (_) {
      return '';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No tasks yet!\nAdd tasks from the Home screen.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }
}