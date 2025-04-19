import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/counsellor_controller.dart';
import 'package:jooyful_heaven/models/chat_model.dart';

class ChatWithClientScreen extends StatelessWidget {
  final CounselorController controller = Get.find<CounselorController>();
  final AuthController authController = Get.find<AuthController>();
  
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final selectedClient = controller.selectedClient.value;
    
    if (selectedClient == null) {
      Get.back();
      return const SizedBox.shrink();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedClient.name),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.currentChat.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Start a conversation with ${selectedClient.name}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.currentChat.length,
                itemBuilder: (context, index) {
                  final message = controller.currentChat[index];
                  final isMe = message.senderId == authController.userModel.value?.uid;
                  
                  return _buildMessageBubble(message, isMe);
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatModel message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp as int),
                    style: TextStyle(
                      color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) _buildAvatar(isMe: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({bool isMe = false}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isMe ? Colors.blue : Colors.grey,
      child: Text(
        isMe 
            ? (authController.userModel?.value?.name.isEmpty ?? true 
                ? 'C' 
                : authController.userModel.value!.name[0].toUpperCase()) 
            : (controller.selectedClient.value?.name.isEmpty ?? true 
                ? '?' 
                : controller.selectedClient.value!.name[0].toUpperCase()),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (messageController.text.trim().isNotEmpty) {
                  controller.sendMessage(messageController.text.trim());
                  messageController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (now.difference(date).inHours < 24 && now.day == date.day) {
      // Today, show only time
      return DateFormat('h:mm a').format(date);
    } else if (now.difference(date).inDays < 7) {
      // Within a week, show day and time
      return DateFormat('E, h:mm a').format(date);
    } else {
      // Older messages, show full date
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }
}