import 'dart:math';
import 'package:flutter/material.dart';

// Stores the tip position and angle of each branch
// Leaves will use this to know WHERE to sit on a branch
class BranchInfo {
  final Offset startPoint;  // where branch begins (on trunk)
  final Offset endPoint;    // where branch tip ends
  final double angleDegrees; // angle in degrees

  const BranchInfo({
    required this.startPoint,
    required this.endPoint,
    required this.angleDegrees,
  });

  // Calculates a point at X% along this branch
  // e.g. pointAlong(0.6) = 60% from start to tip
  Offset pointAlong(double ratio) {
    return Offset(
      startPoint.dx + (endPoint.dx - startPoint.dx) * ratio,
      startPoint.dy + (endPoint.dy - startPoint.dy) * ratio,
    );
  }
}

// CustomPainter replaces all your JS branch creation code:
// branchAngles.forEach((angle, index) => {
//   const branch = document.createElement('div'); ...
// })
class TreePainter extends CustomPainter {
  // These match your HTML exactly:
  // const branchAngles = [-70,-50,-39,-29,-8,6,25,30,50,70];
  static const List<double> branchAngles = [
    -70, -50, -39, -29, -7, 7, 25, 30, 50, 70
  ];

  // const branchHeights = [0.32,0.37,0.45,0.54,0.5,0.5,0.5,0.4,0.37,0.32];
  // These are "from bottom" in HTML — we convert to "from top" below
  static const List<double> branchHeightsFromBottom = [
    0.32, 0.37, 0.45, 0.54, 0.60,
    0.60, 0.60, 0.40, 0.37, 0.32
  ];

  // After painting, branch info is stored here
  // Step 6 will read this to place leaves
  final List<BranchInfo> branchInfoList = [];

  // Paint objects — like CSS background colors for the tree
  final Paint _trunkPaint = Paint()
    ..color = const Color(0xFF6D4C41)  // brown
    ..strokeWidth = 28
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final Paint _branchPaint = Paint()
    ..color = const Color(0xFF6D4C41)
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final Paint _subBranchPaint = Paint()
    ..color = const Color(0xFF5D4037) // slightly darker brown
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // Clear previous branch info on repaint
    branchInfoList.clear();

    // ── Draw trunk ──────────────────────────────────────
    // Replaces: .trunk { height: 300px; width: 30px; }
    //
    // Trunk goes from bottom-center up to 30% of canvas height
    final trunkBaseX = size.width / 2;
    final trunkBottomY = size.height * 0.92; // near bottom
    final trunkTopY = size.height * 0.42;    //  from top

    // Draw trunk as a thick line
    canvas.drawLine(
      Offset(trunkBaseX, trunkBottomY),
      Offset(trunkBaseX, trunkTopY),
      _trunkPaint,
    );

    // Trunk base oval — replaces .trunk::before
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(trunkBaseX, trunkBottomY + 5),
        width: 55,
        height: 18,
      ),
      Paint()..color = const Color(0xFF5D4037),
    );

    // ── Draw branches ──────────────────────────────────
    // Replaces the branchAngles.forEach loop in your JS
    for (int i = 0; i < branchAngles.length; i++) {
      final angleDeg = branchAngles[i];

      // Convert "from bottom %" to actual Y coordinate
      // HTML: branch.style.bottom = `${branchHeights[i] * 100}%`
      // Flutter: y = totalHeight - (totalHeight * heightRatio)
      //
      // BUT our canvas doesn't include the full screen height —
      // it's just the tree widget area. The trunk spans from
      // trunkBottomY to trunkTopY, so we interpolate within that.
      final trunkSpan = trunkBottomY - trunkTopY;
      final startY = trunkBottomY - (trunkSpan * branchHeightsFromBottom[i]);
      final startX = trunkBaseX;

      // Branch length — replaces: height: 180px in your CSS
      // We scale it relative to canvas size
      final branchLength = size.height * 0.22;

      // Convert degrees to radians for math
      // In your HTML: transform: rotate(${angle}deg)
      // Flutter uses radians for trig functions
      final angleRad = angleDeg * pi / 180;

      // Calculate branch tip position
      // sin gives horizontal movement, cos gives vertical
      // We SUBTRACT cos*length because y increases downward in Flutter
      final endX = startX + sin(angleRad) * branchLength;
      final endY = startY - cos(angleRad) * branchLength;

      final branchStart = Offset(startX, startY);
      final branchEnd = Offset(endX, endY);

      // Branch thickness tapers based on position
      // Left branches (negative angles) and right branches get same treatment
      final isOuter = i == 0 || i == 9;
      _branchPaint.strokeWidth = isOuter ? 10 : 13;

      // Draw the main branch line
      canvas.drawLine(branchStart, branchEnd, _branchPaint);

      // Store branch info — Step 6 reads this for leaf placement
      final info = BranchInfo(
        startPoint: branchStart,
        endPoint: branchEnd,
        angleDegrees: angleDeg,
      );
      branchInfoList.add(info);

      // ── Draw 2 sub-branches per main branch ──────────
      // Replaces:
      // for (let i = 0; i < 2; i++) {
      //   const subBranch = document.createElement('div'); ...
      // }
      for (int j = 0; j < 2; j++) {
        // Sub-branch starts at 65% or 85% along main branch
        // Replaces: const subPosition = 0.65 + (i * 0.2)
        final subStartRatio = 0.65 + (j * 0.20);
        final subStart = info.pointAlong(subStartRatio);

        // Sub-branch angle is relative to main branch angle
        // Replaces: const subAngle = -20 + (i * 30)  → -20 or +10
        final subAngleDeg = angleDeg + (-20 + j * 30);
        final subAngleRad = subAngleDeg * pi / 180;

        // Sub-branch length — replaces: const subLength = 40 + 1 * 30 = 70px
        final subLength = size.height * 0.10;

        final subEndX = subStart.dx + sin(subAngleRad) * subLength;
        final subEndY = subStart.dy - cos(subAngleRad) * subLength;

        _subBranchPaint.strokeWidth = 7;
        canvas.drawLine(subStart, Offset(subEndX, subEndY), _subBranchPaint);
      }
    }
  }

  // Flutter calls this to check if it needs to repaint
  // false = tree shape never changes, so no need to repaint
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}