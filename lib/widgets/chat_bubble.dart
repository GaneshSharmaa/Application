import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mitra/widgets/markdown_with_copy.dart';
import 'package:mitra/widgets/typewriter_markdown.dart';
import 'selected_model.dart';

class ChatBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool animateBotText;
  final bool stopTyping;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.animateBotText = false,
    this.stopTyping = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with TickerProviderStateMixin {
  bool _showOptions = false;
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isRegenerating = false;

  late final AnimationController _spinController;
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _onTypingComplete() {
    setState(() {
      _showOptions = true;
    });
    _controller.forward(); // start animation
  }

  @override
  void dispose() {
    _controller.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: widget.isUser
              ? Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.90),
                padding: const EdgeInsets.all(8),
                child: widget.animateBotText
                    ? TypewriterMarkdown(
                  data: widget.text,
                  stopTyping: widget.stopTyping,
                  onFinished: _onTypingComplete,
                )
                    : MarkdownWithCopy(data: widget.text),
              ),

              // 👍👇 Option Row with animation
              if (_showOptions)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child:
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("Copied!"),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green[600],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _spinController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _spinController.value * 2 * 3.1416,
                                child: child,
                              );
                            },
                            child: IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: () {
                                if (!_isRegenerating) {
                                  _spinController.forward(from: 0);
                                  setState(() {
                                    _isRegenerating = true;
                                  });

                                  // TODO: Replace with your regenerate logic here
                                  Future.delayed(const Duration(milliseconds: 800), () {
                                    setState(() {
                                      _isRegenerating = false;
                                    });
                                  });
                                }
                              },
                            ),
                          ),

                          if (!_isDisliked)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                              child: IconButton(
                                key: ValueKey<bool>(_isLiked),
                                icon: Icon(
                                  _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                  size: 20,
                                  color: _isLiked ? Colors.green : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_isLiked) {
                                      _isLiked = false;
                                    } else {
                                      _isLiked = true;
                                      _isDisliked = false;
                                    }
                                  });
                                },
                              ),
                            ),
                          if (!_isLiked)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                              child: IconButton(
                                key: ValueKey<bool>(_isDisliked),
                                icon: Icon(
                                  _isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                                  size: 20,
                                  color: _isDisliked ? Colors.red : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (_isDisliked) {
                                      _isDisliked = false;
                                    } else {
                                      _isDisliked = true;
                                      _isLiked = false;
                                    }
                                  });
                                },
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.share, size: 20),
                            onPressed: () {
                              // TODO: Share logic
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
