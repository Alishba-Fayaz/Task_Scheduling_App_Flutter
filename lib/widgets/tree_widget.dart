import 'package:flutter/material.dart';
import 'tree_painter.dart';

// This widget:
// 1. Renders the tree using TreePainter
// 2. Exposes branch positions for leaf placement
// 3. Provides a GlobalKey so we can find tree position on screen
//
// Replaces: <div class="tree-container"> + <div class="tree">
class TreeWidget extends StatefulWidget {
  // Callback — called after tree is drawn with branch positions
  // Step 6 uses this to know where to place leaves
  final Function(List<BranchInfo>, Offset treeOffset, Size treeSize)?
      onBranchesReady;

  const TreeWidget({
    super.key,
    this.onBranchesReady,
  });

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> {
  final TreePainter _painter = TreePainter();

  // GlobalKey lets us find this widget's position on screen
  // We need this to convert branch coordinates to screen coordinates
  final GlobalKey _treeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // After first frame is drawn, report branch positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportBranchPositions();
    });
  }

  void _reportBranchPositions() {
    if (widget.onBranchesReady == null) return;

    final renderBox =
        _treeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Gets the tree widget's position relative to the screen top-left
    final treeOffset = renderBox.localToGlobal(Offset.zero);
    final treeSize = renderBox.size;

    widget.onBranchesReady!(
      _painter.branchInfoList,
      treeOffset,
      treeSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Tree takes up most of the screen
    // Replaces: .tree-container { width: 400px; height: 500px; }
    // We use proportional sizing so it looks good on all screen sizes
    final treeWidth = screenSize.width * 0.85;
    final treeHeight = screenSize.height * 0.65;

    return Center(
      child: SizedBox(
        key: _treeKey,
        width: treeWidth,
        height: treeHeight,
        child: CustomPaint(
          painter: _painter,
          // CustomPaint fills the SizedBox completely
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}