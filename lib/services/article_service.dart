import 'package:firebase_database/firebase_database.dart';
import '../models/article_model.dart';
import 'realtime_db_service.dart';

class ArticleService {
  final RealtimeDbService _dbService;
  
  ArticleService(this._dbService);
  
  // Upload article
  Future<void> uploadArticle(
    String title,
    String content,
    String category,
  ) async {
    try {
      String articleId =
          _dbService.dbRef.child('articles').child(category).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _dbService.dbRef.child('articles').child(category).child(articleId).set({
        'title': title,
        'content': content,
        'category': category,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error uploading article: $e");
      throw e;
    }
  }

  // Get articles by category
  Future<List<Map<String, dynamic>>> getArticlesByCategory(
    String category,
  ) async {
    try {
      DataSnapshot snapshot = await _dbService.dbRef.child('articles').child(category).get();

      List<Map<String, dynamic>> articles = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Map<dynamic, dynamic> article = value as Map<dynamic, dynamic>;
          article['id'] = key;
          articles.add(Map<String, dynamic>.from(article));
        });
      }

      return articles;
    } catch (e) {
      print("Error getting articles: $e");
      throw e;
    }
  }

  // Get all articles
  Future<List<ArticleModel>> getArticles() async {
    try {
      DataSnapshot snapshot = await _dbService.dbRef.child('articles').get();

      List<ArticleModel> articles = [];

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> categories =
            snapshot.value as Map<dynamic, dynamic>;
        categories.forEach((category, categoryData) {
          Map<dynamic, dynamic> articlesInCategory =
              categoryData as Map<dynamic, dynamic>;
          articlesInCategory.forEach((key, value) {
            Map<dynamic, dynamic> articleData = value as Map<dynamic, dynamic>;
            // Add category and id to the map
            Map<String, dynamic> formattedData = Map<String, dynamic>.from(
              articleData,
            );
            formattedData['category'] = category;
            articles.add(ArticleModel.fromMap(formattedData, key.toString()));
          });
        });
      }

      return articles;
    } catch (e) {
      print("Error getting all articles: $e");
      throw e;
    }
  }

  // Add article
  Future<void> addArticle(ArticleModel article) async {
    try {
      String category = article.category;
      String articleId =
          _dbService.dbRef.child('articles').child(category).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _dbService.dbRef.child('articles').child(category).child(articleId).set({
        'title': article.title,
        'content': article.content,
        'createdAt': article.createdAt.millisecondsSinceEpoch,
        'authorId': article.authorId,
        'authorName': article.authorName,
        'tags': article.tags,
        'audience': article.audience,
        'imageUrl': article.imageUrl,
      });
    } catch (e) {
      print("Error adding article: $e");
      rethrow;
    }
  }

  // Delete article
  Future<void> deleteArticle(String articleId) async {
    try {
      // Since articles are stored by category, we need to find which category this article belongs to
      DataSnapshot snapshot = await _dbService.dbRef.child('articles').get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> categories =
            snapshot.value as Map<dynamic, dynamic>;

        for (var category in categories.keys) {
          Map<dynamic, dynamic> articlesInCategory =
              categories[category] as Map<dynamic, dynamic>;

          if (articlesInCategory.containsKey(articleId)) {
            await _dbService.dbRef
                .child('articles')
                .child(category.toString())
                .child(articleId)
                .remove();
            print("Article deleted successfully");
            return;
          }
        }

        throw Exception('Article not found');
      } else {
        throw Exception('No articles found');
      }
    } catch (e) {
      print("Error deleting article: $e");
      throw e;
    }
  }

  // Upload study material
  Future<void> uploadStudyMaterial(
    String title,
    String content,
    String category,
  ) async {
    try {
      String materialId =
          _dbService.dbRef.child('study_materials').child(category).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _dbService.dbRef.child('study_materials').child(category).child(materialId).set({
        'title': title,
        'content': content,
        'category': category,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error uploading study material: $e");
      throw e;
    }
  }

  // Get study materials
  Future<List<Map<String, dynamic>>> getStudyMaterials() async {
    try {
      DataSnapshot snapshot = await _dbService.dbRef.child('study_materials').get();

      List<Map<String, dynamic>> materials = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> categories =
            snapshot.value as Map<dynamic, dynamic>;
        categories.forEach((category, categoryData) {
          Map<dynamic, dynamic> materialsInCategory =
              categoryData as Map<dynamic, dynamic>;
          materialsInCategory.forEach((key, value) {
            Map<dynamic, dynamic> material = value as Map<dynamic, dynamic>;
            material['id'] = key;
            material['category'] = category;
            materials.add(Map<String, dynamic>.from(material));
          });
        });
      }

      return materials;
    } catch (e) {
      print("Error getting study materials: $e");
      throw e;
    }
  }
}