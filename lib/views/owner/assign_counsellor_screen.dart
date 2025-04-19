import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/owner_controller.dart';
import '../../models/user_model.dart';

class AssignCounselorScreen extends GetView<OwnerController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Counselors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.pendingRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'No pending counselor requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('All clients have been assigned counselors'),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.pendingRequests.length,
          itemBuilder: (context, index) {
            final request = controller.pendingRequests[index];
            final clientId = request['clientId'];
            
            // Find the client from the clientId
            final client = controller.clients.firstWhere(
              (c) => c.uid == clientId,
              orElse: () => UserModel(
                uid: clientId,
                name: 'Unknown Client',
                email: '',
                role: 'client',
                createdAt: DateTime.now(),
              ),
            );
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Email: ${client.email}'),
                    if (client.phoneNumber != null)
                      Text('Phone: ${client.phoneNumber}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a Counselor:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildCounselorSelection(clientId),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
  
  Widget _buildCounselorSelection(String clientId) {
    // If no counselors are available
    if (controller.counselors.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No counselors available. Please add counselors first.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(
              controller.counselors.length > 3 ? 3 : controller.counselors.length,
              (index) {
                final counselor = controller.counselors[index];
                // Replace the ListTile with a custom Row to avoid the width constraint issues
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      // Leading - Avatar
                      CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.medical_services, color: Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      // Title and subtitle - Expanded to take remaining space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              counselor.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              counselor.email,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Trailing - Button
                      SizedBox(
                        width: 80, // Fixed width for the button
                        child: ElevatedButton(
                          onPressed: () => _assignCounselor(clientId, counselor.uid),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Assign'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (controller.counselors.length > 3)
          TextButton(
            onPressed: () => _showAllCounselorsDialog(clientId),
            child: const Text('View All Counselors'),
          ),
      ],
    );
  }
  
  void _assignCounselor(String clientId, String counselorId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Assignment'),
        content: const Text('Are you sure you want to assign this counselor to the client?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.assignCounselor(clientId, counselorId);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
  
  void _showAllCounselorsDialog(String clientId) {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Select Counselor'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.counselors.length,
                  itemBuilder: (context, index) {
                    final counselor = controller.counselors[index];
                    // Also fix the ListTile in the dialog with the same approach
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.medical_services, color: Colors.orange),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  counselor.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  counselor.email,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                _assignCounselor(clientId, counselor.uid);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Assign'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}