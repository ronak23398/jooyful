import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/models/chat_model.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

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
    _clientId = _authController.userModel.value?.uid;
    _counselorId = Get.arguments?['counselorId'];

    if (_clientId != null && _counselorId != null) {
      loadCounselorData();
      loadChatMessages();
      setupMessageListener();
    } else {
      Get.snackbar('Error', 'Something went wrong. Please try again.');
      Get.back();
    }
  }

  @override
  void onClose() {
    messageController.dispose();

    cancelAllListeners();
    super.onClose();
  }

  Future<void> loadCounselorData() async {
    try {
      if (_counselorId != null && _counselorId!.isNotEmpty) {
        counselor.value = await _dbService.getUserData(_counselorId!);
        isCounselorLoaded.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load counselor data: ${e.toString()}');
    }
  }

  Future<void> loadChatMessages() async {
    try {
      isLoading.value = true;

      if (_clientId != null && _counselorId != null) {
        // Mark messages as read first
        await _dbService.markMessagesAsRead(
          _clientId!,
          _counselorId!,
          _clientId!,
        );

        // Then load messages
        List<Map<String, dynamic>> chatData = await _dbService.getChatMessages(
          _clientId!,
          _counselorId!,
        );

        // Convert to ChatModel objects and sort by timestamp (newest first)
        List<ChatModel> chatMessages =
            chatData
                .map((map) => ChatModel.fromMap(map, map['id'] ?? ''))
                .toList();

        chatMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        messages.value = chatMessages;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void setupMessageListener() {
    if (_clientId != null && _counselorId != null) {
      String chatId = "${_clientId}_${_counselorId}";

      FirebaseDatabase.instance
          .ref()
          .child('chats')
          .child(chatId)
          .onChildAdded
          .listen((event) {
            // Process new message
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

                // Mark as read if from the other person
                if (newMessage.senderId != _clientId) {
                  _dbService.markMessagesAsRead(
                    _clientId!,
                    _counselorId!,
                    _clientId!,
                  );
                }
              }
            }
          });
    }
  }

  void updateCanSendMessage() {
    canSendMessage.value = messageController.text.trim().isNotEmpty;
  }

  Future<void> sendMessage() async {
    if (!canSendMessage.value || _clientId == null || _counselorId == null)
      return;

    final text = messageController.text.trim();
    messageController.clear();
    canSendMessage.value = false;

    try {
      // Add message optimistically for instant UI update
      final newMessage = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _clientId!,
        receiverId: _counselorId!,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Save to database
      await _dbService.saveChatMessage(
        _clientId!,
        _counselorId!,
        _clientId!,
        text,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
      // Remove the optimistically added message if there was an error
      messages.removeWhere(
        (msg) =>
            msg!.text == text &&
            msg.timestamp.difference(DateTime.now()).inSeconds < 5,
      );
    }
  }
}
