import 'package:equatable/equatable.dart';
import '../models/quiz_question.dart';

enum QuizStatus { initial, loading, success, error }

class QuizState extends Equatable {
  final QuizStatus status;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final Map<int, String> answers; // Map<QuestionIndex, SelectedAnswer>
  final String? errorMessage;

  const QuizState({
    this.status = QuizStatus.initial,
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.errorMessage,
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuizQuestion>? questions,
    int? currentIndex,
    Map<int, String>? answers,
    String? errorMessage,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Computes the score based on the current answers and correct answers.
  int get score {
    int s = 0;
    answers.forEach((index, answer) {
      if (index < questions.length &&
          questions[index].correctAnswer == answer) {
        s++;
      }
    });
    return s;
  }

  /// Computes the score only for questions before the current index.
  int get completedScore {
    int s = 0;
    answers.forEach((index, answer) {
      if (index < currentIndex &&
          index < questions.length &&
          questions[index].correctAnswer == answer) {
        s++;
      }
    });
    return s;
  }

  @override
  List<Object?> get props =>
      [status, questions, currentIndex, answers, errorMessage];
}
