import 'package:class_mate/screens/chatbotpage.dart';
import 'package:class_mate/screens/goaltracker.dart';
import 'package:class_mate/screens/notespage.dart';
import 'package:flutter/material.dart';
import 'screens/classmate_dashboard.dart';
import 'screens/attendance_calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassMate',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const ClassMateDashboard(user: 'Ganesh'),  // Example username
        '/attendance': (context) => const AttendanceCalculator(),
        '/chatbot': (context) => const ChatbotPage(),
        '/notes': (context) => const NotesPage(),
        '/goalTracker': (context) => const GoalTracker(),
        '/performance': (context) => Scaffold(body: Center(child: Text('Performance Page'))),
        '/settings': (context) => Scaffold(body: Center(child: Text('Settings Page'))),
      },
    );
  }
}