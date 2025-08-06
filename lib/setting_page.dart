import 'package:flutter/material.dart';
import 'package:mitra/widgets/glass_tile.dart';
// import 'glass_tile.dart'; // Your animated ripple tile with glass effect

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers = [];
  late final List<Animation<Offset>> _offsetAnimations = [];

  final List<Map<String, dynamic>> _settings = [
    {'icon': Icons.account_circle_outlined, 'title': 'User'},
    {'icon': Icons.email_outlined, 'title': 'Email'},
    {'icon': Icons.phone, 'title': 'Phone'},
    {'icon': Icons.stars_sharp, 'title': 'Upgrade to Pro'},
    {'icon': Icons.person, 'title': 'Personalization'},
    {'icon': Icons.security, 'title': 'Security'},
    {'icon': Icons.handshake_outlined, 'title': 'Support'},
    {'icon': Icons.logout, 'title': 'Sign Out', 'color' : Colors.redAccent},
    // {'icon': Icons.dark_mode, 'title': 'Dark Mode'}, // Last one
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers and animations
    for (int i = 0; i < _settings.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      final animation = Tween<Offset>(
        begin: const Offset(0, 0.2), // Slide up from bottom
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );

      _controllers.add(controller);
      _offsetAnimations.add(animation);

      // Start animations with delay
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _settings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final setting = _settings[index];
          return SlideTransition(
            position: _offsetAnimations[index],
            child: FadeTransition(
              opacity: _controllers[index],
              child: GlassTile(
                icon: setting['icon'],
                title: setting['title'],
                onTap: () {
                  // Define your navigation or actions here
                  debugPrint('Tapped: ${setting['title']}');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
