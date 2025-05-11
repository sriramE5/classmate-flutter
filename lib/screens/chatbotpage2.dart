import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotPage2 extends StatefulWidget {
  const ChatbotPage2({Key? key}) : super(key: key);

  static const String chatbotUrl =
      'https://tsivaganeshvemula-jarvis-thegenai-chatbot.hf.space';

  @override
  State<ChatbotPage2> createState() => _ChatbotPage2State();
}

class _ChatbotPage2State extends State<ChatbotPage2> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint("Loading: $url");
          },
          onPageFinished: (url) {
            debugPrint("Finished loading: $url");
          },
        ),
      )
      ..loadRequest(Uri.parse(ChatbotPage2.chatbotUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🤖 ClassMate AI Chatbot"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("← Back to Dashboard",
              style: TextStyle(color: Color(0xFFFcb045), fontSize: 16)),
        ),
      ),
    );
  }
}
