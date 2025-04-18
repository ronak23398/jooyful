import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/owner_controller.dart';
import '../../routes/app_routes.dart';
import '../../models/user_model.dart';

class AllClientsScreen extends GetView<OwnerController> {
  AllClientsScreen({super.key});

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<UserModel> filteredClients = <UserModel>[].obs;

  @override
  Widget build(BuildContext context) {
    // Initialize filtered list with all clients
    filteredClients.value = controller.clients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAllUsers(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  suffixIcon: Obx(
                    () =>
                        searchQuery.value.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                                filteredClients.value = controller.clients;
                              },
                            )
                            : const SizedBox.shrink(),
                  ),
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                  if (value.isEmpty) {
                    filteredClients.value = controller.clients;
                  } else {
                    filteredClients.value =
                        controller.clients.where((client) {
                          final name = client.name.toLowerCase();
                          final email = client.email.toLowerCase();
                          final query = value.toLowerCase();
                          return name.contains(query) || email.contains(query);
                        }).toList();
                  }
                },
              ),
            ),

            // Client count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      '${filteredClients.length} clients',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () =>
                        controller.pendingRequests.isNotEmpty
                            ? Flexible(
                              // Add this wrapper
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.assignment_ind),
                                label: Text(
                                  '${controller.pendingRequests.length} Pending Requests',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[100],
                                  foregroundColor: Colors.amber[800],
                                ),
                                onPressed:
                                    () =>
                                        Get.toNamed(AppRoutes.ASSIGN_COUNSELOR),
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Clients list
            Expanded(
              child: Obx(() {
                if (filteredClients.isEmpty) {
                  return const Center(
                    child: Text(
                      'No clients found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredClients.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return _buildClientCard(client, context);
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildClientCard(UserModel client, BuildContext context) {
    bool hasCounselor =
        client.assignedCounselorId != null &&
        client.assignedCounselorId!.isNotEmpty;
    UserModel? assignedCounselor;

    if (hasCounselor) {
      try {
        assignedCounselor = controller.counselors.firstWhere(
          (counselor) => counselor.uid == client.assignedCounselorId,
        );
      } catch (_) {
        hasCounselor = false;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    client.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        client.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showClientOptions(context, client);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child:
                      hasCounselor
                          ? Text(
                            'Assigned to: ${assignedCounselor!.name}',
                            style: const TextStyle(fontSize: 14),
                          )
                          : const Text(
                            'No counselor assigned',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                ),
                hasCounselor
                    ? TextButton.icon(
                      icon: const Icon(Icons.person_remove, size: 16),
                      label: const Text('Unassign'),
                      onPressed: () {
                        _confirmUnassignCounselor(context, client);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    )
                    : TextButton.icon(
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Assign'),
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.ASSIGN_COUNSELOR,
                          arguments: {'clientId': client.uid},
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClientOptions(BuildContext context, UserModel client) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to detailed profile view
                  // Get.toNamed(AppRoutes.CLIENT_DETAIL, arguments: client);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('View Test Results'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to test results
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red[700]),
                title: Text(
                  'Remove Client',
                  style: TextStyle(color: Colors.red[700]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteClient(context, client);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmUnassignCounselor(BuildContext context, UserModel client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unassign Counselor'),
          content: const Text(
            'Are you sure you want to unassign the counselor from this client?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.unassignCounselor(client.uid);
              },
              child: const Text('UNASSIGN'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteClient(BuildContext context, UserModel client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Client'),
          content: Text(
            'Are you sure you want to remove ${client.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement delete functionality
                // controller.deleteClient(client.uid);
                Get.snackbar(
                  'Not Implemented',
                  'Delete functionality not implemented yet',
                );
              },
              child: const Text('REMOVE'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
