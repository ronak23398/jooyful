import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'realtime_db_service.dart';

// Top-level function for isolate processing
Future<Map<String, bool>> processUnreadMessagesInIsolate(Map<dynamic, dynamic> params) async {
  final Map values = params['values'];
  final String readerId = params['readerId'];
  final Map<String, bool> updates = {};
  
  values.forEach((key, value) {
    // Skip participants node
    if (key == 'participants') return;
    
    if (value is Map && value['isRead'] == false && value['senderId'] != readerId) {
      updates[key] = true;
    }
  });
  
  return updates;
}

class ChatService {
  final RealtimeDbService _dbService;
  
  ChatService(this._dbService);
  
  // Save chat message with batch updates
  Future<void> saveChatMessage(
    String clientId,
    String counselorId,
    String senderId,
    String text,
  ) async {
    try {
      String chatId = "${clientId}_${counselorId}";
      String messageId =
          _dbService.dbRef.child('chats').child(chatId).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Use batch update for efficiency
      final Map<String, dynamic> updates = {};
      
      // Ensure the chat has participant data
      updates['chats/$chatId/participants/$clientId'] = true;
      updates['chats/$chatId/participants/$counselorId'] = true;
      
      // Add message data
      updates['chats/$chatId/$messageId/senderId'] = senderId;
      updates['chats/$chatId/$messageId/text'] = text;
      updates['chats/$chatId/$messageId/timestamp'] = ServerValue.timestamp;
      updates['chats/$chatId/$messageId/isRead'] = false;
      
      // Execute batch update
      await _dbService.dbRef.update(updates);
    } catch (e) {
      print("Error saving chat message: $e");
      throw e;
    }
  }

  // Get chat messages with efficient pagination
  Future<List<Map<String, dynamic>>> getChatMessages(
    String clientId,
    String counselorId, {
    int limit = 30,
    String? lastMessageKey,
  }) async {
    try {
      String chatId = "${clientId}_${counselorId}";
      
      // Create base query - more efficient with startAfter instead of endAt
      Query query = _dbService.dbRef
          .child('chats')
          .child(chatId)
          .orderByChild('timestamp');
      
      // Add pagination with startAfter for better performance
      if (lastMessageKey != null) {
        DataSnapshot keySnapshot = await _dbService.dbRef
            .child('chats')
            .child(chatId)
            .child(lastMessageKey)
            .get();
        
        if (keySnapshot.exists && keySnapshot.value is Map) {
          int lastTimestamp = (keySnapshot.value as Map)['timestamp'] ?? 0;
          // Use startAfter for forward pagination (more efficient)
          query = query.startAfter(lastTimestamp);
        }
      }
      
      // Limit results
      query = query.limitToLast(limit);
      
      // Execute query
      DataSnapshot snapshot = await query.get();
      
      // Process results in isolate if there's significant data
      if (snapshot.exists && snapshot.value is Map) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        
        // Filter out participants node
        values.remove('participants');
        
        // Process messages directly if small amount
        if (values.length <= 10) {
          return _processMessagesMap(values);
        } else {
          // Process in isolate for large datasets
          return await compute(_processMessagesMapInIsolate, values);
        }
      }
      
      return [];
    } catch (e) {
      print("Error getting chat messages: $e");
      throw e;
    }
  }
  
  // Helper method to process messages outside isolate
  List<Map<String, dynamic>> _processMessagesMap(Map<dynamic, dynamic> values) {
    List<Map<String, dynamic>> messages = [];
    
    values.forEach((key, value) {
      if (value is Map) {
        messages.add({
          'id': key,
          ...Map<String, dynamic>.from(value),
        });
      }
    });
    
    return messages;
  }
  
  // Helper method for isolate processing
  static List<Map<String, dynamic>> _processMessagesMapInIsolate(Map<dynamic, dynamic> values) {
    List<Map<String, dynamic>> messages = [];
    
    values.forEach((key, value) {
      if (value is Map) {
        messages.add({
          'id': key,
          ...Map<String, dynamic>.from(value),
        });
      }
    });
    
    return messages;
  }

  // Mark chat messages as read with optimized batch update
  Future<void> markMessagesAsRead(
    String clientId,
    String counselorId,
    String readerId,
  ) async {
    try {
      String chatId = "${clientId}_${counselorId}";
      
      // First get unread messages
      DataSnapshot snapshot = await _dbService.dbRef
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
        
        // Only update if we have messages to mark
        if (updates.isNotEmpty) {
          // Apply all updates in one batch operation
          final Map<String, dynamic> dbUpdates = {};
          updates.forEach((key, _) {
            dbUpdates['/chats/$chatId/$key/isRead'] = true;
          });
          
          await _dbService.dbRef.update(dbUpdates);
        }
      }
    } catch (e) {
      print("Error marking messages as read: $e");
      throw e;
    }
  }
}