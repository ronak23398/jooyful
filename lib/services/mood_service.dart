import 'package:firebase_database/firebase_database.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class MoodService {
  final RealtimeDbService _dbService;

  MoodService(this._dbService);

  // Save the user's mood for today
  Future<void> saveMood(String userId, String mood, String emoji) async {
    try {
      final todayDate = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD format
      final moodData = {
        'mood': mood,
        'emoji': emoji,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Store mood under the user's node
      await _dbService.dbRef.child('users/$userId/moods/$todayDate').set(moodData);
    } catch (e) {
      throw Exception('Failed to save mood: ${e.toString()}');
    }
  }

  // Get all moods for a user in the last week
  Future<Map<String, Map<String, dynamic>>> getWeeklyMoods(String userId) async {
    try {
      // Calculate date for last 7 days
      final today = DateTime.now();
      final lastWeekDate = today.subtract(Duration(days: 6)); // 7 days including today
      
      final startDate = lastWeekDate.toString().substring(0, 10);
      final endDate = today.toString().substring(0, 10);

      // Query moods for the last week
      final DataSnapshot snapshot = await _dbService.dbRef
          .child('users/$userId/moods')
          .orderByKey()
          .startAt(startDate)
          .endAt(endDate)
          .get();

      if (snapshot.value == null) {
        return {};
      }

      // Convert to Map<String, Map<String, dynamic>> where key is the date
      Map<String, Map<String, dynamic>> moodData = {};
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      
      values.forEach((key, value) {
        moodData[key.toString()] = Map<String, dynamic>.from(value as Map);
      });

      return moodData;
    } catch (e) {
      throw Exception('Failed to get weekly moods: ${e.toString()}');
    }
  }
}