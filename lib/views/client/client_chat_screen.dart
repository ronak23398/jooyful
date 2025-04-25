import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/client_controllers/client_chat_controller.dart';
import 'package:jooyful_heaven/models/chat_model.dart';
import 'package:intl/intl.dart';
import 'package:jooyful_heaven/services/whatsapp_service.dart';

class ClientChatScreen extends GetView<ClientChatController> {
  final AuthController authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.isCounselorLoaded.value 
          ? Text('Chat with ${controller.counselor.value!.name}')
          : Text('Chat with Counselor')),
        actions: [
          // Voice Call Button
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () => _initiateWhatsAppVoiceCall(),
            tooltip: 'WhatsApp Voice Call',
          ),
          // Video Call Button
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () => _initiateWhatsAppVideoCall(),
            tooltip: 'WhatsApp Video Call',
          ),
          // Counselor Info Button
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showCounselorInfo(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() => controller.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : controller.messages.isEmpty
                ? _buildEmptyChatMessage()
                : _buildChatMessages()
            ),
          ),
          
          // Input field
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) => controller.updateCanSendMessage(),
                  ),
                ),
                SizedBox(width: 8.0),
                Obx(() => IconButton(
                  icon: Icon(Icons.send),
                  color: controller.canSendMessage.value ? Colors.blue : Colors.grey,
                  onPressed: controller.canSendMessage.value
                    ? () => controller.sendMessage()
                    : null,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Updated method for initiating WhatsApp voice call
  void _initiateWhatsAppVoiceCall() {
    if (!controller.isCounselorLoaded.value) {
      Get.snackbar('Cannot Call', 'Counselor information not loaded yet');
      return;
    }
    
    final counselor = controller.counselor.value;
    
    if (counselor != null && counselor.phoneNumber != null) {
      try {
        WhatsAppService.launchWhatsAppVoiceCall(counselor.phoneNumber!);
      } catch (e) {
        Get.snackbar(
          'Error', 
          'Could not initiate WhatsApp call: ${e.toString()}',
          duration: Duration(seconds: 3)
        );
      }
    } else {
      Get.snackbar(
        'Missing Information', 
        'Counselor phone number is not available',
        duration: Duration(seconds: 3)
      );
    }
  }
  
  // Updated method for initiating WhatsApp video call
  void _initiateWhatsAppVideoCall() {
    if (!controller.isCounselorLoaded.value) {
      Get.snackbar('Cannot Call', 'Counselor information not loaded yet');
      return;
    }
    
    final counselor = controller.counselor.value;
    
    if (counselor != null && counselor.phoneNumber != null) {
      try {
        WhatsAppService.launchWhatsAppVideoCall(counselor.phoneNumber!);
      } catch (e) {
        Get.snackbar(
          'Error', 
          'Could not initiate WhatsApp video call: ${e.toString()}',
          duration: Duration(seconds: 3)
        );
      }
    } else {
      Get.snackbar(
        'Missing Information', 
        'Counselor phone number is not available',
        duration: Duration(seconds: 3)
      );
    }
  }
  
  Widget _buildEmptyChatMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start your conversation with your counselor',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatMessages() {
    String currentUserId = authController.userModel.value!.uid;
    
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        final bool isMe = message.senderId == currentUserId;
        final bool showDate = _shouldShowDate(index);
        
        return Column(
          children: [
            if (showDate) _buildDateDivider(message.timestamp),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }
  
  Widget _buildMessageBubble(ChatModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6.0,
          bottom: 6.0,
          left: isMe ? 64.0 : 0.0,
          right: isMe ? 0.0 : 64.0,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDateDivider(DateTime timestamp) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 1.0)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _formatDate(timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
          ),
          Expanded(child: Divider(thickness: 1.0)),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
  
  bool _shouldShowDate(int index) {
    if (index == controller.messages.length - 1) {
      return true;
    }
    
    final currentMessage = controller.messages[index];
    final previousMessage = controller.messages[index + 1];
    
    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );
    
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );
    
    return currentDate != previousDate;
  }
  
  void _showCounselorInfo(BuildContext context) {
    if (!controller.isCounselorLoaded.value) return;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: Icon(Icons.person, size: 50, color: Colors.blue),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                controller.counselor.value!.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                'Professional Counselor',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.counselor.value!.role,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Specializations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('Anxiety')),
                Chip(label: Text('Depression')),
                Chip(label: Text('Stress Management')),
              ],
            ),
            // Add WhatsApp call buttons in the bottom sheet as well
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.call),
                  label: Text('WhatsApp Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _initiateWhatsAppVoiceCall();
                  },
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.videocam),
                  label: Text('WhatsApp Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _initiateWhatsAppVideoCall();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}