import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

// Replaces:
// <div class="task-form-container">
//   <input id="taskName">
//   <select id="taskPriority">
//   <input type="date" id="taskDate">
//   <textarea id="taskDescription">
// </div>
class TaskFormDialog extends StatefulWidget {
  final Function({
    required String name,
    required TaskPriority priority,
    required String date,
    required String description,
  }) onSubmit;

  const TaskFormDialog({super.key, required this.onSubmit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  // Replaces: taskPrioritySelect.value = 'medium'
  TaskPriority _priority = TaskPriority.medium;

  // Replaces: taskDateInput.value = today
  DateTime _selectedDate = DateTime.now();

  // Controls error display
  bool _showNameError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Replaces: taskDateInput click handler + browser date picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Replaces your addTask() validation + submission
  void _submit() {
    final name = _nameController.text.trim();

    // Replaces: if (!taskName) { alert('Please enter a task name'); return; }
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    widget.onSubmit(
      name: name,
      priority: _priority,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      description: _descController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    'Add New Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  // Replaces: <button class="close-form-btn">×</button>
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Task Name ────────────────────────────
              // Replaces: <input type="text" id="taskName">
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
                  hintText: 'Enter task name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                  errorText: _showNameError ? 'Please enter a task name' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onChanged: (_) {
                  if (_showNameError) {
                    setState(() => _showNameError = false);
                  }
                },
              ),

              const SizedBox(height: 12),

              // ── Priority Dropdown ─────────────────────
              // Replaces: <select id="taskPriority">
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
                            // Color dot next to label
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
              // Replaces: <input type="date" id="taskDate">
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
              // Replaces: <textarea id="taskDescription">
              const Text(
                'Description (Optional)',
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
                  hintText: 'Enter description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),

              const SizedBox(height: 16),

              // ── Submit Button ─────────────────────────
              // Replaces: <button id="submitTaskBtn">Add Task</button>
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3d2369),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}