import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

// Manages quiz lifecycle: loading, selection, scoring, and navigation.
class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _questions = [];
  bool _loading = true;
  String? _error;

  int _currentIndex = 0;
  String? _selectedAnswer;
  List<String?> _selectedAnswers = [];
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // Fetch questions and reset local quiz state.
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
      _questions = [];
      _currentIndex = 0;
      _selectedAnswer = null;
      _selectedAnswers = [];
      _score = 0;
    });
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _selectedAnswers = List<String?>.filled(questions.length, null);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch questions. Please try again.';
        _loading = false;
      });
    }
  }

  // Select a single answer for current question.
  void _onSelect(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _selectedAnswers[_currentIndex] = answer;
    });
  }

  // Proceed to next question only if an answer is selected; compute score.
  void _onNext() {
    if (_selectedAnswer == null) return;
    final current = _questions[_currentIndex];
    final isCorrect = _selectedAnswer == current.correctAnswer;
    final newScore = _score + (isCorrect ? 1 : 0);
    if (_currentIndex == _questions.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            questions: _questions,
            userAnswers: _selectedAnswers.map((e) => e ?? '').toList(),
            score: newScore,
          ),
        ),
      );
    } else {
      setState(() {
        _score = newScore;
        _currentIndex++;
        _selectedAnswer = null;
      });
    }
  }

  // Removed unused computeScore helper since score updates on Next.

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final scheme = Theme.of(context).colorScheme;
      return Scaffold(
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
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetch,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F469A),
        foregroundColor: Colors.white,
        title: Text('Question ${_currentIndex + 1} / ${_questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                q.question,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: q.allAnswers.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index < q.allAnswers.length) {
                    final answer = q.allAnswers[index];
                    final selected = _selectedAnswer == answer;
                    return _AnswerOptionTile(
                      text: answer,
                      selected: selected,
                      onTap: () => _onSelect(answer),
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F469A).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF0F469A)),
                          ),
                          child: Text(
                            '$_score/${_questions.length}',
                            style: const TextStyle(
                              color: Color(0xFF0F469A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 135),
                        SizedBox(
                          width: 130,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F469A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _selectedAnswer == null ? null : _onNext,
                            child: Text(
                              _currentIndex == _questions.length - 1
                                  ? 'Finish'
                                  : 'Next',
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _AnswerOptionTile({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF0F469A) : Colors.grey.shade300,
          width: selected ? 0 : 1,
        ),
        color: selected ? const Color(0xFF0F469A) : scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
            blurRadius: selected ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }
}
