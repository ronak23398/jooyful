import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({Key? key}) : super(key: key);

  @override
  _CreateTestPageState createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<Question> _questions = [];
  List<ResultRange> _resultRanges = [];
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Add an initial empty question
    _addNewQuestion();
    // Add initial result range
    _addNewResultRange();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _addNewQuestion() {
    setState(() {
      _questions.add(Question(
        text: '',
        answers: [Answer(text: '', score: 0)],
      ));
    });
  }
  
  void _addNewResultRange() {
    setState(() {
      _resultRanges.add(ResultRange(
        minScore: _resultRanges.isEmpty ? 0 : _resultRanges.last.maxScore + 1,
        maxScore: _resultRanges.isEmpty ? 10 : _resultRanges.last.maxScore + 10,
        description: '',
      ));
    });
  }
  
  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test must have at least one question'))
      );
    }
  }
  
  void _removeResultRange(int index) {
    if (_resultRanges.length > 1) {
      setState(() {
        _resultRanges.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test must have at least one result range'))
      );
    }
  }
  
  void _addAnswerToQuestion(int questionIndex) {
    setState(() {
      _questions[questionIndex].answers.add(Answer(text: '', score: 0));
    });
  }
  
  void _removeAnswer(int questionIndex, int answerIndex) {
    if (_questions[questionIndex].answers.length > 1) {
      setState(() {
        _questions[questionIndex].answers.removeAt(answerIndex);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question must have at least one answer'))
      );
    }
  }
  
  Future<void> _saveTest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if all fields are filled
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'))
      );
      return;
    }
    
    // Check if questions and answers are properly set
    for (var question in _questions) {
      if (question.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all question texts'))
        );
        return;
      }
      
      for (var answer in question.answers) {
        if (answer.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all answer texts'))
          );
          return;
        }
      }
    }
    
    // Check if result ranges are properly set
    for (var range in _resultRanges) {
      if (range.description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all result descriptions'))
        );
        return;
      }
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create a map of test data
      final testData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'createdAt': ServerValue.timestamp,
        'questions': _questions.map((q) => q.toMap()).toList(),
        'resultRanges': _resultRanges.map((r) => r.toMap()).toList(),
      };
      
      // Save to Firebase
      final databaseRef = FirebaseDatabase.instance.ref();
      final newTestRef = databaseRef.child('tests').push();
      await newTestRef.set(testData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test created successfully!'))
      );
      
      // Clear form for a new test
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _questions = [Question(text: '', answers: [Answer(text: '', score: 0)])];
        _resultRanges = [ResultRange(minScore: 0, maxScore: 10, description: '')];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving test: ${e.toString()}'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Psychological Test'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Test Basic Information
                const Text(
                  'Test Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Test Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Test Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Questions Section
                const Text(
                  'Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Dynamic list of questions
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, questionIndex) {
                    return _buildQuestionCard(questionIndex);
                  },
                ),
                
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addNewQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Question'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Result Ranges Section
                const Text(
                  'Result Ranges',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Dynamic list of result ranges
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _resultRanges.length,
                  itemBuilder: (context, rangeIndex) {
                    return _buildResultRangeCard(rangeIndex);
                  },
                ),
                
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addNewResultRange,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Result Range'),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saveTest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('Save Test', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  
  Widget _buildQuestionCard(int questionIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${questionIndex + 1}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeQuestion(questionIndex),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _questions[questionIndex].text,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter question text';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _questions[questionIndex].text = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Answer Options:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            // Answers list for this question
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions[questionIndex].answers.length,
              itemBuilder: (context, answerIndex) {
                return _buildAnswerItem(questionIndex, answerIndex);
              },
            ),
            
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _addAnswerToQuestion(questionIndex),
                icon: const Icon(Icons.add),
                label: const Text('Add Answer Option'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnswerItem(int questionIndex, int answerIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: _questions[questionIndex].answers[answerIndex].text,
              decoration: InputDecoration(
                labelText: 'Answer ${answerIndex + 1}',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _questions[questionIndex].answers[answerIndex].text = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: _questions[questionIndex].answers[answerIndex].score.toString(),
              decoration: const InputDecoration(
                labelText: 'Score',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (int.tryParse(value) == null) {
                  return 'Invalid';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _questions[questionIndex].answers[answerIndex].score = int.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _removeAnswer(questionIndex, answerIndex),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultRangeCard(int rangeIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Result Range ${rangeIndex + 1}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeResultRange(rangeIndex),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _resultRanges[rangeIndex].minScore.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Min Score',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _resultRanges[rangeIndex].minScore = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _resultRanges[rangeIndex].maxScore.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Max Score',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _resultRanges[rangeIndex].maxScore = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _resultRanges[rangeIndex].description,
              decoration: const InputDecoration(
                labelText: 'Result Description',
                border: OutlineInputBorder(),
                hintText: 'E.g., No depression, Mild depression, etc.',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _resultRanges[rangeIndex].description = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Model Classes
class Question {
  String text;
  List<Answer> answers;
  
  Question({required this.text, required this.answers});
  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }
  
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'] ?? '',
      answers: (map['answers'] as List).map((a) => Answer.fromMap(a)).toList(),
    );
  }
}

class Answer {
  String text;
  int score;
  
  Answer({required this.text, required this.score});
  
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'score': score,
    };
  }
  
  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      text: map['text'] ?? '',
      score: map['score'] ?? 0,
    );
  }
}

class ResultRange {
  int minScore;
  int maxScore;
  String description;
  
  ResultRange({required this.minScore, required this.maxScore, required this.description});
  
  Map<String, dynamic> toMap() {
    return {
      'minScore': minScore,
      'maxScore': maxScore,
      'description': description,
    };
  }
  
  factory ResultRange.fromMap(Map<String, dynamic> map) {
    return ResultRange(
      minScore: map['minScore'] ?? 0,
      maxScore: map['maxScore'] ?? 0,
      description: map['description'] ?? '',
    );
  }
}