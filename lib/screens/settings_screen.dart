import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/task_provider.dart';
import 'debug_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3d2369),
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── App info ─────────────────────────────────
          _buildSection(
            title: 'App Info',
            children: [
              _buildInfoTile(
                icon: Icons.eco,
                iconColor: Colors.green,
                title: 'Task Scheduling Tree',
                subtitle: 'Version 1.0.0',
              ),
              _buildInfoTile(
                icon: Icons.task_alt,
                iconColor: Colors.blue,
                title: 'Total Tasks',
                subtitle: '${provider.taskCount} tasks saved',
              ),
              _buildInfoTile(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                title: 'Completed',
                subtitle: '${provider.completedCount} tasks done',
              ),
              _buildInfoTile(
                icon: Icons.pending_actions,
                iconColor: Colors.orange,
                title: 'Remaining',
                subtitle: '${provider.incompleteCount} tasks active',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Data management ──────────────────────────
          _buildSection(
            title: 'Data',
            children: [
              _buildActionTile(
                icon: Icons.delete_sweep,
                iconColor: Colors.red,
                title: 'Clear All Tasks',
                subtitle: 'Remove all tasks permanently',
                onTap: () => _confirmClearAll(context, provider),
              ),
              _buildActionTile(
                icon: Icons.bug_report,
                iconColor: Colors.grey,
                title: 'Storage Debug',
                subtitle: 'View storage details (developer)',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DebugScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── About ─────────────────────────────────────
          _buildSection(
            title: 'About',
            children: [
              _buildInfoTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF3d2369),
                title: 'How to use',
                subtitle:
                    'Tap "Add Task" on the tree screen, fill in details, then pick a branch to place your task leaf.',
              ),
              _buildInfoTile(
                icon: Icons.palette,
                iconColor: Colors.orange,
                title: 'Priority Colors',
                subtitle: '🔴 High   🟡 Medium   🟢 Low',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _confirmClearAll(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text('This permanently removes all tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.clearAllTasks();
            },
            style: TextButton.styleFrom(
                foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}