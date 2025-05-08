import 'package:flutter/material.dart';

class ClassMateDashboard extends StatelessWidget {
  final String? user;

  const ClassMateDashboard({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('ClassMate'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  color: Colors.white,
                ),
              ),
            ),
          ),
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
                  dashboardCard(context, Icons.flag, "Goal Tracker", "/goalTracker"), // Changed icon to 'flag'
                  dashboardCard(context, Icons.show_chart, "Performance", "/performance"),
                  dashboardCard(context, Icons.settings, "Settings", "/settings"),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFfcb045),
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: ''), // Changed icon to 'flag'
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF3a3a3a), Color(0xFF2a2a2a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
