import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/quiz_cubit.dart';
import '../cubits/quiz_state.dart';
import 'result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit()..loadQuestions(),
      child: const _QuizView(),
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView();

  void _onNext(BuildContext context, QuizState state) {
    final selectedAnswer = state.answers[state.currentIndex];

    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer first!')),
      );
      return;
    }

    if (state.currentIndex == state.questions.length - 1) {
      // Finish
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            questions: state.questions,
            userAnswers: List.generate(
              state.questions.length,
              (index) => state.answers[index] ?? '',
            ),
            score: state.score,
          ),
        ),
      );
    } else {
      context.read<QuizCubit>().nextQuestion();
    }
  }

  void _onPrevious(BuildContext context) {
    context.read<QuizCubit>().previousQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        final scheme = Theme.of(context).colorScheme;

        // Loading State
        if (state.status == QuizStatus.loading) {
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

        // Error State
        if (state.status == QuizStatus.error) {
          return Scaffold(
            appBar: AppBar(title: const Text('Quiz Error')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'An error occurred',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<QuizCubit>().loadQuestions(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Empty State
        if (state.questions.isEmpty) {
          return const Scaffold(
              body: Center(child: Text('No questions found.')));
        }

        final q = state.questions[state.currentIndex];
        final selectedAnswer = state.answers[state.currentIndex];
        final isLast = state.currentIndex == state.questions.length - 1;

        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F469A),
            foregroundColor: Colors.white,
            title: Text(
              'Question ${state.currentIndex + 1} / ${state.questions.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Text(
                      q.question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Answers List
                  Expanded(
                    child: ListView.separated(
                      itemCount: q.allAnswers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final answer = q.allAnswers[index];
                        final isSelected = selectedAnswer == answer;
                        return _AnswerOptionTile(
                          text: answer,
                          selected: isSelected,
                          onTap: () =>
                              context.read<QuizCubit>().selectAnswer(answer),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Buttons & Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous Button
                      if (state.currentIndex > 0)
                        SizedBox(
                          width: 100, // Fixed width for equality
                          child: OutlinedButton(
                            onPressed: () => _onPrevious(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF0F469A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(
                                color: Color(0xFF0F469A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                            width:
                                100), // Spacer to balance layout if needed or just empty space

                      // Score & Next Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Score Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F469A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Score: ${state.completedScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Next/Finish Button
                          SizedBox(
                            width: 100, // Fixed width for equality
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F469A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                elevation: 4,
                                shadowColor: const Color(0xFF0F469A)
                                    .withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: selectedAnswer == null
                                  ? null
                                  : () => _onNext(context, state),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLast ? 'Finish' : 'Next',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isLast) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        color: selected ? const Color(0xFF0F469A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.3 : 0.1),
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
