import 'package:html_unescape/html_unescape.dart';

// Model representing a single quiz question returned from Open Trivia DB.
// Decodes HTML entities and builds a shuffled list of answer options.
class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allAnswers,
  });

  // Creates a QuizQuestion from the Open Trivia DB response map.
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    final unescape = HtmlUnescape();
    final question = unescape.convert(map['question'] as String);
    final correct = unescape.convert(map['correct_answer'] as String);
    final incorrect = (map['incorrect_answers'] as List<dynamic>)
        .map((e) => unescape.convert(e as String))
        .toList();

    // Prepare 4 options (3 incorrect + 1 correct) and shuffle them.
    final answers = [...incorrect, correct]..shuffle();
    return QuizQuestion(
      question: question,
      correctAnswer: correct,
      incorrectAnswers: incorrect,
      allAnswers: answers,
    );
  }
}
