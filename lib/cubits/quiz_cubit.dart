import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(const QuizState());

  Future<void> loadQuestions() async {
    emit(state.copyWith(status: QuizStatus.loading));
    try {
      final questions = await ApiService.fetchQuestions();
      emit(state.copyWith(
        status: QuizStatus.success,
        questions: questions,
        currentIndex: 0,
        answers: {},
      ));
    } catch (e) {
      emit(state.copyWith(status: QuizStatus.error, errorMessage: e.toString()));
    }
  }

  void selectAnswer(String answer) {
    if (state.status != QuizStatus.success) return;
    final newAnswers = Map<int, String>.from(state.answers);
    newAnswers[state.currentIndex] = answer;
    emit(state.copyWith(answers: newAnswers));
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }
}
