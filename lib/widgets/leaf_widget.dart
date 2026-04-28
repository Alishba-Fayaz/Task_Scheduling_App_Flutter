import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

// Animated leaf widget
// Handles three animation states:
// 1. isFalling = true  → plays fall + fade animation then calls onFallComplete
// 2. Normal state      → plays gentle sway animation forever
// 3. completed = true  → brown leaf, still sways
class LeafWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final bool isFalling;

  // Called when fall animation finishes
  // tree_screen uses this to actually delete from state
  final VoidCallback? onFallComplete;

  const LeafWidget({
    super.key,
    required this.task,
    required this.onTap,
    this.isFalling = false,
    this.onFallComplete,
  });

  @override
  State<LeafWidget> createState() => _LeafWidgetState();
}

class _LeafWidgetState extends State<LeafWidget>
    with TickerProviderStateMixin {
  // ── Fall animation ─────────────────────────────────────
  // Replaces: animation: leafFall 1.5s forwards
  late AnimationController _fallController;
  late Animation<double> _fallY;       // moves leaf down
  late Animation<double> _fallRotate;  // spins the leaf
  late Animation<double> _fallOpacity; // fades out

  // ── Sway animation ─────────────────────────────────────
  // New addition — gentle idle movement
  late AnimationController _swayController;
  late Animation<double> _swayRotation;

  // Random offset so not all leaves sway in sync
  late double _swayOffset;

  @override
  void initState() {
    super.initState();

    final random = Random();
    _swayOffset = random.nextDouble() * 2 * pi;

    // ── Set up fall animation ─────────────────────────
    // Duration matches your CSS: 1.5s
    _fallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // translateY(0) → translateY(300px)
    _fallY = Tween<double>(begin: 0, end: 350).animate(
      CurvedAnimation(
        parent: _fallController,
        // Ease in so leaf starts slow then speeds up (gravity feel)
        curve: Curves.easeIn,
      ),
    );

    // rotate(0deg) → rotate(360deg)
    _fallRotate = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _fallController,
        curve: Curves.linear,
      ),
    );

    // opacity: 1 → opacity: 0
    _fallOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fallController,
        // Only start fading at 60% through animation
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // When fall finishes → tell parent to remove this task
    _fallController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFallComplete?.call();
      }
    });

    // ── Set up sway animation ──────────────────────────
    // Gentle back-and-forth rotation
    _swayController = AnimationController(
      vsync: this,
      // Random duration between 2-4 seconds for each leaf
      duration: Duration(
        milliseconds: 2000 + random.nextInt(2000),
      ),
    );

    // Sway from -8 degrees to +8 degrees
    _swayRotation = Tween<double>(
      begin: -8 * pi / 180,
      end: 8 * pi / 180,
    ).animate(
      CurvedAnimation(
        parent: _swayController,
        curve: Curves.easeInOut,
      ),
    );

    // Only sway if not falling
    if (!widget.isFalling) {
      // repeat(reverse: true) makes it go back and forth
      // Like CSS: animation-direction: alternate
      _swayController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LeafWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Parent just set isFalling = true → start fall animation
    // Replaces: leaf.classList.add('falling')
    if (widget.isFalling && !oldWidget.isFalling) {
      _swayController.stop(); // stop swaying when falling
      _fallController.forward();
    }
  }

  @override
  void dispose() {
    _fallController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.position == null) return const SizedBox.shrink();

    // AnimatedBuilder rebuilds every animation frame
    // Like requestAnimationFrame in JavaScript
    return AnimatedBuilder(
      animation: Listenable.merge([_fallController, _swayController]),
      builder: (context, child) {
        // ── Falling state ────────────────────────────
        if (widget.isFalling || _fallController.isAnimating) {
          return Positioned(
            // Fall animation adds to original Y position
            left: widget.task.position!.left,
            top: widget.task.position!.top + _fallY.value,
            child: Opacity(
              opacity: _fallOpacity.value,
              child: Transform.rotate(
                // Combine original rotation + fall spin
                angle: (widget.task.position!.rotation * pi / 180) +
                    _fallRotate.value,
                child: child!,
              ),
            ),
          );
        }

        // ── Normal / sway state ──────────────────────
        return Positioned(
          left: widget.task.position!.left,
          top: widget.task.position!.top,
          child: Transform.rotate(
            // Combine the stored position rotation + live sway
            angle: (widget.task.position!.rotation * pi / 180) +
                _swayRotation.value,
            child: child!,
          ),
        );
      },
      // child is built once and reused each frame (performance)
      child: GestureDetector(
        onTap: widget.onTap,
        child: _buildLeafShape(),
      ),
    );
  }

  Widget _buildLeafShape() {
    final leafColor = widget.task.completed
        ? const Color(0xFF8D6E63).withOpacity(0.7)
        : widget.task.priority.color;

    final displayName = widget.task.name.length > 12
        ? '${widget.task.name.substring(0, 10)}...'
        : widget.task.name;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: leafColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            displayName,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}