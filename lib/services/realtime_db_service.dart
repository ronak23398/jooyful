import 'package:firebase_database/firebase_database.dart';

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
          final data = Map<String, dynamic>.from(value);
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

  // Get the database reference
  DatabaseReference get dbRef => _db;
}