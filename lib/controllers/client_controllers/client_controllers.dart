

import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class ClientController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> articles = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> tests = <Map<String, dynamic>>[].obs;
  final RxString assignedCounselorId = ''.obs;
  final Rx<UserModel?> counselor = Rx<UserModel?>(null);
  final RxBool hasCounselorRequest = false.obs;
  final RxList<Map<String, dynamic>> appointments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> testResults = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Show basic UI first, then load data
    Future.delayed(Duration(milliseconds: 100), () {
      loadBasicData();
    });
  }

  Future<void> loadBasicData() async {
    try {
      isLoading.value = true;
      
      // First, load only critical data
      UserModel? userData = _authController.userModel.value;
      if (userData != null) {
        assignedCounselorId.value = userData.assignedCounselorId ?? '';
        
        // Load tests first (these are mocked data)
        await loadTests();
        
        // Then check for counselor request (lightweight operation with the new optimized method)
        await checkCounselorRequest(userData.uid);
        
        // Now trigger background loading of heavier data
        _loadRemainingDataInBackground(userData);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRemainingDataInBackground(UserModel userData) async {
    // Load articles in background
    loadArticles();
    
    // Load counselor data if assigned
    if (assignedCounselorId.value.isNotEmpty) {
      counselor.value = await _dbService.getUserData(assignedCounselorId.value);
    }
    
    // Load appointments
    loadAppointments(userData.uid);
    
    // Load test results
    loadTestResults(userData.uid);
  }

  Future<void> loadClientData() async {
    try {
      isLoading.value = true;
      
      // Get current user data to check for assigned counselor
      UserModel? userData = _authController.userModel.value;
      if (userData != null) {
        assignedCounselorId.value = userData.assignedCounselorId ?? '';
        
        // Load counselor data if assigned
        if (assignedCounselorId.value.isNotEmpty) {
          counselor.value = await _dbService.getUserData(assignedCounselorId.value);
        }
        
        // Check if there's a pending counselor request with the optimized method
        await checkCounselorRequest(userData.uid);
        
        // Load articles
        await loadArticles();
        
        // Load available psychological tests
        await loadTests();
        
        // Load appointments
        await loadAppointments(userData.uid);
        
        // Load test results
        await loadTestResults(userData.uid);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadArticles() async {
    try {
      // Load categories one by one
      List<Map<String, dynamic>> allArticles = [];
      
      // Get mental health articles first
      List<Map<String, dynamic>> mentalHealthArticles = 
          await _dbService.getArticlesByCategory('mental-health');
      allArticles.addAll(mentalHealthArticles);
      articles.value = allArticles; // Update UI with first batch
      
      // Get anxiety articles next
      List<Map<String, dynamic>> anxietyArticles = 
          await _dbService.getArticlesByCategory('anxiety');
      allArticles.addAll(anxietyArticles);
      articles.value = allArticles; // Update UI with second batch
      
      // Get depression articles last
      List<Map<String, dynamic>> depressionArticles = 
          await _dbService.getArticlesByCategory('depression');
      allArticles.addAll(depressionArticles);
      articles.value = allArticles; // Update UI with all articles
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load articles: ${e.toString()}');
    }
  }

  Future<void> loadTests() async {
    try {
      // This would typically come from Firebase
      // Mocking the tests for now
      tests.value = [
        {
          'id': 'anxiety_test',
          'title': 'Anxiety Assessment',
          'description': 'Evaluate your anxiety levels',
          'questions': 10,
        },
        {
          'id': 'depression_test',
          'title': 'Depression Screening',
          'description': 'Screen for depression symptoms',
          'questions': 15,
        },
        {
          'id': 'stress_test',
          'title': 'Stress Measurement',
          'description': 'Measure your current stress levels',
          'questions': 12,
        },
      ];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tests: ${e.toString()}');
    }
  }

  Future<void> checkCounselorRequest(String userId) async {
    try {
      // Use the optimized method that only checks this specific user's request
      hasCounselorRequest.value = await _dbService.hasClientCounselorRequest(userId);
    } catch (e) {
      print("Error checking counselor request: $e");
      hasCounselorRequest.value = false;
    }
  }

  Future<void> requestCounselor() async {
    try {
      isLoading.value = true;
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null) {
        await _dbService.requestCounselor(userId);
        hasCounselorRequest.value = true;
        Get.snackbar('Success', 'Counselor request submitted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request counselor: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestAppointment(String date, String time) async {
    try {
      isLoading.value = true;
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null && assignedCounselorId.value.isNotEmpty) {
        await _dbService.createAppointmentRequest(
          userId, 
          assignedCounselorId.value, 
          date, 
          time
        );
        await loadAppointments(userId);
        Get.snackbar('Success', 'Appointment request submitted');
      } else {
        Get.snackbar('Error', 'You must be assigned a counselor first');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request appointment: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAppointments(String userId) async {
    try {
      // This would typically come from Firebase
      // We're assuming a structure where appointments are stored by client ID
      // In a real implementation, you'd get this from the DB service
      
      // Mocking appointments for now
      appointments.value = [
        {
          'id': 'apt1',
          'counselorId': assignedCounselorId.value,
          'date': '2025-04-25',
          'time': '10:00 AM',
          'status': 'pending',
        },
        {
          'id': 'apt2',
          'counselorId': assignedCounselorId.value,
          'date': '2025-05-02',
          'time': '2:30 PM',
          'status': 'confirmed',
        },
      ];
      
      // Actual implementation would be something like:
      // DataSnapshot snapshot = await _db.child('appointments').child(userId).get();
      // Process snapshot data...
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}');
    }
  }

  Future<void> loadTestResults(String userId) async {
    try {
      // In a real implementation, you'd get this from the DB service
      // Mocking test results for now
      testResults.value = [
        {
          'testId': 'anxiety_test',
          'testName': 'Anxiety Assessment',
          'score': 7,
          'maxScore': 20,
          'date': '2025-04-10',
          'counselorComment': 'Your anxiety appears to be mild. We can discuss coping strategies in our next session.',
        },
        {
          'testId': 'depression_test',
          'testName': 'Depression Screening',
          'score': 12,
          'maxScore': 30,
          'date': '2025-04-05',
          'counselorComment': null,
        },
      ];
      
      // Actual implementation would be something like:
      // DataSnapshot snapshot = await _db.child('test_results').child(userId).get();
      // Process snapshot data...
    } catch (e) {
      Get.snackbar('Error', 'Failed to load test results: ${e.toString()}');
    }
  }

  Future<void> saveTestResult(String testId, String testName, int score, int maxScore) async {
    try {
      isLoading.value = true;
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null) {
        await _dbService.saveTestResult(userId, testId, score);
        
        // Update local test results
        testResults.add({
          'testId': testId,
          'testName': testName,
          'score': score,
          'maxScore': maxScore,
          'date': DateTime.now().toString().substring(0, 10), // YYYY-MM-DD
          'counselorComment': null,
        });
        
        Get.snackbar('Success', 'Test result saved successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save test result: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}