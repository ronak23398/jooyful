import 'package:firebase_database/firebase_database.dart';
import '../models/test_model.dart';
import 'realtime_db_service.dart';

class TestService {
  final RealtimeDbService _dbService;
  
  TestService(this._dbService);
  
  // Create test on Firebase
  Future<void> createTest(TestModel test) async {
    try {
      await _dbService.dbRef.child('tests').child(test.id).set(test.toMap());
    } catch (e) {
      print("Error creating test: $e");
      throw e;
    }
  }

  // Get all tests
  Future<List<TestModel>> getAllTests() async {
    try {
      DataSnapshot snapshot = await _dbService.dbRef.child('tests').get();
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

  // Save test result
  Future<void> saveTestResult(String userId, String testId, int score) async {
    try {
      await _dbService.dbRef.child('test_results').child(userId).child(testId).set({
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
          await _dbService.dbRef.child('test_results').child(userId).get();

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
          await _dbService.dbRef.child('test_results').child(clientId).get();

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
      await _dbService.dbRef.child('test_results').child(clientId).child(testId).update({
        'counselorComment': comment,
        'commentTimestamp': ServerValue.timestamp,
      });
    } catch (e) {
      print("Error adding comment to test result: $e");
      throw e;
    }
  }
}