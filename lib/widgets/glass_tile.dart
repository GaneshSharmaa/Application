import 'dart:ui';
import 'package:flutter/material.dart';

class GlassTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Animation<Offset>? slideAnimation;
  final Animation<double>? fadeAnimation;

  const GlassTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.slideAnimation,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
      child: FadeTransition(
        opacity: fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            children: [
              // 🔹 Blurred background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),

              // 🔹 Foreground with ripple effect
              Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(50),
                  onTap: onTap,
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}