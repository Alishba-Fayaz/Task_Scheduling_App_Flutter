import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/task_provider.dart';
import '../models/models.dart';   

// Debug screen — shows storage status and lets you test
// Remove this screen before releasing the app
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats =
        await context.read<TaskProvider>().getStorageStats();
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Debug'),
        backgroundColor: const Color(0xFF3d2369),
        foregroundColor: Colors.white,
        actions: [
          // Refresh stats button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Storage Stats Card ─────────────────
                  _buildCard(
                    title: '📊 Storage Stats',
                    children: _stats.entries.map((e) {
                      return _buildRow(
                        e.key,
                        e.value.toString(),
                        // Highlight errors in red
                        valueColor: e.key == 'hasError' &&
                                e.value == true
                            ? Colors.red
                            : null,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // ── Task List Card ─────────────────────
                  _buildCard(
                    title: '📋 Saved Tasks (${provider.taskCount})',
                    children: provider.tasks.isEmpty
                        ? [
                            const Text(
                              'No tasks saved',
                              style: TextStyle(color: Colors.grey),
                            )
                          ]
                        : provider.tasks.map((task) {
                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Task name + completion status
                                  Row(
                                    children: [
                                      Icon(
                                        task.completed
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        size: 16,
                                        color: task.completed
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          task.name,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Priority badge
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: task.priority.color,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          task.priority.label,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Storage details
                                  Text(
                                    'ID: ${task.id.substring(0, 8)}...',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Branch: ${task.branchIndex == -1 ? "unplaced" : task.branchIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Position: ${task.position != null ? "saved ✓" : "none"}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: task.position != null
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                  Text(
                                    'Due: ${task.date}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // ── Test Actions Card ──────────────────
                  _buildCard(
                    title: '🧪 Test Actions',
                    children: [
                      // Test: reload stats from disk
                      _buildActionButton(
                        label: 'Refresh Stats from Disk',
                        color: const Color(0xFF2196F3),
                        onTap: _loadStats,
                      ),

                      const SizedBox(height: 8),

                      // Test: clear all storage
                      _buildActionButton(
                        label: '⚠️ Clear ALL Storage',
                        color: const Color(0xFFF44336),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Clear Storage'),
                              content: const Text(
                                'This deletes all saved tasks '
                                'from device storage permanently.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, true),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && mounted) {
                            await context
                                .read<TaskProvider>()
                                .clearStorage();
                            _loadStats();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── How to verify storage works ─────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 How to Verify Storage',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Add a task on the main screen'),
                        Text('2. Come back here → check task appears'),
                        Text('3. Kill the app completely'),
                        Text('4. Reopen app → task should still exist'),
                        Text('5. storageSizeBytes should be > 0'),
                        Text('6. hasError should be false'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper: builds a titled card
  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  // Helper: builds a key-value row
  Widget _buildRow(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: builds a full-width action button
  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}