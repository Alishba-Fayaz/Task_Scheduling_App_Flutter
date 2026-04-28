import 'package:flutter/material.dart';

// Replaces:
// <div class="branch-selection">
//   <div class="branch-options"> (buttons 1-10) </div>
//   <button id="confirmBranch">Place Leaf Here</button>
//   <button id="cancelBranchBtn">Cancel</button>
// </div>
class BranchSelectionDialog extends StatefulWidget {
  final int branchCount;
  final Function(int branchIndex) onBranchSelected;

  const BranchSelectionDialog({
    super.key,
    required this.branchCount,
    required this.onBranchSelected,
  });

  @override
  State<BranchSelectionDialog> createState() => _BranchSelectionDialogState();
}

class _BranchSelectionDialogState extends State<BranchSelectionDialog> {
  // Replaces: let selectedBranchIndex = null;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Select a branch for your task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Branch number buttons grid
            // Replaces: branches.forEach((branch, i) => { option = createElement... })
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(widget.branchCount, (i) {
                final isSelected = _selectedIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      // Replaces: .branch-option.selected { background: #4CAF50 }
                      // .branch-option { background: #1bdad7 }
                      color: isSelected
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF1bdad7),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Action buttons row
            Row(
              children: [
                // Cancel button
                // Replaces: <button id="cancelBranchBtn">Cancel</button>
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 12),

                // Confirm button
                // Replaces: <button id="confirmBranch">Place Leaf Here</button>
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedIndex == null
                        ? null // disabled if no branch selected
                        : () {
                            widget.onBranchSelected(_selectedIndex!);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00e372),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Place Leaf Here',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}