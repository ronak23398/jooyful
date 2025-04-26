import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/models/psychological_test_model.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';
import 'package:firebase_database/firebase_database.dart';

class TestsSection extends StatefulWidget {
  const TestsSection({
    Key? key,
  }) : super(key: key);

  @override
  State<TestsSection> createState() => _TestsSectionState();
}

class _TestsSectionState extends State<TestsSection> {
  final RxList<PsychologicalTest> tests = <PsychologicalTest>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    loadTests();
  }

  Future<void> loadTests() async {
    isLoading.value = true;
    
    try {
      final ref = FirebaseDatabase.instance.ref().child('tests');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final loadedTests = <PsychologicalTest>[];
        final map = snapshot.value as Map<dynamic, dynamic>;

        map.forEach((key, value) {
          final testData = Map<String, dynamic>.from(value as Map);
          final test = PsychologicalTest.fromMap(testData, key);
          loadedTests.add(test);
        });

        // Sort tests by creation date (newest first)
        loadedTests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        tests.value = loadedTests;
      }
    } catch (e) {
      print("Error loading tests: $e");
    } finally {
      isLoading.value = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Psychological Tests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.LIST_OF_TESTS),
              child: Text(
                'View All Tests',
                style: TextStyle(
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Obx(() => isLoading.value
            ? Center(
                child: Container(
                  height: 150,
                  child: CircularProgressIndicator(),
                ),
              )
            : tests.isEmpty
                ? Center(
                    child: Container(
                      height: 150,
                      child: Text('No tests available'),
                    ),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        return Container(
                          width: 200,
                          margin: EdgeInsets.only(right: 12),
                          child: Card(
                            color: Colors.purple.shade50,
                            child: InkWell(
                              onTap: () => Get.toNamed(
                                AppRoutes.TEST_SCREEN,
                                arguments: {'testId': test.id},
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.psychology, color: Colors.purple),
                                    SizedBox(height: 8),
                                    Text(
                                      test.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Expanded(
                                      child: Text(
                                        test.description,
                                        style: TextStyle(fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${test.questions.length} questions',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }
}