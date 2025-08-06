import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TypewriterMarkdown extends StatefulWidget {
  final String data;
  final bool? stopTyping;
  final VoidCallback? onFinished;

  const TypewriterMarkdown({
    super.key,
    required this.data,
    this.stopTyping,
    this.onFinished,
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
  String _visibleText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 8), (timer) {
      if (widget.stopTyping == true) {
        timer.cancel();
        return;
      }

      if (_currentIndex < widget.data.length) {
        setState(() {
          _currentIndex++;
          _visibleText = widget.data.substring(0, _currentIndex);
        });
      } else {
        timer.cancel();
        widget.onFinished?.call(); // ✅ Call this once text is done
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(data: _visibleText);
  }
}
