import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/realtime_db_service.dart';
import './auth_controllers.dart';

class CounselorController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool isLoading = false.obs;
  final RxList<UserModel> assignedClients = <UserModel>[].obs;
  final RxList<Map<String, dynamic>> appointments = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCounselorData();
  }
  
  Future<void> loadCounselorData() async {
    try {
      isLoading.value = true;
      String? counselorId = _authController.userModel.value?.uid;
      
      if (counselorId != null) {
        // Load assigned clients
        await loadAssignedClients(counselorId);
        
        // Load appointments
        await loadAppointments(counselorId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load counselor data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadAssignedClients(String counselorId) async {
    try {
      // Get clients assigned to this counselor
      List<UserModel> clients = await _dbService.getAssignedClients(counselorId);
      assignedClients.assignAll(clients);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load assigned clients: ${e.toString()}');
    }
  }
  
  Future<void> loadAppointments(String counselorId) async {
    try {
      // Load appointments for this counselor
      List<Map<String, dynamic>> counselorAppointments = 
          await _dbService.getCounselorAppointments(counselorId);
          
      appointments.assignAll(counselorAppointments);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}');
    }
  }
  
  Future<void> updateAppointmentStatus(String appointmentId, String clientId, String status) async {
    try {
      isLoading.value = true;
      await _dbService.updateAppointmentStatus(appointmentId, clientId, status);
      
      // Reload appointments
      String? counselorId = _authController.userModel.value?.uid;
      if (counselorId != null) {
        await loadAppointments(counselorId);
      }
      
      Get.snackbar('Success', 'Appointment status updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update appointment status: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> addTestResultComment(String clientId, String testId, String comment) async {
    try {
      isLoading.value = true;
      await _dbService.addTestResultComment(clientId, testId, comment);
      Get.snackbar('Success', 'Comment added to test result');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<Map<String, dynamic>> getClientTestResults(String clientId) async {
    try {
      isLoading.value = true;
      return await _dbService.getClientTestResults(clientId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get client test results: ${e.toString()}');
      return {};
    } finally {
      isLoading.value = false;
    }
  }
}