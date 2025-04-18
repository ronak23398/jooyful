import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/owner_controller.dart';
import '../../models/user_model.dart';

class AllInternsScreen extends GetView<OwnerController> {
  AllInternsScreen({Key? key}) : super(key: key);
  
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<UserModel> filteredInterns = <UserModel>[].obs;

  @override
  Widget build(BuildContext context) {
    // Initialize filtered list with all interns
    filteredInterns.value = controller.interns;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Interns'),
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
                  hintText: 'Search interns...',
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
                          filteredInterns.value = controller.interns;
                        },
                      )
                    : const SizedBox.shrink(),
                  ),
                ),
                onChanged: (value) {
                  searchQuery.value = value;
                  if (value.isEmpty) {
                    filteredInterns.value = controller.interns;
                  } else {
                    filteredInterns.value = controller.interns.where((intern) {
                      final name = intern.name.toLowerCase();
                      final email = intern.email.toLowerCase();
                      final query = value.toLowerCase();
                      return name.contains(query) || email.contains(query);
                    }).toList();
                  }
                },
              ),
            ),

            // Intern count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Obx(() => Text(
                    '${filteredInterns.length} interns',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  )),
                  const Spacer(),
                  Flexible(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Intern'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[100],
                        foregroundColor: Colors.purple[800],
                      ),
                      onPressed: () {
                        // Navigate to add intern screen or show modal
                        Get.snackbar('Not Implemented', 'Add intern functionality not implemented yet');
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Interns list
            Expanded(
              child: Obx(() {
                if (filteredInterns.isEmpty) {
                  return const Center(
                    child: Text(
                      'No interns found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredInterns.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final intern = filteredInterns[index];
                    return _buildInternCard(intern, context);
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildInternCard(UserModel intern, BuildContext context) {
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
                  backgroundColor: Colors.purple[100],
                  child: Text(
                    intern.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.purple[800],
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
                        intern.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        intern.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Study material access indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showInternOptions(context, intern);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.school,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                const Text(
                  'Access to Study Materials',
                  style: TextStyle(fontSize: 14),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Activity'),
                  onPressed: () {
                    Get.snackbar('Not Implemented', 'View activity functionality not implemented yet');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple[700],
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
  
  void _showInternOptions(BuildContext context, UserModel intern) {
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
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Manage Study Access'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to manage study access
                  Get.snackbar('Not Implemented', 'Manage study access functionality not implemented yet');
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.person_add, color: Colors.green[700]),
                title: Text('Promote to Counselor', style: TextStyle(color: Colors.green[700])),
                onTap: () {
                  Navigator.pop(context);
                  _confirmPromoteIntern(context, intern);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red[700]),
                title: Text('Remove Intern', style: TextStyle(color: Colors.red[700])),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteIntern(context, intern);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _confirmPromoteIntern(BuildContext context, UserModel intern) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Promote to Counselor'),
          content: Text('Are you sure you want to promote ${intern.name} to Counselor role? They will be given all counselor privileges.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement promotion functionality
                Get.snackbar('Not Implemented', 'Promotion functionality not implemented yet');
              },
              child: const Text('PROMOTE'),
              style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
            ),
          ],
        );
      },
    );
  }
  
  void _confirmDeleteIntern(BuildContext context, UserModel intern) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Intern'),
          content: Text('Are you sure you want to remove ${intern.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
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
}