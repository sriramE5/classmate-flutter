import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  Future<void> sendMessage() async {
    String prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": prompt});
      _controller.clear();
    });

    try {
      final response = await http.post(
        Uri.parse("http://192.168.61.104:8000/api/chat"), // use your local IP
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );

      final data = jsonDecode(response.body);
      String reply = data["reply"];

      setState(() {
        messages.add({"role": "bot", "text": reply});
      });

      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "<p>⚠️ Error: ${e.toString()}</p>"});
      });
    }
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg["role"] == "user";

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(maxWidth: 300),
            child: isUser
                ? Text(
              msg["text"],
              style: const TextStyle(color: Colors.white),
            )
                : Html(data: msg["text"]),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              final plainText = _extractPlainText(msg["text"]);
              Clipboard.setData(ClipboardData(text: plainText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied!")),
              );
            },
          )
        ],
      ),
    );
  }

  String _extractPlainText(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
