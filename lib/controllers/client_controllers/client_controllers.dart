import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/models/article_model.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/services/appointment_service.dart';
import 'package:jooyful_heaven/services/article_service.dart';
import 'package:jooyful_heaven/services/counsellor_req_service.dart';
import 'package:jooyful_heaven/services/mood_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';
import 'package:jooyful_heaven/services/test_service.dart';
import 'package:jooyful_heaven/services/user_service.dart';

class ClientController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  final AuthController _authController = Get.find<AuthController>();
  final MoodService _moodService = MoodService(RealtimeDbService());
  
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> tests = <Map<String, dynamic>>[].obs;
  final RxString assignedCounselorId = ''.obs;
  final Rx<UserModel?> counselor = Rx<UserModel?>(null);
  final RxBool hasCounselorRequest = false.obs;
  final RxList<Map<String, dynamic>> appointments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> testResults = <Map<String, dynamic>>[].obs;
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxMap<String, Map<String, dynamic>> weeklyMoods = <String, Map<String, dynamic>>{}.obs;
  final RxBool hasMoodRecordedToday = false.obs;
  final Rx<Map<String, dynamic>?> todaysMood = Rx<Map<String, dynamic>?>(null);

  // Track initialization status
  bool _isBasicDataLoaded = false;
  final List<Future> _pendingTasks = [];
  final RxBool isInitializing = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Show basic UI first, then load data in stages
    Future.microtask(() => _loadDataInStages());
  }
  
  @override
  void onClose() {
    // Cancel any pending tasks if needed
    super.onClose();
  }

  Future<void> _loadDataInStages() async {
    try {
      // Stage 1: Critical data (must show immediately)
      await _loadStage1CriticalData();
      
      // Stage 2: Important but can load in background 
      _loadStage2BackgroundData();
      
      // Stage 3: Non-critical data (can load later)
      _loadStage3OptionalData();
    } catch (e) {
      print("Error in _loadDataInStages: $e");
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> _loadStage1CriticalData() async {
    if (_isBasicDataLoaded) return;
    
    try {
      isLoading.value = true;
      
      UserModel? userData = _authController.userModel.value;
      if (userData != null) {
        // This is critical minimal data we need right away
        assignedCounselorId.value = userData.assignedCounselorId ?? '';
        
        // Load tests (mocked data - very fast)
        await loadTests();
        
        // Check counselor request (optimized method)
        await checkCounselorRequest(userData.uid);
        
        _isBasicDataLoaded = true;
      }
    } catch (e) {
      print("Error loading critical data: $e");
      Get.snackbar('Error', 'Failed to load initial data');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadStage2BackgroundData() {
    UserModel? userData = _authController.userModel.value;
    if (userData == null) return;
    
    // These can load in parallel without blocking UI
    _pendingTasks.add(loadWeeklyMoods());
    
    if (assignedCounselorId.value.isNotEmpty) {
      _pendingTasks.add(_loadCounselorData());
    }
  }

  void _loadStage3OptionalData() {
    UserModel? userData = _authController.userModel.value;
    if (userData == null) return;
    
    // These are least critical - load last
    _pendingTasks.add(_loadArticlesInBatches());
    _pendingTasks.add(_loadAppointmentsData(userData.uid));
    _pendingTasks.add(_loadTestResultsData(userData.uid));
  }

  Future<void> _loadCounselorData() async {
    try {
      if (assignedCounselorId.value.isNotEmpty) {
        counselor.value = await UserService(_dbService).getUserData(assignedCounselorId.value);
      }
    } catch (e) {
      print("Error loading counselor data: $e");
    }
  }

  Future<void> _loadArticlesInBatches() async {
    try {
      // Load articles in batches to prevent UI freezes
      // First batch - mental health
      await _loadArticleBatch('mental-health');
      
      // Small delay to let UI breathe
      await Future.delayed(Duration(milliseconds: 50));
      
      // Second batch - anxiety
      await _loadArticleBatch('anxiety');
      
      // Small delay
      await Future.delayed(Duration(milliseconds: 50));
      
      // Third batch - depression
      await _loadArticleBatch('depression');
    } catch (e) {
      print("Error loading articles in batches: $e");
    }
  }
  
  Future<void> _loadArticleBatch(String category) async {
    try {
      List<Map<String, dynamic>> articleMaps = 
          await ArticleService(_dbService).getArticlesByCategory(category);
      
      List<ArticleModel> batchArticles = [];
      for (var articleMap in articleMaps) {
        if (articleMap['category'] == null) {
          articleMap['category'] = category;
        }
        
        String id = articleMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        
        try {
          ArticleModel article = ArticleModel.fromMap(articleMap, id);
          batchArticles.add(article);
        } catch (e) {
          print("Error converting $category article: $e");
        }
      }
      
      // Update UI with new batch
      articles.addAll(batchArticles);
    } catch (e) {
      print("Error loading $category articles: $e");
    }
  }

  Future<void> _loadAppointmentsData(String userId) async {
  try {
    final appointmentService = AppointmentService(RealtimeDbService());
    
    // Fetch real appointments from Firebase
    final appointmentList = await appointmentService.getClientAppointments(userId);
    
    // Update the appointments value with the fetched data
    appointments.value = appointmentList;
    
    print("Loaded ${appointmentList.length} appointments from Firebase");
  } catch (e) {
    print("Error loading appointments: $e");
    // Handle the error appropriately, perhaps show a message to the user
    appointments.value = []; // Reset to empty list on error
  }
}

  Future<void> _loadTestResultsData(String userId) async {
    try {
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
    } catch (e) {
      print("Error loading test results: $e");
    }
  }

  // Original methods with optimizations

  Future<void> loadClientData() async {
    // Use staged loading instead
    if (!_isBasicDataLoaded) {
      await _loadDataInStages();
    } else {
      // Just refresh data if already loaded
      UserModel? userData = _authController.userModel.value;
      if (userData != null) {
        await Future.wait([
          loadWeeklyMoods(),
          checkCounselorRequest(userData.uid),
          _loadCounselorData(),
        ]);
      }
    }
  }

  Future<void> loadArticles() async {
    await _loadArticlesInBatches();
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
      print("Error loading tests: $e");
    }
  }

  Future<void> checkCounselorRequest(String userId) async {
    try {
      // Use the optimized method that only checks this specific user's request
      hasCounselorRequest.value = await CounselorRequestService(_dbService).hasClientCounselorRequest(userId);
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
        await CounselorRequestService(_dbService).requestCounselor(userId);
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
        await AppointmentService(_dbService).createAppointmentRequest(
          userId, 
          assignedCounselorId.value, 
          date, 
          time
        );
        await _loadAppointmentsData(userId);
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
    await _loadAppointmentsData(userId);
  }

  Future<void> loadTestResults(String userId) async {
    await _loadTestResultsData(userId);
  }

  Future<void> saveTestResult(String testId, String testName, int score, int maxScore) async {
    try {
      isLoading.value = true;
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null) {
        // Do heavy DB operation first
        await TestService(_dbService).saveTestResult(userId, testId, score);
        
        // Then update UI in a microtask
        Future.microtask(() {
          testResults.add({
            'testId': testId,
            'testName': testName,
            'score': score,
            'maxScore': maxScore,
            'date': DateTime.now().toString().substring(0, 10), // YYYY-MM-DD
            'counselorComment': null,
          });
        });
        
        Get.snackbar('Success', 'Test result saved successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save test result: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> checkTodaysMood() async {
    try {
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null) {
        final todayDate = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD format
        
        // Check if today's date exists in the weekly moods
        if (weeklyMoods.containsKey(todayDate)) {
          hasMoodRecordedToday.value = true;
          todaysMood.value = weeklyMoods[todayDate];
        } else {
          hasMoodRecordedToday.value = false;
          todaysMood.value = null;
        }
      }
    } catch (e) {
      print("Error checking today's mood: ${e.toString()}");
    }
  }

  Future<void> saveMood(String mood, String emoji) async {
    try {
      isLoading.value = true;
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null) {
        // Save to database first
        await _moodService.saveMood(userId, mood, emoji);
        
        // Update today's mood immediately for better UX
        final todayDate = DateTime.now().toString().substring(0, 10);
        todaysMood.value = {
          'mood': mood,
          'emoji': emoji,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        hasMoodRecordedToday.value = true;
        
        // Then update weekly moods in background
        Future.microtask(() => loadWeeklyMoods());
        
        Get.snackbar('Success', 'Your mood has been recorded!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save mood: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadWeeklyMoods() async {
    try {
      String? userId = _authController.userModel.value?.uid;
      
      if (userId != null) {
        final moodData = await _moodService.getWeeklyMoods(userId);
        weeklyMoods.value = moodData;
        
        // Check if user has recorded mood today
        await checkTodaysMood();
      }
    } catch (e) {
      print("Error loading weekly moods: ${e.toString()}");
    }
  }
}