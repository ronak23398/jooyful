import 'package:get/get.dart';
import 'package:jooyful_heaven/services/article_service.dart';
import '../services/realtime_db_service.dart';

class InternController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> articles = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> studyMaterials = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadInternData();
  }
  
  Future<void> loadInternData() async {
    try {
      isLoading.value = true;
      
      // Load all articles
      await loadArticles();
      
      // Load study materials
      await loadStudyMaterials();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load intern data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadArticles() async {
    try {
      // Load all articles from different categories
      List<Map<String, dynamic>> allArticles = [];
      
      // Get mental health articles
      List<Map<String, dynamic>> mentalHealthArticles = 
          await ArticleService(_dbService).getArticlesByCategory('mental-health');
      allArticles.addAll(mentalHealthArticles);
      
      // Get anxiety articles
      List<Map<String, dynamic>> anxietyArticles = 
          await ArticleService(_dbService).getArticlesByCategory('anxiety');
      allArticles.addAll(anxietyArticles);
      
      // Get depression articles
      List<Map<String, dynamic>> depressionArticles = 
          await ArticleService(_dbService).getArticlesByCategory('depression');
      allArticles.addAll(depressionArticles);
      
      articles.value = allArticles;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load articles: ${e.toString()}');
    }
  }
  
  Future<void> loadStudyMaterials() async {
    try {
      // Get study materials uploaded by owner
      List<Map<String, dynamic>> materials = await ArticleService(_dbService).getStudyMaterials();
      studyMaterials.value = materials;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load study materials: ${e.toString()}');
    }
  }
}