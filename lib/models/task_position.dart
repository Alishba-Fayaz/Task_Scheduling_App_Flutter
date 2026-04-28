// Replaces this JS object:
// task.position = { left: perpX - 20, top: perpY - 20, rotation: angle * 0.3 }

class TaskPosition {
  final double left;
  final double top;
  final double rotation; // in degrees

  const TaskPosition({
    required this.left,
    required this.top,
    required this.rotation,
  });

  // Converts to a Map so we can save it as JSON
  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'rotation': rotation,
    };
  }

  // Recreates a TaskPosition from saved JSON data
  factory TaskPosition.fromMap(Map<String, dynamic> map) {
    return TaskPosition(
      left: (map['left'] as num).toDouble(),
      top: (map['top'] as num).toDouble(),
      rotation: (map['rotation'] as num).toDouble(),
    );
  }
}