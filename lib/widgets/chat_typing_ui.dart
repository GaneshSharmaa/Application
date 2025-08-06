import 'package:flutter/material.dart';
import 'dart:async';

class ChatTypingUI extends StatefulWidget {
  const ChatTypingUI({super.key});

  @override
  State<ChatTypingUI> createState() => _ChatTypingUIState();
}

class _ChatTypingUIState extends State<ChatTypingUI> {
  String animatedDots = '';
  Timer? dotTimer;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();
    dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
        animatedDots = '.' * dotCount;
      });
    });
  }

  @override
  void dispose() {
    dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(32),
            ),
            height: 56,
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ask anything$animatedDots',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Icon(Icons.graphic_eq, color: Colors.white54),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Navigation Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.search, size: 28, color: Colors.white),
              Icon(Icons.language, size: 28, color: Colors.white),
              Icon(Icons.brightness_2, size: 28, color: Colors.white),
              Icon(Icons.radar, size: 28, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}