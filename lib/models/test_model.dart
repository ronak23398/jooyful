class TestModel {
  final String id;
  final String title;
  final String description;
  final List<TestQuestion> questions;
  
  TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });
  
  factory TestModel.fromMap(Map<String, dynamic> map, String id) {
    List<TestQuestion> questions = [];
    if (map['questions'] != null) {
      map['questions'].forEach((key, value) {
        questions.add(TestQuestion.fromMap(value, key));
      });
    }
    
    return TestModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions: questions,
    );
  }
  
  Map<String, dynamic> toMap() {
    Map<String, dynamic> questionsMap = {};
    for (var question in questions) {
      questionsMap[question.id] = question.toMap();
    }
    
    return {
      'title': title,
      'description': description,
      'questions': questionsMap,
    };
  }
}

class TestQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  
  TestQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
  
  factory TestQuestion.fromMap(Map<String, dynamic> map, String id) {
    List<String> options = [];
    if (map['options'] != null) {
      map['options'].forEach((option) {
        options.add(option.toString());
      });
    }
    
    return TestQuestion(
      id: id,
      question: map['question'] ?? '',
      options: options,
      correctAnswer: map['correctAnswer'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}