// import 'package:get/get.dart';
// import 'package:jooyful_heaven/models/article_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:jooyful_heaven/services/realtime_db_service.dart';

// class BookmarkService extends GetxService {
//   final RealtimeDbService _dbService;
//   late SharedPreferences _prefs;
  
//   // Key for storing bookmarks in SharedPreferences
//   static const String _bookmarksKey = 'user_bookmarks';
  
//   BookmarkService({RealtimeDbService? dbService}) 
//     : _dbService = dbService ?? Get.find<RealtimeDbService>();
  
//   /// Initialize the service
//   Future<BookmarkService> init() async {
//     _prefs = await SharedPreferences.getInstance();
//     return this;
//   }
  
//   /// Get all bookmarked articles
//   Future<List<ArticleModel>> getBookmarkedArticles() async {
//     try {
//       // Get bookmarked article IDs
//       List<String> bookmarkIds = _getBookmarkIds();
      
//       if (bookmarkIds.isEmpty) {
//         return [];
//       }
      
//       // Get articles from local cache first
//       List<ArticleModel> articles = _getBookmarkedArticlesFromCache();
      
//       // If we have cached articles, use them
//       if (articles.isNotEmpty) {
//         return articles;
//       }
      
//       // Otherwise fetch from server
//       List<ArticleModel> fetchedArticles = [];
      
//       for (String id in bookmarkIds) {
//         try {
//           Map<String, dynamic>? articleData = await _dbService.getDocumentById('articles', id);
          
//           if (articleData != null) {
//             ArticleModel article = ArticleModel.fromMap(articleData, id);
//             fetchedArticles.add(article);
//           }
//         } catch (e) {
//           print('Error fetching article $id: $e');
//           // Continue with next article
//         }
//       }
      
//       // Cache fetched articles
//       _cacheBookmarkedArticles(fetchedArticles);
      
//       return fetchedArticles;
//     } catch (e) {
//       print('Error getting bookmarked articles: $e');
//       return [];
//     }
//   }
  
//   /// Check if an article is bookmarked
//   Future<bool> isBookmarked(String articleId) async {
//     List<String> bookmarkIds = _getBookmarkIds();
//     return bookmarkIds.contains(articleId);
//   }
  
//   /// Add an article to bookmarks
//   Future<void> addBookmark(ArticleModel article) async {
//     try {
//       // Get current bookmarks
//       List<String> bookmarkIds = _getBookmarkIds();
//       List<ArticleModel> articles = _getBookmarkedArticlesFromCache();
      
//       // Add article ID if not already bookmarked
//       if (!bookmarkIds.contains(article.id)) {
//         bookmarkIds.add(article.id);
//         articles.add(article);
        
//         // Save updated bookmarks
//         await _saveBookmarkIds(bookmarkIds);
//         _cacheBookmarkedArticles(articles);
        
//         // Sync with server if user is logged in
//         _syncBookmarksWithServer(bookmarkIds);
//       }
//     } catch (e) {
//       print('Error adding bookmark: $e');
//       throw Exception('Failed to add bookmark');
//     }
//   }
  
//   /// Remove an article from bookmarks
//   Future<void> removeBookmark(String articleId) async {
//     try {
//       // Get current bookmarks
//       List<String> bookmarkIds = _getBookmarkIds();
//       List<ArticleModel> articles = _getBookmarkedArticlesFromCache();
      
//       // Remove article ID if bookmarked
//       if (bookmarkIds.contains(articleId)) {
//         bookmarkIds.remove(articleId);
//         articles.removeWhere((article) => article.id == articleId);
        
//         // Save updated bookmarks
//         await _saveBookmarkIds(bookmarkIds);
//         _cacheBookmarkedArticles(articles);
        
//         // Sync with server if user is logged in
//         _syncBookmarksWithServer(bookmarkIds);
//       }
//     } catch (e) {
//       print('Error removing bookmark: $e');
//       throw Exception('Failed to remove bookmark');
//     }
//   }
  
//   /// Get bookmark IDs from SharedPreferences
//   List<String> _getBookmarkIds() {
//     try {
//       String? bookmarksJson = _prefs.getString(_bookmarksKey);
      
//       if (bookmarksJson == null || bookmarksJson.isEmpty) {
//         return [];
//       }
      
//       List<dynamic> bookmarksList = jsonDecode(bookmarksJson);
//       return bookmarksList.map((item) => item.toString()).toList();
//     } catch (e) {
//       print('Error getting bookmark IDs: $e');
//       return [];
//     }
//   }
  
//   /// Save bookmark IDs to SharedPreferences
//   Future<void> _saveBookmarkIds(List<String> bookmarkIds) async {
//     try {
//       String bookmarksJson = jsonEncode(bookmarkIds);
//       await _prefs.setString(_bookmarksKey, bookmarksJson);
//     } catch (e) {
//       print('Error saving bookmark IDs: $e');
//       throw Exception('Failed to save bookmarks');
//     }
//   }
  
//   /// Get bookmarked articles from cache
//   List<ArticleModel> _getBookmarkedArticlesFromCache() {
//     try {
//       String? articlesJson = _prefs.getString('${_bookmarksKey}_articles');
      
//       if (articlesJson == null || articlesJson.isEmpty) {
//         return [];
//       }
      
//       List<dynamic> articlesList = jsonDecode(articlesJson);
//       List<ArticleModel> articles = [];
      
//       for (var articleMap in articlesList) {
//         try {
//           String id = articleMap['id'] ?? '';
//           ArticleModel article = ArticleModel.fromMap(articleMap, id);
//           articles.add(article);
//         } catch (e) {
//           print('Error parsing cached article: $e');
//           // Continue with next article
//         }
//       }
      
//       return articles;
//     } catch (e) {
//       print('Error getting cached articles: $e');
//       return [];
//     }
//   }
  
//   /// Cache bookmarked articles
//   void _cacheBookmarkedArticles(List<ArticleModel> articles) {
//     try {
//       List<Map<String, dynamic>> articleMaps = 
//           articles.map((article) => article.toMap()).toList();
      
//       String articlesJson = jsonEncode(articleMaps);
//       _prefs.setString('${_bookmarksKey}_articles', articlesJson);
//     } catch (e) {
//       print('Error caching articles: $e');
//       // Non-critical error, can be ignored
//     }
//   }
  
//   /// Sync bookmarks with server (if user is logged in)
//   Future<void> _syncBookmarksWithServer(List<String> bookmarkIds) async {
//     try {
//       String? userId = _dbService.getCurrentUserId();
      
//       if (userId != null && userId.isNotEmpty) {
//         // Update bookmarks in user profile
//         await _dbService.updateDocument(
//           'users',
//           userId,
//           {'bookmarks': bookmarkIds},
//         );
//       }
//     } catch (e) {
//       print('Error syncing bookmarks with server: $e');
//       // Non-critical error, can continue
//     }
//   }
  
//   /// Clear all bookmarks
//   Future<void> clearBookmarks() async {
//     try {
//       await _prefs.remove(_bookmarksKey);
//       await _prefs.remove('${_bookmarksKey}_articles');
      
//       // Clear bookmarks on server if user is logged in
//       String? userId = _dbService.getCurrentUserId();
      
//       if (userId != null && userId.isNotEmpty) {
//         await _dbService.updateDocument(
//           'users',
//           userId,
//           {'bookmarks': []},
//         );
//       }
//     } catch (e) {
//       print('Error clearing bookmarks: $e');
//       throw Exception('Failed to clear bookmarks');
//     }
//   }
// }