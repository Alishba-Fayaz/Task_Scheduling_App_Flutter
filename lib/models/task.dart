import 'package:uuid/uuid.dart';
import 'task_priority.dart';
import 'task_position.dart';

class Task {
  final String id;         // was: id: Date.now()
  String name;             // was: name: taskName
  TaskPriority priority;   // was: priority: "high"/"medium"/"low"
  String date;             // was: date: taskDateInput.value
  String description;      // was: description: taskDescriptionInput.value
  bool completed;          // was: completed: false
  int branchIndex;         // was: branchIndex: -1
  TaskPosition? position;  // was: position: { left, top, rotation }
                           // (nullable — not set until placed on branch)

  Task({
    String? id,
    required this.name,
    required this.priority,
    required this.date,
    this.description = '',
    this.completed = false,
    this.branchIndex = -1,
    this.position,
  }) : id = id ?? const Uuid().v4();
  //   ^^^^^^^^^^^^^^^^^^^^^^^^^^^
  //   Auto-generates a unique ID if none provided
  //   Replaces: id: Date.now()

  // -------------------------------------------
  // Replaces: localStorage.setItem(...)
  // Converts Task object → Map → JSON string
  // -------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'priority': priority.name,
      'date': date,
      'description': description,
      'completed': completed,
      'branchIndex': branchIndex,
      'position': position?.toMap(), // null if not placed yet
    };
  }

  // -------------------------------------------
  // Replaces: JSON.parse(localStorage.getItem(...))
  // Recreates a Task object from saved JSON data
  // -------------------------------------------
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      name: map['name'] as String,
      priority: TaskPriorityExtension.fromString(map['priority'] as String),
      date: map['date'] as String,
      description: map['description'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
      branchIndex: map['branchIndex'] as int? ?? -1,
      position: map['position'] != null
          ? TaskPosition.fromMap(map['position'] as Map<String, dynamic>)
          : null,
    );
  }

  // Creates a copy of a task with some fields changed
  // We need this because Flutter state management prefers
  // creating new objects instead of mutating existing ones
  Task copyWith({
    String? name,
    TaskPriority? priority,
    String? date,
    String? description,
    bool? completed,
    int? branchIndex,
    TaskPosition? position,
  }) {
    return Task(
      id: id, // keep the same ID
      name: name ?? this.name,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      branchIndex: branchIndex ?? this.branchIndex,
      position: position ?? this.position,
    );
  }
}