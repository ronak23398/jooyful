

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jooyful_heaven/controllers/counsellor/counsellor_chat_controller.dart';
import 'package:jooyful_heaven/models/appointment_model.dart';
import 'package:jooyful_heaven/models/chat_model.dart';
import 'package:jooyful_heaven/models/user_model.dart';
import 'package:jooyful_heaven/services/firebase_auth_service.dart';
import 'package:jooyful_heaven/services/realtime_db_service.dart';

class CounselorController extends GetxController {
  final FirebaseAuthService authService;
  final RealtimeDbService dbService;
  
  CounselorChatController? chatController;

  CounselorController({
    required this.authService,
    required this.dbService,
  });

  final RxList<UserModel> assignedClients = <UserModel>[].obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<UserModel?> selectedClient = Rx<UserModel?>(null);
  final RxList<ChatModel> currentChat = <ChatModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssignedClients();
    fetchAppointments();
  }

  Future<void> fetchAssignedClients() async {
    try {
      isLoading.value = true;
      
      // Get current counselor ID
      final counselorId = authService.currentUser?.uid;
      if (counselorId == null) return;
      
      // Fetch all users where assignedCounselorId equals current counselor ID
      final clients = await dbService.getWhere('users', 'assignedCounselorId', counselorId);
      
      // Convert to UserModel objects
      assignedClients.value = clients.map((clientData) {
  Map<String, dynamic> data = clientData as Map<String, dynamic>;
  return UserModel.fromMap(data, );
}).toList();
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clients: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
Future<void> fetchAppointments() async {
  try {
    isLoading.value = true;
    
    final counselorId = authService.currentUser?.uid;
    if (counselorId == null) {
      isLoading.value = false;
      return;
    }
    
    // Get all appointments from the root appointments node
    final allAppointmentsData = await dbService.get('appointments');
    
    List<AppointmentModel> appointmentsList = [];
    
    if (allAppointmentsData != null && allAppointmentsData is Map) {
      // Iterate through each client's appointments
      for (var entry in allAppointmentsData.entries) {
        final clientId = entry.key;
        final clientAppointments = entry.value;
        
        if (clientAppointments is Map) {
          // Pre-fetch client name to reuse for all appointments
          String clientName = 'Client $clientId';
          try {
            // Fetch client data from users node
            final clientData = await dbService.get('users/$clientId');
            if (clientData != null && clientData is Map) {
              // Try to get the best name representation available
              // First try: full name from firstName + lastName
              final firstName = clientData['firstName'] ?? '';
              final lastName = clientData['lastName'] ?? '';
              if (firstName.toString().isNotEmpty || lastName.toString().isNotEmpty) {
                clientName = '$firstName $lastName'.trim();
                if (clientName.isEmpty) {
                  clientName = 'Client $clientId';
                }
              } 
              // Second try: displayName
              else if (clientData['displayName'] != null && 
                       clientData['displayName'].toString().isNotEmpty) {
                clientName = clientData['displayName'].toString();
              }
              // Third try: name
              else if (clientData['name'] != null && 
                       clientData['name'].toString().isNotEmpty) {
                clientName = clientData['name'].toString();
              }
              // Fourth try: fullName
              else if (clientData['fullName'] != null && 
                       clientData['fullName'].toString().isNotEmpty) {
                clientName = clientData['fullName'].toString();
              }
              // Last try: username or email, but only if it doesn't look like an email
              else if (clientData['username'] != null && 
                       clientData['username'].toString().isNotEmpty) {
                final username = clientData['username'].toString();
                if (!username.contains('@')) {
                  clientName = username;
                }
              }
              
              // Debug what we found
              print('Found client name for $clientId: $clientName');
            }
          } catch (e) {
            print('Error fetching client data for $clientId: $e');
          }
        
          // Iterate through this client's appointments
          clientAppointments.forEach((appointmentId, appointmentData) {
            if (appointmentData is Map) {
              try {
                // Check if this appointment belongs to the current counselor
                final counselorIdFromData = appointmentData['counselorId'];
                if (counselorIdFromData == counselorId) {
                  // Create appointment model with client info
                  final Map<String, dynamic> appointmentMap = {
                    'id': appointmentId,
                    'clientId': clientId,
                    'clientName': clientName, // Set the retrieved client name
                  };
                  
                  // Add the rest of the appointment data
                  appointmentData.forEach((key, value) {
                    appointmentMap[key.toString()] = value;
                  });
                  
                  final appointment = AppointmentModel.fromJson(appointmentMap);
                  appointmentsList.add(appointment);
                }
              } catch (e) {
                print('Error parsing appointment $appointmentId: $e');
              }
            }
          });
        }
      }
    }
    
    // Update appointments list
    appointments.value = appointmentsList;
  } catch (e) {
    Get.snackbar('Error', 'Failed to load appointments: ${e.toString()}');
  } finally {
    isLoading.value = false;
  }
}

  void selectClient(UserModel client) {
  selectedClient.value = client;
  // Don't load chat here
}

  Future<void> loadClientChat(String clientId) async {
  try {
    final counselorId = authService.currentUser?.uid;
    if (counselorId == null) return;
    
    final chatId = '${clientId}_$counselorId';
    final chatData = await dbService.get('chats/$chatId');
    
    if (chatData != null && chatData is Map) {
      List<ChatModel> chatMessages = [];
      
      chatData.forEach((messageId, data) {
        // Skip participants node
        if (messageId == 'participants') return;
        
        if (data is Map) {
          // Convert to Map<String, dynamic>
          Map<String, dynamic> messageData = {};
          data.forEach((key, val) {
            messageData[key.toString()] = val;
          });
          
          messageData['id'] = messageId;
          
          try {
            final message = ChatModel.fromMap(messageData, messageId.toString());
            chatMessages.add(message);
          } catch (e) {
            print('Error converting message $messageId: $e');
          }
        }
      });
      
      // Sort messages by timestamp
      chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      currentChat.value = chatMessages;
    } else {
      currentChat.value = [];
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to load chat: ${e.toString()}');
  }
}

  Future<void> sendMessage(String text) async {
    try {
      if (selectedClient.value == null) return;
      
      final counselorId = authService.currentUser?.uid;
      if (counselorId == null) return;
      
      final clientId = selectedClient.value!.uid;
      final chatId = '${clientId}_$counselorId';
      
      final newMessage = ChatModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: counselorId,
        text: text,
        timestamp: DateTime.now(), receiverId: clientId,
      );
      
      await dbService.set('chats/$chatId/${newMessage.id}', newMessage.toMap());
      
      // Add to local list
      currentChat.add(newMessage);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: ${e.toString()}');
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
  try {
    isLoading.value = true;
    
    // Find the appointment in our local list to get the clientId
    final appointment = appointments.firstWhere(
      (app) => app.id == appointmentId,
      orElse: () => throw Exception('Appointment not found'),
    );
    
    // Now we know which client this appointment belongs to
    final clientId = appointment.clientId;
    
    // Update in Firebase
    await dbService.update(
      'appointments/$clientId/$appointmentId', 
      {'status': status}
    );
    
    // Update the local copy
    final index = appointments.indexWhere((app) => app.id == appointmentId);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(status: status);
    }
    
    Get.snackbar(
      'Success', 
      'Appointment status updated to ${status.capitalizeFirst}',
      backgroundColor: Colors.green.shade100,
    );
  } catch (e) {
    Get.snackbar(
      'Error', 
      'Failed to update appointment: ${e.toString()}',
      backgroundColor: Colors.red.shade100,
    );
  } finally {
    isLoading.value = false;
  }
}
}