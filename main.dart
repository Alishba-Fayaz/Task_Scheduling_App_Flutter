import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/task_provider.dart';
import 'screens/main_shell.dart';

void main() async {
  // Required before using SharedPreferences
  // Replaces: document.addEventListener('DOMContentLoaded', ...)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TaskTreeApp());
}

class TaskTreeApp extends StatelessWidget {
  const TaskTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'Task Scheduling Tree',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3d2369),
          ),
          fontFamily: 'Arial',
        ),
        home: const MainShell(),
      ),
    );
  }
}