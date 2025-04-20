import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:jooyful_heaven/models/article_model.dart';
import '../models/user_model.dart';
import '../models/test_model.dart';

Future<Map<String, dynamic>> processUnreadMessagesInIsolate(Map<String, dynamic> params) async {
  final Map<dynamic, dynamic> values = params['values'];
  final String readerId = params['readerId'];
  
  Map<String, dynamic> updates = {};
  values.forEach((key, value) {
    // Skip participants node
    if (key == 'participants') return;
    
    if (value is Map && value['senderId'] != readerId) {
      updates[key.toString()] = true;
    }
  });
  
  return updates;
}

class RealtimeDbService {
  late final DatabaseReference _db;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  RealtimeDbService() {
    // Initialize with the correct region URL
    FirebaseDatabase database = FirebaseDatabase.instance;
    database.databaseURL =
        'https://jooyful-hea-default-rtdb.asia-southeast1.firebasedatabase.app';
    _db = database.ref();
  }
  Future<void> createUser(UserModel user) async {
    try {
      print("RealtimeDbService: Starting to create user");
      print("Database path: users/${user.uid}");

      // Now try to write the user data
      await _db.child('users').child(user.uid).set(user.toMap());
      print("User data written successfully");
    } catch (e) {
      print("Error creating user in database: $e");
      throw e;
    }
  }

  // Get user data
  Future<UserModel> getUserData(String uid) async {
    try {
      DatabaseReference userRef = _db.child('users').child(uid);
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        return UserModel.fromMap(Map<String, dynamic>.from(data));
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error getting user data: $e");
      throw e;
    }
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      DataSnapshot snapshot = await _db.child('users').get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<UserModel> users = [];

        data.forEach((key, value) {
          if (value is Map) {
            users.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
          }
        });

        return users;
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting all users: $e");
      throw e;
    }
  }

  // Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.child('users').child(uid).update(data);
    } catch (e) {
      print("Error updating user: $e");
      throw e;
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      DataSnapshot snapshot =
          await _db.child('users').orderByChild('role').equalTo(role).get();

      List<UserModel> users = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          users.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
        });
      }

      return users;
    } catch (e) {
      print("Error getting users by role: $e");
      throw e;
    }
  }

  // Get assigned clients for a counselor
  Future<List<UserModel>> getAssignedClients(String counselorId) async {
    try {
      DataSnapshot snapshot =
          await _db
              .child('users')
              .orderByChild('assignedCounselorId')
              .equalTo(counselorId)
              .get();

      List<UserModel> clients = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          clients.add(UserModel.fromMap(Map<String, dynamic>.from(value)));
        });
      }

      return clients;
    } catch (e) {
      print("Error getting assigned clients: $e");
      throw e;
    }
  }

  Future<void> requestCounselor(String clientId) async {
    try {
      await _db.child('counselor_requests').child(clientId).set({
        'clientId': clientId,
        'status': 'pending',
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error requesting counselor: $e");
      throw e;
    }
  }

  Future<void> createCounselorRequest(String clientId) async {
    try {
      print("Creating counselor request for client $clientId");
      await _db.child('counselor_requests').child(clientId).set({
        'clientId': clientId,
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print("Counselor request created successfully");
    } catch (e) {
      print("Error creating counselor request: $e");
      throw e;
    }
  }

  // Get counselor requests
  Future<List<Map<String, dynamic>>> getCounselorRequests() async {
    try {
      DataSnapshot snapshot = await _db.child('counselor_requests').get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> requests = [];

        data.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> request = Map<String, dynamic>.from(value);
            request['requestId'] = key.toString();
            requests.add(request);
          }
        });

        return requests;
      } else {
        return [];
      }
    } catch (e) {
      print("Error getting counselor requests: $e");
      throw e;
    }
  }

  // Check if a specific client has a counselor request
  Future<bool> hasClientCounselorRequest(String clientId) async {
    try {
      // Only check the specific client's request instead of loading all requests
      DataSnapshot snapshot =
          await _db.child('counselor_requests').child(clientId).get();
      return snapshot.exists;
    } catch (e) {
      print("Error checking client counselor request: $e");
      return false;
    }
  }

  // Assign counselor to client
  Future<void> assignCounselorToClient(
    String clientId,
    String? counselorId,
  ) async {
    try {
      print(
        "Attempting to ${counselorId == null ? 'unassign counselor from' : 'assign counselor to'} client $clientId",
      );

      Map<String, dynamic> updates = {};

      if (counselorId == null) {
        // Remove the field completely for unassigning
        updates['assignedCounselorId'] = null;
      } else {
        updates['assignedCounselorId'] = counselorId;
      }

      await _db.child('users').child(clientId).update(updates);
      print(
        "Counselor ${counselorId == null ? 'unassigned' : 'assigned'} successfully",
      );
    } catch (e) {
      print(
        "Error ${counselorId == null ? 'unassigning' : 'assigning'} counselor: $e",
      );
      throw e;
    }
  }

  // Update counselor request status
  Future<void> updateCounselorRequestStatus(
    String clientId,
    String status,
  ) async {
    try {
      print("Updating request status for client $clientId to $status");
      await _db.child('counselor_requests').child(clientId).update({
        'status': status,
      });
      print("Request status updated successfully");
    } catch (e) {
      print("Error updating request status: $e");
      throw e;
    }
  }

  // Upload article
  Future<void> uploadArticle(
    String title,
    String content,
    String category,
  ) async {
    try {
      String articleId =
          _db.child('articles').child(category).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _db.child('articles').child(category).child(articleId).set({
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
      DataSnapshot snapshot = await _db.child('articles').child(category).get();

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
      DataSnapshot snapshot = await _db.child('articles').get();

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
  // Add article
  Future<void> addArticle(ArticleModel article) async {
    try {
      String category = article.category;
      String articleId =
          _db.child('articles').child(category).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _db.child('articles').child(category).child(articleId).set({
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
      DataSnapshot snapshot = await _db.child('articles').get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> categories =
            snapshot.value as Map<dynamic, dynamic>;

        for (var category in categories.keys) {
          Map<dynamic, dynamic> articlesInCategory =
              categories[category] as Map<dynamic, dynamic>;

          if (articlesInCategory.containsKey(articleId)) {
            await _db
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
          _db.child('study_materials').child(category).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _db.child('study_materials').child(category).child(materialId).set({
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
      DataSnapshot snapshot = await _db.child('study_materials').get();

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

  // Save test result
  Future<void> saveTestResult(String userId, String testId, int score) async {
    try {
      await _db.child('test_results').child(userId).child(testId).set({
        'score': score,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error saving test result: $e");
      throw e;
    }
  }

  // Get test results for a user
  Future<List<Map<String, dynamic>>> getTestResults(String userId) async {
    try {
      DataSnapshot snapshot =
          await _db.child('test_results').child(userId).get();

      List<Map<String, dynamic>> results = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((testId, value) {
          Map<dynamic, dynamic> result = value as Map<dynamic, dynamic>;
          result['testId'] = testId;
          results.add(Map<String, dynamic>.from(result));
        });
      }

      return results;
    } catch (e) {
      print("Error getting test results: $e");
      throw e;
    }
  }

  // Get client test results (for counselors)
  Future<Map<String, dynamic>> getClientTestResults(String clientId) async {
    try {
      DataSnapshot snapshot =
          await _db.child('test_results').child(clientId).get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> results = snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(results);
      }

      return {};
    } catch (e) {
      print("Error getting client test results: $e");
      throw e;
    }
  }

  // Add counselor comment to test result
  Future<void> addTestResultComment(
    String clientId,
    String testId,
    String comment,
  ) async {
    try {
      await _db.child('test_results').child(clientId).child(testId).update({
        'counselorComment': comment,
        'commentTimestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error adding comment to test result: $e");
      throw e;
    }
  }

  // Save chat message
  Future<void> saveChatMessage(
    String clientId,
    String counselorId,
    String senderId,
    String text,
  ) async {
    try {
      String chatId = "${clientId}_${counselorId}";
      String messageId =
          _db.child('chats').child(chatId).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // First, ensure the chat has participant data
      await _db.child('chats').child(chatId).child('participants').update({
        clientId: true,
        counselorId: true,
      });

      // Then save the message
      await _db.child('chats').child(chatId).child(messageId).set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp,
        'isRead': false,
      });
    } catch (e) {
      print("Error saving chat message: $e");
      throw e;
    }
  }

  // Get chat messages
  Future<List<Map<String, dynamic>>> getChatMessages(
  String clientId,
  String counselorId, {
  int limit = 30,  // Load 30 messages at a time
  String? lastMessageKey,
}) async {
  try {
    String chatId = "${clientId}_${counselorId}";
    Query query = _db
        .child('chats')
        .child(chatId)
        .orderByChild('timestamp');
    
    // Add pagination
    if (lastMessageKey != null) {
      DataSnapshot keySnapshot = await _db
          .child('chats')
          .child(chatId)
          .child(lastMessageKey)
          .get();
      if (keySnapshot.exists && keySnapshot.value is Map) {
        int lastTimestamp = (keySnapshot.value as Map)['timestamp'] ?? 0;
        query = query.endAt(lastTimestamp);
      }
    }
    
    query = query.limitToLast(limit);
    DataSnapshot snapshot = await query.get();
    
    List<Map<String, dynamic>> messages = [];
    
    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        // Skip participants node
        if (key == 'participants') return;
        
        if (value is Map) {
          Map<dynamic, dynamic> message = value;
          messages.add({
            'id': key,
            ...Map<String, dynamic>.from(message),
          });
        }
      });
    }
    
    return messages;
  } catch (e) {
    print("Error getting chat messages: $e");
    throw e;
  }
}

  // Mark chat messages as read
 Future<void> markMessagesAsRead(
  String clientId,
  String counselorId,
  String readerId,
) async {
  try {
    String chatId = "${clientId}_${counselorId}";
    
    // First get unread messages
    DataSnapshot snapshot = await _db
        .child('chats')
        .child(chatId)
        .orderByChild('isRead')
        .equalTo(false)
        .get();
    
    if (snapshot.exists && snapshot.value is Map) {
      Map values = snapshot.value as Map;
      
      // Process which messages need updates in isolate
      final updates = await compute(
        processUnreadMessagesInIsolate, 
        {'values': values, 'readerId': readerId}
      );
      
      // Apply all updates in one operation on main thread
      final Map<String, dynamic> dbUpdates = {};
      updates.forEach((key, value) {
        dbUpdates['/chats/$chatId/$key/isRead'] = true;
      });
      
      if (dbUpdates.isNotEmpty) {
        await _db.update(dbUpdates);
      }
    }
  } catch (e) {
    print("Error marking messages as read: $e");
    throw e;
  }
}

  // Create appointment request
  Future<void> createAppointmentRequest(
    String clientId,
    String counselorId,
    String date,
    String time,
  ) async {
    try {
      String appointmentId =
          _db.child('appointments').child(clientId).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      await _db.child('appointments').child(clientId).child(appointmentId).set({
        'clientId': clientId,
        'counselorId': counselorId,
        'date': date,
        'time': time,
        'status': 'pending',
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error creating appointment request: $e");
      throw e;
    }
  }

  // Get appointments for client
  Future<List<Map<String, dynamic>>> getClientAppointments(
    String clientId,
  ) async {
    try {
      DataSnapshot snapshot =
          await _db.child('appointments').child(clientId).get();

      List<Map<String, dynamic>> appointments = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Map<dynamic, dynamic> appointment = value as Map<dynamic, dynamic>;
          appointment['id'] = key;
          appointments.add(Map<String, dynamic>.from(appointment));
        });
      }

      return appointments;
    } catch (e) {
      print("Error getting client appointments: $e");
      throw e;
    }
  }

  // Get appointments for counselor (across all clients)
  Future<List<Map<String, dynamic>>> getCounselorAppointments(
    String counselorId,
  ) async {
    try {
      // Get all appointments
      DataSnapshot snapshot = await _db.child('appointments').get();
      List<Map<String, dynamic>> appointments = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> clientAppointments =
            snapshot.value as Map<dynamic, dynamic>;

        // Loop through each client's appointments
        clientAppointments.forEach((clientId, clientAppts) {
          Map<dynamic, dynamic> appts = clientAppts as Map<dynamic, dynamic>;

          // Loop through each appointment for this client
          appts.forEach((appointmentId, appointmentData) {
            Map<dynamic, dynamic> appointment =
                appointmentData as Map<dynamic, dynamic>;

            // Check if this appointment is for the specified counselor
            if (appointment['counselorId'] == counselorId) {
              appointment['id'] = appointmentId;
              appointment['clientId'] = clientId;
              appointments.add(Map<String, dynamic>.from(appointment));
            }
          });
        });
      }

      return appointments;
    } catch (e) {
      print("Error getting counselor appointments: $e");
      throw e;
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String clientId,
    String status,
  ) async {
    try {
      await _db
          .child('appointments')
          .child(clientId)
          .child(appointmentId)
          .update({'status': status});
    } catch (e) {
      print("Error updating appointment status: $e");
      throw e;
    }
  }

  // Create test on Firebase
  Future<void> createTest(TestModel test) async {
    try {
      await _db.child('tests').child(test.id).set(test.toMap());
    } catch (e) {
      print("Error creating test: $e");
      throw e;
    }
  }

  // Get all tests
  Future<List<TestModel>> getAllTests() async {
    try {
      DataSnapshot snapshot = await _db.child('tests').get();
      List<TestModel> tests = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          tests.add(
            TestModel.fromMap(Map<String, dynamic>.from(value), key.toString()),
          );
        });
      }

      return tests;
    } catch (e) {
      print("Error getting tests: $e");
      throw e;
    }
  }

  // Test database connection
  Future<bool> testConnection() async {
    try {
      print("Testing database connection...");
      await _db.child('test').set({
        'timestamp': ServerValue.timestamp,
        'test': 'connection',
      });
      print("✅ Database connection successful");
      return true;
    } catch (e) {
      print("❌ Database connection failed: $e");
      return false;
    }
  }

  // Get data at a specific path
  Future<dynamic> get(String path) async {
    try {
      final reference = _database.ref(path);
      final snapshot = await reference.get();
      return snapshot.value;
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  // Set data at a specific path
  Future<void> set(String path, dynamic data) async {
    try {
      final reference = _database.ref(path);
      await reference.set(data);
    } catch (e) {
      throw Exception('Failed to set data: $e');
    }
  }

  // Update specific fields at a path
  Future<void> update(String path, Map<String, dynamic> data) async {
    try {
      final reference = _database.ref(path);
      await reference.update(data);
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  // Delete data at a specific path
  Future<void> delete(String path) async {
    try {
      final reference = _database.ref(path);
      await reference.remove();
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }

  // Query data where a field equals a specific value
  Future<List<dynamic>> getWhere(
    String path,
    String field,
    dynamic value,
  ) async {
    try {
      final reference = _database.ref(path);
      final query = reference.orderByChild(field).equalTo(value);
      final snapshot = await query.get();

      if (snapshot.value == null) return [];

      final resultMap = snapshot.value as Map<dynamic, dynamic>;
      final results = <dynamic>[];

      resultMap.forEach((key, value) {
        if (value is Map) {
          // Add the key as part of the data
          final data = Map<String, dynamic>.from(value as Map);
          data['id'] = key;
          results.add(data);
        }
      });

      return results;
    } catch (e) {
      throw Exception('Failed to query data: $e');
    }
  }

  // Listen for changes at a specific path
  Stream<DatabaseEvent> listenToPath(String path) {
    final reference = _database.ref(path);
    return reference.onValue;
  }

  // Listen for child added events at a specific path
  Stream<DatabaseEvent> listenToChildAdded(String path) {
    final reference = _database.ref(path);
    return reference.onChildAdded;
  }

  // Listen for child changed events at a specific path
  Stream<DatabaseEvent> listenToChildChanged(String path) {
    final reference = _database.ref(path);
    return reference.onChildChanged;
  }

  // Add a new item with an auto-generated key
  Future<String> push(String path, dynamic data) async {
    try {
      final reference = _database.ref(path).push();
      await reference.set(data);
      return reference.key ?? '';
    } catch (e) {
      throw Exception('Failed to push data: $e');
    }
  }
}
