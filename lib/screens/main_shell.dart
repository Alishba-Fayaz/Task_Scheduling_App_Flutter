import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/task_provider.dart';
import 'tree_screen.dart';
import 'search_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TreeScreen(),
    SearchScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    // Count overdue tasks for badge
    final today = DateTime.now().toIso8601String().split('T')[0];
    final overdueCount = provider.tasks
        .where((t) => !t.completed && t.date.compareTo(today) < 0)
        .length;

    return Scaffold(
      // IndexedStack keeps all screens alive (clouds keep animating)
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3d2369),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.park_outlined),
              activeIcon: Icon(Icons.park),
              label: 'Tree',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: overdueCount > 0,
                label: Text('$overdueCount'),
                child: const Icon(Icons.notifications_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: overdueCount > 0,
                label: Text('$overdueCount'),
                child: const Icon(Icons.notifications),
              ),
              label: 'Reminders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}