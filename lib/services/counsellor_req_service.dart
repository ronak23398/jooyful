import 'package:firebase_database/firebase_database.dart';
import 'realtime_db_service.dart';

class CounselorRequestService {
  final RealtimeDbService _dbService;
  
  CounselorRequestService(this._dbService);
  
  Future<void> requestCounselor(String clientId) async {
    try {
      await _dbService.dbRef.child('counselor_requests').child(clientId).set({
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
      await _dbService.dbRef.child('counselor_requests').child(clientId).set({
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
      DataSnapshot snapshot = await _dbService.dbRef.child('counselor_requests').get();

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
          await _dbService.dbRef.child('counselor_requests').child(clientId).get();
      return snapshot.exists;
    } catch (e) {
      print("Error checking client counselor request: $e");
      return false;
    }
  }

  // Update counselor request status
  Future<void> updateCounselorRequestStatus(
    String clientId,
    String status,
  ) async {
    try {
      print("Updating request status for client $clientId to $status");
      await _dbService.dbRef.child('counselor_requests').child(clientId).update({
        'status': status,
      });
      print("Request status updated successfully");
    } catch (e) {
      print("Error updating request status: $e");
      throw e;
    }
  }
}