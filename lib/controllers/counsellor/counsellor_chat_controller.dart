import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/services/chat_service.dart';
import 'package:jooyful_heaven/services/user_service.dart';
import '../../models/chat_model.dart';
import '../../services/realtime_db_service.dart';
import '../../models/user_model.dart';
import '../auth_controllers.dart';

// Top-level function to be run in isolate
Future<List<ChatModel>> processMessagesInIsolate(
  Map<String, dynamic> params,
) async {
  final List<Map<String, dynamic>> messagesData = params['messagesData'];

  return messagesData
      .where((map) => map['id'] != null) // Filter out potential invalid entries
      .map((map) => ChatModel.fromMap(map, map['id'] ?? ''))
      .toList();
}

Future<ChatModel?> processNewMessageInIsolate(
  Map<String, dynamic> params,
) async {
  final Map<dynamic, dynamic> data = params['data'];
  final String messageId = params['messageId'];

  try {
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

// Optimized batch message processing
Future<List<ChatModel>> processBatchMessagesInIsolate(Map<String, dynamic> params) async {
  final List<Map<dynamic, dynamic>> batchData = params['batchData'];
  final List<String> messageIds = params['messageIds'];
  
  List<ChatModel> results = [];
  
  for (int i = 0; i < batchData.length; i++) {
    try {
      Map<String, dynamic> messageData = {};
      batchData[i].forEach((key, val) {
        messageData[key.toString()] = val;
      });
      
      messageData['id'] = messageIds[i];
      results.add(ChatModel.fromMap(messageData, messageIds[i]));
    } catch (e) {
      print('Error processing batch message in isolate: $e');
    }
  }
  
  return results;
}

// Helper function to spawn isolate
Future<List<ChatModel>> processMessagesWithIsolate(
  List<Map<String, dynamic>> messagesData,
) async {
  final response = await compute(processMessagesInIsolate, {
    'messagesData': messagesData,
  });
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
  final RxList<Map<String, dynamic>> clientTestResults =
      <Map<String, dynamic>>[].obs;

  String? _counselorId;
  String? _clientId;
  StreamSubscription? _chatSubscription;
  
  // Batch message updates
  final List<DataSnapshot> _pendingSnapshots = [];
  Timer? _batchProcessTimer;
  final int _batchSize = 10; // Process in batches of 10
  final int _batchDelay = 500; // Milliseconds to wait for batch processing

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
      // Load chat and client data in parallel
      Future.wait([
        loadChatMessages(),
        loadClientData(),
        loadClientTestResults(),
        loadSessionNotes(),
      ]).then((_) {
        // Setup listener only after loading initial data
        setupMessageListener();
        checkClientStatus();
      });
    } else {
      Get.snackbar(
        'Error',
        'Could not load chat. Missing client or counselor ID.',
      );
    }
  }

  @override
  void onClose() {
    cancelAllListeners();
    messageController.dispose();
    _batchProcessTimer?.cancel();
    super.onClose();
  }
  
  // Make this public so it can be called during cleanup
  void cancelAllListeners() {
    _chatSubscription?.cancel();
    _batchProcessTimer?.cancel();
  }

  Future<void> loadClientData() async {
    try {
      if (_clientId != null && _clientId!.isNotEmpty) {
        client.value = await UserService(_dbService).getUserData(_clientId!);
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
        await ChatService(
          _dbService,
        ).markMessagesAsRead(_clientId!, _counselorId!, _counselorId!);

        // Then load messages - fetch data on main thread
        List<Map<String, dynamic>> chatData = await ChatService(
          _dbService,
        ).getChatMessages(_clientId!, _counselorId!);

        // Process in isolate if there's a significant amount of data
        List<ChatModel> chatMessages;
        if (chatData.length > 20) {
          chatMessages = await processMessagesWithIsolate(chatData);
        } else {
          // Process directly for small amounts
          chatMessages = chatData
              .where((map) => map['id'] != null)
              .map((map) => ChatModel.fromMap(map, map['id'] ?? ''))
              .toList();
        }

        // Sort once after processing
        chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Use addAll instead of value assignment to prevent unnecessary rebuilds
        if (messages.isEmpty) {
          messages.value = chatMessages;
        } else {
          messages.clear();
          messages.addAll(chatMessages);
        }
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
        // For now, using mock data - keep this simple to avoid performance issues
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
        sessionNotes.value =
            'Client has been showing progress in managing anxiety. ' +
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
        sessionNotes.value = notes;
        Get.snackbar('Success', 'Session notes saved successfully');
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

        if (latestTest['testName'] == 'Depression Screening' &&
            score > maxScore * 0.6) {
          clientStatus.value = 'distressed';
          clientStatusMessage.value =
              'Client\'s recent depression screening shows elevated levels';
        } else if (latestTest['testName'] == 'Anxiety Assessment' &&
            score > maxScore * 0.5) {
          clientStatus.value = 'needs_attention';
          clientStatusMessage.value = 'Client reported moderate anxiety levels';
        }
      }
    } catch (e) {
      print('Error checking client status: ${e.toString()}');
    }
  }

  // Optimized message listener with efficient batch processing
  void setupMessageListener() {
    if (_clientId != null && _counselorId != null) {
      String chatId = "${_clientId}_${_counselorId}";
      print("setupmessagelistener started $chatId");

      // Get a reference to avoid creating multiple references
      final chatRef = FirebaseDatabase.instance
          .ref()
          .child('chats')
          .child(chatId);

      // Use the 'startAt' technique to only listen for new messages
      final latestTimestamp = messages.isNotEmpty 
          ? messages[0].timestamp.millisecondsSinceEpoch + 1 
          : DateTime.now().millisecondsSinceEpoch;

      _chatSubscription = chatRef
          .orderByChild('timestamp')
          .startAt(latestTimestamp)
          .onChildAdded
          .listen(
            (event) {
              // Skip participants node
              if (event.snapshot.key == 'participants') return;
              if (!event.snapshot.exists) return;
              
              // Add snapshot to pending list for batch processing
              _pendingSnapshots.add(event.snapshot);
              
              // Start or reset batch timer
              _batchProcessTimer?.cancel();
              _batchProcessTimer = Timer(Duration(milliseconds: _batchDelay), () {
                _processPendingSnapshots();
              });
              
              // Process immediately if batch size threshold reached
              if (_pendingSnapshots.length >= _batchSize) {
                _batchProcessTimer?.cancel();
                _processPendingSnapshots();
              }
            },
            onError: (error) {
              print('Firebase listener error: ${error.toString()}');
            },
          );
    }
  }
  
  // Process snapshots in batch
  Future<void> _processPendingSnapshots() async {
    if (_pendingSnapshots.isEmpty) return;
    
    // Make a copy and clear the pending list
    final snapshots = List<DataSnapshot>.from(_pendingSnapshots);
    _pendingSnapshots.clear();
    
    try {  
      // Prepare data for batch processing in isolate
      final List<Map<dynamic, dynamic>> batchData = [];
      final List<String> messageIds = [];
      
      for (var snapshot in snapshots) {
        if (snapshot.value is Map) {
          batchData.add(snapshot.value as Map<dynamic, dynamic>);
          messageIds.add(snapshot.key ?? DateTime.now().millisecondsSinceEpoch.toString());
        }
      }
      
      if (batchData.isEmpty) return;
      
      // Process batch in isolate
      final newMessages = await compute(
        processBatchMessagesInIsolate,
        {
          'batchData': batchData,
          'messageIds': messageIds,
        },
      );
      
      // Filter out messages we already have
      final uniqueMessages = newMessages.where(
        (newMsg) => !messages.any((msg) => msg.id == newMsg.id)
      ).toList();
      
      if (uniqueMessages.isNotEmpty) {
        // Sort before adding
        uniqueMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Insert at beginning
        messages.insertAll(0, uniqueMessages);
        
        // Mark messages as read if any are from client
        final hasUnreadFromClient = uniqueMessages.any(
          (msg) => msg.senderId != _counselorId,
        );
        
        if (hasUnreadFromClient && _clientId != null && _counselorId != null) {
          ChatService(_dbService).markMessagesAsRead(
            _clientId!,
            _counselorId!,
            _counselorId!,
          );
        }
      }
    } catch (e) {
      print('Error in batch message processing: $e');
    }
  }

  void updateCanSendMessage() {
    final canSend = messageController.text.trim().isNotEmpty;
    if (canSendMessage.value != canSend) {
      canSendMessage.value = canSend;
    }
  }

  Future<void> sendMessage() async {
    print("send message started");
    if (!canSendMessage.value || _counselorId == null || _clientId == null)
      return;

    final text = messageController.text.trim();
    messageController.clear();
    canSendMessage.value = false;
    
    try {
      print("dbservice starting");
      // Save to database using the optimized ChatService
      await ChatService(
        _dbService,
      ).saveChatMessage(_clientId!, _counselorId!, _counselorId!, text);
      
      // Don't add manually - let the listener handle it
      // This prevents duplicate messages and ensures proper sorting
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    }
  }
}