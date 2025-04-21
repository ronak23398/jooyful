import 'package:get/get.dart';
import 'package:jooyful_heaven/services/counsellor_req_service.dart';
import 'package:jooyful_heaven/services/user_service.dart';
import '../models/user_model.dart';
import '../services/realtime_db_service.dart';

class OwnerController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<UserModel> clients = <UserModel>[].obs;
  final RxList<UserModel> counselors = <UserModel>[].obs;
  final RxList<UserModel> interns = <UserModel>[].obs;
  final RxList<Map<String, dynamic>> pendingRequests = <Map<String, dynamic>>[].obs;
  
  // Computed values for counts
  int get clientCount => clients.length;
  int get counselorCount => counselors.length;
  int get internCount => interns.length;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
    fetchCounselorRequests();
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      
      // Clear existing lists
      clients.clear();
      counselors.clear();
      interns.clear();
      
      // Fetch all users from database
      List<UserModel> allUsers = await UserService(_dbService).getAllUsers();
      
      // Sort users by role
      for (var user in allUsers) {
        switch (user.role) {
          case 'client':
            clients.add(user);
            break;
          case 'counselor':
            counselors.add(user);
            break;
          case 'intern':
            interns.add(user);
            break;
          default:
            // Owner or unknown role - ignore
            break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCounselorRequests() async {
    try {
      // Fetch pending counselor requests from database
      List<Map<String, dynamic>> requests = await CounselorRequestService(_dbService).getCounselorRequests();
      pendingRequests.value = requests.where((req) => req['status'] == 'pending').toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load counselor requests: ${e.toString()}');
    }
  }

  // Get a client by ID
  UserModel? getClientById(String clientId) {
    try {
      return clients.firstWhere((client) => client.uid == clientId);
    } catch (e) {
      print("Client not found: $clientId");
      return null;
    }
  }

  // Method to assign counselor to client
  Future<void> assignCounselor(String clientId, String counselorId) async {
    try {
      isLoading.value = true;
      
      // Get counselor details for logging
      final counselor = counselors.firstWhere((c) => c.uid == counselorId);
      
      print("Assigning counselor ${counselor.name} (ID: $counselorId) to client ID: $clientId");
      
      // Update client with assigned counselor
      await UserService(_dbService).assignCounselorToClient(clientId, counselorId);
      
      // Update request status to completed
      await CounselorRequestService(_dbService).updateCounselorRequestStatus(clientId, 'completed');
      
      print("Counselor successfully assigned");
      
      // Refresh data
      await fetchAllUsers();
      await fetchCounselorRequests();
      
      Get.snackbar('Success', 'Counselor assigned successfully');
    } catch (e) {
      print("Error assigning counselor: $e");
      Get.snackbar('Error', 'Failed to assign counselor: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Method to unassign counselor from client
  Future<void> unassignCounselor(String clientId) async {
    try {
      isLoading.value = true;
      
      // Update client to remove assigned counselor
      await UserService(_dbService).assignCounselorToClient(clientId,null);
      
      // Refresh data
      await fetchAllUsers();
      
      Get.snackbar('Success', 'Counselor unassigned successfully');
    } catch (e) {
      print("Error unassigning counselor: $e");
      Get.snackbar('Error', 'Failed to unassign counselor: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Method to filter counselors (could be used for search functionality)
  List<UserModel> filterCounselors(String query) {
    if (query.isEmpty) {
      return counselors;
    }
    
    return counselors.where((counselor) {
      return counselor.name.toLowerCase().contains(query.toLowerCase()) ||
             counselor.email.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}