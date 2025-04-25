// import 'package:get/get.dart';
// import 'package:jooyful_heaven/models/article_model.dart';
// import 'package:jooyful_heaven/services/article_service.dart';

// class ArticleDetailController extends GetxController {
//   final ArticleService _articleService;
//   final BookmarkService _bookmarkService;
  
//   final RxBool isLoading = true.obs;
//   final RxBool isBookmarked = false.obs;
//   final RxList<ArticleModel> relatedArticles = <ArticleModel>[].obs;
  
//   ArticleDetailController({
//     ArticleService? articleService,
//     BookmarkService? bookmarkService,
//   }) : _articleService = articleService ?? Get.find<ArticleService>(),
//        _bookmarkService = bookmarkService ?? Get.find<BookmarkService>();
  
//   @override
//   void onInit() {
//     super.onInit();
    
//     // Get the article from arguments
//     if (Get.arguments != null && Get.arguments['article'] != null) {
//       final ArticleModel article = Get.arguments['article'];
      
//       // Load article data
//       loadArticleData(article);
      
//       // Check if bookmarked
//       checkIfBookmarked(article);
//     } else {
//       // No article provided in arguments
//       isLoading.value = false;
//     }
//   }
  
//   Future<void> loadArticleData(ArticleModel article) async {
//     try {
//       isLoading.value = true;
      
//       // If the article has minimal content, try to get full content
//       if (article.content == null || article.content!.isEmpty) {
//         await _loadFullArticle(article);
//       }
      
//       // Load related articles
//       await _loadRelatedArticles(article);
      
//       // Track view
//       _articleService.trackArticleView(article.id);
      
//     } catch (e) {
//       print('Error loading article data: $e');
//       Get.snackbar(
//         'Error', 
//         'Failed to load article data',
//         snackPosition: SnackPosition.BOTTOM
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
  
//   Future<void> _loadFullArticle(ArticleModel article) async {
//     try {
//       final ArticleModel? fullArticle = await _articleService.getArticleById(article.id);
      
//       if (fullArticle != null) {
//         // Update article in arguments
//         Get.arguments['article'] = fullArticle;
//       }
//     } catch (e) {
//       print('Error loading full article: $e');
//       // Continue with original article
//     }
//   }
  
//   Future<void> _loadRelatedArticles(ArticleModel article) async {
//     try {
//       // Get articles from the same category, excluding current article
//       List<ArticleModel> categoryArticles = await _articleService.getRelatedArticles(
//         categoryId: article.category ?? '',
//         excludeId: article.id,
//         limit: 5,
//       );
      
//       relatedArticles.value = categoryArticles;
//     } catch (e) {
//       print('Error loading related articles: $e');
//       // Continue without related articles
//     }
//   }
  
//   Future<void> checkIfBookmarked(ArticleModel article) async {
//     try {
//       // Check if article is bookmarked
//       bool bookmarked = await _bookmarkService.isBookmarked(article.id);
//       isBookmarked.value = bookmarked;
//     } catch (e) {
//       print('Error checking bookmark status: $e');
//     }
//   }
  
//   Future<void> toggleBookmark(ArticleModel article) async {
//     try {
//       if (isBookmarked.value) {
//         // Remove bookmark
//         await _bookmarkService.removeBookmark(article.id);
//         isBookmarked.value = false;
        
//         Get.snackbar(
//           'Bookmark Removed', 
//           'Article removed from bookmarks',
//           snackPosition: SnackPosition.BOTTOM
//         );
//       } else {
//         // Add bookmark
//         await _bookmarkService.addBookmark(article);
//         isBookmarked.value = true;
        
//         Get.snackbar(
//           'Bookmarked', 
//           'Article added to bookmarks',
//           snackPosition: SnackPosition.BOTTOM
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error', 
//         'Failed to update bookmark',
//         snackPosition: SnackPosition.BOTTOM
//       );
//     }
//   }
// }