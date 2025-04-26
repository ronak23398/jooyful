import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/models/psychological_test_model.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';
import 'package:jooyful_heaven/views/client/attempt_test_page.dart';

class ListOfTestsPage extends StatefulWidget {
  const ListOfTestsPage({super.key});

  @override
  _ListOfTestsPageState createState() => _ListOfTestsPageState();
}

class _ListOfTestsPageState extends State<ListOfTestsPage> {
  bool _isLoading = true;
  List<PsychologicalTest> _tests = [];

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future<void> _loadTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ref = FirebaseDatabase.instance.ref().child('tests');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final List<PsychologicalTest> tests = [];
        final map = snapshot.value as Map<dynamic, dynamic>;

        map.forEach((key, value) {
          final testData = Map<String, dynamic>.from(value as Map);
          final test = PsychologicalTest.fromMap(testData, key);
          tests.add(test);
        });

        // Sort tests by creation date (newest first)
        tests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          _tests = tests;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tests: ${e.toString()}')),
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
      appBar: AppBar(title: const Text('Psychological Tests')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tests.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No tests available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTests,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadTests,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tests.length,
                  itemBuilder: (context, index) {
                    final test = _tests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.TEST_SCREEN,
                            arguments: {'testId': test.id, 'test': test},
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                test.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.question_answer, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${test.questions.length} questions'),
                                  const Spacer(),
                                  // Wrap with SizedBox to provide width constraints
                                  SizedBox(
                                    width: 100, // Adjust this value as needed
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    AttemptTestPage(test: test),
                                          ),
                                        );
                                      },
                                      child: const Text('Start Test'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
