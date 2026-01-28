import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quiz_question.dart';

// Service layer that fetches quiz questions from Open Trivia DB using http.
class ApiService {
  static const _endpoint =
      'https://opentdb.com/api.php?amount=10&type=multiple';

  // Fetches 10 multiple-choice questions and maps them into model objects.
  static Future<List<QuizQuestion>> fetchQuestions() async {
    final uri = Uri.parse(_endpoint);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load questions');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>?) ?? [];
    if (results.isEmpty) {
      throw Exception('No questions received');
    }
    return results
        .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
