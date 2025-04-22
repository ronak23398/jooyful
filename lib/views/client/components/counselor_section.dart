import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/routes/app_routes.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_controllers.dart';

class CounselorSection extends StatelessWidget {
  final ClientController controller;
  final UserModel? counselor; 
  final String assignedCounselorId;
  final bool hasCounselorRequest;
  
  const CounselorSection({
    super.key,
    required this.controller,
    this.counselor,
    required this.assignedCounselorId,
    required this.hasCounselorRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Your Counselor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (assignedCounselorId.isNotEmpty && counselor != null)
              // Counselor is assigned
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              counselor!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('Professional Counselor'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.chat),
                          label: Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Get.toNamed(
                            AppRoutes.CHAT_SCREEN,
                            arguments: {'counselorId': assignedCounselorId}
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text('Appointment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: (){},
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else if (hasCounselorRequest)
              // Request is pending
              Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_top, size: 40, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'Counselor request is pending',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber.shade800,
                      ),
                    ),
                    Text(
                      'We will assign you a counselor soon',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              // No counselor yet
              Center(
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No counselor assigned yet',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.requestCounselor(),
                      child: Text('Request a Counselor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}