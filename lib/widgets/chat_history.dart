import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistory extends StatefulWidget {
  final Function(String) onChatSelected;

  const ChatHistory({super.key, required this.onChatSelected});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  List<String> chatHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      chatHistory = prefs.getStringList('chatHistory') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('chatHistory', chatHistory);
  }

  void addChat(String title) {
    setState(() {
      chatHistory.insert(0, title);
    });
    _saveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.history),
      title: const Text("Chat History"),
      children: chatHistory.isNotEmpty
          ? chatHistory.map((historyItem) {
        return ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: Text(historyItem),
          onTap: () {
            widget.onChatSelected(historyItem);
            Navigator.pop(context);
          },
        );
      }).toList()
          : [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text("No chat history yet"),
        ),
      ],
    );
  }
}
