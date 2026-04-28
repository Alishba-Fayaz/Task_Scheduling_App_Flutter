import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class TaskProvider extends ChangeNotifier {

  // ── Private state ─────────────────────────────────────
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _lastError; // stores last error message for debugging

  static const String _storageKey = 'treeTasks';
  static const String _versionKey = 'treeTasksVersion';
  static const int _currentVersion = 1;

  // ── Constructor ───────────────────────────────────────
  TaskProvider() {
    _loadTasksFromStorage();
  }

  // ── Public getters ────────────────────────────────────
  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> get incompleteTasks =>
      _tasks.where((t) => !t.completed).toList();

  List<Task> get completedTasks =>
      _tasks.where((t) => t.completed).toList();

  bool get isLoading => _isLoading;
  bool get isEmpty => _tasks.isEmpty;
  String? get lastError => _lastError;

  int get taskCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.completed).length;
  int get incompleteCount => _tasks.where((t) => !t.completed).length;

  List<Task> getTasksOnBranch(int branchIndex) =>
      _tasks.where((t) => t.branchIndex == branchIndex).toList();

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Add task ──────────────────────────────────────────
  void addTask({
    required String name,
    required TaskPriority priority,
    required String date,
    String description = '',
  }) {
    // Guard: don't add empty names
    if (name.trim().isEmpty) return;

    final newTask = Task(
      name: name.trim(),
      priority: priority,
      date: date,
      description: description.trim(),
    );

    _tasks.add(newTask);
    _saveTasksToStorage();
    notifyListeners();
  }

  // ── Place task on branch ──────────────────────────────
  void placeTaskOnBranch({
    required String taskId,
    required int branchIndex,
    required TaskPosition position,
  }) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      debugPrint('placeTaskOnBranch: task $taskId not found');
      return;
    }

    _tasks[index] = _tasks[index].copyWith(
      branchIndex: branchIndex,
      position: position,
    );

    _saveTasksToStorage();
    notifyListeners();
  }

  // ── Delete task ───────────────────────────────────────
  void deleteTask(String taskId) {
    final before = _tasks.length;
    _tasks.removeWhere((t) => t.id == taskId);

    // Only save and notify if something actually changed
    if (_tasks.length != before) {
      _saveTasksToStorage();
      notifyListeners();
    }
  }

  // ── Toggle complete ───────────────────────────────────
  void toggleComplete(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      completed: !_tasks[index].completed,
    );

    _saveTasksToStorage();
    notifyListeners();
  }

  // ── Update task ───────────────────────────────────────
  void updateTask({
    required String taskId,
    required String name,
    required TaskPriority priority,
    required String date,
    required String description,
  }) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    // Guard: don't save empty names
    if (name.trim().isEmpty) return;

    _tasks[index] = _tasks[index].copyWith(
      name: name.trim(),
      priority: priority,
      date: date,
      description: description.trim(),
    );

    _saveTasksToStorage();
    notifyListeners();
  }

  // ── Clear all tasks ───────────────────────────────────
  void clearAllTasks() {
    if (_tasks.isEmpty) return;
    _tasks.clear();
    _saveTasksToStorage();
    notifyListeners();
  }

  // ── Update position (for screen resize fix) ───────────
  // Called by tree_screen when screen dimensions change
  void updateTaskPosition(String taskId, TaskPosition newPosition) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(position: newPosition);
    // Note: we save but don't notifyListeners here
    // because this is called during build
    _saveTasksToStorage();
  }

  // ─────────────────────────────────────────────────────
  // STORAGE: SAVE
  // Replaces: localStorage.setItem('treeTasks', JSON.stringify(tasks))
  // ─────────────────────────────────────────────────────
  Future<void> _saveTasksToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert each task to a Map, then encode to JSON string
      final taskMaps = _tasks.map((task) => task.toMap()).toList();
      final tasksJson = jsonEncode(taskMaps);

      // Save tasks JSON
      await prefs.setString(_storageKey, tasksJson);

      // Save version number (useful for future migrations)
      await prefs.setInt(_versionKey, _currentVersion);

      _lastError = null; // clear any previous error
      debugPrint('Saved ${_tasks.length} tasks to storage');

    } catch (e) {
      // Storage failed — keep in memory but log the error
      _lastError = 'Save failed: $e';
      debugPrint('Storage save error: $e');
    }
  }

  // ─────────────────────────────────────────────────────
  // STORAGE: LOAD
  // Replaces: JSON.parse(localStorage.getItem('treeTasks')) || []
  // ─────────────────────────────────────────────────────
  Future<void> _loadTasksFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ── Check if any saved data exists ──────────────
      // Replaces: || [] fallback in JS
      final tasksJson = prefs.getString(_storageKey);

      if (tasksJson == null || tasksJson.isEmpty) {
        // First launch — no saved data, start fresh
        debugPrint('No saved tasks found, starting fresh');
        _tasks = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ── Decode JSON ──────────────────────────────────
      final dynamic decoded = jsonDecode(tasksJson);

      // Guard: make sure it's actually a List
      // Corrupted data might decode to something unexpected
      if (decoded is! List) {
        debugPrint('Storage data is not a List, resetting');
        _tasks = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ── Convert each item to a Task ──────────────────
      final loadedTasks = <Task>[];

      for (final item in decoded) {
        try {
          // Guard: skip null or non-Map items
          if (item == null || item is! Map<String, dynamic>) {
            debugPrint('Skipping invalid task item: $item');
            continue;
          }

          // Guard: skip tasks with no ID
          // Replaces: tasks.filter(task => task && task.id)
          if (item['id'] == null ||
              item['id'].toString().isEmpty) {
            debugPrint('Skipping task with no ID');
            continue;
          }

          final task = Task.fromMap(item);
          loadedTasks.add(task);

        } catch (e) {
          // One bad task won't crash everything — just skip it
          debugPrint('Failed to parse task: $e\nData: $item');
        }
      }

      _tasks = loadedTasks;
      _lastError = null;
      debugPrint('Loaded ${_tasks.length} tasks from storage');

    } catch (e) {
      // Complete failure — start fresh rather than crash
      _lastError = 'Load failed: $e';
      debugPrint('Storage load error: $e');
      _tasks = [];

    } finally {
      // Always runs — marks loading as done
      // Even if everything above failed
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Clear storage completely (for testing/reset) ──────
  Future<void> clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_versionKey);
      _tasks = [];
      notifyListeners();
      debugPrint('Storage cleared');
    } catch (e) {
      debugPrint('Clear storage error: $e');
    }
  }

  // ── Get storage stats (for debug screen) ─────────────
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_storageKey);
      final version = prefs.getInt(_versionKey);

      return {
        'taskCount': _tasks.length,
        'completedCount': completedCount,
        'incompleteCount': incompleteCount,
        'storageVersion': version ?? 'none',
        'storageSizeBytes': tasksJson?.length ?? 0,
        'hasError': _lastError != null,
        'lastError': _lastError ?? 'none',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}