import 'package:class_mate/screens/chatbotpage.dart';
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
        '/taskManager': (context) => Scaffold(body: Center(child: Text('Task Manager Page'))),
        '/goalTracker': (context) => Scaffold(body: Center(child: Text('Goal Tracker Page'))),
        '/performance': (context) => Scaffold(body: Center(child: Text('Performance Page'))),
        '/settings': (context) => Scaffold(body: Center(child: Text('Settings Page'))),
      },
    );
  }
}