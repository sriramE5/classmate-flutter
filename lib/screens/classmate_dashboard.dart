import 'package:flutter/material.dart';

class ClassMateDashboard extends StatelessWidget {
  final String? user;

  const ClassMateDashboard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('ClassMate', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF833ab4),
                  Color(0xFFfd1d1d),
                  Color(0xFFfcb045),
                ],
              ).createShader(bounds),
              child: Text(
                'Hi ${user ?? 'there'}, let\'s get productive!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // masked by gradient
                ),
              ),
            ),
          ),
          // Dashboard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  dashboardCard(context, Icons.calendar_today, "Attendance", "/attendance"),
                  dashboardCard(context, Icons.smart_toy, "AI Chatbot", "/chatbot"),
                  dashboardCard(context, Icons.task, "Task Manager", "/taskManager"),
                  dashboardCard(context, Icons.flag, "Goal Tracker", "/goalTracker"),
                  dashboardCard(context, Icons.show_chart, "Performance", "/performance"),
                  dashboardCard(context, Icons.settings, "Settings", "/settings"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(BuildContext context, IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFF1F1F1), // Light card color
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.black),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
