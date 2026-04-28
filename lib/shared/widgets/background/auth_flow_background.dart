import 'dart:ui';

import 'package:flutter/material.dart';

class AuthFlowBackground extends StatelessWidget {
  const AuthFlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -90,
          top: -120,
          child: SizedBox(
            width: 210,
            height: 210,
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      color: const Color(0x0D0066CC),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    color: const Color(0x0D0066CC),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -90,
          bottom: -90,
          child: SizedBox(
            width: 156,
            height: 353,
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: 156,
                    height: 353,
                    decoration: BoxDecoration(
                      color: const Color(0x1A0066CC),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                Container(
                  width: 156,
                  height: 353,
                  decoration: BoxDecoration(
                    color: const Color(0x1A0066CC),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AuthBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const AuthBackgroundWrapper({super.key, required this.child});

  static const Color glowColor = Color(0x1A0066CC); // #0066CC1A

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(color: Colors.white),

        // TOP-LEFT BLUR
        const Positioned(
          top: -80,
          left: -80,
          child: _BlurCircle(size: 220, color: glowColor),
        ),

        // BOTTOM-RIGHT BLUR
        const Positioned(
          bottom: -80,
          right: -80,
          child: _BlurCircle(size: 260, color: glowColor),
        ),

        // CONTENT
        child,
      ],
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
