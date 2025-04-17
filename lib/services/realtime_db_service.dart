import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class RealtimeDbService {
  late final DatabaseReference _db;
  
  RealtimeDbService() {
    // Initialize with the correct region URL
    FirebaseDatabase database = FirebaseDatabase.instance;
    database.databaseURL = 'https://jooyful-hea-default-rtdb.asia-southeast1.firebasedatabase.app';
    _db = database.ref();
  }
  
  // Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      print("RealtimeDbService: Starting to create user");
      print("Database path: users/${user.uid}");
      
      // Test if the database connection works with a simpler write
      await _db.child('test').set({
        'timestamp': ServerValue.timestamp
      });
      print("Test write successful");
      
      // Now try to write the user data
      await _db.child('users').child(user.uid).set(user.toJson());
      print("User data written successfully");
    } catch (e) {
      print("Error creating user in database: $e");
      throw e;
    }
  }
  
  // Get user data
  Future<UserModel> getUserData(String uid) async {
    try {
      DataSnapshot snapshot = await _db.child('users').child(uid).get();
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.value as Map<dynamic, dynamic>);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error getting user data: $e");
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
  
  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      DataSnapshot snapshot = await _db.child('users').get();
      List<UserModel> users = [];
      
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          users.add(UserModel.fromJson(value as Map<dynamic, dynamic>));
        });
      }
      
      return users;
    } catch (e) {
      print("Error getting all users: $e");
      throw e;
    }
  }
  
  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      DataSnapshot snapshot = await _db.child('users')
          .orderByChild('role')
          .equalTo(role)
          .get();
      
      List<UserModel> users = [];
      
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          users.add(UserModel.fromJson(value as Map<dynamic, dynamic>));
        });
      }
      
      return users;
    } catch (e) {
      print("Error getting users by role: $e");
      throw e;
    }
  }
  
  // Request a counselor
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
  
  // Get counselor requests
  Future<List<Map<String, dynamic>>> getCounselorRequests() async {
    try {
      DataSnapshot snapshot = await _db.child('counselor_requests')
          .orderByChild('status')
          .equalTo('pending')
          .get();
      
      List<Map<String, dynamic>> requests = [];
      
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Map<dynamic, dynamic> request = value as Map<dynamic, dynamic>;
          // Attach client ID as key
          request['clientId'] = key;
          requests.add(Map<String, dynamic>.from(request));
        });
      }
      
      return requests;
    } catch (e) {
      print("Error getting counselor requests: $e");
      throw e;
    }
  }
  
  // Assign counselor to client
  Future<void> assignCounselorToClient(String clientId, String counselorId) async {
    try {
      // Update client's assigned counselor
      await _db.child('users').child(clientId).update({
        'assignedCounselorId': counselorId,
      });
      
      // Update the request status
      await _db.child('counselor_requests').child(clientId).update({
        'status': 'completed',
        'counselorId': counselorId,
      });
    } catch (e) {
      print("Error assigning counselor: $e");
      throw e;
    }
  }
  
  // Update counselor request status
  Future<void> updateCounselorRequestStatus(String clientId, String status) async {
    try {
      await _db.child('counselor_requests').child(clientId).update({
        'status': status,
      });
    } catch (e) {
      print("Error updating counselor request: $e");
      throw e;
    }
  }
  
  // Upload article
  Future<void> uploadArticle(String title, String content, String category) async {
    try {
      String articleId = _db.child('articles').child(category).push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
      
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
  Future<List<Map<String, dynamic>>> getArticlesByCategory(String category) async {
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
  
  // Add counselor comments to test result
  Future<void> addCommentToTestResult(String clientId, String testId, String comment) async {
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
  Future<void> saveChatMessage(String clientId, String counselorId, String senderId, String text) async {
    try {
      String chatId = "${clientId}_${counselorId}";
      String messageId = _db.child('chats').child(chatId).push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      await _db.child('chats').child(chatId).child(messageId).set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error saving chat message: $e");
      throw e;
    }
  }
  
  // Get chat messages
  Future<List<Map<String, dynamic>>> getChatMessages(String clientId, String counselorId) async {
    try {
      String chatId = "${clientId}_${counselorId}";
      DataSnapshot snapshot = await _db.child('chats').child(chatId).orderByChild('timestamp').get();
      
      List<Map<String, dynamic>> messages = [];
      
      if (snapshot.exists) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Map<dynamic, dynamic> message = value as Map<dynamic, dynamic>;
          message['id'] = key;
          messages.add(Map<String, dynamic>.from(message));
        });
      }
      
      return messages;
    } catch (e) {
      print("Error getting chat messages: $e");
      throw e;
    }
  }
  
  // Create appointment request
  Future<void> createAppointmentRequest(String clientId, String counselorId, String date, String time) async {
    try {
      String appointmentId = _db.child('appointments').child(clientId).push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      await _db.child('appointments').child(clientId).child(appointmentId).set({
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
  
  // Update appointment status
  Future<void> updateAppointmentStatus(String clientId, String appointmentId, String status) async {
    try {
      await _db.child('appointments').child(clientId).child(appointmentId).update({
        'status': status,
      });
    } catch (e) {
      print("Error updating appointment status: $e");
      throw e;
    }
  }
  
  // Test database connection
  Future<bool> testConnection() async {
    try {
      print("Testing database connection...");
      await _db.child('test').set({
        'timestamp': ServerValue.timestamp,
        'test': 'connection'
      });
      print("✅ Database connection successful");
      return true;
    } catch (e) {
      print("❌ Database connection failed: $e");
      return false;
    }
  }
}