import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceCalculator extends StatefulWidget {
  const AttendanceCalculator({Key? key}) : super(key: key);

  @override
  State<AttendanceCalculator> createState() => _AttendanceCalculatorState();
}

class _AttendanceCalculatorState extends State<AttendanceCalculator> {
  final TextEditingController totalController = TextEditingController();
  final TextEditingController attendedController = TextEditingController();
  final TextEditingController mandatoryController = TextEditingController();
  final TextEditingController perDayController = TextEditingController();

  String resultText = '';
  Color resultColor = Colors.black;

  void calculateAttendance() {
    final int? total = int.tryParse(totalController.text);
    final int? attended = int.tryParse(attendedController.text);
    final int? mandatory = int.tryParse(mandatoryController.text);
    final int? perDay = int.tryParse(perDayController.text);

    if (total == null || attended == null || mandatory == null || perDay == null || perDay <= 0) {
      setState(() {
        resultText = "⚠️ Please fill all fields correctly.";
        resultColor = const Color(0xFFFcb045); // Yellow
      });
      return;
    }

    final double percentage = (attended / total) * 100;
    String result;
    Color color;

    if (percentage >= mandatory) {
      color = const Color(0xFF00b87c); // Green
      final int canBunk = (attended * 100 ~/ mandatory) - total;
      final int daysCanBunk = canBunk ~/ perDay;
      result = '✅ You are safe with ${percentage.toStringAsFixed(2)}%.\n'
          'You can skip $canBunk more classes.\n'
          "That's $daysCanBunk day(s).";
    } else {
      color = percentage >= 50 ? const Color(0xFFFcb045) : const Color(0xFFFF4C4C);
      final int needToAttend = ((mandatory * total - attended * 100) / (100 - mandatory)).ceil();
      final int daysToAttend = (needToAttend / perDay).ceil();
      result = '⚠️ Current Attendance: ${percentage.toStringAsFixed(2)}%.\n'
          'You must attend $needToAttend more classes.\n'
          "That's $daysToAttend day(s) to reach $mandatory%.";
    }

    setState(() {
      resultText = result;
      resultColor = color;
    });
  }

  Widget _buildInputField(String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "ClassMate - Attendance",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 0)),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildInputField("Total Classes:", totalController, "Enter total classes"),
                _buildInputField("Attended Classes:", attendedController, "Enter attended classes"),
                _buildInputField("Mandatory Attendance (%):", mandatoryController, "e.g., 75"),
                _buildInputField("Classes Per Day:", perDayController, "Enter classes per day"),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: calculateAttendance,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Calculate",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (resultText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      resultText,
                      style: GoogleFonts.lato(color: resultColor, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "← Back to Dashboard",
                    style: GoogleFonts.lato(fontSize: 14, color: const Color(0xFFFcb045)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    totalController.dispose();
    attendedController.dispose();
    mandatoryController.dispose();
    perDayController.dispose();
    super.dispose();
  }
}
