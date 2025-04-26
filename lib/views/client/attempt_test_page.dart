import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jooyful_heaven/models/psychological_test_model.dart';

class AttemptTestPage extends StatefulWidget {
  final PsychologicalTest test;

  const AttemptTestPage({Key? key, required this.test}) : super(key: key);

  @override
  _AttemptTestPageState createState() => _AttemptTestPageState();
}

class _AttemptTestPageState extends State<AttemptTestPage> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  bool _testCompleted = false;
  int _totalScore = 0;
  String _resultDescription = '';

  @override
  void initState() {
    super.initState();
    // Initialize selected answers list with nulls (no selection)
    _selectedAnswers = List<int?>.filled(widget.test.questions.length, null);
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.test.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishTest() {
    // Check if all questions are answered
    if (_selectedAnswers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before finishing'),
        ),
      );
      return;
    }

    // Calculate total score
    int score = 0;
    for (int i = 0; i < _selectedAnswers.length; i++) {
      final questionAnswers = widget.test.questions[i].answers;
      final selectedAnswerIndex = _selectedAnswers[i]!;
      score += questionAnswers[selectedAnswerIndex].score;
    }

    // Determine result based on score ranges
    String resultText = '';
    for (var range in widget.test.resultRanges) {
      if (score >= range.minScore && score <= range.maxScore) {
        resultText = range.description;
        break;
      }
    }

    // If no range matches, use the closest one
    if (resultText.isEmpty && widget.test.resultRanges.isNotEmpty) {
      widget.test.resultRanges.sort((a, b) {
        int aDiff = (score - a.minScore).abs() + (score - a.maxScore).abs();
        int bDiff = (score - b.minScore).abs() + (score - b.maxScore).abs();
        return aDiff.compareTo(bDiff);
      });
      resultText = widget.test.resultRanges.first.description;
    }

    // Save test result to Firebase
    _saveTestResult(score, resultText);

    setState(() {
      _testCompleted = true;
      _totalScore = score;
      _resultDescription = resultText;
    });
  }

  Future<void> _saveTestResult(int score, String resultText) async {
    try {
      final userId =
          "current_user_id"; // Replace with actual user ID from your auth system

      final resultData = {
        'testId': widget.test.id,
        'testTitle': widget.test.title,
        'userId': userId,
        'completedAt': ServerValue.timestamp,
        'score': score,
        'result': resultText,
        'answers':
            _selectedAnswers
                .map(
                  (index) =>
                      index != null
                          ? widget
                              .test
                              .questions[_selectedAnswers.indexOf(index)]
                              .answers[index]
                              .text
                          : '',
                )
                .toList(),
      };

      final databaseRef = FirebaseDatabase.instance.ref();
      await databaseRef.child('test_results').push().set(resultData);
    } catch (e) {
      print('Error saving test result: $e');
    }
  }

  void _restartTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers = List<int?>.filled(widget.test.questions.length, null);
      _testCompleted = false;
      _totalScore = 0;
      _resultDescription = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test.title),
        actions: [
          if (!_testCompleted)
            TextButton(
              onPressed: _finishTest,
              child: const Text(
                'Finish',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _testCompleted ? _buildResultScreen() : _buildQuestionScreen(),
    );
  }

  Widget _buildQuestionScreen() {
    final question = widget.test.questions[_currentQuestionIndex];
    final selectedAnswerIndex = _selectedAnswers[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.test.questions.length,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.test.questions.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question text
          Text(
            question.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),

          // Answer options
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.answers.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: selectedAnswerIndex == index ? 4 : 1,
                color:
                    selectedAnswerIndex == index
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : null,
                child: InkWell(
                  onTap: () => _selectAnswer(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: selectedAnswerIndex,
                          onChanged: (value) => _selectAnswer(value!),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.answers[index].text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentQuestionIndex > 0)
                ElevatedButton.icon(
                  onPressed: _previousQuestion,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                )
              else
                const SizedBox(width: 100),

              if (_currentQuestionIndex < widget.test.questions.length - 1)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Next'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: 180, // Adjust this width as needed
                  child: ElevatedButton(
                    onPressed: _finishTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Complete Test'),
                        SizedBox(width: 8),
                        Icon(Icons.check_circle),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    // Find the appropriate color based on score
    Color resultColor;
    if (_resultDescription.toLowerCase().contains('severe') ||
        _resultDescription.toLowerCase().contains('high')) {
      resultColor = Colors.red[700]!;
    } else if (_resultDescription.toLowerCase().contains('moderate') ||
        _resultDescription.toLowerCase().contains('mild')) {
      resultColor = Colors.orange[700]!;
    } else {
      resultColor = Colors.green[700]!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Test Completed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Your Score: $_totalScore',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: resultColor, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _resultDescription,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _restartTest,
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Test'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back to Tests'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
