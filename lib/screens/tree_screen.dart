import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/task_provider.dart';
import '../widgets/sky_background.dart';
import '../widgets/grass_layer.dart';
import '../widgets/app_header.dart';
import '../widgets/tree_widget.dart';
import '../widgets/tree_painter.dart';
import '../widgets/leaf_widget.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/branch_selection_dialog.dart';
import '../widgets/task_detail_modal.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  List<BranchInfo> _branchInfoList = [];
  Offset _treeOffset = Offset.zero;
  Size _treeSize = Size.zero;

  // Tracks which tasks are currently mid-fall animation
  // Replaces: leaf.classList.add('falling')
  final Set<String> _fallingTaskIds = {};

  // Stores task pending branch selection
  Task? _pendingTask;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Sky + Clouds
          const SkyBackground(),

          // Layer 2: Header
          const AppHeader(),

          // Layer 3: Tree
          Positioned(
            top: MediaQuery.of(context).size.height * 0.08,
            left: 0,
            right: 0,
            bottom: 100,
            child: taskProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : TreeWidget(
                    onBranchesReady: (branches, offset, size) {
                      setState(() {
                        _branchInfoList = branches;
                        _treeOffset = offset;
                        _treeSize = size;
                      });
                    },
                  ),
          ),

          // Layer 4: Leaves (with animations)
          if (_branchInfoList.isNotEmpty)
            ..._buildLeaves(taskProvider),

          // Layer 5: Empty state
          if (taskProvider.isEmpty &&
              !taskProvider.isLoading &&
              _fallingTaskIds.isEmpty)
            _buildEmptyState(),

          // Layer 6: Grass
          const GrassLayer(),

          // Layer 7: Buttons
          _buildButtons(taskProvider),




        ],
      ),
    );
  }

  // ── Build all leaf widgets ──────────────────────────────
  List<Widget> _buildLeaves(TaskProvider taskProvider) {
    // We show leaves that:
    // 1. Have a position (placed on a branch)
    // 2. OR are currently in falling animation
    final visibleTasks = taskProvider.tasks
        .where((t) => t.position != null)
        .toList();

    return visibleTasks.map((task) {
      final isFalling = _fallingTaskIds.contains(task.id);

      return LeafWidget(
        key: ValueKey(task.id),
        task: task,
        isFalling: isFalling,
        onTap: isFalling ? () {} : () => _openTaskDetail(task),

        // Called when fall animation completes
        // THEN we actually remove from state
        // Replaces the setTimeout in your HTML:
        // setTimeout(() => { leafToRemove.remove(); }, 1500)
        onFallComplete: () {
          // Remove from falling set
          setState(() => _fallingTaskIds.remove(task.id));
          // Now delete from provider (triggers rebuild without this leaf)
          context.read<TaskProvider>().deleteTask(task.id);
          // Show empty state if needed
          if (context.read<TaskProvider>().isEmpty) {
            setState(() {});
          }
        },
      );
    }).toList();
  }

  // ── Empty state message ─────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8),
            ],
          ),
          child: const Text(
            'Add your first task to see it appear on the tree!',
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Buttons ─────────────────────────────────────────────
  Widget _buildButtons(TaskProvider taskProvider) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!taskProvider.isEmpty || _fallingTaskIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: _fallingTaskIds.isNotEmpty
                    ? null // disable during animation
                    : () => _confirmClearAll(context, taskProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Clear All Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ElevatedButton(
            onPressed: _fallingTaskIds.isNotEmpty
                ? null // disable during animation
                : () => _showTaskForm(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3d2369),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Add Task',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Show task form ──────────────────────────────────────
  void _showTaskForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        onSubmit: ({
          required String name,
          required TaskPriority priority,
          required String date,
          required String description,
        }) {
          final provider = context.read<TaskProvider>();
          provider.addTask(
            name: name,
            priority: priority,
            date: date,
            description: description,
          );

          final newTask = provider.tasks.last;
          setState(() => _pendingTask = newTask);

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _showBranchSelection(context);
          });
        },
      ),
    );
  }

  // ── Show branch selection ────────────────────────────────
  void _showBranchSelection(BuildContext context) {
    if (_pendingTask == null || _branchInfoList.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BranchSelectionDialog(
        branchCount: _branchInfoList.length,
        onBranchSelected: (branchIndex) {
          _placeLeafOnBranch(_pendingTask!, branchIndex);
          setState(() => _pendingTask = null);
        },
      ),
    ).then((_) {
      if (_pendingTask != null) {
        context.read<TaskProvider>().deleteTask(_pendingTask!.id);
        setState(() => _pendingTask = null);
      }
    });
  }

  // ── Place leaf on branch ────────────────────────────────
  void _placeLeafOnBranch(Task task, int branchIndex) {
  if (branchIndex >= _branchInfoList.length) return;

  final branch = _branchInfoList[branchIndex];
  final provider = context.read<TaskProvider>();

  final leavesOnBranch = provider.tasks
      .where((t) => t.branchIndex == branchIndex && t.id != task.id)
      .length;

  const maxLeaves = 4;
  const spacing = 0.12; // each new leaf steps 12% back from tip
final positionRatio =
    (0.97 - (leavesOnBranch * spacing)).clamp(0.4, 0.97);

  // Get point along branch in TREE-LOCAL coordinates
  final leafPoint = branch.pointAlong(positionRatio);

  // Small alternating side offset so multiple leaves don't stack
  final sideOffset = (leavesOnBranch % 2) * 18.0 - 9.0;
  final rotationOffset = (leavesOnBranch % 2) * 20.0 - 10.0;

  final angleRad = branch.angleDegrees * pi / 180;

  // Perpendicular offset
  final perpX = leafPoint.dx + cos(angleRad) * sideOffset;
  final perpY = leafPoint.dy + sin(angleRad) * sideOffset;

  // ── KEY FIX ──────────────────────────────────────────
  // _treeOffset is where the tree widget starts on screen
  // leafPoint is LOCAL to the tree canvas
  // We add them together to get SCREEN position
  // Then subtract 22 to center the 44px leaf on the point
  final screenX = _treeOffset.dx + perpX - 22;
  final screenY = _treeOffset.dy + perpY - 22;

  final position = TaskPosition(
    left: screenX,
    top: screenY,
    rotation: branch.angleDegrees * 0.3 + rotationOffset,
  );

  provider.placeTaskOnBranch(
    taskId: task.id,
    branchIndex: branchIndex,
    position: position,
  );
}

  // ── Open task detail ────────────────────────────────────
  void _openTaskDetail(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => TaskDetailModal(
        task: task,
        onDelete: () => _startLeafFall(task.id),
        onToggleComplete: () {
          context.read<TaskProvider>().toggleComplete(task.id);
        },
        onSave: ({
          required String name,
          required TaskPriority priority,
          required String date,
          required String description,
        }) {
          context.read<TaskProvider>().updateTask(
                taskId: task.id,
                name: name,
                priority: priority,
                date: date,
                description: description,
              );
        },
      ),
    );
  }

  // ── Start single leaf fall ──────────────────────────────
  // Replaces: leaf.classList.add('falling') for one leaf
  //
  // We mark the leaf as falling in state.
  // LeafWidget sees isFalling=true → starts its AnimationController
  // When animation ends → onFallComplete fires → deleteTask()
  void _startLeafFall(String taskId) {
    setState(() => _fallingTaskIds.add(taskId));
  }

  // ── Staggered clear all ─────────────────────────────────
  // Replaces:
  // allLeaves.forEach((leaf, index) => {
  //   setTimeout(() => { leaf.classList.add('falling'); }, index * 100)
  // })
  void _startClearAllAnimation(List<Task> tasks) {
    for (int i = 0; i < tasks.length; i++) {
      // Stagger each leaf by 100ms
      // index * 100ms matches your HTML exactly
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          setState(() => _fallingTaskIds.add(tasks[i].id));
        }
      });
    }
  }

  // ── Confirm clear all ───────────────────────────────────
  void _confirmClearAll(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Tasks'),
        content: const Text(
          'Are you sure you want to clear all tasks? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);

              // Get snapshot of tasks BEFORE clearing
              // We need the list to animate them
              final tasksToAnimate = taskProvider.tasks
                  .where((t) => t.position != null)
                  .toList();

              if (tasksToAnimate.isEmpty) {
                taskProvider.clearAllTasks();
                return;
              }

              // Start staggered fall animation
              _startClearAllAnimation(tasksToAnimate);

              // After ALL animations finish, clear the state
              // Last leaf starts at: (count-1) * 100ms
              // Each animation is 1500ms long
              // So total wait = (count-1)*100 + 1500 + 100 buffer
              final totalDuration = Duration(
                milliseconds:
                    (tasksToAnimate.length - 1) * 100 + 1500 + 100,
              );

              Future.delayed(totalDuration, () {
                if (mounted) {
                  taskProvider.clearAllTasks();
                  setState(() => _fallingTaskIds.clear());
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFF44336),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}