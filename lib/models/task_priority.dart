import 'package:flutter/material.dart';

// This replaces your CSS classes: .leaf.high / .leaf.medium / .leaf.low
enum TaskPriority { high, medium, low }

// Helper extension — adds useful methods directly to the enum
extension TaskPriorityExtension on TaskPriority {
  
  // Converts enum → string for saving to storage
  // high → "high", medium → "medium", low → "low"
  String get name {
    switch (this) {
      case TaskPriority.high:
        return 'high';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.low:
        return 'low';
    }
  }

  // Converts string → enum when loading from storage
  static TaskPriority fromString(String value) {
    switch (value) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }

  // Replaces your CSS leaf colors:
  // .leaf.high { background: #ef5350; }
  // .leaf.medium { background: #ffca28; }
  // .leaf.low { background: #66bb6a; }
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return const Color(0xFFef5350); // red
      case TaskPriority.medium:
        return const Color(0xFFffca28); // yellow
      case TaskPriority.low:
        return const Color(0xFF66bb6a); // green
    }
  }

  // Human-readable label for the dropdown
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}