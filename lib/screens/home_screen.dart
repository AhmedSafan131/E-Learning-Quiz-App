import 'package:flutter/material.dart';
import 'quiz_screen.dart';

// Simple landing screen with app title and Start Quiz CTA.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.15),
                    scheme.surfaceTint.withValues(alpha: 0.08),
                    scheme.secondary.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -40,
            child: _Blob(
              color: const Color(0xFF0F469A).withValues(alpha: 0.25),
              size: 250,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: _Blob(
              color: const Color(0xFF0F469A).withValues(alpha: 0.25),
              size: 250,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/start.png',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 120),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F469A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(_slideFade(const QuizScreen()));
                      },
                      child: const Text('Start Quiz'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PageRoute _slideFade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
                begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.46),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
