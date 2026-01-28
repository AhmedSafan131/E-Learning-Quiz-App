import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import 'home_screen.dart';

// Shows final score and per-question review with clear correct/incorrect highlights.
class ResultScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final List<String> userAnswers;
  final int score;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F469A),
        foregroundColor: Colors.white,
        title: const Text('Results'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.12),
                    scheme.secondary.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: _ScoreBadge(score: score, total: questions.length)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: questions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      final user = userAnswers[index];
                      final isCorrect = user == q.correctAnswer;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q.question,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: q.allAnswers.map((a) {
                                final selected = a == user;
                                final correct = a == q.correctAnswer;
                                Color? color;
                                if (selected) {
                                  color = isCorrect ? Colors.green : Colors.red;
                                } else if (correct) {
                                  color = Colors.green.withValues(alpha: 0.2);
                                }
                                return Chip(
                                  label: Text(a),
                                  backgroundColor: color,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Correct answer: ${q.correctAnswer}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F469A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake Quiz'),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionsBuilder:
                              (_, animation, secondaryAnimation, child) {
                            final slide = Tween<Offset>(
                                    begin: const Offset(0, 0.04),
                                    end: Offset.zero)
                                .animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic));
                            final fade = CurvedAnimation(
                                parent: animation, curve: Curves.easeOut);
                            return FadeTransition(
                              opacity: fade,
                              child: SlideTransition(
                                  position: slide, child: child),
                            );
                          },
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final int total;
  const _ScoreBadge({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    const outer = Color(0xFF3D76D0);
    const inner = Color(0xFF0F469A);
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: outer,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: inner,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$score/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
