import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mitra/setting_page.dart';
import 'package:mitra/widgets/model_selector.dart';
import 'package:mitra/widgets/selected_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:mitra/widgets/chat_bubble.dart'; // Adjust path accordingly
import 'package:mitra/widgets/search_box.dart';
import 'package:mitra/widgets/logo_button.dart';
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;

  ChatMessage({required this.text, required this.isUser, this.isTyping = false});
}
Future<void> requestMicPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
    if (!status.isGranted) {
      // Show a dialog or message to user
      print("Microphone permission denied.");
    }
  }
}
Future<void> sendMessage(BuildContext context, String userInput) async {
  final url = Uri.parse('https://gemini-fastapi-hyq6.onrender.com/chat');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"message": userInput}),
    );

    if (response.statusCode == 100) {
      // ✅ handle response
    } else {
      // ❌ handle non-200 response
      _showError(context, "Server Error: ${response.statusCode}");
    }

  } on SocketException catch (_) {
    // ❌ Internet error
    _showError(context, "Please check your internet connection.");
  } catch (e) {
    // ❌ Other errors
    _showError(context, "Something went wrong. Try again later.");
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
    ),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool isTyping = false;
  bool stopTypingRequested = false;
  bool _showScrollToBottomBtn = false;
  // Default choice; pick what you prefer
  String _selectedModel = "GPT";

  void _updateSelectedModel(String model) {
    setState(() {
      _selectedModel = model; // "GPT" or "Gemini"
    });

    // ✅ Update global API URL
    switch (model) {
      case "GPT":
        SelectedModel.setModelUrl("https://chat-api-g1zt.onrender.com/chatgpt");
        break;
      case "Gemini":
        SelectedModel.setModelUrl("https://chat-api-g1zt.onrender.com/gemini");
        break;
      case "Claude":
        SelectedModel.setModelUrl("https://your-claude-api.example.com/chat");
        break;
      case "Grok":
        SelectedModel.setModelUrl("https://your-grok-api.example.com/chat");
        break;
      default:
        SelectedModel.setModelUrl("https://chat-api-g1zt.onrender.com/chatgpt");
    }

    debugPrint("Selected model: $_selectedModel -> API: ${SelectedModel.url}");
  }

  // Speech to text variables
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  // Animation variables
  late AnimationController _sendBtnAnimationController;
  late Animation<double> _sendBtnScaleAnimation;
  late Animation<double> _sendBtnOpacityAnimation;
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();

    // ✅ Request mic permission before using speech
    requestMicPermission();

    initSpeech();

    _sendBtnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sendBtnScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _sendBtnAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _sendBtnOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _sendBtnAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _showSendButton) {
        setState(() {
          _showSendButton = hasText;
        });
        if (hasText) {
          _sendBtnAnimationController.forward();
        } else {
          _sendBtnAnimationController.reverse();
        }
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showScrollToBottomBtn) {
        setState(() => _showScrollToBottomBtn = true);
      } else if (_scrollController.offset <= 200 && _showScrollToBottomBtn) {
        setState(() => _showScrollToBottomBtn = false);
      }
    });
  }
  void initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _sendBtnAnimationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    isTyping = true;


    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _messages.insert(0, ChatMessage(text: "", isUser: false, isTyping: true));
    });

    _controller.clear();
    _scrollToBottom();

    sendMessageToMitra(text).then((botReply) {
      setState(() {
        _messages.removeAt(0);
        _messages.insert(0, ChatMessage(text: botReply, isUser: false));
      });
      _scrollToBottom();
    }).catchError((error) {
      setState(() {
        _messages.removeAt(0);
        _messages.insert(0, ChatMessage(text: "❌ Error: $error", isUser: false));
      });
      _scrollToBottom();
    });
  }

  final Map<String, String> modelUrls = {
    'Gemini': "https://chat-api-g1zt.onrender.com/gemini",
    'GPT': "https://chat-api-g1zt.onrender.com/chatgpt",
  };

  Future<String> sendMessageToMitra(String userMessage) async {
    stopTypingRequested = false;
    isTyping = true;

    final apiUrl = SelectedModel.url;
    debugPrint("🚀 Sending to: $apiUrl");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}), // no "model" field needed
      );

      if (stopTypingRequested) {
        return "⏹️ Response stopped.";
      }

      isTyping = false;

      if (response.statusCode == 200) {        // ✅ correct success code
        final data = jsonDecode(response.body);
        // Your FastAPI returns {"reply": "..."}
        return (data["reply"] as String?) ?? "⚠️ No reply from server.";
      } else {
        _showError(context, "Server error: ${response.statusCode}");
        return "⚠️ Server returned error.";
      }

    } on SocketException {
      isTyping = false;
      _showError(context, "Please check your internet connection.");
      return "📡 No internet connection.";
    } catch (e) {
      isTyping = false;
      _showError(context, "Something went wrong.");
      return "⚠️ Unexpected error occurred.";
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleVoiceInput() async {
    if (!_speechEnabled) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _isListening = true;
        _wordsSpoken = "";
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _wordsSpoken = result.recognizedWords;
            _confidenceLevel = result.confidence;
            _controller.text = _wordsSpoken;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: "en_US",
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }

  void _showVoiceWaveform() {
    print('Show voice waveform');
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mitra AI'),
        actions: [
          LogoButton(
            onModelSelected: (selectedModel) {
              setState(() {
                _selectedModel = selectedModel; // "Gemini" or "GPT"
              });
              debugPrint("✅ Model changed to $_selectedModel");
            },
          ),

        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];

                      if (message.isTyping) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: TypingIndicator(),
                        );
                      }
                      final isLastBotMessage = !message.isUser && index == 0;
                      return ChatBubble(
                        text: message.text,
                        isUser: message.isUser,
                        animateBotText: isLastBotMessage,
                      );
                    },
                  ),
                ),
                SearchBox(
                  controller: _controller,
                  focusNode: _focusNode,
                  isTyping: isTyping,
                  showSendButton: _showSendButton,
                  isListening: _isListening,
                  sendBtnScaleAnimation: _sendBtnScaleAnimation,
                  sendBtnOpacityAnimation: _sendBtnOpacityAnimation,
                  onSend: _handleSend,
                  onStopTyping: () {
                    setState(() {
                      stopTypingRequested = true;
                      isTyping = false;
                    });
                  },
                  onToggleVoiceInput: _toggleVoiceInput,
                  onShowVoiceWaveform: _showVoiceWaveform,
                ),
              ],
            ),
            if (_showScrollToBottomBtn)
              Positioned(
                bottom: 80, // Just above the SearchBox
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Icon(Icons.arrow_downward, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Mitra AI Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation1 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    _animation2 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.7, curve: Curves.easeInOut)),
    );

    _animation3 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white70.withOpacity(animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF2F2F2F),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(18),
          topLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(width: 10),
          _buildDot(_animation1),
          _buildDot(_animation2),
          _buildDot(_animation3),
        ],
      ),
    );
  }
}