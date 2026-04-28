import 'package:flutter/material.dart';

// Replaces:
// <header class="site-header">
//   <h1 class="site-title">Task Scheduling Tree</h1>
//   <p class="site-tagline">Branch out your productivity...</p>
// </header>
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Replaces: .site-title
            const Text(
              'Task Scheduling Tree',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0f035b),
                fontFamily: 'Georgia',
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Replaces: .site-tagline
            const Text(
              'Branch out your productivity and stay organized',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF059a4a),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}