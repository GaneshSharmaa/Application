import 'dart:ui';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTyping;
  final bool showSendButton;
  final bool isListening;
  final Animation<double> sendBtnScaleAnimation;
  final Animation<double> sendBtnOpacityAnimation;
  final VoidCallback onSend;
  final VoidCallback onStopTyping;
  final VoidCallback onToggleVoiceInput;
  final VoidCallback onShowVoiceWaveform;

  const SearchBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isTyping,
    required this.showSendButton,
    required this.isListening,
    required this.sendBtnScaleAnimation,
    required this.sendBtnOpacityAnimation,
    required this.onSend,
    required this.onStopTyping,
    required this.onToggleVoiceInput,
    required this.onShowVoiceWaveform,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: (_) => onSend(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Ask anything',
                      hintStyle: TextStyle(color: Colors.white60, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                if (isTyping)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: onStopTyping,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:
                        const Icon(Icons.stop, color: Colors.black, size: 24),
                      ),
                    ),
                  ),
                if (showSendButton)
                  FadeTransition(
                    opacity: sendBtnOpacityAnimation,
                    child: ScaleTransition(
                      scale: sendBtnScaleAnimation,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: onSend,
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 8),
                            alignment: Alignment.center,
                            child: const Icon(Icons.arrow_upward,
                                color: Colors.black, size: 25),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!showSendButton) ...[
                  GestureDetector(
                    onLongPress: onToggleVoiceInput,
                    onTap: onToggleVoiceInput,
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isListening
                            ? Colors.red.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: isListening
                            ? Border.all(
                            color: Colors.red.withOpacity(0.5), width: 2)
                            : null,
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: isListening ? Colors.red : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onShowVoiceWaveform,
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.mic_off_outlined,
                          color: Colors.grey[400], size: 20),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
