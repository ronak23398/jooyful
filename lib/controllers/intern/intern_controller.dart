import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/models/article_model.dart';
import 'package:jooyful_heaven/services/article_service.dart';
import 'package:jooyful_heaven/services/file_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/realtime_db_service.dart';

class InternController extends GetxController {
  final ArticleService _articleService;
  final FileService _fileService;
  
  final RxBool isLoading = false.obs;
  final RxList<ArticleModel> articles = <ArticleModel>[].obs;
  final RxList<Map<String, dynamic>> studyMaterials = <Map<String, dynamic>>[].obs;
  
  // For currently selected category
  final RxString selectedCategory = 'all'.obs;
  final RxList<String> categories = <String>['all'].obs;
  
  // For downloading progress
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  
  InternController({
    ArticleService? articleService,
    FileService? fileService
  }) : _articleService = articleService ?? ArticleService(RealtimeDbService()),
       _fileService = fileService ?? FileService();
  
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
      
      // Update categories
      _updateCategories();
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to load intern data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadArticles() async {
    try {
      List<ArticleModel> allArticles = [];
      
      // Load articles for all categories in parallel
      List<String> categoryList = ['mental-health', 'anxiety', 'depression'];
      
      await Future.wait(
        categoryList.map((category) async {
          try {
            List<Map<String, dynamic>> articleMaps = 
                await _articleService.getArticlesByCategory(category);
            
            for (var articleMap in articleMaps) {
              // Ensure category is set
              if (articleMap['category'] == null) {
                articleMap['category'] = category;
              }
              
              // Ensure ID exists
              String id = articleMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
              
              try {
                ArticleModel article = ArticleModel.fromMap(articleMap, id);
                allArticles.add(article);
              } catch (e) {
                print("Error converting article: $e");
              }
            }
          } catch (e) {
            print("Error loading articles for category $category: $e");
          }
        })
      );
      
      // Update articles list once all are loaded
      articles.value = allArticles;
      
    } catch (e) {
      print("Error in loadArticles: ${e.toString()}");
      Get.snackbar(
        'Error', 
        'Failed to load articles: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
    }
  }
  
  Future<void> loadStudyMaterials() async {
    try {
      // Get study materials uploaded by owner
      List<Map<String, dynamic>> materials = await _articleService.getStudyMaterials();
      studyMaterials.value = materials;
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to load study materials: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM
      );
    }
  }
  
  void _updateCategories() {
    Set<String> uniqueCategories = {'all'};
    
    for (var article in articles) {
      if (article.category.isNotEmpty) {
        uniqueCategories.add(article.category);
      }
    }
    
    categories.value = uniqueCategories.toList();
  }
  
  Future<void> downloadStudyMaterial(Map<String, dynamic> material) async {
    try {
      final String? fileUrl = material['fileUrl'];
      final String fileName = material['title'] ?? 'download_${DateTime.now().millisecondsSinceEpoch}';
      
      if (fileUrl == null || fileUrl.isEmpty) {
        Get.snackbar('Error', 'No download URL available for this material');
        return;
      }
      
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      
      if (kIsWeb) {
        // For web platform, just open the URL
        if (await canLaunchUrl(fileUrl as Uri)) {
          await launchUrl(fileUrl as Uri);
        } else {
          throw 'Could not launch $fileUrl';
        }
      } else {
        // For mobile platforms
        if (Platform.isAndroid || Platform.isIOS) {
          // Request storage permission
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            throw 'Storage permission not granted';
          }
          
          // Get downloads directory
          Directory? directory;
          if (Platform.isAndroid) {
            directory = await getExternalStorageDirectory();
          } else {
            directory = await getApplicationDocumentsDirectory();
          }
          
          if (directory == null) {
            throw 'Could not access storage directory';
          }
          
          // Start download with progress
          final String savePath = '${directory.path}/$fileName';
          
          await _fileService.downloadFile(
            fileUrl, 
            savePath,
            onProgress: (progress) {
              downloadProgress.value = progress;
            },
          );
          
          Get.snackbar(
            'Success', 
            'Material downloaded successfully to $savePath',
            snackPosition: SnackPosition.BOTTOM
          );
        } else {
          // For desktop platforms
          if (await canLaunch(fileUrl)) {
            await launch(fileUrl);
          } else {
            throw 'Could not launch $fileUrl';
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Download Failed', 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM
      );
    } finally {
      isDownloading.value = false;
    }
  }
  
  // Filter articles by category
  List<ArticleModel> getArticlesByCategory(String category) {
    if (category == 'all') {
      return articles;
    }
    return articles.where((article) => article.category == category).toList();
  }
}