// File: lib/models/psychological_test_models.dart

class PsychologicalTest {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<Question> questions;
  final List<ResultRange> resultRanges;
  
  PsychologicalTest({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.questions,
    required this.resultRanges,
  });
  
  factory PsychologicalTest.fromMap(Map<String, dynamic> map, String id) {
    return PsychologicalTest(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      questions: (map['questions'] as List).map((q) => Question.fromMap(Map<String, dynamic>.from(q))).toList(),
      resultRanges: (map['resultRanges'] as List).map((r) => ResultRange.fromMap(Map<String, dynamic>.from(r))).toList(),
    );
  }
}

class Question {
  late final String text;
  final List<Answer> answers;
  
  Question({required this.text, required this.answers});
  
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'] ?? '',
      answers: (map['answers'] as List).map((a) => Answer.fromMap(Map<String, dynamic>.from(a))).toList(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }
}

class Answer {
  late final String text;
  late final int score;
  
  Answer({required this.text, required this.score});
  
  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      text: map['text'] ?? '',
      score: map['score'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'score': score,
    };
  }
}

class ResultRange {
  final int minScore;
  final int maxScore;
  final String description;
  
  ResultRange({required this.minScore, required this.maxScore, required this.description});
  
  factory ResultRange.fromMap(Map<String, dynamic> map) {
    return ResultRange(
      minScore: map['minScore'] ?? 0,
      maxScore: map['maxScore'] ?? 0,
      description: map['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'minScore': minScore,
      'maxScore': maxScore,
      'description': description,
    };
  }
}

