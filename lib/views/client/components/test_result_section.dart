import 'package:flutter/material.dart';

class TestResultsSection extends StatelessWidget {
  final List<dynamic> testResults;
  
  const TestResultsSection({
    super.key,
    required this.testResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Recent Tests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: testResults.length > 2 ? 2 : testResults.length,
          itemBuilder: (context, index) {
            final result = testResults[index];
            final score = result['score'];
            final maxScore = result['maxScore'];
            final percentage = (score / maxScore) * 100;
            
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          result['testName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          result['date'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score / maxScore,
                              minHeight: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage < 30 ? Colors.green : 
                                percentage < 60 ? Colors.amber : Colors.red,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '$score/$maxScore',
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    if (result['counselorComment'] != null) ...[
                      SizedBox(height: 12),
                      Divider(),
                      SizedBox(height: 4),
                      Text(
                        'Counselor Comment:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        result['counselorComment'],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}