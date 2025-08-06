import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 8),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String displayedText = "";
  int _index = 0;
  bool _isTyping = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _resetAndStart();
    }
  }

  void _resetAndStart() {
    setState(() {
      displayedText = "";
      _index = 0;
      _isTyping = true;
    });
    _startTyping();
  }

  void _startTyping() async {
    while (_index < widget.text.length && mounted) {
      await Future.delayed(widget.speed);
      setState(() {
        displayedText += widget.text[_index];
        _index++;
        if (_index >= widget.text.length) {
          _isTyping = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final cursor = _isTyping ? "|" : "";
    return SelectableText(
      displayedText,
      style: widget.style ?? const TextStyle(fontSize: 16),
    );
  }
}
