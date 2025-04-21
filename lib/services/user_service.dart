import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import 'realtime_db_service.dart';

class UserService {
  final RealtimeDbService _dbService;
  
  UserService(this._dbService);
  
  Future<void> createUser(UserModel user) async {
    try {
      print("UserService: Starting to create user");
      print("Database path: users/${user.uid}");

      // Now try to write the user data
      await _dbService.dbRef.child('users').child(user.uid).set(user.toMap());
      print("User data written successfully");
    } catch (e) {
      print("Error creating user in database: $e");
      throw e;
    }
  }

  // Get user data
  Future<UserModel> getUserData(String uid) async {
    try {
      DatabaseReference userRef = _dbService.dbRef.child('users').child(uid);
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
      DataSnapshot snapshot = await _dbService.dbRef.child('users').get();

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
      await _dbService.dbRef.child('users').child(uid).update(data);
    } catch (e) {
      print("Error updating user: $e");
      throw e;
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      DataSnapshot snapshot =
          await _dbService.dbRef.child('users').orderByChild('role').equalTo(role).get();

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
          await _dbService.dbRef
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

      await _dbService.dbRef.child('users').child(clientId).update(updates);
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
}