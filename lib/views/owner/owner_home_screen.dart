import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import '../../controllers/owner_controller.dart';
import '../../routes/app_routes.dart';

class OwnerHomeScreen extends GetView<OwnerController> {
  final AuthController authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value 
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${authController.userModel.value?.name ?? "Owner"}!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your mental health platform from here.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Stats section
                Row(
                  children: [
                    _buildStatCard('Clients', controller.clients.length.toString(), Colors.green.shade100, Icons.people),
                    SizedBox(width: 12),
                    _buildStatCard('Counselors', controller.counselors.length.toString(), Colors.orange.shade100, Icons.medical_services),
                    SizedBox(width: 12),
                    _buildStatCard('Interns', controller.interns.length.toString(), Colors.purple.shade100, Icons.school),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Counselor requests alert
                if (controller.counselorRequests.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.amber.shade800),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${controller.counselorRequests.length} clients requesting counselor assignment',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.ASSIGN_COUNSELOR),
                          child: Text('HANDLE'),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 32),
                
                // Navigation buttons
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildActionButton(
                  'View All Clients',
                  Icons.people,
                  Colors.green,
                  () => Get.toNamed(AppRoutes.ALL_CLIENTS),
                ),
                SizedBox(height: 12),
                _buildActionButton(
                  'View All Counselors',
                  Icons.medical_services,
                  Colors.orange,
                  () => Get.toNamed(AppRoutes.ALL_COUNSELORS),
                ),
                SizedBox(height: 12),
                _buildActionButton(
                  'View All Interns',
                  Icons.school,
                  Colors.purple,
                  () => Get.toNamed(AppRoutes.ALL_INTERNS),
                ),
                SizedBox(height: 12),
                _buildActionButton(
                  'Upload Article/Resource',
                  Icons.upload_file,
                  Colors.blue,
                  () => Get.toNamed(AppRoutes.UPLOAD_ARTICLE),
                ),
              ],
            ),
          ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 16)),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}