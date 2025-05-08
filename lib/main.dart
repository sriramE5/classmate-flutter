import 'package:flutter/material.dart';
import 'screens/dashboard.dart';

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
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const ClassMateDashboard(user: 'Ganesh'),  // Example username
        '/attendance': (context) => Scaffold(body: Center(child: Text('Attendance Page'))),
        '/chatbot': (context) => Scaffold(body: Center(child: Text('Chatbot Page'))),
        '/taskManager': (context) => Scaffold(body: Center(child: Text('Task Manager Page'))),
        '/goalTracker': (context) => Scaffold(body: Center(child: Text('Goal Tracker Page'))),
        '/performance': (context) => Scaffold(body: Center(child: Text('Performance Page'))),
        '/settings': (context) => Scaffold(body: Center(child: Text('Settings Page'))),
      },
    );
  }
}