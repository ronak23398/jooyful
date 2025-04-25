import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/models/chat_model.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/services/chat_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';
import 'package:jooyful_heaven/services/user_service.dart';

class ClientChatController extends GetxController {
  final RealtimeDbService _dbService = RealtimeDbService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController messageController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxList<ChatModel> messages = <ChatModel>[].obs;
  final RxBool canSendMessage = false.obs;
  final Rx<UserModel?> counselor = Rx<UserModel?>(null);
  final RxBool isCounselorLoaded = false.obs;

  String? _clientId;
  String? _counselorId;
  StreamSubscription? _chatSubscription;
  StreamSubscription? _typingSubscription;
  bool _isInitialized = false;

  // Add this method to cancel all listeners
  void cancelAllListeners() {
    print("Cancelling all listeners in ClientChatController");
    _chatSubscription?.cancel();
    _chatSubscription = null;

    _typingSubscription?.cancel();
    _typingSubscription = null;

    // Cancel any other Firebase listeners here
  }

  @override
  void onInit() {
    super.onInit();
    
    // Initialize with basic data first
    _clientId = _authController.userModel.value?.uid;
    _counselorId = Get.arguments?['counselorId'];

    if (_clientId != null && _counselorId != null) {
      // Load basic UI first, then proceed with data loading
      Future.microtask(() => _initializeChat());
    } else {
      Get.snackbar('Error', 'Something went wrong. Please try again.');
      Get.back();
    }
    
    // Keep the listener for efficient background updates
    messageController.addListener(_onMessageChanged);
  }

  // Add this method back for the UI's onChanged handler
  void updateCanSendMessage() {
    canSendMessage.value = messageController.text.trim().isNotEmpty;
  }

  // Move initialization logic to a separate method
  Future<void> _initializeChat() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    try {
      // Start loading counselor data (don't await)
      loadCounselorData();
      
      // Load messages (await this since we need them first)
      await loadChatMessages();
      
      // Setup listener after messages are loaded
      Future.microtask(() => setupMessageListener());
    } catch (e) {
      print("Error initializing chat: $e");
    }
  }

  void _onMessageChanged() {
    canSendMessage.value = messageController.text.trim().isNotEmpty;
  }

  @override
  void onClose() {
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    cancelAllListeners();
    super.onClose();
  }

  Future<void> loadCounselorData() async {
    try {
      if (_counselorId != null && _counselorId!.isNotEmpty) {
        counselor.value = await UserService(
          _dbService,
        ).getUserData(_counselorId!);
        isCounselorLoaded.value = true;
      }
    } catch (e) {
      print('Failed to load counselor data: ${e.toString()}');
      // Don't show snackbar for background operations
    }
  }

  Future<void> loadChatMessages() async {
    try {
      isLoading.value = true;

      if (_clientId != null && _counselorId != null) {
        // Mark messages as read in background
        Future.microtask(() => ChatService(
              _dbService,
            ).markMessagesAsRead(_clientId!, _counselorId!, _clientId!));

        // Load messages without waiting for mark-as-read operation
        List<Map<String, dynamic>> chatData = await ChatService(
          _dbService,
        ).getChatMessages(_clientId!, _counselorId!);

        // Do conversion in a compute-isolated task if possible
        // For now, do it in a microtask
        Future.microtask(() {
          // Convert to ChatModel objects and sort by timestamp (newest first)
          List<ChatModel> chatMessages = chatData
              .map((map) => ChatModel.fromMap(map, map['id'] ?? ''))
              .toList();

          chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          messages.value = chatMessages;
        });
      }
    } catch (e) {
      print('Failed to load messages: ${e.toString()}');
      Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void setupMessageListener() {
    if (_clientId != null && _counselorId != null) {
      String chatId = "${_clientId}_${_counselorId}";

      // Cancel any existing subscription
      _chatSubscription?.cancel();
      
      _chatSubscription = FirebaseDatabase.instance
          .ref()
          .child('chats')
          .child(chatId)
          .onChildAdded
          .listen((event) {
            // Process new message in a microtask to prevent UI block
            Future.microtask(() {
              if (event.snapshot.exists) {
                Map<dynamic, dynamic> value =
                    event.snapshot.value as Map<dynamic, dynamic>;
                value['id'] = event.snapshot.key;
                ChatModel newMessage = ChatModel.fromMap(
                  Map<String, dynamic>.from(value),
                  value['id'],
                );

                // Add to messages list if not already there
                if (!messages.any((msg) => msg.id == newMessage.id)) {
                  messages.insert(0, newMessage);

                  // Mark as read if from the other person (in background)
                  if (newMessage.senderId != _clientId) {
                    ChatService(
                      _dbService,
                    ).markMessagesAsRead(_clientId!, _counselorId!, _clientId!);
                  }
                }
              }
            });
          });
    }
  }

  Future<void> sendMessage() async {
    if (!canSendMessage.value || _clientId == null || _counselorId == null)
      return;

    final text = messageController.text.trim();
    messageController.clear();
    canSendMessage.value = false;

    try {
      // Save to database
      await ChatService(
        _dbService,
      ).saveChatMessage(_clientId!, _counselorId!, _clientId!, text);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    }
  }
}