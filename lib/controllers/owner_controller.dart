import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/realtime_db_service.dart';

class OwnerController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  
  final RxList<UserModel> clients = <UserModel>[].obs;
  final RxList<UserModel> counselors = <UserModel>[].obs;
  final RxList<UserModel> interns = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> counselorRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
    fetchCounselorRequests();
  }

  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      
      // Fetch users by role
      final allUsers = await _dbService.getAllUsers();
      
      // Clear current lists
      clients.clear();
      counselors.clear();
      interns.clear();
      
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
        }
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCounselorRequests() async {
    try {
      final requests = await _dbService.getCounselorRequests();
      counselorRequests.value = requests;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch counselor requests: ${e.toString()}');
    }
  }

  Future<void> assignCounselorToClient(String clientId, String counselorId) async {
    try {
      isLoading.value = true;
      await _dbService.assignCounselorToClient(clientId, counselorId);
      await _dbService.updateCounselorRequestStatus(clientId, 'assigned');
      
      // Refresh data
      await fetchAllUsers();
      await fetchCounselorRequests();
      
      Get.snackbar('Success', 'Counselor assigned successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign counselor: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadArticle(String title, String content, String category) async {
    try {
      isLoading.value = true;
      await _dbService.uploadArticle(title, content, category);
      Get.snackbar('Success', 'Article uploaded successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload article: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
