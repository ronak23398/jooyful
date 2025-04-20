import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jooyful_heaven/controllers/auth_controllers.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_chat_controller.dart';
import 'package:jooyful_heaven/models/chat_model.dart';

class CounselorChatScreen extends StatelessWidget {
  final CounselorChatController controller = Get.put(CounselorChatController());
  final AuthController authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => controller.isClientLoaded.value 
          ? Text('Chat with ${controller.client.value!.name}')
          : Text('Chat with Client')),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showClientInfo(context),
          ),
          IconButton(
            icon: Icon(Icons.note_add),
            onPressed: () => _showSessionNotes(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Client status banner (if needed)
          _buildStatusBanner(),
          
          // Chat messages
          Expanded(
            child: Obx(() => controller.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : controller.messages.isEmpty
                ? _buildEmptyChatMessage(context)
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
                // Quick response button
                IconButton(
                  icon: Icon(Icons.short_text, color: Colors.blue),
                  onPressed: () => _showQuickResponses(context),
                ),
                
                // Text input
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
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8.0),
                
                // Send button
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

  Widget _buildStatusBanner() {
    return Obx(() {
      if (!controller.isClientLoaded.value || controller.clientStatus.value.isEmpty) {
        return SizedBox.shrink();
      }
      
      Color backgroundColor;
      IconData statusIcon;
      
      switch (controller.clientStatus.value) {
        case 'distressed':
          backgroundColor = Colors.red[100]!;
          statusIcon = Icons.warning;
          break;
        case 'needs_attention':
          backgroundColor = Colors.amber[100]!;
          statusIcon = Icons.notifications_active;
          break;
        default:
          return SizedBox.shrink();
      }
      
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: backgroundColor,
        child: Row(
          children: [
            Icon(statusIcon, color: Colors.grey[800]),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(
                controller.clientStatusMessage.value,
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      );
    });
  }
  
 Widget _buildEmptyChatMessage(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('No messages yet'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Make sure to use the correct context here
            // This is likely where your error is
            // Use the BuildContext parameter, not something else named Context
            showDialog(
              context: context, // Use this context parameter
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  // Your dialog content
                );
              },
            );
          },
          child: Text('Start Conversation'),
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
          color: isMe ? Colors.teal : Colors.grey[200],
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 10.0,
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
              ],
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
  
  void _showClientInfo(BuildContext context) {
    if (!controller.isClientLoaded.value) return;
    
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
                backgroundColor: Colors.teal.shade100,
                child: Icon(Icons.person, size: 50, color: Colors.teal),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                controller.client.value!.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                controller.client.value!.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Recent Test Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Obx(() => controller.clientTestResults.isEmpty
              ? Text('No test results available')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.clientTestResults.length > 2 ? 2 : controller.clientTestResults.length,
                  itemBuilder: (context, index) {
                    final result = controller.clientTestResults[index];
                    return ListTile(
                      title: Text(result['testName']),
                      subtitle: Text('Score: ${result['score']}/${result['maxScore']}'),
                      trailing: Text(result['date']),
                    );
                  },
                ),
            ),
            SizedBox(height: 16),
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text('Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.note_add),
                  label: Text('Add Note'),
                  onPressed: () {
                    Get.back();
                    _showSessionNotes(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSessionNotes(BuildContext context) {
    final noteController = TextEditingController();
    
    if (controller.sessionNotes.value.isNotEmpty) {
      noteController.text = controller.sessionNotes.value;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Session Notes'),
        content: Container(
          constraints: BoxConstraints(maxHeight: 300),
          child: TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: 'Add notes about this client...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () {
              controller.saveSessionNotes(noteController.text);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
  
  void _showQuickResponses(BuildContext context) {
    final quickResponses = [
      'Hello! How are you feeling today?',
      'I hope you are doing well. Is there anything specific you would like to discuss?',
      'I noticed you took a test recently. Would you like to discuss the results?',
      'Its great to hear from you. How have you been since our last session?',
      'Would it help to talk about whats been challenging for you lately?',
      'Remember to practice those relaxation techniques we discussed.',
      'Im here to listen whenever youre ready to share.',
    ];
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Responses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: quickResponses.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(quickResponses[index]),
                    onTap: () {
                      controller.messageController.text = quickResponses[index];
                      controller.updateCanSendMessage();
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}