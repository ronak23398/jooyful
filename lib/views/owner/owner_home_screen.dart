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
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: () async {
                    // Refresh all data when pulled
                    await controller.fetchAllUsers();
                    await controller.fetchCounselorRequests();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Important to make refresh work even when content doesn't scroll
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${authController.userModel.value?.name ?? "Owner"}!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Manage your mental health platform from here.',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          
                              
                            
                          
                          const SizedBox(height: 24),
                          // Stats section
                          Row(
                            children: [
                              _buildStatCard(
                                'Clients',
                                controller.clientCount.toString(),
                                Colors.green.shade100,
                                Icons.people,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Counselors',
                                controller.counselorCount.toString(),
                                Colors.orange.shade100,
                                Icons.medical_services,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                'Interns',
                                controller.internCount.toString(),
                                Colors.purple.shade100,
                                Icons.school,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Counselor requests alert
                          Obx(() {
                            if (controller.pendingRequests.isNotEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_active,
                                      color: Colors.amber.shade800,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${controller.pendingRequests.length} clients requesting counselor assignment',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Get.toNamed(
                                            AppRoutes.ASSIGN_COUNSELOR,
                                          ),
                                      child: const Text('HANDLE'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),

                          const SizedBox(height: 32),

                          // Navigation buttons
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            'View All Clients',
                            Icons.people,
                            Colors.green,
                            () => Get.toNamed(AppRoutes.ALL_CLIENTS),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            'View All Counselors',
                            Icons.medical_services,
                            Colors.orange,
                            () => Get.toNamed(AppRoutes.ALL_COUNSELORS),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            'View All Interns',
                            Icons.school,
                            Colors.purple,
                            () => Get.toNamed(AppRoutes.ALL_INTERNS),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            'Upload Article/Resource',
                            Icons.upload_file,
                            Colors.blue,
                            () => Get.toNamed(AppRoutes.UPLOAD_ARTICLE),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            'View all Tests',
                            Icons.book,
                            Colors.blue,
                            () => Get.toNamed(AppRoutes.LIST_OF_TESTS),
                          ),
                          // Add extra padding at bottom to allow overscroll for refresh
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
