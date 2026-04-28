import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

// Replaces:
// <div class="modal" id="taskModal">
//   <div class="modal-content"> ... </div>
// </div>
class TaskDetailModal extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final Function({
    required String name,
    required TaskPriority priority,
    required String date,
    required String description,
  }) onSave;

  const TaskDetailModal({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onSave,
  });

  @override
  State<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends State<TaskDetailModal> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TaskPriority _priority;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with current task values
    // Replaces: editTaskName.value = task.name; etc.
    _nameController = TextEditingController(text: widget.task.name);
    _descController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _selectedDate = DateTime.tryParse(widget.task.date) ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    widget.onSave(
      name: _nameController.text.trim(),
      priority: _priority,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      description: _descController.text.trim(),
    );
    Navigator.pop(context);
  }

  void _delete() {
    Navigator.pop(context);
    // Small delay so modal closes before animation starts
    Future.delayed(const Duration(milliseconds: 100), widget.onDelete);
  }

  void _toggleComplete() {
    widget.onToggleComplete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Replaces: <button class="close-btn">×</button>
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Task Name ────────────────────────────
              const Text(
                'Task Name',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Priority ─────────────────────────────
              const Text(
                'Priority',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFBDBDBD)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskPriority>(
                    value: _priority,
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Due Date ─────────────────────────────
              const Text(
                'Due Date',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBDBDBD)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Description ──────────────────────────
              const Text(
                'Description',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),

              const SizedBox(height: 20),

              // ── Action Buttons ────────────────────────
              // Replaces: <div class="modal-actions">
              Row(
                children: [
                  // Delete — replaces: <button id="deleteBtn">
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _delete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Complete / Incomplete toggle
                  // Replaces: completeBtn / incompleteBtn show/hide logic
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.task.completed
                            ? const Color(0xFFFFA000) // orange = mark incomplete
                            : const Color(0xFF4CAF50), // green = mark complete
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        widget.task.completed ? 'Incomplete' : 'Complete',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Save — replaces: <button id="saveBtn">
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}