import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/task_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  TaskPriority? _filterPriority;
  bool? _filterCompleted;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(List<Task> tasks) {
    return tasks.where((task) {
      final matchesQuery = _query.isEmpty ||
          task.name.toLowerCase().contains(_query.toLowerCase()) ||
          task.description.toLowerCase().contains(_query.toLowerCase());

      final matchesPriority =
          _filterPriority == null || task.priority == _filterPriority;

      final matchesCompleted =
          _filterCompleted == null || task.completed == _filterCompleted;

      return matchesQuery && matchesPriority && matchesCompleted;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final filtered = _getFilteredTasks(tasks.toList());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3d2369),
        foregroundColor: Colors.white,
        title: const Text('Search Tasks'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Search bar + filters ─────────────────────
          Container(
            color: const Color(0xFF3d2369),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search input
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name or description...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),

                const SizedBox(height: 10),

                // Filter chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Completion filter
                      _filterChip(
                        label: 'All',
                        selected: _filterCompleted == null,
                        onTap: () => setState(() => _filterCompleted = null),
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'Active',
                        selected: _filterCompleted == false,
                        onTap: () => setState(() => _filterCompleted = false),
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'Completed',
                        selected: _filterCompleted == true,
                        onTap: () => setState(() => _filterCompleted = true),
                      ),
                      const SizedBox(width: 16),
                      // Priority filter
                      ...TaskPriority.values.map((p) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _filterChip(
                              label: p.label,
                              selected: _filterPriority == p,
                              color: p.color,
                              onTap: () => setState(() {
                                _filterPriority =
                                    _filterPriority == p ? null : p;
                              }),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Results ──────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          tasks.isEmpty
                              ? 'No tasks yet.\nAdd tasks from the Home screen!'
                              : 'No tasks match your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildTaskCard(filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? Colors.white)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white38,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (color != null ? Colors.black87 : const Color(0xFF3d2369))
                : Colors.white,
            fontWeight:
                selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: task.completed
                ? const Color(0xFF8D6E63).withOpacity(0.7)
                : task.priority.color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: Icon(
            task.completed ? Icons.check : Icons.eco,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          task.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  task.date,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: task.priority.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: task.priority.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (task.branchIndex >= 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Branch ${task.branchIndex + 1}',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Icon(
          task.completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: task.completed ? Colors.green : Colors.grey,
        ),
        onTap: () => context.read<TaskProvider>().toggleComplete(task.id),
      ),
    );
  }
}