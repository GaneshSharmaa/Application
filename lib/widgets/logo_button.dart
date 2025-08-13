import 'package:flutter/material.dart';
import 'glass_pill.dart';
import 'selected_model.dart';


class LogoButton extends StatefulWidget {
  final List<String> models;
  final Function(String)? onModelSelected;

  const LogoButton({
    super.key,
    this.models = const ['Gemini', 'Claude', 'GPT', 'Grok'],
    this.onModelSelected,
  });

  @override
  State<LogoButton> createState() => _LogoButtonState();
}

class _LogoButtonState extends State<LogoButton> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  // 🧠 Map model to icon path
  final Map<String, String> modelIcons = {
    'Gemini': 'assets/icon/gemini.png',
    'Claude': 'assets/icon/claude.png',
    'GPT': 'assets/icon/gpt.png',
    'Grok': 'assets/icon/grok.png',
  };
  // 🧠 Map model to API URL
  final Map<String, String> modelUrls = {
    'Gemini': "https://chat-api-g1zt.onrender.com/gemini",
    // 'Claude': "https://claude-chat-api.onrender.com",
    'GPT': "https://chat-api-g1zt.onrender.com/chatgpt",
    // 'Grok': "https://grok-chat-api.onrender.com",
  };


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _rotationAnimation = Tween<double>(
      begin: 0.35,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showOverlay();
      _controller.forward();
    } else {
      _controller.reverse().then((_) => _removeOverlay());
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              _controller.reverse().then((_) => _removeOverlay());
            },
            child: IgnorePointer(child: Container(color: Colors.transparent)),
          ),
          Positioned(
            width: 160,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(-110, 45),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.topCenter,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(_rotationAnimation.value),
                          child: child,
                        );
                      },
                      child: IntrinsicWidth(
                        child: Column(
                          children: modelIcons.keys.map((model) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: GlassPill(
                                modelName: model,
                                iconPath: modelIcons[model],
                                  onTap: () {
                                    SelectedModel.setModelUrl(modelUrls[model] ?? SelectedModel.baseUrl);
                                    print("Selected model: $model -> API: ${SelectedModel.url}");
                                  }
                              ),
                            );
                          }).toList(),
                        )
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: ClipOval(
          child: Image.asset(
            'assets/logo.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }
}
