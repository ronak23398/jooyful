import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:jooyful_heaven/services/db_utils.dart';
import 'realtime_db_service.dart';

class ChatService {
  final RealtimeDbService _dbService;
  
  ChatService(this._dbService);
  
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
          _dbService.dbRef.child('chats').child(chatId).push().key ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // First, ensure the chat has participant data
      await _dbService.dbRef.child('chats').child(chatId).child('participants').update({
        clientId: true,
        counselorId: true,
      });

      // Then save the message
      await _dbService.dbRef.child('chats').child(chatId).child(messageId).set({
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
      Query query = _dbService.dbRef
          .child('chats')
          .child(chatId)
          .orderByChild('timestamp');
      
      // Add pagination
      if (lastMessageKey != null) {
        DataSnapshot keySnapshot = await _dbService.dbRef
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
        
        // Apply all updates in one operation on main thread
        final Map<String, dynamic> dbUpdates = {};
        updates.forEach((key, value) {
          dbUpdates['/chats/$chatId/$key/isRead'] = true;
        });
        
        if (dbUpdates.isNotEmpty) {
          await _dbService.dbRef.update(dbUpdates);
        }
      }
    } catch (e) {
      print("Error marking messages as read: $e");
      throw e;
    }
  }
}