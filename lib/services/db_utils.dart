
// This isolate function processes unread messages to determine which need to be marked as read
Future<Map<String, dynamic>> processUnreadMessagesInIsolate(Map<String, dynamic> params) async {
  final Map<dynamic, dynamic> values = params['values'];
  final String readerId = params['readerId'];
  
  Map<String, dynamic> updates = {};
  values.forEach((key, value) {
    // Skip participants node
    if (key == 'participants') return;
    
    if (value is Map && value['senderId'] != readerId) {
      updates[key.toString()] = true;
    }
  });
  
  return updates;
}