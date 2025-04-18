class TestResultModel {
  final String id;
  final String testId;
  final String testName;
  final int score;
  final int maxScore;
  final DateTime timestamp;
  final String? counselorComment;
  
  TestResultModel({
    required this.id,
    required this.testId,
    required this.testName,
    required this.score,
    required this.maxScore,
    required this.timestamp,
    this.counselorComment,
  });
  
  factory TestResultModel.fromMap(Map<String, dynamic> map, String id) {
    return TestResultModel(
      id: id,
      testId: map['testId'] ?? '',
      testName: map['testName'] ?? '',
      score: map['score'] ?? 0,
      maxScore: map['maxScore'] ?? 0,
      timestamp: map['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
        : DateTime.now(),
      counselorComment: map['counselorComment'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'testName': testName,
      'score': score,
      'maxScore': maxScore,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'counselorComment': counselorComment,
    };
  }
}