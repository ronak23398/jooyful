import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/owner_controller.dart';
import '../../models/user_model.dart';

class AllCounselorsScreen extends GetView<OwnerController> {
  AllCounselorsScreen({Key? key}) : super(key: key);
  
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<UserModel> filteredCounselors = <UserModel>[].obs;

  @override
  Widget build(BuildContext context) {
    // Initialize filtered list with all counselors
    filteredCounselors.value = controller.counselors;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Counselors'),
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
                  hintText: 'Search counselors...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          searchQuery.value = '';
                          filteredCounselors.value = controller.counselors;
                        },
                      )
                    : const SizedBox.shrink(),
                  ),
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                  if (value.isEmpty) {
                    filteredCounselors.value = controller.counselors;
                  } else {
                    filteredCounselors.value = controller.filterCounselors(value);
                  }
                },
              ),
            ),

            // Counselor count
           // Replace the problem area (around line 79-93) with this code:
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Row(
    children: [
      Obx(() => Text(
        '${filteredCounselors.length} counselors',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      )),
      const Spacer(),
      // Fix: Wrap with intrinsic width constraint
      SizedBox(
        width: 150, // Explicit width instead of infinite constraint
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Counselor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[100],
            foregroundColor: Colors.orange[800],
          ),
          onPressed: () {
            // Navigate to add counselor screen or show modal
            Get.snackbar('Not Implemented', 'Add counselor functionality not implemented yet');
          },
        ),
      ),
    ],
  ),
),
            
            const SizedBox(height: 10),
            
            // Counselors list
            Expanded(
              child: Obx(() {
                if (filteredCounselors.isEmpty) {
                  return const Center(
                    child: Text(
                      'No counselors found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredCounselors.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final counselor = filteredCounselors[index];
                    return _buildCounselorCard(counselor, context);
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildCounselorCard(UserModel counselor, BuildContext context) {
    // Calculate assigned clients count
    int assignedClientsCount = controller.clients
        .where((client) => client.assignedCounselorId == counselor.uid)
        .length;
    
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
                  backgroundColor: Colors.orange[100],
                  child: Text(
                    counselor.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.orange[800],
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
                        counselor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        counselor.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showCounselorOptions(context, counselor);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Assigned Clients: $assignedClientsCount',
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Clients'),
                  onPressed: () {
                    _showAssignedClients(context, counselor);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
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
  
  void _showCounselorOptions(BuildContext context, UserModel counselor) {
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
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Details'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit details
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red[700]),
                title: Text('Remove Counselor', style: TextStyle(color: Colors.red[700])),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteCounselor(context, counselor);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAssignedClients(BuildContext context, UserModel counselor) {
    // Get list of clients assigned to this counselor
    final assignedClients = controller.clients
        .where((client) => client.assignedCounselorId == counselor.uid)
        .toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Clients assigned to ${counselor.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${assignedClients.length} clients',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: assignedClients.isEmpty
                    ? Center(
                        child: Text(
                          'No clients assigned',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: assignedClients.length,
                        itemBuilder: (context, index) {
                          final client = assignedClients[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                client.name[0].toUpperCase(),
                                style: TextStyle(color: Colors.blue[800]),
                              ),
                            ),
                            title: Text(client.name),
                            subtitle: Text(client.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove),
                              color: Colors.red[700],
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmUnassignClient(context, client);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _confirmDeleteCounselor(BuildContext context, UserModel counselor) {
    // Check if counselor has assigned clients
    final assignedClientsCount = controller.clients
        .where((client) => client.assignedCounselorId == counselor.uid)
        .length;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Counselor'),
          content: assignedClientsCount > 0
              ? Text('${counselor.name} has $assignedClientsCount assigned clients. You need to reassign these clients before removing this counselor.')
              : Text('Are you sure you want to remove ${counselor.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            if (assignedClientsCount == 0)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement delete functionality
                  Get.snackbar('Not Implemented', 'Delete functionality not implemented yet');
                },
                child: const Text('REMOVE'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
          ],
        );
      },
    );
  }
  
  void _confirmUnassignClient(BuildContext context, UserModel client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unassign Client'),
          content: Text('Are you sure you want to unassign ${client.name} from their counselor?'),
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
}