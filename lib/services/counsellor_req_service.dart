import 'package:firebase_database/firebase_database.dart';
import 'realtime_db_service.dart';

class CounselorRequestService {
  final RealtimeDbService _dbService;
  
  CounselorRequestService(this._dbService);
  
  Future<void> requestCounselor(String clientId) async {
  try {
    // Create a unique request ID (could use push() to generate one)
    String requestId = _dbService.dbRef.child('counselor_requests').push().key ?? "";
    
    await _dbService.dbRef.child('counselor_requests').child(requestId).set({
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
    final snapshot = await _dbService.dbRef.child('counselor_requests').get();
    final List<Map<String, dynamic>> requests = [];
    
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      
      data.forEach((key, value) {
        // Check if value is a Map and not a primitive value
        if (value is Map) {
          final request = Map<String, dynamic>.from(value);
          request['id'] = key; // Include the database key as the ID
          requests.add(request);
        }
      });
    }
    
    return requests;
  } catch (e) {
    print("Error fetching counselor requests: $e");
    throw e;
  }
}

  // Check if a specific client has a counselor request
 Future<bool> hasClientCounselorRequest(String clientId) async {
  try {
    DataSnapshot snapshot = await _dbService.dbRef
        .child('counselor_requests')
        .orderByChild('clientId')
        .equalTo(clientId)
        .get();
    return snapshot.exists && snapshot.value != null;
  } catch (e) {
    print("Error checking client counselor request: $e");
    return false;
  }
}

  // Update counselor request status
 // This should be in your CounselorRequestService class
Future<void> updateCounselorRequestStatus(String requestId, String status) async {
  try {
    // Update the status of the specific request
    await _dbService.dbRef.child('counselor_requests').child(requestId).update({
      'status': status
    });
  } catch (e) {
    print("Error updating counselor request status: $e");
    throw e;
  }
}
}