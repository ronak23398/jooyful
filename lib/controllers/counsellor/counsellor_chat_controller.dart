import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/chat_model.dart';
import '../../services/realtime_db_service.dart';
import '../../models/user_model.dart';
import '../auth_controllers.dart';

// Top-level function to be run in isolate
Future<List<ChatModel>> processMessagesInIsolate(Map<String, dynamic> params) async {
  final List<Map<String, dynamic>> messagesData = params['messagesData'];
  
  return messagesData
      .where((map) => map['id'] != null) // Filter out potential invalid entries
      .map((map) => ChatModel.fromMap(map, map['id'] ?? ''))
      .toList();
}

Future<ChatModel?> processNewMessageInIsolate(Map<String, dynamic> params) async {
  final Map<dynamic, dynamic> data = params['data'];
  final String messageId = params['messageId'];
  
  try {
    if (data == null) return null;
    
    Map<String, dynamic> messageData = {};
    data.forEach((key, val) {
      messageData[key.toString()] = val;
    });
    
    messageData['id'] = messageId;
    return ChatModel.fromMap(messageData, messageData['id'] ?? '');
  } catch (e) {
    print('Error processing message in isolate: $e');
    return null;
  }
}

// Helper function to spawn isolate
Future<List<ChatModel>> processMessagesWithIsolate(List<Map<String, dynamic>> messagesData) async {
  final response = await compute(
    processMessagesInIsolate, 
    {'messagesData': messagesData}
  );
  return response;
}

class CounselorChatController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();
  
  final RxBool isLoading = false.obs;
  final RxList<ChatModel> messages = <ChatModel>[].obs;
  final RxBool canSendMessage = false.obs;
  final Rx<UserModel?> client = Rx<UserModel?>(null);
  final RxBool isClientLoaded = false.obs;
  final RxString clientStatus = ''.obs;
  final RxString clientStatusMessage = ''.obs;
  final RxString sessionNotes = ''.obs;
  final RxList<Map<String, dynamic>> clientTestResults = <Map<String, dynamic>>[].obs;
  
  String? _counselorId;
  String? _clientId;
  StreamSubscription? _chatSubscription;
  
@override
void onInit() {
  super.onInit();
  
  // Debug what arguments are being received
  print("Arguments received: ${Get.arguments}");
  
  _counselorId = _authController.userModel.value?.uid;
  _clientId = Get.arguments?['clientId'];
  
  print("ClientId: $_clientId");
  print("CounselorId: $_counselorId");
  
  if (_counselorId != null && _clientId != null) {
    loadChatMessages();
    loadClientData();
    setupMessageListener();
    loadClientTestResults();
    loadSessionNotes();
    checkClientStatus();
  } else {
    Get.snackbar('Error', 'Could not load chat. Missing client or counselor ID.');
  }
}
  
  @override
void onClose() {
  messageController.dispose();
  _chatSubscription?.cancel();
  super.onClose();
}
  
  Future<void> loadClientData() async {
    try {
      if (_clientId != null && _clientId!.isNotEmpty) {
        client.value = await _dbService.getUserData(_clientId!);
        isClientLoaded.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load client data: ${e.toString()}');
    }
  }
  
  Future<void> loadChatMessages() async {
  print("load chatmessages started");
  try {
    isLoading.value = true;
    
    if (_clientId != null && _counselorId != null) {
      // Mark messages as read first - keep this on main thread as it's quick
      await _dbService.markMessagesAsRead(_clientId!, _counselorId!, _counselorId!);
      
      // Then load messages - fetch data on main thread
      List<Map<String, dynamic>> chatData = await _dbService.getChatMessages(_clientId!, _counselorId!);
      
      // Process in isolate
      final chatMessages = await processMessagesWithIsolate(chatData);
      
      // Sort after receiving from isolate
      chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      messages.value = chatMessages;
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
  } finally {
    isLoading.value = false;
  }
}
  
  Future<void> loadClientTestResults() async {
    try {
      if (_clientId != null) {
        // In a real application, fetch this from Firebase
        // For now, using mock data
        clientTestResults.value = [
          {
            'testId': 'anxiety_test',
            'testName': 'Anxiety Assessment',
            'score': 7,
            'maxScore': 20,
            'date': '2025-04-10',
          },
          {
            'testId': 'depression_test',
            'testName': 'Depression Screening',
            'score': 12,
            'maxScore': 30,
            'date': '2025-04-05',
          },
        ];
      }
    } catch (e) {
      print('Error loading client test results: ${e.toString()}');
    }
  }
  
  Future<void> loadSessionNotes() async {
    try {
      if (_clientId != null && _counselorId != null) {
        // In a real app, this would be loaded from Firebase
        // For now, using mock data
        sessionNotes.value = 'Client has been showing progress in managing anxiety. ' +
            'Recommended daily mindfulness exercises and regular journaling. ' +
            'Follow up on sleep patterns in the next session.';
      }
    } catch (e) {
      print('Error loading session notes: ${e.toString()}');
    }
  }
  
  Future<void> saveSessionNotes(String notes) async {
    try {
      if (_clientId != null && _counselorId != null) {
        // In a real app, this would save to Firebase
        sessionNotes.value = notes;
        Get.snackbar('Success', 'Session notes saved successfully');
        
        // Example of how to save in a real app:
        // await _dbService.saveSessionNotes(_counselorId!, _clientId!, notes);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save session notes: ${e.toString()}');
    }
  }
  
  void checkClientStatus() {
    try {
      // This would typically check recent test results, message patterns, etc.
      // For demonstration, we'll set a mock status based on test results
      
      if (clientTestResults.isNotEmpty) {
        final latestTest = clientTestResults[0];
        final score = latestTest['score'] as int;
        final maxScore = latestTest['maxScore'] as int;
        
        if (latestTest['testName'] == 'Depression Screening' && score > maxScore * 0.6) {
          clientStatus.value = 'distressed';
          clientStatusMessage.value = 'Client\'s recent depression screening shows elevated levels';
        } else if (latestTest['testName'] == 'Anxiety Assessment' && score > maxScore * 0.5) {
          clientStatus.value = 'needs_attention';
          clientStatusMessage.value = 'Client reported moderate anxiety levels';
        }
      }
    } catch (e) {
      print('Error checking client status: ${e.toString()}');
    }
  }
  


void setupMessageListener() {
  if (_clientId != null && _counselorId != null) {
    String chatId = "${_clientId}_${_counselorId}";
    print("setupmessagelistener started $chatId");
    
    // Batch updates with debouncing
    List<ChatModel> pendingMessages = [];
    Timer? debounceTimer;
    
    _chatSubscription = FirebaseDatabase.instance
    .ref()
    .child('chats')
    .child(chatId)
    .onChildAdded
    .listen((event) async {
      try {
        // Skip if it's a 'participants' node
        if (event.snapshot.key == 'participants') return;
        if (!event.snapshot.exists) return;
        
        var snapshotData = event.snapshot.value;
        if (snapshotData is! Map) return;
        
        // Process in isolate
        final newMessage = await compute(
          processNewMessageInIsolate, 
          {'data': snapshotData, 'messageId': event.snapshot.key}
        );
        
        if (newMessage != null && !messages.any((msg) => msg.id == newMessage.id)) {
          pendingMessages.add(newMessage);
          
          // Debounce updates
          debounceTimer?.cancel();
          debounceTimer = Timer(const Duration(milliseconds: 300), () {
            if (pendingMessages.isNotEmpty) {
              messages.insertAll(0, pendingMessages);
              
              // Mark messages as read once per batch
              final hasUnreadFromClient = pendingMessages.any((msg) => msg.senderId != _counselorId);
              if (hasUnreadFromClient) {
                _dbService.markMessagesAsRead(_clientId!, _counselorId!, _counselorId!);
              }
              
              pendingMessages.clear();
            }
          });
        }
      } catch (e) {
        print('Error in message listener: ${e.toString()}');
      }
    }, onError: (error) {
      print('Firebase listener error: ${error.toString()}');
    });
  }
}
  
  void updateCanSendMessage() {
    canSendMessage.value = messageController.text.trim().isNotEmpty;
  }
  
  Future<void> sendMessage() async {
    print("send message started");
    if (!canSendMessage.value || _counselorId == null || _clientId == null) return;
    
    final text = messageController.text.trim();
    messageController.clear();
    canSendMessage.value = false;
    try {
      // Add message optimistically for instant UI update
      final newMessage = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _counselorId!,
        receiverId: _clientId!,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      print("dbservice starting");
      // Save to database
      await _dbService.saveChatMessage(_clientId!, _counselorId!, _counselorId!, text);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
      // Remove the optimistically added message if there was an error
      messages.removeWhere((msg) => msg.text == text && msg.timestamp.difference(DateTime.now()).inSeconds < 5);
    }
  }
}