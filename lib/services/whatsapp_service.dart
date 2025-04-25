import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  // Launch WhatsApp voice call
  static Future<void> launchWhatsAppVoiceCall(String phoneNumber) async {
    await _launchWhatsAppCall(phoneNumber, false);
  }
  
  // Launch WhatsApp video call
  static Future<void> launchWhatsAppVideoCall(String phoneNumber) async {
    await _launchWhatsAppCall(phoneNumber, true);
  }
  
  // Private helper method for WhatsApp calls
  static Future<void> _launchWhatsAppCall(String phoneNumber, bool isVideo) async {
    // Make sure the phone number is in international format without any symbols
    // e.g., "1234567890" for a US number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Create the WhatsApp call URL
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$phoneNumber${isVideo ? '&video=1' : ''}');
    
    try {
      // Check if WhatsApp is installed
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        // WhatsApp is not installed
        throw 'WhatsApp is not installed on this device';
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      // Return the error so it can be handled by the caller
      rethrow;
    }
  }
}