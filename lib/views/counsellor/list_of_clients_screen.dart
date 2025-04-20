import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_controller.dart';
import 'package:jooyful_heaven/models/user_model.dart';

class MyClientsScreen extends StatelessWidget {
  final CounselorController controller = Get.find<CounselorController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Clients')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.assignedClients.isEmpty) {
          return const Center(
            child: Text(
              'No clients assigned to you yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.assignedClients.length,
          itemBuilder: (context, index) {
            final client = controller.assignedClients[index];
            return _buildClientTile(client);
          },
        );
      }),
    );
  }

  Widget _buildClientTile(UserModel client) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Text(
            client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(client.email, style: TextStyle(color: Colors.grey[600])),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
              onPressed: () {
                controller.selectClient(client);
                // Pass clientId directly in the arguments
                Get.toNamed(
                  '/counselor/chat',
                  arguments: {'clientId': client.uid},
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.description_outlined, color: Colors.green),
              onPressed: () {
                // Navigate to client test details screen
                Get.toNamed(
                  '/counselor/client-test-details',
                  arguments: client,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
