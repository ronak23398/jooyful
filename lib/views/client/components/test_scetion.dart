import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';

class TestsSection extends StatelessWidget {
  final List<dynamic> tests;
  
  const TestsSection({
    super.key,
    required this.tests,
  });

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
          ],
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: tests.isEmpty
            ? Center(child: Text('No tests available'))
            : ListView.builder(
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
                          arguments: {'testId': test['id']}
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.psychology, color: Colors.purple),
                              SizedBox(height: 8),
                              Text(
                                test['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  test['description'],
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${test['questions']} questions',
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
      ],
    );
  }
}